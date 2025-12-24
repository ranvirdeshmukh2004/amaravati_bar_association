import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants.dart';
import '../../../core/app_gradients.dart';
import '../../auth/auth_controller.dart';

class AppSidebar extends ConsumerStatefulWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  ConsumerState<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends ConsumerState<AppSidebar> {
  bool _isCollapsed = false;

  void _toggleSidebar() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = _isCollapsed ? 72.0 : 260.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: BoxDecoration(
         gradient: AppGradients.sidebar(context),
      ),
      child: Column(
        children: [
          // Header
          _SidebarHeader(
            isCollapsed: _isCollapsed,
            onToggle: _toggleSidebar,
          ),
          
          const Divider(height: 1),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildGroup(
                  title: 'Overview',
                  items: [
                    _SidebarItem(
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard,
                      label: 'Dashboard',
                      index: 0,
                      selectedIndex: widget.selectedIndex,
                      isCollapsed: _isCollapsed,
                      onTap: () => widget.onDestinationSelected(0),
                    ),
                  ],
                ),
                _buildGroup(
                  title: 'Subscriptions',
                  items: [
                    _SidebarItem(
                      icon: Icons.currency_rupee_outlined,
                      activeIcon: Icons.currency_rupee,
                      label: 'Subscription Status',
                      index: 1,
                      selectedIndex: widget.selectedIndex,
                      isCollapsed: _isCollapsed,
                      onTap: () => widget.onDestinationSelected(1),
                    ),
                    _SidebarItem(
                      icon: Icons.post_add_outlined,
                      activeIcon: Icons.post_add,
                      label: 'Subscription Entry',
                      index: 2,
                      selectedIndex: widget.selectedIndex,
                      isCollapsed: _isCollapsed,
                      onTap: () => widget.onDestinationSelected(2),
                    ),
                    _SidebarItem(
                      icon: Icons.receipt_long_outlined,
                      activeIcon: Icons.receipt_long,
                      label: 'Subscription Records',
                      index: 3,
                      selectedIndex: widget.selectedIndex,
                      isCollapsed: _isCollapsed,
                      onTap: () => widget.onDestinationSelected(3),
                    ),
                  ],
                ),
                _buildGroup(
                  title: 'Directory',
                  items: [
                    _SidebarItem(
                      icon: Icons.person_add_outlined,
                      activeIcon: Icons.person_add,
                      label: 'Add Member',
                      index: 4,
                      selectedIndex: widget.selectedIndex,
                      isCollapsed: _isCollapsed,
                      onTap: () => widget.onDestinationSelected(4),
                    ),
                    _SidebarItem(
                      icon: Icons.people_outline,
                      activeIcon: Icons.people,
                      label: 'Member Registry',
                      index: 5,
                      selectedIndex: widget.selectedIndex,
                      isCollapsed: _isCollapsed,
                      onTap: () => widget.onDestinationSelected(5),
                    ),
                  ],
                ),
                _buildGroup(
                  title: 'System',
                  items: [
                    _SidebarItem(
                      icon: Icons.settings_outlined,
                      activeIcon: Icons.settings,
                      label: 'Settings',
                      index: 6,
                      selectedIndex: widget.selectedIndex,
                      isCollapsed: _isCollapsed,
                      onTap: () => widget.onDestinationSelected(6),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Footer (User & Logout)
          _SidebarFooter(
            isCollapsed: _isCollapsed,
            onLogout: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup({required String title, required List<Widget> items}) {
    if (_isCollapsed) {
      return Column(children: items);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...items,
      ],
    );
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

class _SidebarHeader extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;

  const _SidebarHeader({required this.isCollapsed, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          const SizedBox(width: 12), 
          IconButton(
            onPressed: onToggle,
            icon: const Icon(Icons.menu),
            tooltip: isCollapsed ? 'Expand' : 'Collapse',
          ),
          // Animate Title
          Expanded(
              child: AnimatedOpacity(
                opacity: isCollapsed ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: isCollapsed ? const SizedBox() : Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                      'ADBA Subscription',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                   ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int selectedIndex;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;
    final theme = Theme.of(context);
    final primaryColor = AppConstants.primaryColor;
    
    // Always use the same container structure to prevent tree rebuilds
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Tooltip(
        message: isCollapsed ? label : '', // Only show tooltip when collapsed
        waitDuration: const Duration(milliseconds: 500),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                // Active Indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                ),
                // Icon Area
                const SizedBox(width: 12),
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 24,
                  color: isSelected ? primaryColor : theme.iconTheme.color,
                ),
                
                // Animate Text Visibility
                Expanded(
                  child: AnimatedOpacity(
                    opacity: isCollapsed ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: isCollapsed 
                      ? const SizedBox() 
                      : Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isSelected ? primaryColor : theme.textTheme.bodyMedium?.color,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onLogout;

  const _SidebarFooter({required this.isCollapsed, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.logoutArea(context),
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // User Info (Placeholder)
          InkWell(
             onTap: () {}, // Optional profile action
             borderRadius: BorderRadius.circular(4),
             child: Padding(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
               child: Row(
                 mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                 children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.person, color: Colors.grey, size: 20),
                    ),
                    if (!isCollapsed) 
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                               Text('Admin User', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                               Text('admin@adba.com', style: TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      )
                 ],
               ),
             ),
          ),
          
          const SizedBox(height: 8),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Tooltip(
               message: isCollapsed ? 'Logout' : '',
               child: InkWell(
                  onTap: onLogout,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                       mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                       children: [
                          const SizedBox(width: 4), // Align with item icons
                          const Icon(Icons.logout, color: Colors.red, size: 24),
                          Expanded(
                            child: AnimatedOpacity(
                              opacity: isCollapsed ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: isCollapsed ? const SizedBox() : const Padding( 
                                padding: EdgeInsets.only(left: 12),
                                child: Text(
                                  'Logout', 
                                  style: TextStyle(color: Colors.red, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ),
                       ],
                    ),
                  ),
               ),
            ),
          ),
        ],
      ),
    );
  }
}
