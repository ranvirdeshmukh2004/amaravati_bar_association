import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';
import 'daos/subscriptions_dao.dart';

import 'daos/members_dao.dart';

import 'tables/subscription_config.dart';

import 'daos/subscription_config_dao.dart';
import 'daos/yearly_summaries_dao.dart';
import 'daos/past_outstanding_dao.dart';
import 'daos/donations_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Subscriptions, AdminSettings, Members, SubscriptionConfig, YearlySummaries, PastOutstandingDues, Donations],
  daos: [SubscriptionsDao, MembersDao, SubscriptionConfigDao, YearlySummariesDao, PastOutstandingDao, DonationsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 15;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        
        Future<void> safeAddColumn(TableInfo table, GeneratedColumn column) async {
          try {
            await m.addColumn(table, column);
          } catch (e) {
            // Ignore duplicate column errors (SqliteException code 1)
            if (e.toString().contains('duplicate column name')) {
              print('Column ${column.name} already exists, skipping.');
            } else {
              rethrow;
            }
          }
        }

        if (from < 2) {
          await safeAddColumn(members, members.memberStatus);
        } else if (from < 6) {
           if (from >= 2) {
             await safeAddColumn(members, members.memberStatus);
           }
        }
        
        if (from < 3) {
          // Future migrations
        }
        if (from < 4) {
          await m.createTable(subscriptions);
        }
        if (from < 5) {
          if (from >= 4) {
             await safeAddColumn(subscriptions, subscriptions.notes);
          }
        }
        if (from < 6) {
           await m.createTable(pastOutstandingDues);
        }
        if (from < 7) {
           // ..
        }
        if (from < 8) {
           if (from >= 6) {
             await safeAddColumn(pastOutstandingDues, pastOutstandingDues.isCleared);
             await safeAddColumn(pastOutstandingDues, pastOutstandingDues.clearedAt);
             await safeAddColumn(pastOutstandingDues, pastOutstandingDues.linkedPaymentId);
           }
        }
        if (from < 9) {
           if (from >= 2) { 
              await safeAddColumn(members, members.profilePhotoPath);
           }
        }
        if (from < 10) {
           if (from >= 2) {
              await safeAddColumn(members, members.remarks);
           }
        }
        if (from < 11) {
           await m.createTable(donations);
        }
        if (from < 12) {
           if (from >= 4) {
              await safeAddColumn(subscriptions, subscriptions.receiptType);
              await safeAddColumn(subscriptions, subscriptions.dailySequence);
           }
           if (from >= 11) {
              await safeAddColumn(donations, donations.dailySequence);
           }
        }
        if (from < 13) {
           if (from >= 11) {
              await safeAddColumn(donations, donations.donorMobile);
              await safeAddColumn(donations, donations.donorEmail);
              await safeAddColumn(donations, donations.donorAddress);
              await safeAddColumn(donations, donations.organization);
           }
        }
         if (from < 14) {
            // V14: Add tracking columns (uuid, isSynced, lastUpdatedAt, deleted)
           // Members
           await safeAddColumn(members, members.uuid);
           await safeAddColumn(members, members.isSynced);
           await safeAddColumn(members, members.lastUpdatedAt);
           await safeAddColumn(members, members.deleted);
           
           // Subscriptions
           await safeAddColumn(subscriptions, subscriptions.uuid);
           await safeAddColumn(subscriptions, subscriptions.isSynced);
           await safeAddColumn(subscriptions, subscriptions.lastUpdatedAt);
           await safeAddColumn(subscriptions, subscriptions.deleted);

           // PastOutstandingDues
           await safeAddColumn(pastOutstandingDues, pastOutstandingDues.uuid);
           await safeAddColumn(pastOutstandingDues, pastOutstandingDues.isSynced);
           await safeAddColumn(pastOutstandingDues, pastOutstandingDues.lastUpdatedAt);
           await safeAddColumn(pastOutstandingDues, pastOutstandingDues.deleted);

           // Donations
           await safeAddColumn(donations, donations.uuid);
           await safeAddColumn(donations, donations.isSynced);
           await safeAddColumn(donations, donations.lastUpdatedAt);
           await safeAddColumn(donations, donations.deleted);

           // Post-Migration: Generate UUIDs for existing records
           // Note: We cannot run raw UPDATE queries easily inside onUpgrade with type safety,
           // but we can execute custom SQL.
        }
        if (from < 15) {
           await safeAddColumn(subscriptionConfig, subscriptionConfig.uuid);
           await safeAddColumn(subscriptionConfig, subscriptionConfig.isSynced);
           await safeAddColumn(subscriptionConfig, subscriptionConfig.deleted);
           
            // Keep sync columns for backward compatibility

        }
      },
      beforeOpen: (details) async {
        // Run UUID Backfill if needed (Safe to run every time, low cost)
        // If we are on v14 or higher, ensure UUIDs exist.
        if (details.versionNow >= 14) {
             await _backfillUuids(details);
        }
        if (details.versionNow >= 15) {
             // specific check for config if needed, but _backfillUuids covers generic tables if added.
             await _backfillUuids(details); 
        }
      },
    );
  }



  Future<void> _backfillUuids(OpeningDetails details) async {
     const uuid = Uuid();
     
     // Helper to backfill a specific table
     Future<void> backfillTable(String tableName) async {
       try {
         final rows = await customSelect('SELECT id FROM $tableName WHERE uuid IS NULL').get();
         if (rows.isNotEmpty) {
           print('Backfilling UUIDs for $tableName: ${rows.length} records...');
           for (final row in rows) {
              final id = row.read<int>('id');
              final newUuid = uuid.v4();
              await customUpdate(
                'UPDATE $tableName SET uuid = ? WHERE id = ?',
                variables: [Variable.withString(newUuid), Variable.withInt(id)],
              );
           }
         }
       } catch (e) {
         print('Error backfilling $tableName: $e');
       }
     }

     await backfillTable('members');
     await backfillTable('subscriptions');
     await backfillTable('past_outstanding_dues');
     await backfillTable('donations');
     await backfillTable('subscription_config');
  }

  Future<void> deleteSubscriptions() {
    return delete(subscriptions).go();
  }

  Future<void> deleteMembers() {
    return delete(members).go();
  }

  Future<void> deleteDonations() {
    return delete(donations).go();
  }

  Future<void> deletePastOutstanding() {
    return delete(pastOutstandingDues).go();
  }

  Future<void> deleteSubscriptionConfig() {
    return delete(subscriptionConfig).go();
  }

  Future<void> deleteAllData() async {
    // Soft Delete All
    await deleteSubscriptions();
    await deleteMembers();
    await deleteDonations();
    await deletePastOutstanding();
    await deleteSubscriptionConfig();
  }

  /// Hard Delete All Local Data.
  /// This permanently removes all rows from the database.
  Future<void> wipeLocalDatabase() async {
    await delete(subscriptions).go();
    await delete(members).go();
    await delete(donations).go();
    await delete(pastOutstandingDues).go();
    await delete(subscriptionConfig).go();
  }
}


