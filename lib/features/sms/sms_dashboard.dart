import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import 'widgets/custom_sms_panel.dart';
import 'widgets/due_alert_panel.dart';

class SmsDashboardScreen extends ConsumerStatefulWidget {
  const SmsDashboardScreen({super.key});

  @override
  ConsumerState<SmsDashboardScreen> createState() => _SmsDashboardScreenState();
}

class _SmsDashboardScreenState extends ConsumerState<SmsDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Notifications'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Custom SMS', icon: Icon(Icons.message)),
            Tab(text: 'Outstanding Dues Alert', icon: Icon(Icons.notification_important)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CustomSmsPanel(),
          DueAlertPanel(),
        ],
      ),
    );
  }
}
