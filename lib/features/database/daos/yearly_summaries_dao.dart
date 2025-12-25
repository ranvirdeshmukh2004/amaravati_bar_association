import 'package:drift/drift.dart';
import '../tables.dart';
import '../app_database.dart';

part 'yearly_summaries_dao.g.dart';

@DriftAccessor(tables: [YearlySummaries])
class YearlySummariesDao extends DatabaseAccessor<AppDatabase>
    with _$YearlySummariesDaoMixin {
  YearlySummariesDao(AppDatabase db) : super(db);

  Stream<List<YearlySummary>> watchAllSummaries() {
    return select(yearlySummaries).watch();
  }

  Future<void> insertSummary(YearlySummariesCompanion summary) {
    return into(yearlySummaries).insert(summary);
  }
  
  Future<List<YearlySummary>> getSummariesForYear(String year) {
    return (select(yearlySummaries)..where((t) => t.financialYear.equals(year))).get();
  }

  Future<void> deleteAllSummaries() {
    return delete(yearlySummaries).go();
  }

  // Aggregations for Developer Dashboard
  Stream<double> watchTotalPendingAmount() {
    final sumBalance = yearlySummaries.balance.sum();
    return (selectOnly(yearlySummaries)..addColumns([sumBalance]))
        .map((row) => row.read(sumBalance) ?? 0.0)
        .watchSingle();
  }

  Stream<double> watchTotalCollectedAmount() {
    final sumPaid = yearlySummaries.totalPaid.sum();
    return (selectOnly(yearlySummaries)..addColumns([sumPaid]))
        .map((row) => row.read(sumPaid) ?? 0.0)
        .watchSingle();
  }
}