LazyDatabase _openConnection() {
  return LazyDatabase(() async {
      File file;
    if (kReleaseMode) {
      // Release: Try [DriveRoot]:\.aba_data (Hidden)
      // Fallback: Documents Folder
      try {
        final exePath = Platform.resolvedExecutable;
        final driveRoot = p.rootPrefix(exePath); 
        final dataDir = Directory(p.join(driveRoot, '.aba_data'));

        if (!await dataDir.exists()) {
          await dataDir.create();
          if (Platform.isWindows) {
            try {
               await Process.run('attrib', ['+h', dataDir.path]);
            } catch (_) {} 
          }
        }
        file = File(p.join(dataDir.path, 'aba_donation.sqlite'));
        // Test write permission
        await file.parent.create(recursive: true); // Ensure exists
      } catch (e) {
        // Fallback to Documents if permission denied
        debugPrint("⚠️ Failed to use Database Root. Falling back to Documents. Error: $e");
        final dbFolder = await getApplicationDocumentsDirectory();
        file = File(p.join(dbFolder.path, 'aba_donation.sqlite'));
      }
    } else {
      // Debug
      final dbFolder = await getApplicationDocumentsDirectory();
      file = File(p.join(dbFolder.path, 'aba_donation.sqlite'));
    }
    return NativeDatabase.createInBackground(file);
  });
}
