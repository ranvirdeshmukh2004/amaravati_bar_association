import 'package:drift/drift.dart';
import '../tables.dart';
import '../app_database.dart';

part 'subscriptions_dao.g.dart';

@DriftAccessor(tables: [Subscriptions])
class SubscriptionsDao extends DatabaseAccessor<AppDatabase>
    with _$SubscriptionsDaoMixin {
  SubscriptionsDao(super.db);

  // Insert a subscription
  Future<int> insertSubscription(SubscriptionsCompanion subscription) =>
      into(subscriptions).insert(subscription);

  // Get all subscriptions
  Future<List<Subscription>> getAllSubscriptions() =>
      select(subscriptions).get();

  Future<Subscription?> getSubscriptionById(int id) {
    return (select(subscriptions)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<List<Subscription>> watchAllSubscriptions() =>
      (select(subscriptions)..orderBy([
            (t) => OrderingTerm(
              expression: t.subscriptionDate,
              mode: OrderingMode.desc,
            ),
          ]))
          .watch();

  // Get current month subscriptions
  Stream<List<Subscription>> watchCurrentMonthSubscriptions() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);
    final endOfMonth = DateTime(now.year, now.month + 1);

    return (select(subscriptions)
          ..where(
            (t) => t.subscriptionDate.isBetweenValues(startOfMonth, endOfMonth),
          )
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.subscriptionDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  // Get total amount subscribed
  Stream<double> watchTotalSubscriptionAmount() {
    final sumAmount = subscriptions.amount.sum();
    final query = selectOnly(subscriptions)..addColumns([sumAmount]);
    return query.map((row) => row.read(sumAmount) ?? 0.0).watchSingle();
  }

  // Get total number of subscriptions
  Stream<int> watchTotalSubscriptionCount() {
    final count = subscriptions.id.count();
    final query = selectOnly(subscriptions)..addColumns([count]);
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  // Get count for current month
  Stream<int> watchCurrentMonthSubscriptionCount() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);
    final endOfMonth = DateTime(now.year, now.month + 1);

    final count = subscriptions.id.count();
    final query = selectOnly(subscriptions)
      ..where(
        subscriptions.subscriptionDate.isBetweenValues(
          startOfMonth,
          endOfMonth,
        ),
      )
      ..addColumns([count]);

    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  // Get subscriptions for a specific year
  Stream<List<Subscription>> watchSubscriptionsForYear(int year) {
    final startOfYear = DateTime(year, 1, 1);
    final endOfYear = DateTime(year + 1, 1, 1);

    return (select(subscriptions)
          ..where(
            (t) => t.subscriptionDate.isBetweenValues(startOfYear, endOfYear),
          )
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.subscriptionDate,
              mode: OrderingMode.asc,
            ),
          ]))
        .watch();
  }
  // Get next daily sequence for a receipt type
  Future<int> getNextSequence(String type, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final query = select(subscriptions)
      ..where((tbl) => tbl.receiptType.equals(type))
      ..where((tbl) => tbl.subscriptionDate.isBetweenValues(startOfDay, endOfDay))
      ..orderBy([(t) => OrderingTerm(expression: t.dailySequence, mode: OrderingMode.desc)])
      ..limit(1);

    final result = await query.getSingleOrNull();
    // Default to 0 if no record found, so next is 1
    return (result?.dailySequence ?? 0) + 1;
  }
}
