import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'database_path_provider.dart';
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

  /// Notifier for migration errors — UI can listen to this to show alerts.
  /// If non-null, a migration failure occurred and the value contains
  /// a human-readable error message.
  static final ValueNotifier<String?> migrationError = ValueNotifier(null);

  @override
  int get schemaVersion => 15;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        debugPrint('📦 Database migration: v$from → v$to');

        Future<void> safeAddColumn(TableInfo table, GeneratedColumn column) async {
          try {
            await m.addColumn(table, column);
          } catch (e) {
            // Ignore duplicate column errors (SqliteException code 1)
            if (e.toString().contains('duplicate column name')) {
              debugPrint('Column ${column.name} already exists, skipping.');
            } else {
              rethrow;
            }
          }
        }

        try {

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

         debugPrint('✅ Database migration v$from → v$to completed successfully.');
        } catch (e, stack) {
          debugPrint('⚠️ MIGRATION FAILED from v$from to v$to: $e');
          debugPrint(stack.toString());
          migrationError.value =
              'Database migration failed (v$from → v$to). '
              'Your existing data is safe and untouched. '
              'Please contact support.\n\nError: $e';
           rethrow; // Drift rolls back the transaction automatically
        }
       },
      beforeOpen: (details) async {
        // 1. Self-heal: ensure all expected columns exist in every table.
        //    This catches gaps from migration bugs, restored backups from
        //    older versions, or databases copied between machines.
        await _ensureSchemaIntegrity();

        // 2. Run UUID Backfill if needed (Safe to run every time, low cost)
        if (details.versionNow >= 14) {
             await _backfillUuids(details);
        }
      },
    );
  }

  /// Self-healing schema check.
  ///
  /// Runs on every database open. Uses `PRAGMA table_info` to detect
  /// which columns actually exist, then adds any missing ones via
  /// `ALTER TABLE`. This is idempotent and safe to call repeatedly.
  ///
  /// **Why this is needed:** The migration `onUpgrade` only runs when
  /// the schema version changes. If a database file is restored from
  /// a backup, or was created by an older app version that had a
  /// migration bug, columns can be permanently missing. This method
  /// acts as a safety net that guarantees schema completeness.
  Future<void> _ensureSchemaIntegrity() async {
    // --- subscriptions ---
    await _ensureColumnsExist('subscriptions', {
      'notes': 'TEXT',
      'receipt_type': 'TEXT',
      'daily_sequence': 'INTEGER NOT NULL DEFAULT 0',
      'uuid': 'TEXT',
      'is_synced': 'INTEGER NOT NULL DEFAULT 0',
      'last_updated_at': 'INTEGER',
      'deleted': 'INTEGER NOT NULL DEFAULT 0',
    });

    // --- members ---
    await _ensureColumnsExist('members', {
      'member_status': "TEXT NOT NULL DEFAULT 'Active'",
      'profile_photo_path': 'TEXT',
      'remarks': 'TEXT',
      'uuid': 'TEXT',
      'is_synced': 'INTEGER NOT NULL DEFAULT 0',
      'last_updated_at': 'INTEGER',
      'deleted': 'INTEGER NOT NULL DEFAULT 0',
    });

    // --- past_outstanding_dues ---
    await _ensureColumnsExist('past_outstanding_dues', {
      'is_cleared': 'INTEGER NOT NULL DEFAULT 0',
      'cleared_at': 'INTEGER',
      'linked_payment_id': 'INTEGER',
      'uuid': 'TEXT',
      'is_synced': 'INTEGER NOT NULL DEFAULT 0',
      'last_updated_at': 'INTEGER',
      'deleted': 'INTEGER NOT NULL DEFAULT 0',
    });

    // --- donations ---
    await _ensureColumnsExist('donations', {
      'daily_sequence': 'INTEGER NOT NULL DEFAULT 0',
      'donor_mobile': 'TEXT',
      'donor_email': 'TEXT',
      'donor_address': 'TEXT',
      'organization': 'TEXT',
      'uuid': 'TEXT',
      'is_synced': 'INTEGER NOT NULL DEFAULT 0',
      'last_updated_at': 'INTEGER',
      'deleted': 'INTEGER NOT NULL DEFAULT 0',
    });

    // --- subscription_config ---
    await _ensureColumnsExist('subscription_config', {
      'uuid': 'TEXT',
      'is_synced': 'INTEGER NOT NULL DEFAULT 0',
      'deleted': 'INTEGER NOT NULL DEFAULT 0',
    });
  }

  /// Checks if all [requiredColumns] exist in [tableName] and adds any
  /// that are missing. Uses raw SQL so it works regardless of Drift state.
  Future<void> _ensureColumnsExist(
      String tableName, Map<String, String> requiredColumns) async {
    try {
      final result =
          await customSelect('PRAGMA table_info($tableName)').get();
      final existingColumns =
          result.map((row) => row.read<String>('name')).toSet();

      for (final entry in requiredColumns.entries) {
        if (!existingColumns.contains(entry.key)) {
          try {
            await customStatement(
                'ALTER TABLE $tableName ADD COLUMN ${entry.key} ${entry.value}');
            debugPrint(
                '🔧 Schema repair: added missing column $tableName.${entry.key}');
          } catch (e) {
            debugPrint(
                '⚠️ Failed to add column $tableName.${entry.key}: $e');
          }
        }
      }
    } catch (e) {
      // Table might not exist yet (e.g., fresh database before onCreate).
      // That's fine — onCreate will create it with all columns.
      debugPrint('ℹ️ Table $tableName not found for schema check: $e');
    }
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
    final dbPath = await DatabasePathProvider.getDatabasePath();
    final file = File(dbPath);
    return NativeDatabase.createInBackground(file);
  });
}
