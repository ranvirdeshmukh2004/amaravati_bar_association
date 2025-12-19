import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../database/app_database.dart';
import '../database/database_provider.dart';

final memberControllerProvider = Provider((ref) => MemberController(ref));

// Provider for fetching a single member by ID
final memberDetailsProvider = FutureProvider.family<Member?, int>((
  ref,
  id,
) async {
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.members,
  )..where((t) => t.id.equals(id))).getSingleOrNull();
});

class MemberController {
  final Ref _ref;

  MemberController(this._ref);

  Future<void> addMember({
    required String surname,
    required String firstName,
    String? middleName,
    required int age,
    DateTime? dateOfBirth,
    String? bloodGroup,
    DateTime? enrollmentDateAba,
    DateTime? enrollmentDateBar,
    required String registrationNumber,
    required String address,
    required String mobileNumber,
    String? email,
  }) async {
    final db = _ref.read(databaseProvider);

    // Check for duplicate RegNo or Mobile is handled by DB constraints (RegNo) or we can check manually for friendly error
    final existingParams = await db.membersDao.getMemberByRegNo(
      registrationNumber,
    );
    if (existingParams != null) {
      throw Exception(
        'Member with Registration Number $registrationNumber already exists.',
      );
    }

    final entry = MembersCompanion(
      surname: drift.Value(surname),
      firstName: drift.Value(firstName),
      middleName: drift.Value(middleName),
      age: drift.Value(age),
      dateOfBirth: drift.Value(dateOfBirth),
      bloodGroup: drift.Value(bloodGroup),
      enrollmentDateAba: drift.Value(enrollmentDateAba),
      enrollmentDateBar: drift.Value(enrollmentDateBar),
      registrationNumber: drift.Value(registrationNumber),
      address: drift.Value(address),
      mobileNumber: drift.Value(mobileNumber),
      email: drift.Value(email),
    );

    await db.membersDao.insertMember(entry);
  }

  Future<void> updateMember(Member member) async {
    final db = _ref.read(databaseProvider);
    await db.membersDao.updateMember(member);
  }
}
