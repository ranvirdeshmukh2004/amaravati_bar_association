import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_provider.dart';
import '../database/app_database.dart';

final totalSubscriptionAmountProvider = StreamProvider<double>((ref) {
  final db = ref.watch(databaseProvider);
  return db.subscriptionsDao.watchTotalSubscriptionAmount();
});

final totalSubscriptionCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  return db.subscriptionsDao.watchTotalSubscriptionCount();
});

final currentMonthSubscriptionCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  return db.subscriptionsDao.watchCurrentMonthSubscriptionCount();
});

final subscriptionsForYearProvider =
    StreamProvider.family<List<Subscription>, int>((ref, year) {
      final db = ref.watch(databaseProvider);
      return db.subscriptionsDao.watchSubscriptionsForYear(year);
    });
