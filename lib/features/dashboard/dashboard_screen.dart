import 'package:amaravati_bar_association/features/dashboard/widgets/analytics_charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/utils.dart';
import 'dashboard_service.dart';
import 'widgets/kpi_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(dashboardAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: analyticsAsync.when(
        data: (data) => _DashboardLayout(data: data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
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
                if (constraints.maxWidth > 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Analytics (Charts)
                      Expanded(
                        flex: 2,
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
                        flex: 1,
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
          ],
        );
      },
    );
  }

  Widget _buildMonthlyTrendSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
      child: Padding(
        padding: const EdgeInsets.all(24),
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
      child: Padding(
        padding: const EdgeInsets.all(24),
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
      color: Colors.orange.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...data.recentActivity.map((item) {
              if (item.runtimeType.toString().contains('Subscription')) {
                // Hacky check since we lost type info in dynamic list
                // It's a Subscription (actually Drift row class name is 'Subscription')
                // Wait, Drift class is 'Subscription', my logic in service used generic dynamic
                // Let's assume fields exist
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.receipt, color: Colors.white, size: 16),
                  ),
                  title: Text('Payment Received'),
                  subtitle: Text(
                    DateFormat(
                      'dd MMM',
                    ).format((item as dynamic).subscriptionDate),
                  ),
                  trailing: Text(
                    '+${(item as dynamic).amount}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              } else {
                // Member
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(
                      Icons.person_add,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  title: Text('New Member Joined'),
                  subtitle: Text(
                    DateFormat('dd MMM').format((item as dynamic).createdAt),
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
