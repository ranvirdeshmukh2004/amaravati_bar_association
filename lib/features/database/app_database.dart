import 'dart:io';

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

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Subscriptions, AdminSettings, Members, SubscriptionConfig, YearlySummaries],
  daos: [SubscriptionsDao, MembersDao, SubscriptionConfigDao, YearlySummariesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(members);
      }
      if (from < 3) {
        // Since user wiped data, we can just create the new table.
        // Old donations table will persist but be unused.
        await m.createTable(subscriptions);
      }
      if (from < 4) {
        await m.createTable(subscriptionConfig);
      }
      if (from < 5) {
        await m.createTable(yearlySummaries);
      }
      if (from < 6) {
        await m.addColumn(members, members.memberStatus);
      }
    },
  );

  Future<void> deleteSubscriptions() => delete(subscriptions).go();

  Future<void> deleteMembers() => delete(members).go();

  Future<void> deleteAllData() async {
    await deleteSubscriptions();
    await deleteMembers();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'aba_donation.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
