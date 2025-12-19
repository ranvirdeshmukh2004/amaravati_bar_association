import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/subscription_config.dart';

part 'subscription_config_dao.g.dart';

@DriftAccessor(tables: [SubscriptionConfig])
class SubscriptionConfigDao extends DatabaseAccessor<AppDatabase>
    with _$SubscriptionConfigDaoMixin {
  SubscriptionConfigDao(AppDatabase db) : super(db);

  Future<SubscriptionConfigData?> getConfig() async {
    return await select(subscriptionConfig).getSingleOrNull();
  }

  Future<void> updateConfig(double amount, DateTime startDate) async {
    await delete(subscriptionConfig).go();
    await into(subscriptionConfig).insert(
      SubscriptionConfigCompanion(
        monthlyAmount: Value(amount),
        subscriptionStartDate: Value(startDate),
        lastUpdated: Value(DateTime.now()),
      ),
    );
  }

  Stream<SubscriptionConfigData?> watchConfig() {
    return select(subscriptionConfig).watchSingleOrNull();
  }
}
