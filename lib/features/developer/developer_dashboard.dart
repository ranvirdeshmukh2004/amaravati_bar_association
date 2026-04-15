import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../auth/auth_controller.dart';
import 'developer_controller.dart';
import 'backup_service.dart';
import 'package:intl/intl.dart';

class DeveloperDashboard extends ConsumerStatefulWidget {
  const DeveloperDashboard({super.key});

  @override
  ConsumerState<DeveloperDashboard> createState() => _DeveloperDashboardState();
}

class _DeveloperDashboardState extends ConsumerState<DeveloperDashboard> {
  // Toggles for sections
  bool _showTopMetrics = true;
  bool _showAdminPanel = false;
  bool _showBackupPanel = false;
  bool _showDataPanel = false;
  
  // Theme Constants
  final Color _bgColor = Colors.black;
  final Color _cardColor = const Color(0xFF1E1E1E); // Dark Grey
  final Color _accentColor = Colors.greenAccent; // Matrix Green
  final TextStyle _monoStyle = const TextStyle(fontFamily: 'RobotoMono', color: Colors.white);
  
  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(developerStatsProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text('DEVELOPER CONSOLE [ROOT ACCESS]', style: _monoStyle.copyWith(fontWeight: FontWeight.bold, color: _accentColor)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: _accentColor),
        bottom: PreferredSize(
           preferredSize: Size.fromHeight(1),
           child: Container(color: _accentColor, height: 1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Exit Developer Mode',
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
         padding: const EdgeInsets.all(16),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             _buildSectionHeader('SYSTEM METRICS', _showTopMetrics, (v) => setState(() => _showTopMetrics = v)),
             if (_showTopMetrics) 
               statsAsync.when(
                 data: (stats) => _buildTopMetrics(stats),
                 loading: () => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator(color: Colors.greenAccent))),
                 error: (err, stack) => Text('Error: $err', style: const TextStyle(color: Colors.red)),
               ),
             
             const SizedBox(height: 16),
             _buildSectionHeader('ADMIN ACCOUNTS', _showAdminPanel, (v) => setState(() => _showAdminPanel = v)),
             if (_showAdminPanel) _buildAdminPanel(context, ref),
             
             const SizedBox(height: 16),
             _buildSectionHeader('BACKUP & RECOVERY', _showBackupPanel, (v) => setState(() => _showBackupPanel = v)),
             if (_showBackupPanel) _buildBackupPanel(ref),

             const SizedBox(height: 16),
             _buildSectionHeader('COMPLETE DATA INSPECTOR', _showDataPanel, (v) => setState(() => _showDataPanel = v)),
             if (_showDataPanel) _buildDataInspectorPanel(ref),
           ],
         ),
      ),
    );
  }

  Widget _buildAdminPanel(BuildContext context, WidgetRef ref) {
    return Container(
      color: _cardColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CURRENT ADMIN CREDENTIALS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: _accentColor)),
          const SizedBox(height: 12),
          Table(
             border: TableBorder.all(color: Colors.grey[800]!),
             columnWidths: const {0: FixedColumnWidth(150), 1: FlexColumnWidth()},
             children: [
               _buildTableRow('Username', 'admin'),
               _buildTableRow('Role', 'Super Administrator'),
               _buildPasswordRow(ref),
               _buildTableRow('Security Question', 'Configured (Hidden)'),
             ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _showResetPasswordDialog(context, ref),
                icon: const Icon(Icons.lock_reset, size: 18),
                label: const Text('FORCE RESET PASSWORD'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
              ),
              const SizedBox(width: 16),
              const Text('This will override the current admin password immediately.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70))),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(value, style: _monoStyle)),
      ],
    );
  }

  TableRow _buildPasswordRow(WidgetRef ref) {
    return TableRow(
      children: [
        const Padding(padding: EdgeInsets.all(8.0), child: Text('Password', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70))),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<String?>(
            future: ref.read(authProvider.notifier).getAdminPassword(),
            builder: (context, snapshot) {
               if (!snapshot.hasData) return const Text('Loading...', style: TextStyle(color: Colors.grey));
               final pass = snapshot.data!;
               return Row(
                 children: [
                   Text('•' * pass.length, style: _monoStyle.copyWith(letterSpacing: 2)),
                   const SizedBox(width: 8),
                   const Text('(Use "Reveal" in DB tools to view)', style: TextStyle(color: Colors.grey, fontSize: 10, fontStyle: FontStyle.italic)),
                 ],
               );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showResetPasswordDialog(BuildContext context, WidgetRef ref) async {
      final controller = TextEditingController();
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
           backgroundColor: Colors.grey[900],
           title: Text('Force Reset Password', style: TextStyle(color: _accentColor)),
           content: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               const Text('Enter new password for the Admin account:', style: TextStyle(fontSize: 12, color: Colors.white)),
               const SizedBox(height: 8),
               TextField(
                 controller: controller, 
                 obscureText: false, 
                 style: const TextStyle(color: Colors.white),
                 cursorColor: _accentColor,
                 decoration: InputDecoration(
                   border: OutlineInputBorder(borderSide: BorderSide(color: _accentColor)),
                   enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[800]!)),
                   focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _accentColor)),
                   hintText: 'New Password',
                   hintStyle: const TextStyle(color: Colors.grey),
                  ),
               ),
             ],
           ),
           actions: [
             TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
             FilledButton(
               style: FilledButton.styleFrom(backgroundColor: Colors.red),
               onPressed: () async {
                  if (controller.text.isNotEmpty) {
                      await ref.read(authProvider.notifier).resetPassword(controller.text);
                     if (context.mounted) {
                       Navigator.pop(context);
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password Reset Successfully')));
                     }
                  }
               }, 
               child: const Text('RESET NOW'),
             ),
           ],
        ),
      );
  }

  Widget _buildBackupPanel(WidgetRef ref) {
    return Container(
      color: _cardColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'These operations interact directly with the database file. Ensure no other users are active.',
                  style: TextStyle(color: Colors.orange[300], fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
               Expanded(
                 child: _buildActionCard(
                   icon: Icons.download,
                   title: 'CREATE BACKUP',
                   desc: 'Export database (.sqlite) to safe location.',
                   color: Colors.blueAccent,
                   onTap: () => _handleBackup(ref),
                 ),
               ),
               const SizedBox(width: 16),
               Expanded(
                 child: _buildActionCard(
                   icon: Icons.upload,
                   title: 'RESTORE DATABASE',
                   desc: 'Replace current DB with a backup file.',
                   color: Colors.redAccent,
                   onTap: () => _handleRestore(ref),
                 ),
               ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Data Inspector ---
  
  String _selectedTable = 'members';
  
  Widget _buildDataInspectorPanel(WidgetRef ref) {
     final dataAsync = ref.watch(rawTableDataProvider(_selectedTable));
     
     return Container(
       color: _cardColor,
       padding: const EdgeInsets.all(16),
       height: 500, // Fixed height for scrolling
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Row(
             children: [
               Text('SELECT TABLE: ', style: TextStyle(fontWeight: FontWeight.bold, color: _accentColor)),
               const SizedBox(width: 16),
               DropdownButton<String>(
                 value: _selectedTable,
                 dropdownColor: Colors.grey[900],
                 style: const TextStyle(color: Colors.white),
                 items: const [
                   DropdownMenuItem(value: 'members', child: Text('Members')),
                   DropdownMenuItem(value: 'subscriptions', child: Text('Subscriptions (Receipts)')),
                   DropdownMenuItem(value: 'yearly_summaries', child: Text('Yearly Summaries')),
                   DropdownMenuItem(value: 'admin_settings', child: Text('Admin Settings')),
                   DropdownMenuItem(value: 'donations', child: Text('Donations')),
                   DropdownMenuItem(value: 'past_outstanding_dues', child: Text('Past Outstanding Dues')),
                 ],
                 onChanged: (v) {
                   if (v != null) setState(() => _selectedTable = v);
                 },
               ),
               const Spacer(),
               IconButton(onPressed: () => ref.refresh(rawTableDataProvider(_selectedTable)), icon: Icon(Icons.refresh, color: _accentColor)),
             ],
           ),
           Divider(color: Colors.grey[800]),
           Expanded(
             child: dataAsync.when(
               data: (data) {
                 if (data.isEmpty) return const Center(child: Text('No records found.', style: TextStyle(color: Colors.grey)));
                 // Extract columns from first row
                 final columns = data.first.keys.toList();
                 return Theme(
                   data: Theme.of(context).copyWith(dividerColor: Colors.grey[700], 
                     dataTableTheme: DataTableThemeData(
                       headingTextStyle: TextStyle(color: _accentColor, fontWeight: FontWeight.bold),
                       dataTextStyle: _monoStyle.copyWith(fontSize: 12),
                     )
                   ),
                   child: SingleChildScrollView(
                     scrollDirection: Axis.vertical,
                     child: SingleChildScrollView(
                       scrollDirection: Axis.horizontal,
                       child: DataTable(
                         columns: columns.map((c) => DataColumn(label: Text(c))).toList(),
                         rows: data.map((row) {
                           return DataRow(
                             cells: columns.map((c) {
                               final val = row[c];
                               String displayCheck = '$val';
                               if (val is DateTime) displayCheck = DateFormat('yyyy-MM-dd HH:mm').format(val);
                               return DataCell(Text(displayCheck));
                             }).toList(),
                           );
                         }).toList(),
                       ),
                     ),
                   ),
                 );
               },
               loading: () => Center(child: CircularProgressIndicator(color: _accentColor)),
               error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
             ),
           ),
         ],
       ),
     );
  }

  
  Widget _buildActionCard({required IconData icon, required String title, required String desc, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
          color: color.withOpacity(0.1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBackup(WidgetRef ref) async {
    try {
      final path = await ref.read(backupServiceProvider).createBackup();
      if (path != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup saved to: $path'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _handleRestore(WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('CRITICAL WARNING', style: TextStyle(color: Colors.red)),
        content: const Text('Restoring a database will PERMANENTLY OVERWRITE all current data.\n\nAre you absolutely sure?\n\nThe application will need to restart.', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('CANCEL')),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(c, true), child: const Text('OVERWRITE & RESTORE')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await ref.read(backupServiceProvider).restoreBackup();
        if (success && mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restore Successful. Restarting...'), backgroundColor: Colors.green));
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Restore Failed: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  Widget _buildSectionHeader(String title, bool isExpanded, ValueChanged<bool> onToggle) {
    return InkWell(
      onTap: () => onToggle(!isExpanded),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(bottom: BorderSide(color: _accentColor, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(color: _accentColor, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontFamily: 'RobotoMono')),
            Icon(isExpanded ? Icons.remove : Icons.add, color: _accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildTopMetrics(DeveloperStats stats) {
    final curFormat = NumberFormat.currency(locale: "en_IN", symbol: "₹", decimalDigits: 0);

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.0,
      padding: const EdgeInsets.only(top: 16),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMetricCard('TOTAL MEMBERS', '${stats.totalMembers}', Colors.blueAccent),
        _buildMetricCard('ACTIVE MEMBERS', '${stats.activeMembers}', Colors.greenAccent),
        _buildMetricCard('TOTAL RECEIPTS', '${stats.totalSubscriptions}', Colors.purpleAccent),
        _buildMetricCard('DB SIZE (EST)', '${stats.dbSizeInMB.toStringAsFixed(1)} MB', Colors.cyanAccent),
        
        _buildMetricCard('TOTAL COLLECTED', curFormat.format(stats.totalCollected), Colors.tealAccent),
        _buildMetricCard('TOTAL PENDING', curFormat.format(stats.totalPending), Colors.orangeAccent),
        _buildMetricCard('LAST BACKUP', '2h ago', Colors.grey),
        _buildMetricCard('SYSTEM HEALTH', '98%', Colors.lightGreenAccent),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    // For Matrix/Dark theme, we use black cards with colored borders
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
         color: _cardColor,
         border: Border(left: BorderSide(color: color, width: 4)),
         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value, style: _monoStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
