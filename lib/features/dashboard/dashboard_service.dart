import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import '../database/database_provider.dart';
import '../database/app_database.dart';
import '../subscription/subscription_service.dart';

// Model to hold all dashboard data
class DashboardAnalytics {
  final double totalCollected;
  final double totalDonations; // Added missing field
  final double totalDue;
  final double totalPastOutstanding;
  final int membersWithArrears;
  final int totalMembers;
  final int totalSubscriptions;

  final List<MonthlyTrendData> monthlyTrend;
  final Map<String, int> paymentModeSplit;
  final List<SubscriptionStatus> topDefaulters;
  final List<dynamic> recentActivity; 

  DashboardAnalytics({
    required this.totalCollected,
    required this.totalDonations,
    required this.totalDue,
    required this.totalPastOutstanding,
    required this.membersWithArrears,
    required this.totalMembers,
    required this.totalSubscriptions,
    required this.monthlyTrend,
    required this.paymentModeSplit,
    required this.topDefaulters,
    required this.recentActivity,
  });
}

class MonthlyTrendData {
  final String month;
  final double amount;
  MonthlyTrendData(this.month, this.amount);
}

class DashboardService {
  final Ref _ref;

  DashboardService(this._ref);

  Stream<DashboardAnalytics> watchDashboardAnalytics() {
    final db = _ref.watch(databaseProvider);
    final subscriptionService = _ref.watch(subscriptionServiceProvider);

    return Rx.combineLatest4(
      db.subscriptionsDao.watchAllSubscriptions(),
      db.membersDao.watchAllMembers(),
      subscriptionService.watchMemberStatuses(),
      db.donationsDao.watchAllDonations(), // Added Donations Stream
      (subscriptions, members, statuses, donations) {
        
        // --- 1. Collections & Donations ---
        final totalCollected = subscriptions.fold(0.0, (sum, s) => sum + s.amount);
        final totalDonations = donations.fold(0.0, (sum, d) => sum + d.amount);
        
        // --- 2. Outstanding ---
        final totalDue = statuses.fold(0.0, (sum, s) => sum + s.balance);
        final totalPastOutstanding = statuses.fold(0.0, (sum, s) => sum + s.pastOutstanding);
        final membersWithArrears = statuses.where((s) => s.pastOutstanding > 0).length;

        // --- 3. Counts ---
        final totalMembers = members.length;
        final totalSubscriptions = subscriptions.length;

        // --- 4. Monthly Trend (Subscriptions + Donations) ---
        final now = DateTime.now();
        final Map<String, double> trendMap = {};

        // Initialize last 6 months
        for (int i = 5; i >= 0; i--) {
          final d = DateTime(now.year, now.month - i, 1);
          final key = "${d.year}-${d.month.toString().padLeft(2, '0')}";
          trendMap[key] = 0.0;
        }

        // Add Subscriptions
        for (var s in subscriptions) {
          final key = "${s.subscriptionDate.year}-${s.subscriptionDate.month.toString().padLeft(2, '0')}";
          if (trendMap.containsKey(key)) {
            trendMap[key] = (trendMap[key] ?? 0.0) + s.amount;
          }
        }
        
        // Add Donations
        for (var d in donations) {
          final key = "${d.donationDate.year}-${d.donationDate.month.toString().padLeft(2, '0')}";
          if (trendMap.containsKey(key)) {
            trendMap[key] = (trendMap[key] ?? 0.0) + d.amount;
          }
        }

        final monthlyTrend = trendMap.entries.map((e) {
          final parts = e.key.split('-');
          final monthNum = int.parse(parts[1]);
          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          return MonthlyTrendData(months[monthNum - 1], e.value);
        }).toList();

        // --- 5. Payment Mode Split (Combined) ---
        final Map<String, int> paymentModes = {};
        for (var s in subscriptions) paymentModes[s.paymentMode] = (paymentModes[s.paymentMode] ?? 0) + 1;
        for (var d in donations) paymentModes[d.paymentMode] = (paymentModes[d.paymentMode] ?? 0) + 1;

        // --- 6. Top Defaulters ---
        final defaulters = statuses.where((s) => s.balance > 0).toList();
        defaulters.sort((a, b) => b.balance.compareTo(a.balance));
        final topDefaulters = defaulters.take(5).toList();

        // --- 7. Recent Activity (Subs, Members, Donations) ---
        final recentSubs = subscriptions.toList()..sort((a, b) => b.subscriptionDate.compareTo(a.subscriptionDate));
        final recentMembers = members.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final recentDonations = donations.toList()..sort((a, b) => b.donationDate.compareTo(a.donationDate));

        final List<dynamic> combinedActivity = [
          ...recentSubs.take(5),
          ...recentMembers.take(5),
          ...recentDonations.take(5),
        ];

        combinedActivity.sort((a, b) {
          DateTime dateA;
           if (a is Subscription) dateA = a.subscriptionDate;
           else if (a is Member) dateA = a.createdAt;
           else if (a is Donation) dateA = a.donationDate;
           else dateA = DateTime(0);
           
           DateTime dateB;
           if (b is Subscription) dateB = b.subscriptionDate;
           else if (b is Member) dateB = b.createdAt;
           else if (b is Donation) dateB = b.donationDate;
           else dateB = DateTime(0);

           return dateB.compareTo(dateA);
        });

        return DashboardAnalytics(
          totalCollected: totalCollected,
          totalDonations: totalDonations, // New field
          totalDue: totalDue,
          totalPastOutstanding: totalPastOutstanding,
          membersWithArrears: membersWithArrears,
          totalMembers: totalMembers,
          totalSubscriptions: totalSubscriptions,
          monthlyTrend: monthlyTrend,
          paymentModeSplit: paymentModes,
          topDefaulters: topDefaulters,
          recentActivity: combinedActivity.take(10).toList(),
        );
      },
    );
  }
}

final dashboardServiceProvider = Provider<DashboardService>(
  (ref) => DashboardService(ref),
);

final dashboardAnalyticsProvider = StreamProvider<DashboardAnalytics>((ref) {
  return ref.watch(dashboardServiceProvider).watchDashboardAnalytics();
});
