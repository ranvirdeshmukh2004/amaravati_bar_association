import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../auth/auth_controller.dart';
import 'dashboard_screen.dart';
import '../subscription/subscription_form_screen.dart';
import '../records/records_screen.dart';
import '../settings/settings_screen.dart';
import '../members/member_form_screen.dart';
import '../members/member_list_screen.dart';

import '../subscription/subscription_dashboard_screen.dart';

import 'package:flutter/services.dart';

// Update items count and switch logic
final navigationProvider = StateProvider<int>((ref) => 0);

// ... existing imports ...

// Intents
class OpenAddMemberIntent extends Intent {
  const OpenAddMemberIntent();
}

class OpenSubscriptionEntryIntent extends Intent {
  const OpenSubscriptionEntryIntent();
}

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curIndex = ref.watch(navigationProvider);

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.keyM, control: true):
            const OpenAddMemberIntent(),
        const SingleActivator(LogicalKeyboardKey.keyS, control: true):
            const OpenSubscriptionEntryIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          OpenAddMemberIntent: CallbackAction<OpenAddMemberIntent>(
            onInvoke: (OpenAddMemberIntent intent) {
              ref.read(navigationProvider.notifier).state = 4;
              return null;
            },
          ),
          OpenSubscriptionEntryIntent:
              CallbackAction<OpenSubscriptionEntryIntent>(
                onInvoke: (OpenSubscriptionEntryIntent intent) {
                  ref.read(navigationProvider.notifier).state = 2;
                  return null;
                },
              ),
        },
        child: Focus(
          // Add Focus scope to ensure shortcuts work
          autofocus: true,
          child: Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: curIndex,
                  onDestinationSelected: (value) {
                    if (value == 7) {
                      // Updated logout index
                      _showLogoutDialog(context, ref);
                    } else {
                      ref.read(navigationProvider.notifier).state = value;
                    }
                  },
                  extended: true,
                  minExtendedWidth: 200,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Icon(
                      Icons.account_balance,
                      size: 48,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.monetization_on_outlined),
                      selectedIcon: Icon(Icons.monetization_on),
                      label: Text('Subscription status'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite_border),
                      selectedIcon: Icon(Icons.favorite),
                      label: Text('Subscription Entry'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.receipt_long_outlined),
                      selectedIcon: Icon(Icons.receipt_long),
                      label: Text('Subscription Records'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_add_outlined),
                      selectedIcon: Icon(Icons.person_add),
                      label: Text('Add Member'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people_outline),
                      selectedIcon: Icon(Icons.people),
                      label: Text('Member Registry'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Settings'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.logout, color: Colors.red),
                      label: Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: _buildBody(curIndex)),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // ... existing code ...

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const SubscriptionDashboardScreen();
      case 2:
        return const SubscriptionFormScreen();
      case 3:
        return const RecordsScreen();
      case 4:
        return const MemberFormScreen();
      case 5:
        return const MemberListScreen();
      case 6:
        return const SettingsScreen();
      default:
        return const DashboardScreen();
    }
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
