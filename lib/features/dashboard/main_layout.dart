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
import '../subscription/arrears_clearance_screen.dart';
import '../donation/donation_entry_screen.dart'; // Added this import

import '../subscription/subscription_dashboard_screen.dart';
import '../subscription/past_outstanding_screen.dart';
import 'widgets/app_sidebar.dart';

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
                AppSidebar(
                  selectedIndex: curIndex,
                  onDestinationSelected: (value) {
                    ref.read(navigationProvider.notifier).state = value;
                  },
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
      case 7:
        return const PastOutstandingScreen();
      case 8:
         return const ArrearsClearanceScreen();
      case 9:
        return const DonationEntryScreen();
      default:
        return const DashboardScreen();
    }
  }

}
