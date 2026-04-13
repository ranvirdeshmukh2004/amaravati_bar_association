import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'sync_service.dart';
import '../../core/app_gradients.dart';

class SyncDashboardScreen extends ConsumerWidget {
  const SyncDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sync Status & Diagnostics')),
      body: Container(
        decoration: BoxDecoration(gradient: AppGradients.dashboardBackground(context)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatusCard(context, ref),
              const SizedBox(height: 24),
              Expanded(
                child: Row(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Expanded(child: _buildPendingChangesPanel(context)),
                     const SizedBox(width: 24),
                     Expanded(child: _buildLogPanel(context)),
                   ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, WidgetRef ref) {
    // This could watch a provider for real-time status
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
               width: 60, height: 60,
               decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
               child: const Icon(Icons.cloud_done, color: Colors.green, size: 30),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('System Status: Online', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                // Placeholder for last sync time, ideally fetched from shared prefs
                const Text('Last Sync: Just Now', style: TextStyle(color: Colors.grey)),
              ],
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Triggering Sync...')));
                  try {
                    await ref.read(syncServiceProvider).syncData();
                    if(context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sync Complete!'), backgroundColor: Colors.green));
                    }
                  } catch (e) {
                     if(context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sync Failed: $e'), backgroundColor: Colors.red));
                    }
                  }
              }, 
              icon: const Icon(Icons.sync), 
              label: const Text('Force Sync Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingChangesPanel(BuildContext context) {
    return Card(
      child: Padding(
         padding: const EdgeInsets.all(16),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
              Row(children: [Icon(Icons.upload, color: Colors.orange), SizedBox(width: 8), Text("Pending Changes", style: TextStyle(fontWeight: FontWeight.bold))]),
              Divider(),
              // Placeholder list
              ListTile(title: Text("Pending Uploads: 0"), subtitle: Text("All local changes sourced to cloud.")),
           ],
         ),
      ),
    );
  }

  Widget _buildLogPanel(BuildContext context) {
    return Card(
      child: Padding(
         padding: const EdgeInsets.all(16),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
              Row(children: [Icon(Icons.history, color: Colors.blue), SizedBox(width: 8), Text("Recent Activity Logs", style: TextStyle(fontWeight: FontWeight.bold))]),
              Divider(),
              // Placeholder list
              Expanded(
                child: ListView(
                  children: const [
                     ListTile(leading: Icon(Icons.check, size: 16, color: Colors.green), title: Text("Sync completed successfully"), trailing: Text("12:05 PM")),
                     ListTile(leading: Icon(Icons.check, size: 16, color: Colors.green), title: Text("Push: 2 Members updated"), trailing: Text("11:30 AM")),
                  ],
                ),
              ),
           ],
         ),
      ),
    );
  }
}
