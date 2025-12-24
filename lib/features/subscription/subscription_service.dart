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
          
          // Cap at 12 months for a financial year view if we assume yearly cycles?
          // User asked: "from that date to the next years that date that is 12 months"
          // So if we are in month 14, it arguably belongs to next year, BUT
          // strictly speaking, until "Close Year" is pressed, we might just show total accumulation?
          // OR we cap it. Let's cap at 12 for "Yearly Expected" display, 
          // but the rollover logic handles the rest.
          // actually, simpler: Keep strictly logic: (Now - Start) * Amount.
          // When year closes, Start advances, so (Now - NewStart) restarts from 0.
          
          totalExpected = monthsElapsed * monthlyAmount;
        } else {
          debugPrint(
            'DEBUG: Config missing or Start Date is null. Expected calculated as 0.',
          );
        }

        return members.map((member) {
          // Sum payments for this member made AFTER or ON the Start Date
          final memberSubs = allSubscriptions.where((s) {
            // Check Member ID/Enrollment No
            final isMember =
                s.enrollmentNumber.trim().toLowerCase() ==
                member.registrationNumber.trim().toLowerCase();
            
            if (!isMember) return false;

            // Check Date (Only count payments in current financial period)
            if (startDate != null) {
               // Allow payments strictly after start date (minus a small buffer? no, keep strict)
               // Actually using .isBefore is safer.
               if (s.subscriptionDate.isBefore(startDate)) {
                 return false;
               }
            }
            return true;
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

final subscriptionStatusProvider = StreamProvider<List<SubscriptionStatus>>((
  ref,
) {
  return ref.watch(subscriptionServiceProvider).watchMemberStatuses();
});
