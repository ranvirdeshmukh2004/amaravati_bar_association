import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_provider.dart';

class DeveloperStats {
  final int totalMembers;
  final int activeMembers;
  final int totalSubscriptions;
  final double totalCollected; // From Yearly Summaries (Paid)
  final double totalPending;   // From Yearly Summaries (Balance)
  final double dbSizeInMB;
  final DateTime? lastBackupTime;

  const DeveloperStats({
    this.totalMembers = 0,
    this.activeMembers = 0,
    this.totalSubscriptions = 0,
    this.totalCollected = 0.0,
    this.totalPending = 0.0,
    this.dbSizeInMB = 0.0,
    this.lastBackupTime,
  });

  DeveloperStats copyWith({
    int? totalMembers,
    int? activeMembers,
    int? totalSubscriptions,
    double? totalCollected,
    double? totalPending,
    double? dbSizeInMB,
    DateTime? lastBackupTime,
  }) {
    return DeveloperStats(
      totalMembers: totalMembers ?? this.totalMembers,
      activeMembers: activeMembers ?? this.activeMembers,
      totalSubscriptions: totalSubscriptions ?? this.totalSubscriptions,
      totalCollected: totalCollected ?? this.totalCollected,
      totalPending: totalPending ?? this.totalPending,
      dbSizeInMB: dbSizeInMB ?? this.dbSizeInMB,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
    );
  }
}

final developerStatsProvider = StreamProvider.autoDispose<DeveloperStats>((ref) {
  final db = ref.watch(databaseProvider);
  
  // Combine streams using RxDart would be ideal, but for now we can yield simplified updates 
  // or just stream one struct if we compose them. 
  // Since StreamProvider doesn't easily support combineLatest without RxDart, 
  // Let's use a specialized Stream that merges these manually or listens to all.
  
  // A simpler approach for Riverpod:
  // Return a Stream that emits a new Stats object whenever any underlying stream emits.
  
  return Stream.multi((controller) {
      DeveloperStats currentStats = const DeveloperStats();

      // Helper to emit
      void emit() {
        controller.add(currentStats);
      }

      // Check DB Size (One off)
      try {
         // Assuming default drift storage location or mock for now
         // In a real scenario, we'd get the file path from the database connection logic
         // For now, we mock it or check a known path if available.
         // Let's set it to a static value or query it periodically.
         currentStats = currentStats.copyWith(dbSizeInMB: 5.2); // Placeholder
         emit();
      } catch (e) {
          // ignore
      }

      // 1. Members
      final s1 = db.membersDao.watchTotalMemberCount().listen((count) {
          currentStats = currentStats.copyWith(totalMembers: count);
          emit();
      });

      // 2. Active Members
      final s2 = db.membersDao.watchActiveMemberCount().listen((count) {
          currentStats = currentStats.copyWith(activeMembers: count);
          emit();
      });

      // 3. Subscriptions (Total Count)
      final s3 = db.subscriptionsDao.watchTotalSubscriptionCount().listen((count) {
          currentStats = currentStats.copyWith(totalSubscriptions: count);
          emit();
      });

      // 4. Annual Financials (Collected)
      final s4 = db.yearlySummariesDao.watchTotalCollectedAmount().listen((amount) {
           currentStats = currentStats.copyWith(totalCollected: amount);
           emit();
      });

      // 5. Annual Financials (Pending)
      final s5 = db.yearlySummariesDao.watchTotalPendingAmount().listen((amount) {
           currentStats = currentStats.copyWith(totalPending: amount);
           emit();
      });

      controller.onCancel = () {
        s1.cancel();
        s2.cancel();
        s3.cancel();
        s4.cancel();
        s5.cancel();
      };
  });
});

final rawTableDataProvider = FutureProvider.family.autoDispose<List<Map<String, Object?>>, String>((ref, tableName) async {
  final db = ref.watch(databaseProvider);
  
  // Sanitize input roughly, though this is internal dev tool
  // Drift customSelect takes a string. Only allow specific table names for safety.
  if (!['members', 'subscriptions', 'admin_settings', 'yearly_summaries', 'donations', 'past_outstanding_dues'].contains(tableName)) {
    throw Exception('Invalid table name');
  }
  
  // Use raw custom select
  final result = await db.customSelect('SELECT * FROM $tableName').get();
  return result.map((row) => row.data).toList();
});
