import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart'; 
import '../database/database_provider.dart'; // Correct relative path
import 'subscription_config_screen.dart'; // Same dir
import 'subscription_service.dart';
import 'year_history_screen.dart';
import 'subscription_filter_provider.dart';
import 'widgets/advanced_filter_panel.dart';
import 'export_service.dart';
import '../../core/app_gradients.dart';

class SubscriptionDashboardScreen extends ConsumerStatefulWidget {
  const SubscriptionDashboardScreen({super.key});

  @override
  ConsumerState<SubscriptionDashboardScreen> createState() =>
      _SubscriptionDashboardScreenState();
}

class _SubscriptionDashboardScreenState
    extends ConsumerState<SubscriptionDashboardScreen> {
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void dispose() {
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Watch the FILTERED list (State is managed by provider)
    final statuses = ref.watch(filteredSubscriptionStatusProvider);

    final allStatusesAsync = ref.watch(subscriptionStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'View History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const YearHistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Close Financial Year',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Close Financial Year?'),
                  content: const Text(
                    'This will archive current data, carry forward credits, and advance the financial year. This cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  await ref
                      .read(subscriptionServiceProvider)
                      .closeFinancialYear();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Financial Year Closed Successfully')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubscriptionConfigScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: allStatusesAsync.when(
        data: (allStatuses) {
          // Calculate Global Totals
          final totalExpected = allStatuses.fold(
            0.0,
            (sum, s) => sum + s.totalExpected,
          );
          final totalCollected = allStatuses.fold(
            0.0,
            (sum, s) => sum + s.totalPaid,
          );
          final totalDue = allStatuses.fold(0.0, (sum, s) => sum + s.balance);
          final totalMembers = allStatuses.length;
          final defaulterCount = allStatuses.where((s) => s.balance > 0).length;

          // Filtered list comes from the *other* provider
          final filteredStatuses = statuses;
          filteredStatuses.sort((a, b) => b.balance.compareTo(a.balance));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary Cards (Active Global Stats)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Total Members',
                        value: totalMembers.toString(),
                        icon: Icons.group,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Collected',
                        value: '₹${totalCollected.toStringAsFixed(0)}',
                        icon: Icons.savings,
                        color: Colors.green[700]!,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Outstanding',
                        value: '₹${totalDue.toStringAsFixed(0)}',
                        icon: Icons.warning,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Defaulters',
                        value: defaulterCount.toString(),
                        icon: Icons.person_off,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              // 1. Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Members',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onChanged: (v) => ref
                      .read(subscriptionFilterProvider.notifier)
                      .updateSearchQuery(v),
                ),
              ),

              // ADVANCED FILTER PANEL
              const AdvancedFilterPanel(),

              const SizedBox(height: 8),

              // Result Count & Export
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${filteredStatuses.length} Results',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Row(
                      children: [
                        Consumer(
                           builder: (context, ref, _) {
                            final filter = ref.watch(subscriptionFilterProvider);
                            final date = filter.calculationDate ?? DateTime.now();
                            return OutlinedButton.icon(
                              icon: const Icon(Icons.calendar_month, size: 18),
                              label: Text(
                                'Calculate Till: ${DateFormat('dd MMM yyyy').format(date)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: date,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  ref
                                      .read(subscriptionFilterProvider.notifier)
                                      .updateCalculationDate(picked);
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        TextButton.icon(
                          icon: const Icon(Icons.download),
                          label: const Text('Export Filtered CSV'),
                          onPressed: () async {
                            final success = await ref
                                .read(subscriptionExportProvider)
                                .exportToCsv(filteredStatuses);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'Export Successful'
                                        : 'Export Failed or Cancelled',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Data Table Area - Expanded to take remaining space
              Expanded(
                child: Card(
                  margin: const EdgeInsets.all(16),
                  elevation: 4,
                  child: Container( 
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: AppGradients.tableContainer(context),
                    ),
                    child: DataTable2(
                      scrollController: _verticalScrollController,
                      headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                      headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      columnSpacing: 12,
                      horizontalMargin: 12,
                      minWidth: 1000,
                      fixedLeftColumns: 1,
                      columns: const [
                        DataColumn2(label: Text('MEMBER'), fixedWidth: 200),
                        DataColumn2(label: Text('REG NO'), size: ColumnSize.L),
                        DataColumn2(label: Text('MONTHS'), size: ColumnSize.L),
                        DataColumn2(label: Text('EXPECTED'), size: ColumnSize.L),
                        DataColumn2(label: Text('ARREARS'), size: ColumnSize.L), // New Column
                        DataColumn2(label: Text('PAID'), size: ColumnSize.L),
                        DataColumn2(label: Text('DUE'), size: ColumnSize.L),
                        DataColumn2(label: Text('STATUS'), size: ColumnSize.L),
                      ],
                      rows: filteredStatuses.map((s) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                '${s.member.firstName} ${s.member.surname}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DataCell(Text(s.member.registrationNumber)),
                            DataCell(Text(s.totalMonths.toString())),
                            DataCell(
                              Text(
                                '₹${s.totalExpected.toStringAsFixed(0)}',
                              ),
                            ),
                            DataCell(
                              Text(
                                '₹${s.pastOutstanding.toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.orange), // Highlight arrears
                              ),
                            ),
                            DataCell(
                              Text(
                                '₹${s.totalPaid.toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.green),
                              ),
                            ),
                            DataCell(
                              Text(
                                '₹${s.balance.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: s.balance > 0
                                      ? Colors.red
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: s.statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: s.statusColor),
                                ),
                                child: Text(
                                  s.statusText,
                                  style: TextStyle(color: s.statusColor),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: AppGradients.kpiCard(context),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
