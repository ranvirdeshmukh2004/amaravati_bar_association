import 'package:drift/drift.dart';
import '../tables.dart';
import '../app_database.dart';

part 'donations_dao.g.dart';

@DriftAccessor(tables: [Donations])
class DonationsDao extends DatabaseAccessor<AppDatabase>
    with _$DonationsDaoMixin {
  DonationsDao(super.db);

  // Insert a donation
  Future<int> insertDonation(DonationsCompanion donation) =>
      into(donations).insert(donation);

  // Get all donations
  Future<List<Donation>> getAllDonations() => select(donations).get();
  Stream<List<Donation>> watchAllDonations() =>
      (select(donations)..orderBy([
            (t) => OrderingTerm(
              expression: t.donationDate,
              mode: OrderingMode.desc,
            ),
          ]))
          .watch();

  // Get current month donations
  Stream<List<Donation>> watchCurrentMonthDonations() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);
    final endOfMonth = DateTime(now.year, now.month + 1);

    return (select(donations)
          ..where(
            (t) => t.donationDate.isBetweenValues(startOfMonth, endOfMonth),
          )
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.donationDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  // Get total amount donated
  Stream<double> watchTotalDonationAmount() {
    final sumAmount = donations.amount.sum();
    final query = selectOnly(donations)..addColumns([sumAmount]);
    return query.map((row) => row.read(sumAmount) ?? 0.0).watchSingle();
  }

  // Get total number of donations
  Stream<int> watchTotalDonationCount() {
    final count = donations.id.count();
    final query = selectOnly(donations)..addColumns([count]);
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  // Get count for current month
  Stream<int> watchCurrentMonthDonationCount() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);
    final endOfMonth = DateTime(now.year, now.month + 1);

    final count = donations.id.count();
    final query = selectOnly(donations)
      ..where(donations.donationDate.isBetweenValues(startOfMonth, endOfMonth))
      ..addColumns([count]);

    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  // Get donations for a specific year
  Stream<List<Donation>> watchDonationsForYear(int year) {
    final startOfYear = DateTime(year, 1, 1);
    final endOfYear = DateTime(year + 1, 1, 1);

    return (select(donations)
          ..where((t) => t.donationDate.isBetweenValues(startOfYear, endOfYear))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.donationDate,
              mode: OrderingMode.asc,
            ),
          ]))
        .watch();
  }
}
