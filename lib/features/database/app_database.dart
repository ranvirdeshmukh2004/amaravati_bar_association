import 'dart:io';
import 'package:flutter/foundation.dart';

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
  int get schemaVersion => 13;

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
      },
    );
  }

  Future<void> deleteSubscriptions() => delete(subscriptions).go();

  Future<void> deleteMembers() => delete(members).go();

  Future<void> deleteDonations() => delete(donations).go();

  Future<void> deletePastOutstanding() => delete(pastOutstandingDues).go();

  Future<void> deleteAllData() async {
    await deleteSubscriptions();
    await deleteMembers();
  }
}


LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final File file;
    if (kReleaseMode) {
      // In Release mode, store the DB in a hidden folder at the DRIVE ROOT
      // e.g., if App is at H:\MyApp\app.exe, DB is at H:\.aba_data\aba_donation.sqlite
      final exePath = Platform.resolvedExecutable;
      final driveRoot = p.rootPrefix(exePath); // Returns "H:\" on Windows
      final dataDir = Directory(p.join(driveRoot, '.aba_data'));

      if (!await dataDir.exists()) {
        await dataDir.create();
        // Hide the directory on Windows
        if (Platform.isWindows) {
          try {
             await Process.run('attrib', ['+h', dataDir.path]);
          } catch (_) {} // Ignore if fails
        }
      }

      file = File(p.join(dataDir.path, 'aba_donation.sqlite'));
    } else {
      // In Debug mode, keep using Documents folder
      final dbFolder = await getApplicationDocumentsDirectory();
      file = File(p.join(dbFolder.path, 'aba_donation.sqlite'));
    }
    return NativeDatabase.createInBackground(file);
  });
}
