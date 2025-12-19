import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import '../database/database_provider.dart';
import '../database/app_database.dart';

class SubscriptionStatus {
  final Member member;
  final int totalMonths;
  final double totalExpected;
  final double totalPaid;
  final double balance;
  final bool isDefaulter;

  SubscriptionStatus({
    required this.member,
    required this.totalMonths,
    required this.totalExpected,
    required this.totalPaid,
    required this.balance,
    required this.isDefaulter,
  });

  String get statusText =>
      balance <= 0 ? 'Paid' : 'Due: ₹${balance.toStringAsFixed(0)}';
  Color get statusColor => balance <= 0
      ? Colors.green
      : (balance > 1000 ? Colors.red : Colors.orange);
}

class SubscriptionService {
  final Ref _ref;

  SubscriptionService(this._ref);

  Stream<List<SubscriptionStatus>> watchMemberStatuses() {
    final db = _ref.watch(databaseProvider);

    return Rx.combineLatest3(
      db.subscriptionConfigDao.watchConfig(),
      db.membersDao.watchAllMembers(),
      db.subscriptionsDao.watchAllSubscriptions(),
      (config, members, allSubscriptions) {
        // Determine constraints from Config (if available)
        final DateTime? startDate = config?.subscriptionStartDate;
        final double monthlyAmount = config?.monthlyAmount ?? 0.0;

        final now = DateTime.now();
        int monthsElapsed = 0;
        double totalExpected = 0.0;

        if (startDate != null) {
          // Calculate months elapsed since start date
          monthsElapsed =
              ((now.year - startDate.year) * 12) +
              (now.month - startDate.month) +
              1;
          if (monthsElapsed < 0) monthsElapsed = 0;
          totalExpected = monthsElapsed * monthlyAmount;
        } else {
          debugPrint(
            'DEBUG: Config missing or Start Date is null. Expected calculated as 0.',
          );
        }

        debugPrint(
          'DEBUG: Members: ${members.length}, Subs: ${allSubscriptions.length}',
        );

        return members.map((member) {
          // Sum payments for this member
          // Normalize matching by trimming and ignoring case if necessary,
          // though usually these should be strict.
          final memberSubs = allSubscriptions.where((s) {
            final match =
                s.enrollmentNumber.trim().toLowerCase() ==
                member.registrationNumber.trim().toLowerCase();
            if (match) {
              debugPrint(
                'DEBUG: Match found for ${member.registrationNumber} with Amount: ${s.amount}',
              );
            }
            return match;
          });

          final totalPaid = memberSubs.fold(0.0, (sum, s) => sum + s.amount);
          final balance = totalExpected - totalPaid;

          return SubscriptionStatus(
            member: member,
            totalMonths: monthsElapsed,
            totalExpected: totalExpected,
            totalPaid: totalPaid,
            balance: balance,
            isDefaulter: balance > 0,
          );
        }).toList();
      },
    );
  }
}

final subscriptionServiceProvider = Provider((ref) => SubscriptionService(ref));

final subscriptionStatusProvider = StreamProvider<List<SubscriptionStatus>>((
  ref,
) {
  return ref.watch(subscriptionServiceProvider).watchMemberStatuses();
});
