import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../../core/config/firestore_paths.dart';
import 'firestore_converters.dart';

enum SyncResult { success, skippedNoNetwork, skippedInProgress, failed }

final syncServiceProvider = Provider<SyncService>((ref) {
  final paths = ref.watch(firestorePathsProvider);
  final service = SyncService(ref.read(databaseProvider), paths);
  ref.onDispose(() => service.dispose());
  return service;
});

class SyncService {
  final AppDatabase _db;
  final FirestorePaths _paths;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SyncService(this._db, this._paths);

  Timer? _syncTimer;
  bool _isSyncing = false;

  void dispose() {
    stopAutoSync();
  }

  /// Starts the auto-sync timer (e.g. every 2 minutes)
  void startAutoSync({Duration interval = const Duration(minutes: 2)}) {
    stopAutoSync();
    _syncTimer = Timer.periodic(interval, (_) => syncData());
    debugPrint("⏰ Auto-Sync Started: ${interval.inMinutes} min interval");
  }

  /// Stops the auto-sync timer
  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    debugPrint("🛑 Auto-Sync Stopped");
  }

  /// Main Sync Method: Pushes local changes, then pulls remote updates.
  Future<SyncResult> syncData() async {
    if (_isSyncing) {
      debugPrint("⏳ Sync already in progress, skipping...");
      return SyncResult.skippedInProgress;
    }

    if (!await _hasNetwork()) {
      debugPrint("Sync Skipped: No Network");
      return SyncResult.skippedNoNetwork;
    }

    _isSyncing = true;

    try {
      debugPrint("🔄 Starting Sync...");
      await _pushAndSyncMembers();
      await _pushAndSyncSubscriptions();
      await _pushAndSyncDonations();
      await _pushAndSyncPastOutstanding();
      await _pushAndSyncConfig();
      
      await _saveLastSyncTimestamp();
      debugPrint("✅ Sync Complete");
      return SyncResult.success;
    } catch (e) {
      debugPrint("❌ Sync Failed: $e");
      // Don't rethrow in auto-sync to avoid crashing the scheduled task
      return SyncResult.failed;
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> _hasNetwork() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  // --- Members Sync ---

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('device_installation_id');
    if (id == null) {
      final newId = Uuid().v4();
      await prefs.setString('device_installation_id', newId);
      return newId;
    }
    return id;
  }

  // --- Members Sync ---

  Future<void> _pushAndSyncMembers() async {
    final deviceId = await _getDeviceId();

    // 1. Push Local Changes
    final unsynced = await (_db.select(_db.members)..where((tbl) => tbl.isSynced.equals(false))).get();
    
    if (unsynced.isNotEmpty) {
      debugPrint("📤 Pushing ${unsynced.length} Members...");
      final batch = _firestore.batch();
      
      for (final member in unsynced) {
        if (member.uuid == null) continue; // Skip malformed
        final docRef = _firestore.collection(_paths.members).doc(member.uuid);
        
        if (member.deleted) {
             // Soft Delete in Cloud to propagate to other devices
             batch.set(docRef, {
               'deleted': true, 
               'uuid': member.uuid,
               'sourceDeviceId': deviceId,
               'lastUpdatedAt': FieldValue.serverTimestamp() // Important for triggering pulls
             }, SetOptions(merge: true));
        } else {
             final data = member.toFirestore();
             data['sourceDeviceId'] = deviceId; // Add Source ID
             batch.set(docRef, data, SetOptions(merge: true));
        }
      }
      await batch.commit();
      
      // Mark as Synced
      await _db.customUpdate(
        'UPDATE members SET is_synced = 1 WHERE uuid IN (${unsynced.map((e) => "'${e.uuid}'").join(",")})'
      );
    }

    // 2. Pull Remote Changes
    // 2. Pull Remote Changes
    final lastSync = await getLastSyncTime();
    debugPrint("📥 Pulling members from ${_paths.members} (Since: $lastSync)");

    final query = _firestore.collection(_paths.members)
        .where('lastUpdatedAt', isGreaterThan: lastSync);
        
    final snapshot = await query.get();
    debugPrint("📥 Found ${snapshot.docs.length} remote documents.");
    
    if (snapshot.docs.isNotEmpty) {
      int pulledCount = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        
        // Echo Check
        if (data['sourceDeviceId'] == deviceId) {
             debugPrint("  - Skipped Echo: ${data['uuid']} (Source: ${data['sourceDeviceId']})");
             continue; // Skip our own updates
        }
        
        debugPrint("  + Processing: ${data['uuid']} (Source: ${data['sourceDeviceId']} != Me: $deviceId)");

        final serverUuid = data['uuid'] as String?;
        if (serverUuid == null) continue;

        // Upsert into Local DB
        final exists = await (_db.select(_db.members)..where((t) => t.uuid.equals(serverUuid))).getSingleOrNull();
        final companion = FirestoreParsers.memberFromMap(data);
        
        if (exists != null) {
          await (_db.update(_db.members)..where((t) => t.uuid.equals(serverUuid))).write(companion);
        } else {
          await _db.into(_db.members).insert(companion);
        }
        pulledCount++;
      }
      if (pulledCount > 0) debugPrint("📥 Pulled $pulledCount Members (skipped ${snapshot.docs.length - pulledCount} echoes)");
    }
  }

  // --- Subscriptions Sync ---

  Future<void> _pushAndSyncSubscriptions() async {
      final deviceId = await _getDeviceId();

      // 1. Push
      final unsynced = await (_db.select(_db.subscriptions)..where((tbl) => tbl.isSynced.equals(false))).get();
      if (unsynced.isNotEmpty) {
         debugPrint("📤 Pushing ${unsynced.length} Subscriptions...");
         final batch = _firestore.batch();
         for(final item in unsynced) {
             if(item.uuid == null) continue;
             final docRef = _firestore.collection(_paths.subscriptions).doc(item.uuid);
             if(item.deleted) {
                 batch.set(docRef, {
                    'deleted': true,
                    'uuid': item.uuid,
                    'sourceDeviceId': deviceId,
                    'lastUpdatedAt': FieldValue.serverTimestamp()
                 }, SetOptions(merge: true));
             } else {
                 final data = item.toFirestore();
                 data['sourceDeviceId'] = deviceId;
                 batch.set(docRef, data, SetOptions(merge: true));
             }
         }
         await batch.commit();
         await _db.customUpdate('UPDATE subscriptions SET is_synced = 1 WHERE uuid IN (${unsynced.map((e) => "'${e.uuid}'").join(",")})');
      }
      
      // 2. Pull
       // 2. Pull
       final lastSync = await getLastSyncTime();
       final snapshot = await _firestore.collection(_paths.subscriptions).where('lastUpdatedAt', isGreaterThan: lastSync).get();
       
       if (snapshot.docs.isNotEmpty) {
          int pulledCount = 0;
          for (final doc in snapshot.docs) {
             final data = doc.data();
             
             if (data['sourceDeviceId'] == deviceId) continue;

             final uuid = data['uuid'] as String?;
             if (uuid == null) continue;
             
             final exists = await (_db.select(_db.subscriptions)..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
             final companion = FirestoreParsers.subscriptionFromMap(data);
             
             // Check for Receipt Number Conflict
             final receiptNum = data['receiptNumber'] as String?;
             if (receiptNum != null) {
                final conflict = await (_db.select(_db.subscriptions)
                  ..where((t) => t.receiptNumber.equals(receiptNum) & t.uuid.isNotValue(uuid)))
                  .getSingleOrNull();
                
                if (conflict != null) {
                   debugPrint("⚠️ Conflict detected for Receipt $receiptNum. Renaming local copy.");
                   final newReceipt = "${receiptNum}_CONFLICT_${conflict.uuid?.substring(0,4) ?? 'LOC'}";
                   await (_db.update(_db.subscriptions)..where((t) => t.id.equals(conflict.id)))
                     .write(SubscriptionsCompanion(receiptNumber: Value(newReceipt)));
                }
             }

             if (exists != null) {
                await (_db.update(_db.subscriptions)..where((t) => t.uuid.equals(uuid))).write(companion);
             } else {
                await _db.into(_db.subscriptions).insert(companion);
             }
             pulledCount++;
          }
          if (pulledCount > 0) debugPrint("📥 Pulled $pulledCount Subscriptions");
       }
  }
  
  // --- Donations Sync ---

  Future<void> _pushAndSyncDonations() async {
      final deviceId = await _getDeviceId();

      // 1. Push
      final unsynced = await (_db.select(_db.donations)..where((tbl) => tbl.isSynced.equals(false))).get();
      if (unsynced.isNotEmpty) {
         debugPrint("📤 Pushing ${unsynced.length} Donations...");
         final batch = _firestore.batch();
         for(final item in unsynced) {
             if(item.uuid == null) continue;
             final docRef = _firestore.collection(_paths.donations).doc(item.uuid);
             if(item.deleted) {
                 batch.set(docRef, {
                    'deleted': true,
                    'uuid': item.uuid,
                    'sourceDeviceId': deviceId,
                    'lastUpdatedAt': FieldValue.serverTimestamp()
                 }, SetOptions(merge: true));
             } else {
                 final data = item.toFirestore();
                 data['sourceDeviceId'] = deviceId;
                 batch.set(docRef, data, SetOptions(merge: true));
             }
         }
         await batch.commit();
         await _db.customUpdate('UPDATE donations SET is_synced = 1 WHERE uuid IN (${unsynced.map((e) => "'${e.uuid}'").join(",")})');
      }
      
      // 2. Pull
      // 2. Pull
      final lastSync = await getLastSyncTime();
      final snapshot = await _firestore.collection(_paths.donations).where('lastUpdatedAt', isGreaterThan: lastSync).get();
      
      if (snapshot.docs.isNotEmpty) {
         int pulledCount = 0;
         for (final doc in snapshot.docs) {
             final data = doc.data();
             
             if (data['sourceDeviceId'] == deviceId) continue;

             final uuid = data['uuid'] as String?;
             if (uuid == null) continue;
             
             final exists = await (_db.select(_db.donations)..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
             final companion = FirestoreParsers.donationFromMap(data);
             
             // Check for Receipt Number Conflict
             final receiptNum = data['receiptNumber'] as String?;
             if (receiptNum != null) {
                final conflict = await (_db.select(_db.donations)
                  ..where((t) => t.receiptNumber.equals(receiptNum) & t.uuid.isNotValue(uuid)))
                  .getSingleOrNull();
                
                if (conflict != null) {
                   debugPrint("⚠️ Conflict detected for Donation Receipt $receiptNum. Renaming local copy.");
                   final newReceipt = "${receiptNum}_CONFLICT_${conflict.uuid?.substring(0,4) ?? 'LOC'}";
                   await (_db.update(_db.donations)..where((t) => t.id.equals(conflict.id)))
                     .write(DonationsCompanion(receiptNumber: Value(newReceipt)));
                }
             }

             if (exists != null) {
                await (_db.update(_db.donations)..where((t) => t.uuid.equals(uuid))).write(companion);
             } else {
                await _db.into(_db.donations).insert(companion);
             }
             pulledCount++;
         }
         if (pulledCount > 0) debugPrint("📥 Pulled $pulledCount Donations");
      }
  }
  
  // --- Past Outstanding Sync ---
  
  Future<void> _pushAndSyncPastOutstanding() async {
      final deviceId = await _getDeviceId();

      // 1. Push
      final unsynced = await (_db.select(_db.pastOutstandingDues)..where((tbl) => tbl.isSynced.equals(false))).get();
      if (unsynced.isNotEmpty) {
         debugPrint("📤 Pushing ${unsynced.length} Arrears...");
         final batch = _firestore.batch();
         for(final item in unsynced) {
             if(item.uuid == null) continue;
             final docRef = _firestore.collection(_paths.pastOutstanding).doc(item.uuid);
             if(item.deleted) {
                 batch.set(docRef, {
                    'deleted': true,
                    'uuid': item.uuid,
                    'sourceDeviceId': deviceId,
                    'lastUpdatedAt': FieldValue.serverTimestamp()
                 }, SetOptions(merge: true));
             } else {
                 final data = item.toFirestore();
                 data['sourceDeviceId'] = deviceId;
                 batch.set(docRef, data, SetOptions(merge: true));
             }
         }
         await batch.commit();
         await _db.customUpdate('UPDATE past_outstanding_dues SET is_synced = 1 WHERE uuid IN (${unsynced.map((e) => "'${e.uuid}'").join(",")})');
      }
      
      // 2. Pull
      // 2. Pull
      final lastSync = await getLastSyncTime();
      final snapshot = await _firestore.collection(_paths.pastOutstanding).where('lastUpdatedAt', isGreaterThan: lastSync).get();
      
      if (snapshot.docs.isNotEmpty) {
         int pulledCount = 0;
         for (final doc in snapshot.docs) {
             final data = doc.data();
             
             if (data['sourceDeviceId'] == deviceId) continue;

             final uuid = data['uuid'] as String?;
             if (uuid == null) continue;
             
             final exists = await (_db.select(_db.pastOutstandingDues)..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
             final companion = FirestoreParsers.pastOutstandingFromMap(data);
             
             if (exists != null) {
                await (_db.update(_db.pastOutstandingDues)..where((t) => t.uuid.equals(uuid))).write(companion);
             } else {
                await _db.into(_db.pastOutstandingDues).insert(companion);
             }
             pulledCount++;
         }
         if (pulledCount > 0) debugPrint("📥 Pulled $pulledCount Arrears");
      }
  }

  // --- Config Sync ---

  Future<void> _pushAndSyncConfig() async {
      final deviceId = await _getDeviceId();

      // 1. Push - Config is usually 1 row, but acts like a table
      final unsynced = await (_db.select(_db.subscriptionConfig)..where((tbl) => tbl.isSynced.equals(false))).get();
       if (unsynced.isNotEmpty) {
         debugPrint("📤 Pushing ${unsynced.length} Configs...");
         final batch = _firestore.batch();
         for(final item in unsynced) {
             if(item.uuid == null) continue;
             final docRef = _firestore.collection(_paths.config).doc(item.uuid);
             if(item.deleted) {
                 batch.set(docRef, {
                    'deleted': true,
                    'uuid': item.uuid,
                    'sourceDeviceId': deviceId,
                    'lastUpdatedAt': FieldValue.serverTimestamp()
                 }, SetOptions(merge: true));
             } else {
                 final data = item.toFirestore();
                 data['sourceDeviceId'] = deviceId;
                 batch.set(docRef, data, SetOptions(merge: true));
             }
         }
         await batch.commit();
         await _db.customUpdate('UPDATE subscription_config SET is_synced = 1 WHERE uuid IN (${unsynced.map((e) => "'${e.uuid}'").join(",")})');
      }

      // 2. Pull
      // 2. Pull
      final lastSync = await getLastSyncTime();
      final snapshot = await _firestore.collection(_paths.config).where('lastUpdatedAt', isGreaterThan: lastSync).get();
       if (snapshot.docs.isNotEmpty) {
         int pulledCount = 0;
         for (final doc in snapshot.docs) {
             final data = doc.data();
             
             if (data['sourceDeviceId'] == deviceId) continue;

             final uuid = data['uuid'] as String?;
             if (uuid == null) continue;
             
             final existingConfig = await (_db.select(_db.subscriptionConfig)..limit(1)).getSingleOrNull();
             // Use extension method safely
             final companion = FirestoreConfigParser.subscriptionConfigFromMap(data);
             
             if (existingConfig != null) {
                // Update ANY existing config to maintain Singleton
                await (_db.update(_db.subscriptionConfig)..where((t) => t.id.equals(existingConfig.id))).write(companion);
             } else {
                await _db.into(_db.subscriptionConfig).insert(companion);
             }
             pulledCount++;
         }
         if (pulledCount > 0) debugPrint("📥 Pulled $pulledCount Configs");
      }
  }

  Future<DateTime> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt('last_sync_timestamp');
    if (millis == null) return DateTime(2000); // Distant past
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> _saveLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_sync_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> resetSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_sync_timestamp');
    await prefs.remove('device_installation_id'); // Regenerate Device ID to bypass Echo Check
    debugPrint("🔄 Sync Reset: Timestamp cleared & Device ID regenerated (Force Full Pull)");
  }
}
