import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import 'package:drift/drift.dart';
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

// 1. Define a container for raw data
class SubscriptionRawData {
  final SubscriptionConfigData? config;
  final List<Member> members;
  final List<Subscription> subscriptions;

  SubscriptionRawData(this.config, this.members, this.subscriptions);
}

// 2. Cached Raw Data Provider (KeepAlive - No autoDispose)
final rawSubscriptionDataProvider = StreamProvider<SubscriptionRawData>((ref) {
  final db = ref.watch(databaseProvider);
  return Rx.combineLatest3(
      db.subscriptionConfigDao.watchConfig(),
      db.membersDao.watchAllMembers(),
      db.subscriptionsDao.watchAllSubscriptions(),
      (config, members, subscriptions) =>
          SubscriptionRawData(config, members, subscriptions));
});


class SubscriptionService {
  final Ref _ref;

  SubscriptionService(this._ref);

  // Pure calculation method (Synchronous)
  List<SubscriptionStatus> calculateStatuses(
    SubscriptionRawData data, {
    DateTime? calculationEndDate,
  }) {
    // Determine constraints from Config (if available)
    final DateTime? startDate = data.config?.subscriptionStartDate;
    final double monthlyAmount = data.config?.monthlyAmount ?? 0.0;

    // Use provided date or default to now
    final now = calculationEndDate ?? DateTime.now();
    int monthsElapsed = 0;
    double totalExpected = 0.0;

    if (startDate != null) {
      // Calculate months elapsed since start date
      monthsElapsed = ((now.year - startDate.year) * 12) +
          (now.month - startDate.month) +
          1;
      if (monthsElapsed < 0) monthsElapsed = 0;

      totalExpected = monthsElapsed * monthlyAmount;
    } else {
      debugPrint(
        'DEBUG: Config missing or Start Date is null. Expected calculated as 0.',
      );
    }

    // Pre-process Subscriptions into a Map<EnrollmentNumber, List<Subscription>>
    final subsByMember = <String, List<Subscription>>{};
    for (final sub in data.subscriptions) {
      final key = sub.enrollmentNumber.trim().toLowerCase();
      subsByMember.putIfAbsent(key, () => []).add(sub);
    }

    return data.members.map((member) {
      // Get pre-filtered list
      final key = member.registrationNumber.trim().toLowerCase();
      final rawSubs = subsByMember[key] ?? [];

      // Sum payments for this member made AFTER or ON the Start Date
      double totalPaid = 0.0;
      for (final s in rawSubs) {
        // Check Date (Only count payments in current financial period)
        if (startDate != null) {
          if (s.subscriptionDate.isBefore(startDate)) {
            continue;
          }
        }
        totalPaid += s.amount;
      }

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
  }

  // Wrapper for backward compatibility and simple streaming
  Stream<List<SubscriptionStatus>> watchMemberStatuses({DateTime? calculationEndDate}) {
    final db = _ref.watch(databaseProvider);
    return Rx.combineLatest3(
      db.subscriptionConfigDao.watchConfig(),
      db.membersDao.watchAllMembers(),
      db.subscriptionsDao.watchAllSubscriptions(),
      (config, members, subscriptions) {
         final rawData = SubscriptionRawData(config, members, subscriptions);
         return calculateStatuses(rawData, calculationEndDate: calculationEndDate);
      }
    );
  }

  Future<void> closeFinancialYear() async {
    final db = _ref.read(databaseProvider);
    
    // 1. Get Current Config
    final config = await db.subscriptionConfigDao.getConfig();
    if (config == null || config.subscriptionStartDate == null) {
      throw Exception("Configuration not set. Cannot close year.");
    }

    final startDate = config.subscriptionStartDate!;
    final endDate = DateTime(startDate.year + 1, startDate.month, startDate.day);
    final yearLabel = "${startDate.year}-${endDate.year}";

    // 2. Get All Statuses (Snapshotted)
    // We can use the stream we just re-added
    final statuses = await watchMemberStatuses().first;

    // 3. Batch Operations
    await db.transaction(() async {
      for (final status in statuses) {
        // A. Archive to YearlySummaries
        await db.yearlySummariesDao.insertSummary(
          YearlySummariesCompanion.insert(
            enrollmentNumber: status.member.registrationNumber,
            financialYear: yearLabel,
            totalExpected: status.totalExpected,
            totalPaid: status.totalPaid,
            balance: status.balance,
            status: status.statusText,
          ),
        );

        // B. Handle Rollover (Credit Carry Forward)
        // If balance is negative (e.g. -800), they paid extra.
        // We add this as a starting payment for next year.
        if (status.balance < 0) {
          final creditAmount = status.balance.abs();
          await db.subscriptionsDao.insertSubscription(
            SubscriptionsCompanion.insert(
              firstName: status.member.firstName,
              lastName: status.member.surname,
              address: status.member.address,
              mobileNumber: status.member.mobileNumber,
              enrollmentNumber: status.member.registrationNumber,
              amount: creditAmount,
              paymentMode: 'System',
              transactionInfo: Value('Carry Forward from $yearLabel'),
              subscriptionDate: endDate, // Start of new year
              receiptNumber: 'CF-${status.member.registrationNumber}-${endDate.year}', // Unique receipt
            ),
          );
        }
      }

      // 4. Update Global Start Date
      await db.subscriptionConfigDao.updateConfig(
         config.monthlyAmount,
         endDate,
      );
    });
  }
}

final subscriptionServiceProvider = Provider((ref) => SubscriptionService(ref));


