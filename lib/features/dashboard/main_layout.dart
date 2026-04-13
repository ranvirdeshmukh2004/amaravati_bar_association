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
import '../sms/sms_dashboard.dart';
import 'widgets/app_sidebar.dart';
import '../../core/auth/app_session.dart';
import '../auth/environment_selection_dialog.dart';

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



// ... other imports ...

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {

  @override
  void initState() {
    super.initState();
    // Check if Viewer needs to select environment
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(appSessionProvider);
      if (session.role == UserRole.viewer) {
        showDialog(
          context: context,
          barrierDismissible: false, // Force selection
          builder: (_) => const EnvironmentSelectionDialog(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final curIndex = ref.watch(navigationProvider);
    final isViewer = ref.watch(appSessionProvider).role == UserRole.viewer;
    final isDevEnv = ref.watch(appSessionProvider).environment == AppEnvironment.dev;

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
              if (isViewer) return null; // Disable shortcut for Viewer
              ref.read(navigationProvider.notifier).state = 4;
              return null;
            },
          ),
          OpenSubscriptionEntryIntent:
              CallbackAction<OpenSubscriptionEntryIntent>(
                onInvoke: (OpenSubscriptionEntryIntent intent) {
                   if (isViewer) return null; // Disable shortcut for Viewer
                   ref.read(navigationProvider.notifier).state = 2;
                   return null;
                },
              ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            body: Column(
              children: [
                // Viewer / Environment Banner
                if (isViewer)
                  Container(
                    width: double.infinity,
                    color: isDevEnv ? Colors.orange : Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      isDevEnv 
                        ? "⚠️ VIEWER MODE (DEBUG DATA) - READ ONLY" 
                        : "👁️ VIEWER MODE (RELEASE DATA) - READ ONLY",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  
                Expanded(
                  child: Row(
                    children: [
                      AppSidebar(
                        selectedIndex: curIndex,
                        onDestinationSelected: (value) {
                          ref.read(navigationProvider.notifier).state = value;
                        },
                      ),
                      const VerticalDivider(thickness: 1, width: 1),
                      Expanded(
                        // Wrap body in permissions check or just let sidebar handle navigation
                        // and inner screens handle read-only state.
                        // We will start by letting them navigate inside.
                        child: _buildBody(curIndex), 
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
      case 10:
        return const SmsDashboardScreen(); 
      default:
        return const DashboardScreen();
    }
  }
}
