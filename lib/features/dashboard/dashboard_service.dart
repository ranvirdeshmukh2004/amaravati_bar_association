import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import '../database/database_provider.dart';
import '../database/app_database.dart';
import '../subscription/subscription_service.dart';

// Model to hold all dashboard data
class DashboardAnalytics {
  final double totalCollected;
  final double totalDue;
  final int totalMembers;
  final int totalSubscriptions;

  final List<MonthlyTrendData> monthlyTrend;
  final Map<String, int> paymentModeSplit;
  final List<SubscriptionStatus> topDefaulters;
  final List<dynamic> recentActivity; // Combined list of recent items

  DashboardAnalytics({
    required this.totalCollected,
    required this.totalDue,
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

    return Rx.combineLatest3(
      db.subscriptionsDao.watchAllSubscriptions(),
      db.membersDao.watchAllMembers(),
      subscriptionService.watchMemberStatuses(),
      (subscriptions, members, statuses) {
        // 1. Total Collected
        final totalCollected = subscriptions.fold(
          0.0,
          (sum, s) => sum + s.amount,
        );

        // 2. Total Due (Aggragated from member statuses)
        final totalDue = statuses.fold(0.0, (sum, s) => sum + s.balance);

        // 3. Counts
        final totalMembers = members.length;
        final totalSubscriptions = subscriptions.length;

        // 4. Monthly Trend (Last 6 Months)
        final now = DateTime.now();
        final Map<String, double> trendMap = {};

        // Initialize last 6 months with 0
        for (int i = 5; i >= 0; i--) {
          final d = DateTime(now.year, now.month - i, 1);
          final key =
              "${d.year}-${d.month.toString().padLeft(2, '0')}"; // Sort key
          trendMap[key] = 0.0;
        }

        for (var s in subscriptions) {
          final key =
              "${s.subscriptionDate.year}-${s.subscriptionDate.month.toString().padLeft(2, '0')}";
          if (trendMap.containsKey(key)) {
            trendMap[key] = (trendMap[key] ?? 0.0) + s.amount;
          }
        }

        final monthlyTrend = trendMap.entries.map((e) {
          // Convert key 2024-01 to "Jan"
          final parts = e.key.split('-');
          final monthNum = int.parse(parts[1]);
          const months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];
          return MonthlyTrendData(months[monthNum - 1], e.value);
        }).toList();

        // 5. Payment Mode Split
        final Map<String, int> paymentModes = {};
        for (var s in subscriptions) {
          paymentModes[s.paymentMode] = (paymentModes[s.paymentMode] ?? 0) + 1;
        }

        // 6. Top Defaulters (Sort by balance desc, take top 5)
        final defaulters = statuses.where((s) => s.balance > 0).toList();
        defaulters.sort((a, b) => b.balance.compareTo(a.balance));
        final topDefaulters = defaulters.take(5).toList();

        // 7. Recent Activity (Mix of new Members and Subscriptions, sorted by date)
        // We'll simplisticly take last 5 subs and last 5 members, combine, sort, take 5
        final recentSubs = subscriptions.toList()
          ..sort((a, b) => b.subscriptionDate.compareTo(a.subscriptionDate));

        final recentMembers = members.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final List<dynamic> combinedActivity = [
          ...recentSubs.take(5),
          ...recentMembers.take(5),
        ];

        // Sort combined (need safe dynamic check)
        combinedActivity.sort((a, b) {
          DateTime dateA;
          if (a is Subscription)
            dateA = a.subscriptionDate;
          else if (a is Member)
            dateA = a.createdAt;
          else
            dateA = DateTime(0);

          DateTime dateB;
          if (b is Subscription)
            dateB = b.subscriptionDate;
          else if (b is Member)
            dateB = b.createdAt;
          else
            dateB = DateTime(0);

          return dateB.compareTo(dateA);
        });

        return DashboardAnalytics(
          totalCollected: totalCollected,
          totalDue: totalDue,
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
