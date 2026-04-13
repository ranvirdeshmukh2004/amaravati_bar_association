import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/subscription_config.dart';

part 'subscription_config_dao.g.dart';

@DriftAccessor(tables: [SubscriptionConfig])
class SubscriptionConfigDao extends DatabaseAccessor<AppDatabase>
    with _$SubscriptionConfigDaoMixin {
  SubscriptionConfigDao(super.db);

  Future<SubscriptionConfigData?> getConfig() async {
    return await (select(subscriptionConfig)..limit(1)).getSingleOrNull();
  }

  Future<void> updateConfig(double amount, DateTime startDate) async {
    final existing = await (select(subscriptionConfig)..limit(1)).getSingleOrNull();
    final uuid = existing?.uuid ?? const Uuid().v4();

    if (existing != null) {
      await (update(subscriptionConfig)..where((t) => t.id.equals(existing.id))).write(
        SubscriptionConfigCompanion(
          monthlyAmount: Value(amount),
          subscriptionStartDate: Value(startDate),
          lastUpdated: Value(DateTime.now()),
          isSynced: const Value(false), 
          uuid: Value(uuid), // Preserve strict UUID
        ),
      );
    } else {
      await into(subscriptionConfig).insert(
        SubscriptionConfigCompanion(
          monthlyAmount: Value(amount),
          subscriptionStartDate: Value(startDate),
          lastUpdated: Value(DateTime.now()),
          isSynced: const Value(false),
          deleted: const Value(false),
          uuid: Value(uuid),
        ),
      );
    }
  }

  Stream<SubscriptionConfigData?> watchConfig() {
    return (select(subscriptionConfig)..limit(1)).watchSingleOrNull();
  }
}
