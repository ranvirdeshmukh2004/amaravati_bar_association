import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../database/app_database.dart';
import '../../database/tables.dart';
import '../app_database.dart'; // Ensure Member class is available via app_database or tables


part 'past_outstanding_dao.g.dart';

@DriftAccessor(tables: [PastOutstandingDues])
class PastOutstandingDao extends DatabaseAccessor<AppDatabase> with _$PastOutstandingDaoMixin {
  final AppDatabase db;
  PastOutstandingDao(this.db) : super(db);

  // Insert a new record
  Future<int> insertOutstanding(PastOutstandingDuesCompanion entry) {
    // Ensure UUID and Sync Flags
    final uuid = entry.uuid.value ?? const Uuid().v4();
    return into(pastOutstandingDues).insert(entry.copyWith(
      uuid: Value(uuid),
      isSynced: const Value(false),
      lastUpdatedAt: Value(DateTime.now()),
      deleted: const Value(false),
    ));
  }

  Future<List<PastOutstandingDue>> getAllOutstanding() => 
      (select(pastOutstandingDues)..where((t) => t.deleted.equals(false))).get();

  // Delete a record
  Future<int> deleteOutstanding(int id) {
    return (delete(pastOutstandingDues)..where((t) => t.id.equals(id))).go();
  }

  // Watch all outstanding records (for admin list)
  Stream<List<PastOutstandingDue>> watchAllOutstanding() {
    return (select(pastOutstandingDues)..where((t) => t.deleted.equals(false))).watch();
  }

  // Watch all outstanding WITH member details
  Stream<List<PastArrearWithMember>> watchAllOutstandingWithMembers() {
    final query = select(pastOutstandingDues).join([
      leftOuterJoin(db.members, db.members.registrationNumber.equalsExp(pastOutstandingDues.enrollmentNumber)),
    ])..where(pastOutstandingDues.deleted.equals(false));
    
    return query.watch().map((rows) {
      return rows.map((row) {
        return PastArrearWithMember(
          arrear: row.readTable(pastOutstandingDues),
          member: row.readTableOrNull(db.members),
        );
      }).toList();
    });
  }

  // Watch outstanding for a specific member
  Stream<List<PastOutstandingDue>> watchOutstandingByMember(String enrollmentNumber) {
    return (select(pastOutstandingDues)..where((t) => t.enrollmentNumber.equals(enrollmentNumber) & t.deleted.equals(false))).watch();
  }

  // Get total outstanding amount for a member (Only PENDING)
  Future<double> getTotalOutstanding(String enrollmentNumber) async {
    final query = select(pastOutstandingDues)..where((t) => t.enrollmentNumber.equals(enrollmentNumber) & t.isCleared.equals(false) & t.deleted.equals(false));
    final result = await query.get();
    return result.fold<double>(0.0, (sum, item) => sum + item.amount);
  }

  // Clear an outstanding record
  Future<int> markAsCleared(int id, int paymentId, DateTime date) {
    return (update(pastOutstandingDues)..where((t) => t.id.equals(id))).write(
      PastOutstandingDuesCompanion(
        isCleared: const Value(true),
        linkedPaymentId: Value(paymentId),
        clearedAt: Value(date),
        isSynced: const Value(false),
        lastUpdatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Watch only pending outstanding for a member (for clearance screen)
  Stream<List<PastOutstandingDue>> watchPendingByMember(String enrollmentNumber) {
    return (select(pastOutstandingDues)
          ..where((t) => t.enrollmentNumber.equals(enrollmentNumber) & t.isCleared.equals(false) & t.deleted.equals(false)))
        .watch();
  }
}

class PastArrearWithMember {
  final PastOutstandingDue arrear;
  final Member? member;

  PastArrearWithMember({required this.arrear, this.member});
}
