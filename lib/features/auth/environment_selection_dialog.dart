import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/app_session.dart';
import '../database/database_provider.dart';
import '../sync/sync_service.dart';

class EnvironmentSelectionDialog extends ConsumerStatefulWidget {
  const EnvironmentSelectionDialog({super.key});

  @override
  ConsumerState<EnvironmentSelectionDialog> createState() => _EnvironmentSelectionDialogState();
}

class _EnvironmentSelectionDialogState extends ConsumerState<EnvironmentSelectionDialog> {
  bool _isSwitching = false;

  Future<void> _switchEnvironment(AppEnvironment env) async {
    setState(() => _isSwitching = true);

    try {
      // 1. Wipe Local Data
      final db = ref.read(databaseProvider);
      await db.wipeLocalDatabase();

      // 2. Set New Environment (this triggers SyncService path update)
      ref.read(appSessionProvider.notifier).setEnvironment(env);

      // 3. Reset Sync Status (force fresh pull)
      // 3. Reset Sync Status (force fresh pull)
      await ref.read(syncServiceProvider).resetSyncTimestamp();
      
      // 4. Close Dialog
      if (mounted) Navigator.of(context).pop();

      // 5. Trigger Sync (optional, SyncService auto-starts)
      ref.read(syncServiceProvider).startAutoSync();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to switch: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSwitching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSwitching) {
      return const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             CircularProgressIndicator(),
             SizedBox(height: 16),
             Text("Switching Environment & Clearing Data..."),
          ],
        ),
      );
    }

    return AlertDialog(
      title: const Text('Select Viewer Mode'),
      content: const Text(
        'Please choose which data source to view.\n\n'
        '⚠️ Switching environments will generic clear local data cache and re-download fresh data.',
      ),
      actions: [
        TextButton(
          onPressed: () => _switchEnvironment(AppEnvironment.prod),
          child: const Text('Release View (Live Data)'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          onPressed: () => _switchEnvironment(AppEnvironment.dev),
          child: const Text('Debug View (Dev Data)'),
        ),
      ],
    );
  }
}
