import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../subscription_filter_provider.dart';
import '../../../core/app_gradients.dart';

class AdvancedFilterPanel extends ConsumerStatefulWidget {
  const AdvancedFilterPanel({super.key});

  @override
  ConsumerState<AdvancedFilterPanel> createState() =>
      _AdvancedFilterPanelState();
}

class _AdvancedFilterPanelState extends ConsumerState<AdvancedFilterPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(subscriptionFilterProvider);
    final notifier = ref.read(subscriptionFilterProvider.notifier);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: AppGradients.filterDrawer(context),
        ),
        child: ExpansionPanelList(
          elevation: 0,
          expandedHeaderPadding: EdgeInsets.zero,
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              _isExpanded = !_isExpanded; // Toggle since we only have 1 panel
            });
          },
          children: [
            ExpansionPanel(
              backgroundColor: Colors.transparent,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return const ListTile(
                  leading: Icon(Icons.filter_list_alt, color: Colors.blue),
                  title: Text(
                    'Advanced Subscription Filters',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Status, Due Amount, Overdue Duration'),
                );
              },
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Status Chips
                  const _SectionLabel('Subscription Status'),
                  Wrap(
                    spacing: 8,
                    children: [
                      _StatusChip(
                        label: 'Fully Paid',
                        color: Colors.green,
                        selected: filterState.selectedStatuses.contains(
                          'Fully Paid',
                        ),
                        onSelected: (_) => notifier.toggleStatus('Fully Paid'),
                      ),
                      _StatusChip(
                        label: 'Due',
                        color: Colors.orange,
                        selected: filterState.selectedStatuses.contains('Due'),
                        onSelected: (_) => notifier.toggleStatus('Due'),
                      ),
                      _StatusChip(
                        label: 'Overdue (6m+)',
                        color: Colors.red,
                        selected: filterState.selectedStatuses.contains(
                          'Overdue',
                        ),
                        onSelected: (_) => notifier.toggleStatus('Overdue'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. Due Amount Range
                  const _SectionLabel('Due Amount Range'),
                  RangeSlider(
                    values: filterState.dueAmountRange,
                    min: 0,
                    max: 10000,
                    divisions: 100, // Steps of 100
                    labels: RangeLabels(
                      '₹${filterState.dueAmountRange.start.round()}',
                      '₹${filterState.dueAmountRange.end.round()}+',
                    ),
                    onChanged: (RangeValues values) {
                      notifier.updateDueAmountRange(values);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Min: ₹${filterState.dueAmountRange.start.round()}'),
                      Text('Max: ₹${filterState.dueAmountRange.end.round()}'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 4. Overdue Months Slider
                  const _SectionLabel('Overdue Duration (Months)'),
                  Slider(
                    value: filterState.overdueMonthsMin,
                    min: 0,
                    max: 12,
                    divisions: 12,
                    label: '${filterState.overdueMonthsMin.round()}+ Months',
                    onChanged: (double value) {
                      notifier.updateOverdueMonthsMin(value);
                    },
                  ),
                  Text(
                    '${filterState.overdueMonthsMin.round()}+ Months Overdue',
                  ),

                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.restore),
                        label: const Text('Reset All'),
                        onPressed: () => notifier.reset(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            isExpanded: _isExpanded, // State driven
            canTapOnHeader: true,
          ),
        ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      side: BorderSide(color: selected ? color : Colors.grey.shade400),
      labelStyle: TextStyle(
        color: selected ? color : null,
        fontWeight: selected ? FontWeight.bold : null,
      ),
    );
  }
}
