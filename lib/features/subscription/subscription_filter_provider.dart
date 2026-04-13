import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'subscription_service.dart';

class SubscriptionFilterState {
  final List<String> selectedStatuses; // ['Paid', 'Due', 'Overdue']
  
  // Due Amount
  final bool isDueAmountRangeEnabled;
  final RangeValues dueAmountRange;
  
  // Overdue Duration
  final bool isOverdueMonthsEnabled;
  final double overdueMonthsMin;
  
  final String searchQuery;
  final bool showDefaultersOnly; 
  final DateTime? calculationDate;

  const SubscriptionFilterState({
    this.selectedStatuses = const [],
    this.isDueAmountRangeEnabled = false,
    this.dueAmountRange = const RangeValues(0, 10000),
    this.isOverdueMonthsEnabled = false,
    this.overdueMonthsMin = 0,
    this.searchQuery = '',
    this.showDefaultersOnly = false,
    this.calculationDate,
  });

  SubscriptionFilterState copyWith({
    List<String>? selectedStatuses,
    bool? isDueAmountRangeEnabled,
    RangeValues? dueAmountRange,
    bool? isOverdueMonthsEnabled,
    double? overdueMonthsMin,
    String? searchQuery,
    bool? showDefaultersOnly,
    DateTime? calculationDate,
  }) {
    return SubscriptionFilterState(
      selectedStatuses: selectedStatuses ?? this.selectedStatuses,
      isDueAmountRangeEnabled: isDueAmountRangeEnabled ?? this.isDueAmountRangeEnabled,
      dueAmountRange: dueAmountRange ?? this.dueAmountRange,
      isOverdueMonthsEnabled: isOverdueMonthsEnabled ?? this.isOverdueMonthsEnabled,
      overdueMonthsMin: overdueMonthsMin ?? this.overdueMonthsMin,
      searchQuery: searchQuery ?? this.searchQuery,
      showDefaultersOnly: showDefaultersOnly ?? this.showDefaultersOnly,
      calculationDate: calculationDate ?? this.calculationDate,
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

  void toggleDueAmountRange(bool enabled) {
    state = state.copyWith(isDueAmountRangeEnabled: enabled);
  }

  void updateDueAmountRange(RangeValues range) {
    state = state.copyWith(dueAmountRange: range);
  }

  void toggleOverdueMonths(bool enabled) {
    state = state.copyWith(isOverdueMonthsEnabled: enabled);
  }

  void updateOverdueMonthsMin(double months) {
    state = state.copyWith(overdueMonthsMin: months);
  }

  void updateCalculationDate(DateTime? date) {
    state = state.copyWith(calculationDate: date);
  }

  void reset() {
    state = const SubscriptionFilterState();
  }
}

final subscriptionFilterProvider =
    StateNotifierProvider.autoDispose<SubscriptionFilterNotifier, SubscriptionFilterState>((
      ref,
    ) {
      return SubscriptionFilterNotifier();
    });

// Primary Status Provider (Filtered by Calculation Date)
final subscriptionStatusProvider = Provider.autoDispose<AsyncValue<List<SubscriptionStatus>>>((
  ref,
) {
  final filter = ref.watch(subscriptionFilterProvider);
  final rawDataAsync = ref.watch(rawSubscriptionDataProvider);

  return rawDataAsync.whenData((rawData) {
    return ref.read(subscriptionServiceProvider).calculateStatuses(
      rawData,
      calculationEndDate: filter.calculationDate,
    );
  });
});

// Dependent provider to filter the list
final filteredSubscriptionStatusProvider = Provider.autoDispose<List<SubscriptionStatus>>((
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

        // 3. Due Amount Range (Only if enabled)
        if (filter.isDueAmountRangeEnabled) {
          // If filtering by amount, we imply we only care about positive balances (or negative if range allows)
          // Usually range filters imply "Between X and Y"
          if (status.balance < filter.dueAmountRange.start ||
              status.balance > filter.dueAmountRange.end) {
            return false;
          }
        }

        // 4. Overdue Months (Only if enabled)
        if (filter.isOverdueMonthsEnabled && filter.overdueMonthsMin > 0) {
          final assumedMonthlyAnd = 100.0; // Simplification
          // Protect against divide by zero if amount is 0, though normally expected shouldn't be 0
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
