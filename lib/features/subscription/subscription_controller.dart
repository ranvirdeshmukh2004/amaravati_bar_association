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

    // Auto-generate receipt number: ABA-{Year}-{Month}-{Random/Sequence}
    final now = DateTime.now();
    final receiptNumber =
        '${AppConstants.receiptPrefix}${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';

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
    );
  }
}
