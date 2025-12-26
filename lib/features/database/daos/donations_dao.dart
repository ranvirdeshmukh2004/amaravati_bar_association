import 'package:drift/drift.dart';
import '../tables.dart';
import '../app_database.dart';

part 'donations_dao.g.dart';

@DriftAccessor(tables: [Donations])
class DonationsDao extends DatabaseAccessor<AppDatabase> with _$DonationsDaoMixin {
  DonationsDao(super.db);

  Future<int> insertDonation(DonationsCompanion donation) {
    return into(donations).insert(donation);
  }

  Future<void> updateDonation(Donation donation) {
    return update(donations).replace(donation);
  }

  Future<void> deleteDonation(Donation donation) {
    return delete(donations).delete(donation);
  }

  Stream<List<Donation>> watchAllDonations() {
    return (select(donations)
          ..orderBy([(t) => OrderingTerm(expression: t.donationDate, mode: OrderingMode.desc)]))
        .watch();
  }
  
  Future<List<Donation>> getAllDonations() {
     return (select(donations)
          ..orderBy([(t) => OrderingTerm(expression: t.donationDate, mode: OrderingMode.desc)]))
        .get();
  }

  // Dashboard Aggregations
  Stream<double> watchTotalDonations() {
    var sumAmount = donations.amount.sum();
    return (selectOnly(donations)..addColumns([sumAmount]))
        .map((row) => row.read(sumAmount) ?? 0.0)
        .watchSingle();
  }
  
    Stream<double> watchMonthlyDonations(DateTime startOfMonth) {
      // Simple filter for current month
      var sumAmount = donations.amount.sum();
      return (selectOnly(donations)
            ..where(donations.donationDate.isBiggerOrEqualValue(startOfMonth))
            ..addColumns([sumAmount]))
          .map((row) => row.read(sumAmount) ?? 0.0)
          .watchSingle();
    }

  Future<int> getNextSequence(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final query = select(donations)
      ..where((tbl) => tbl.donationDate.isBetweenValues(startOfDay, endOfDay))
      ..orderBy([(t) => OrderingTerm(expression: t.dailySequence, mode: OrderingMode.desc)])
      ..limit(1);

    final result = await query.getSingleOrNull();
    return (result?.dailySequence ?? 0) + 1;
  }
}
