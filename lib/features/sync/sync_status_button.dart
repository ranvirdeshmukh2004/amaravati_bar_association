import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sync_service.dart';
import 'sync_dashboard_screen.dart';

class SyncStatusButton extends ConsumerStatefulWidget {
  const SyncStatusButton({super.key});

  @override
  ConsumerState<SyncStatusButton> createState() => _SyncStatusButtonState();
}

class _SyncStatusButtonState extends ConsumerState<SyncStatusButton> with SingleTickerProviderStateMixin {
  bool _isSyncing = false;
  bool _hasError = false;
  bool _justCompleted = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(seconds: 1), vsync: this
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _triggerSync() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
      _hasError = false;
      _justCompleted = false;
    });
    _controller.repeat();

    try {
      final syncService = ref.read(syncServiceProvider);
      final result = await syncService.syncData();
      
      if (mounted) {
        setState(() {
          _isSyncing = false;
          // Only show green check if actual success
          _justCompleted = (result == SyncResult.success);
          // Show red cross if no network or failed
          _hasError = (result == SyncResult.skippedNoNetwork || result == SyncResult.failed);
        });
        _controller.stop();
        _controller.reset();
        
        // Auto-reset state after 2 seconds
        if (_justCompleted || _hasError) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
               setState(() {
                 _justCompleted = false;
                 _hasError = false;
               });
            }
          });
        }

        // Show appropriate message
        switch (result) {
          case SyncResult.success:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Sync Successful!'), backgroundColor: Colors.green),
            );
            break;
          case SyncResult.skippedNoNetwork:
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cannot Sync: Connect to internet and Sync again'), 
                backgroundColor: Colors.red
              ),
            );
            break;
          case SyncResult.skippedInProgress:
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('⏳ Sync already in progress'), backgroundColor: Colors.blue),
            );
            break;
           case SyncResult.failed:
             // Handled by catch block normally, but if syncData returns failed explicitly:
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('❌ Sync Encountered Errors (Check Logs)'), backgroundColor: Colors.red),
            );
            break;
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _hasError = true;
        });
        _controller.stop();
        _controller.reset();
        
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('❌ Sync Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      // Navigate to detailed dashboard on long press
      onPressed: _triggerSync,
      icon: GestureDetector(
          onLongPress: () {
             Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SyncDashboardScreen()));
          },
          child: _buildIcon(),
      ),
      tooltip: 'Sync Data (Long press for Details)',
    );
  }

  Widget _buildIcon() {
    if (_isSyncing) {
      return RotationTransition(
        turns: _controller,
        child: const Icon(Icons.sync, color: Colors.blueAccent),
      );
    }
    if (_justCompleted) {
      return const Icon(Icons.check_circle, color: Colors.greenAccent);
    }
    if (_hasError) {
      return const Icon(Icons.sync_problem, color: Colors.redAccent);
    }
    return const Icon(Icons.cloud_sync, color: Colors.white70);
  }
}
