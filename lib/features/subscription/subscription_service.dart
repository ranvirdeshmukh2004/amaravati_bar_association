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
  final double pastOutstanding; // New field
  final double balance;
  final bool isDefaulter;

  SubscriptionStatus({
    required this.member,
    required this.totalMonths,
    required this.totalExpected,
    required this.totalPaid,
    required this.pastOutstanding,
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
  final List<PastOutstandingDue> pastOutstanding; // New field

  SubscriptionRawData(this.config, this.members, this.subscriptions, this.pastOutstanding);
}

// 2. Cached Raw Data Provider (KeepAlive - No autoDispose)
final rawSubscriptionDataProvider = StreamProvider<SubscriptionRawData>((ref) {
  final db = ref.watch(databaseProvider);
  return Rx.combineLatest4(
      db.subscriptionConfigDao.watchConfig(),
      db.membersDao.watchAllMembers(),
      db.subscriptionsDao.watchAllSubscriptions(),
      db.pastOutstandingDao.watchAllOutstanding(),
      (config, members, subscriptions, pastOutstanding) =>
          SubscriptionRawData(config, members, subscriptions, pastOutstanding));
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

    // Pre-process Past Outstanding (Only Pending)
    final arrearsByMember = <String, double>{};
    for (final arrears in data.pastOutstanding) {
      if (arrears.isCleared) continue; // Exclude cleared arrears from "Due" calculation
      final key = arrears.enrollmentNumber.trim().toLowerCase();
      arrearsByMember[key] = (arrearsByMember[key] ?? 0.0) + arrears.amount;
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
      final pastDue = arrearsByMember[key] ?? 0.0;

      // Sum payments for this member made AFTER or ON the Start Date
      double totalPaid = 0.0;
      for (final s in rawSubs) {
        // Exclude Arrears Payments (AR-) from "Current Year Paid"
        // Because "pastDue" only includes Pending Arrears.
        // Exclude Arrears Payments from "Current Year Paid"
        // Check both receiptType (new) and receiptNumber (legacy/backup)
        final rSeq = s.receiptNumber.toUpperCase().trim();
        if (s.receiptType == 'ARR' || rSeq.startsWith('AR') || rSeq.startsWith('ARR')) continue;

        // Check Date (Only count payments in current financial period)
        if (startDate != null) {
          if (s.subscriptionDate.isBefore(startDate)) {
            continue;
          }
        }
        totalPaid += s.amount;
      }

      // Balance = (Expected + Arrears) - Paid
      final balance = (totalExpected + pastDue) - totalPaid;

      return SubscriptionStatus(
        member: member,
        totalMonths: monthsElapsed,
        totalExpected: totalExpected, // Keep this strictly as "Current Year Expected"
        totalPaid: totalPaid,
        pastOutstanding: pastDue,
        balance: balance,
        isDefaulter: balance > 0,
      );
    }).toList();
  }

  // Wrapper for backward compatibility and simple streaming
  Stream<List<SubscriptionStatus>> watchMemberStatuses({DateTime? calculationEndDate}) {
    final db = _ref.watch(databaseProvider);
    return Rx.combineLatest4(
      db.subscriptionConfigDao.watchConfig(),
      db.membersDao.watchAllMembers(),
      db.subscriptionsDao.watchAllSubscriptions(),
      db.pastOutstandingDao.watchAllOutstanding(),
      (config, members, subscriptions, pastOutstanding) {
         final rawData = SubscriptionRawData(config, members, subscriptions, pastOutstanding);
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

        // B. Handle Rollover
        if (status.balance > 0) {
           // DEBIT Carry Forward: Add to Arrears
           // Check duplicate first to ensure idempotency
           final existingArrears = await (db.select(db.pastOutstandingDues)
             ..where((t) => 
                t.enrollmentNumber.equals(status.member.registrationNumber) & 
                t.periodLabel.equals(yearLabel) &
                t.type.equals('Subscription Arrears')
             )).get();
           
           if (existingArrears.isEmpty) {
             await db.pastOutstandingDao.insertOutstanding(
               PastOutstandingDuesCompanion.insert(
                 enrollmentNumber: status.member.registrationNumber,
                 amount: status.balance,
                 type: 'Subscription Arrears',
                 periodLabel: yearLabel,
               ),
             );
           }
        } else if (status.balance < 0) {
          // CREDIT Carry Forward: Add as new payment
          final receiptNo = 'CF-${status.member.registrationNumber}-${endDate.year}';
          
          // Check for existing CF receipt
          final existingSub = await (db.select(db.subscriptions)
            ..where((t) => t.receiptNumber.equals(receiptNo))).getSingleOrNull();

          if (existingSub == null) {
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
                receiptNumber: receiptNo, 
                receiptType: const Value('CF'),
              ),
            );
          }
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


