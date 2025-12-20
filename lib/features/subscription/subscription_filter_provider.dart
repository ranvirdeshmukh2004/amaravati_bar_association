import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'subscription_service.dart';

class SubscriptionFilterState {
  final List<String> selectedStatuses; // ['Paid', 'Due', 'Overdue']
  final RangeValues dueAmountRange;
  final double overdueMonthsMin;
  final String searchQuery;
  final bool
  showDefaultersOnly; // Kept for legacy compatibility if needed, but 'Due' status covers it

  const SubscriptionFilterState({
    this.selectedStatuses = const [],
    this.dueAmountRange = const RangeValues(0, 10000), // Max arbitrary high
    this.overdueMonthsMin = 0,
    this.searchQuery = '',
    this.showDefaultersOnly = false,
  });

  SubscriptionFilterState copyWith({
    List<String>? selectedStatuses,
    RangeValues? dueAmountRange,
    double? overdueMonthsMin,
    String? searchQuery,
    bool? showDefaultersOnly,
  }) {
    return SubscriptionFilterState(
      selectedStatuses: selectedStatuses ?? this.selectedStatuses,
      dueAmountRange: dueAmountRange ?? this.dueAmountRange,
      overdueMonthsMin: overdueMonthsMin ?? this.overdueMonthsMin,
      searchQuery: searchQuery ?? this.searchQuery,
      showDefaultersOnly: showDefaultersOnly ?? this.showDefaultersOnly,
    );
  }
}

class SubscriptionFilterNotifier
    extends StateNotifier<SubscriptionFilterState> {
  SubscriptionFilterNotifier() : super(const SubscriptionFilterState());

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleStatus(String status) {
    final current = List<String>.from(state.selectedStatuses);
    if (current.contains(status)) {
      current.remove(status);
    } else {
      current.add(status);
    }
    state = state.copyWith(selectedStatuses: current);
  }

  void updateDueAmountRange(RangeValues range) {
    state = state.copyWith(dueAmountRange: range);
  }

  void updateOverdueMonthsMin(double months) {
    state = state.copyWith(overdueMonthsMin: months);
  }

  void reset() {
    state = const SubscriptionFilterState();
  }
}

final subscriptionFilterProvider =
    StateNotifierProvider<SubscriptionFilterNotifier, SubscriptionFilterState>((
      ref,
    ) {
      return SubscriptionFilterNotifier();
    });

// Dependent provider to filter the list
final filteredSubscriptionStatusProvider = Provider<List<SubscriptionStatus>>((
  ref,
) {
  final allStatusesAsync = ref.watch(subscriptionStatusProvider);
  final filter = ref.watch(subscriptionFilterProvider);

  return allStatusesAsync.when(
    data: (allStatuses) {
      return allStatuses.where((status) {
        // 1. Search Query
        if (filter.searchQuery.isNotEmpty) {
          final q = filter.searchQuery.toLowerCase();
          final matchesName =
              status.member.firstName.toLowerCase().contains(q) ||
              status.member.surname.toLowerCase().contains(q);
          final matchesReg = status.member.registrationNumber
              .toLowerCase()
              .contains(q);
          if (!matchesName && !matchesReg) return false;
        }

        // 2. Statuses
        if (filter.selectedStatuses.isNotEmpty) {
          bool statusMatch = false;
          if (filter.selectedStatuses.contains('Fully Paid') &&
              status.balance <= 0) {
            statusMatch = true;
          }
          if (filter.selectedStatuses.contains('Due') && status.balance > 0) {
            statusMatch = true;
          }
          if (filter.selectedStatuses.contains('Overdue') &&
              status.totalMonths >= 6 &&
              status.balance > 0) {
            statusMatch = true; // Example 'Overdue' logic
          }

          if (!statusMatch) return false;
        }

        // 3. Due Amount Range
        // Only apply if looking for Dues
        if (status.balance > 0) {
          if (status.balance < filter.dueAmountRange.start ||
              status.balance > filter.dueAmountRange.end) {
            return false;
          }
        }

        // 4. Overdue Months
        if (filter.overdueMonthsMin > 0) {
          // Approximate months overdue logic: Balance / MonthlyAmount (assumed 100 or from config)
          // For simplicity, we can use totalMonths if they paid 0,
          // BUT better to rely on actual calc if we had per-month tracking.
          // Fallback: If balance > (filter.months * 100), assume they are that many months overdue.
          // Or strictly use the totalMonths field if that represents 'Active Months' vs 'Paid'.
          // Let's use: (Balance / 100) >= filter.months
          final assumedMonthlyAnd = 100.0; // Simplification
          final monthsPending = status.balance / assumedMonthlyAnd;
          if (monthsPending < filter.overdueMonthsMin) return false;
        }

        return true;
      }).toList();
    },
    loading: () => [],
    error: (e, s) => [],
  );
});
