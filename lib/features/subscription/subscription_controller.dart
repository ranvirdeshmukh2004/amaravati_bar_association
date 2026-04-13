import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/constants.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';

final subscriptionControllerProvider = Provider(
  (ref) => SubscriptionController(ref),
);

class SubscriptionController {
  final Ref _ref;

  SubscriptionController(this._ref);

  Future<Subscription> saveSubscription({
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

    // Generate Standardized Receipt Number: SUB-YYYYMMDD-SEQ
    final now = DateTime.now();
    const type = 'SUB';
    final seq = await db.subscriptionsDao.getNextSequence(type, now);
    
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final seqStr = seq.toString().padLeft(3, '0');
    final receiptNumber = '$type-$dateStr-$seqStr';

    final entry = SubscriptionsCompanion(
      firstName: drift.Value(firstName),
      lastName: drift.Value(lastName),
      address: drift.Value(address),
      mobileNumber: drift.Value(mobileNumber),
      email: drift.Value(email),
      enrollmentNumber: drift.Value(enrollmentNumber),
      amount: drift.Value(amount),
      paymentMode: drift.Value(paymentMode),
      transactionInfo: drift.Value(transactionInfo),
      subscriptionDate: drift.Value(now),
      receiptNumber: drift.Value(receiptNumber),
      receiptType: drift.Value(type),
      dailySequence: drift.Value(seq),
      isSynced: const drift.Value(false),
      lastUpdatedAt: drift.Value(now),
      deleted: const drift.Value(false),
    );

    final id = await db.subscriptionsDao.insertSubscription(entry);

    return Subscription(
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
      subscriptionDate: now,
      receiptNumber: receiptNumber,
      receiptType: type,
      dailySequence: seq,
      isSynced: false,
      lastUpdatedAt: now,
      deleted: false,
    );
  }
}
