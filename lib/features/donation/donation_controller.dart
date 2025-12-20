import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/constants.dart';
import '../database/database_provider.dart';

final donationControllerProvider = Provider((ref) => DonationController(ref));

class DonationController {
  final Ref _ref;

  DonationController(this._ref);

  Future<Donation> saveDonation({
    required String firstName,
    required String lastName,
    required String address,
    required String mobileNumber,
    String? email,
    required String enrollmentNumber,
    required double amount,
    required String paymentMode,
    String? transactionInfo,
  }) async {
    final db = _ref.read(databaseProvider);

    // Auto-generate receipt number: ABA-{Year}-{Month}-{Random/Sequence}
    // For simplicity, we can use timestamp or simple increment.
    // Ideally we want something sequential.
    // Let's use format: ABA/YYYY/MM/{ID} - ID we get after insert? No, drift insert returns ID.
    // We can generate a temp, insert, update? Or generate unique beforehand.
    // Let's generate a unique timestamp based one first.
    final now = DateTime.now();
    final receiptNumber =
        '${AppConstants.receiptPrefix}${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';

    final entry = DonationsCompanion(
      firstName: drift.Value(firstName),
      lastName: drift.Value(lastName),
      address: drift.Value(address),
      mobileNumber: drift.Value(mobileNumber),
      email: drift.Value(email),
      enrollmentNumber: drift.Value(enrollmentNumber),
      amount: drift.Value(amount),
      paymentMode: drift.Value(paymentMode),
      transactionInfo: drift.Value(transactionInfo),
      donationDate: drift.Value(now),
      receiptNumber: drift.Value(receiptNumber),
    );

    final id = await db.donationsDao.insertDonation(entry);

    // Construct Donation object manually to avoid re-fetch latency or use copyWith on entry if it was a data class
    return Donation(
      id: id,
      firstName: firstName,
      lastName: lastName,
      address: address,
      mobileNumber: mobileNumber,
      email: email,
      enrollmentNumber: enrollmentNumber,
      amount: amount,
      paymentMode: paymentMode,
      transactionInfo: transactionInfo,
      donationDate: now,
      receiptNumber: receiptNumber,
    );
  }
}
