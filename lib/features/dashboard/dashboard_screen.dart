import 'package:amaravati_bar_association/features/dashboard/widgets/analytics_charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/sync/sync_status_button.dart';
import '../../features/sync/sync_service.dart'; // Added
import '../../core/auth/app_session.dart'; // Added
import 'package:intl/intl.dart';
import '../../core/utils.dart';
import '../../core/app_gradients.dart';
import 'dashboard_service.dart';
import 'widgets/kpi_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(dashboardAnalyticsProvider);
    final isDev = ref.watch(appSessionProvider).environment == AppEnvironment.dev;

    return Scaffold(
      backgroundColor: Colors.transparent, // Allow parent background if any
      body: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.dashboardBackground(context),
        ),
        child: Column(
          children: [
            _buildHeader(context, ref, isDev),
            Expanded(
              child: analyticsAsync.when(
                data: (data) => _DashboardLayout(data: data),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, bool isDev) {
    final now = DateTime.now();
    final startYear = now.month >= 4 ? now.year : now.year - 1;
    final fy = "FY $startYear-${(startYear + 1).toString().substring(2)}";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          // Left Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DASHBOARD',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Subscription & Member Overview',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
              ),
            ],
          ),
          const Spacer(),
          // Right Section
          Row(
            children: [
              _buildHeaderTag(context, Icons.calendar_today, fy, Colors.blue),
              const SizedBox(width: 16),
              _buildHeaderTag(
                context, 
                Icons.circle, 
                isDev ? 'Debug Mode' : 'Live Data', 
                isDev ? Colors.orange : Colors.green,
                iconSize: 8 // Smaller dot for status
              ),
              const SizedBox(width: 16),
              // Last Updated
              FutureBuilder<DateTime>(
                future: ref.read(syncServiceProvider).getLastSyncTime(),
                builder: (context, snapshot) {
                  final time = snapshot.data;
                  final timeStr = time != null 
                      ? DateFormat('dd MMM, HH:mm').format(time) 
                      : 'Never';
                  return Text(
                    'Last Updated: $timeStr',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                  );
                }
              ),
              const SizedBox(width: 16),
              const SyncStatusButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTag(BuildContext context, IconData icon, String label, Color color, {double iconSize = 14}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardLayout extends StatelessWidget {
  final DashboardAnalytics data;

  const _DashboardLayout({required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 1. KPI Strip
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [_buildKpiStrip(context), const SizedBox(height: 24)],
            ),
          ),
        ),

        // 2. Main Content Grid (Charts + Health + Alerts)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          sliver: SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive check: if wide enough, show side-by-side
                // Responsive check: if wide enough, show side-by-side
                if (constraints.maxWidth > 1100) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Analytics (Charts)
                      Expanded(
                        flex: 3, // Reduced from 2 (relative to 1) to 3 (relative to 2) -> 60% width
                        child: Column(
                          children: [
                            _buildMonthlyTrendSection(context),
                            const SizedBox(height: 24),
                            _buildPaymentModeSection(context),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Right Column: Health & Alerts
                      Expanded(
                        flex: 2, // Increased from 1 to 2 -> 40% width
                        child: Column(
                          children: [
                            _buildHealthPanel(context),
                            const SizedBox(height: 24),
                            _buildAlertsPanel(context),
                            const SizedBox(height: 24),
                            _buildRecentActivity(context),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  // Narrow layout: Stack everything
                  return Column(
                    children: [
                      _buildMonthlyTrendSection(context),
                      const SizedBox(height: 24),
                      _buildPaymentModeSection(context),
                      const SizedBox(height: 24),
                      _buildHealthPanel(context),
                      const SizedBox(height: 24),
                      _buildAlertsPanel(context),
                      const SizedBox(height: 24),
                      _buildRecentActivity(context),
                    ],
                  );
                }
              },
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }

  Widget _buildKpiStrip(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // 4 items. On desktop (width > 800), use Row. Else Wrap.
        int count = width > 1000 ? 5 : (width > 600 ? 2 : 1);
        // Adjusted for 4 cards actually.
        // Logic to maintain card width reasonable

        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            SizedBox(
              width: count > 3
                  ? (width - 72) / 4
                  : (width - 24) / 2, // Simple responsive math
              child: KpiCard(
                title: 'Total Subscriptions',
                value: AppUtils.formatCurrency(data.totalCollected),
                icon: Icons.currency_rupee,
                color: Colors.green,
              ),
            ),
            SizedBox(
              width: count > 3 ? (width - 72) / 4 : (width - 24) / 2,
              child: KpiCard(
                title: 'This Month',
                value: data.monthlyTrend.isNotEmpty
                    ? AppUtils.formatCurrency(data.monthlyTrend.last.amount)
                    : "0",
                icon: Icons.calendar_today,
                color: Colors.blue,
              ),
            ),
            SizedBox(
              width: count > 3 ? (width - 72) / 4 : (width - 24) / 2,
              child: KpiCard(
                title: 'Total Donations',
                value: AppUtils.formatCurrency(data.totalDonations),
                icon: Icons.volunteer_activism,
                color: Colors.teal,
              ),
            ),
            SizedBox(
              width: count > 3 ? (width - 72) / 4 : (width - 24) / 2,
              child: KpiCard(
                title: 'Total Members',
                value: data.totalMembers.toString(),
                icon: Icons.people,
                color: Colors.purple,
              ),
            ),
            SizedBox(
              width: count > 3 ? (width - 72) / 4 : (width - 24) / 2,
              child: KpiCard(
                title: 'Outstanding Dues',
                value: AppUtils.formatCurrency(data.totalDue),
                icon: Icons.warning,
                color: Colors.red,
                isPositiveTrend: false,
              ),
            ),
            SizedBox(
              width: count > 3 ? (width - 72) / 4 : (width - 24) / 2,
              child: KpiCard(
                title: 'Past Arrears',
                value: AppUtils.formatCurrency(data.totalPastOutstanding),
                icon: Icons.history, 
                color: Colors.orange[800]!,
                isPositiveTrend: false,
              ),
            ),
            SizedBox(
              width: count > 3 ? (width - 72) / 4 : (width - 24) / 2,
              child: KpiCard(
                title: 'Defaulters',
                value: data.membersWithArrears.toString(),
                icon: Icons.person_off,
                color: Colors.red[700]!,
                isPositiveTrend: false,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthlyTrendSection(BuildContext context) {
    return Card(
      elevation: 4, // Subtle elevation
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: AppGradients.analyticsCard(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Subscription Trend',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: MonthlyTrendChart(data: data.monthlyTrend),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentModeSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: AppGradients.analyticsCard(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Mode Distribution',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PaymentModePieChart(data: data.paymentModeSplit),
                  ),
                  Expanded(child: _buildLegend(data.paymentModeSplit)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Map<String, int> data) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    int i = 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: data.entries.map((e) {
        final color = colors[i++ % colors.length];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 12, height: 12, color: color),
              const SizedBox(width: 8),
              Text('${e.key}: ${e.value}'),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHealthPanel(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: AppGradients.analyticsCard(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Defaulters',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (data.topDefaulters.isEmpty)
              const Text(
                'No defaulters found!',
                style: TextStyle(color: Colors.green),
              ),
            ...data.topDefaulters.map(
              (s) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("${s.member.surname} ${s.member.firstName}"),
                subtitle: Text('Due: ${AppUtils.formatCurrency(s.balance)}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsPanel(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // Removed color: argument as we use gradient
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: AppGradients.analyticsCard(context), // Using analytics card gradient for consistency, alert icon handles color
          border: Border.all(color: Colors.orange.withOpacity(0.3)), // Subtle border for alert
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  "System Alerts",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (data.totalDue > 10000)
              _AlertItem(
                text: "High total outstanding dues detected!",
                color: Colors.red,
              ),
            _AlertItem(
              text: "Remember to backup your data regularly.",
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: AppGradients.analyticsCard(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...data.recentActivity.map((item) {
              final type = item.runtimeType.toString();
              if (type.contains('Subscription')) {
                return ListTile(
                  leading: Container(
                    width: 40, 
                    height: 40,
                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                    child: const Icon(Icons.receipt, color: Colors.white, size: 20),
                  ),
                  title: const Text('Payment Received'),
                  subtitle: Text(
                    DateFormat('dd MMM').format((item as dynamic).subscriptionDate),
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                  trailing: Text(
                    '+${(item as dynamic).amount}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                );
              } else if (type.contains('Donation')) {
                 return ListTile(
                  leading: Container(
                    width: 40, 
                    height: 40,
                    decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(4)),
                    child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 20),
                  ),
                  title: const Text('Donation Received'),
                  subtitle: Text(
                    DateFormat('dd MMM').format((item as dynamic).donationDate),
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                  trailing: Text(
                    '+${(item as dynamic).amount}',
                    style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                  ),
                );
              } else {
                // Member
                return ListTile(
                  leading: Container(
                    width: 40, 
                    height: 40,
                    decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(4)),
                    child: const Icon(Icons.person_add, color: Colors.white, size: 20),
                  ),
                  title: const Text('New Member Joined'),
                  subtitle: Text(
                    DateFormat('dd MMM').format((item as dynamic).createdAt),
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                  trailing: Text((item as dynamic).registrationNumber),
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final String text;
  final Color color;
  const _AlertItem({required this.text, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
