import 'package:drift/drift.dart';
import '../tables.dart';
import '../app_database.dart';

part 'members_dao.g.dart';

@DriftAccessor(tables: [Members])
class MembersDao extends DatabaseAccessor<AppDatabase> with _$MembersDaoMixin {
  MembersDao(super.db);

  Future<int> insertMember(MembersCompanion member) {
    return into(members).insert(member);
  }

  Future<void> updateMember(Member member) {
    return update(members).replace(member);
  }

  Future<void> deleteMember(Member member) {
    return delete(members).delete(member);
  }

  Future<Member?> getMemberByRegNo(String regNo) {
    return (select(
      members,
    )..where((t) => t.registrationNumber.equals(regNo))).getSingleOrNull();
  }

  Future<Member?> getMemberByMobile(String mobile) {
    return (select(
      members,
    )..where((t) => t.mobileNumber.equals(mobile))).getSingleOrNull();
  }

  Stream<List<Member>> watchAllMembers({
    String searchQuery = '',
    String? filterBloodGroup,
    int? filterYear,
  }) {
    final query = select(members);

    if (searchQuery.isNotEmpty) {
      query.where(
        (t) =>
            t.firstName.contains(searchQuery) |
            t.surname.contains(searchQuery) |
            t.registrationNumber.contains(searchQuery) |
            t.mobileNumber.contains(searchQuery),
      );
    }

    if (filterBloodGroup != null && filterBloodGroup.isNotEmpty) {
      query.where((t) => t.bloodGroup.equals(filterBloodGroup));
    }

    // For Year filter, assuming ABA Enrollment Date
    if (filterYear != null) {
      final startOfYear = DateTime(filterYear, 1, 1);
      final endOfYear = DateTime(filterYear + 1, 1, 1);
      query.where(
        (t) => t.enrollmentDateAba.isBetweenValues(startOfYear, endOfYear),
      );
    }

    // Default Sort: Name
    query.orderBy([
      (t) => OrderingTerm(expression: t.firstName),
      (t) => OrderingTerm(expression: t.surname),
    ]);

    return query.watch();
  }

  Future<List<Member>> searchMembers(String queryStr) {
    return (select(members)..where(
          (t) =>
              t.firstName.like('%$queryStr%') |
              t.surname.like('%$queryStr%') |
              t.registrationNumber.like('%$queryStr%') |
              t.mobileNumber.like('%$queryStr%'),
        ))
        .get();
  }

  Future<List<Member>> getAllMembers() {
    return select(members).get();
  }
}
