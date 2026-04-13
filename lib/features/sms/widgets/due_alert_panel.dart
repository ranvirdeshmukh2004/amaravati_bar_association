import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:amaravati_bar_association/features/database/app_database.dart';
import 'package:amaravati_bar_association/features/database/database_provider.dart';
import 'package:amaravati_bar_association/features/database/daos/past_outstanding_dao.dart';
import 'package:amaravati_bar_association/features/sms/sms_service.dart';
import '../../../core/auth/app_session.dart';

// Provider to fetch members with outstanding dues
final dueMembersProvider = StreamProvider<List<PastArrearWithMember>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.pastOutstandingDao.watchAllOutstandingWithMembers().map(
        (items) => items.where((item) => !item.arrear.isCleared).toList(),
      );
});

class DueAlertPanel extends ConsumerStatefulWidget {
  const DueAlertPanel({super.key});

  @override
  ConsumerState<DueAlertPanel> createState() => _DueAlertPanelState();
}

class _DueAlertPanelState extends ConsumerState<DueAlertPanel> {
  final Set<String> _selectedEnrollments = {};
  bool _selectAll = false;
  bool _isSending = false;

  // Template
  final _templateController = TextEditingController(
    text: "Dear {{Name}},\nYour outstanding amount is ₹{{Amount}} as of {{Date}}.\nKindly clear dues at the earliest.\n– Amaravati Bar Association"
  );
  bool _isEditingTemplate = false;

  void _handleSelectAll(List<PastArrearWithMember> items) {
     setState(() {
      if (_selectAll) {
        _selectedEnrollments.clear();
        _selectAll = false;
      } else {
        _selectedEnrollments.clear();
        for (var i in items) {
           _selectedEnrollments.add(i.arrear.enrollmentNumber);
        }
        _selectAll = true;
      }
    });
  }

  Future<void> _sendDueAlerts(List<PastArrearWithMember> allItems) async {
    if (_selectedEnrollments.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select members to send alerts to.')));
       return;
    }

    final selectedItems = allItems.where((i) => _selectedEnrollments.contains(i.arrear.enrollmentNumber)).toList();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Due Alerts'),
        content: Text('Send outstanding alerts to ${selectedItems.length} members?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Send Alerts')),
        ],
      ),
    );

    if (confirm != true) return;
    
    setState(() => _isSending = true);

    try {
      int successCount = 0;
      final dateStr = DateFormat('dd-MMM-yyyy').format(DateTime.now());

      for (var item in selectedItems) {
         if (item.member == null || item.member!.mobileNumber.isEmpty) continue;
         
         final name = '${item.member!.firstName} ${item.member!.surname}';
         final amount = item.arrear.amount.toStringAsFixed(0);
         
         String message = _templateController.text
           .replaceAll('{{Name}}', name)
           .replaceAll('{{Amount}}', amount)
           .replaceAll('{{Date}}', dateStr);

         await ref.read(smsServiceProvider).sendSms(
           numbers: [item.member!.mobileNumber],
           message: message,
           type: 'alert',
         );
         successCount++;
      }
      
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sent $successCount alerts.')));
      
      setState(() {
        _selectedEnrollments.clear();
        _selectAll = false;
      });

    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }



// ... class ...
  @override
  Widget build(BuildContext context) {
    final duesAsync = ref.watch(dueMembersProvider);
    final theme = Theme.of(context);
    final isViewer = ref.watch(appSessionProvider).role == UserRole.viewer;

    return Column(
      children: [
        // Top: Template Editor
        Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Message Template', style: theme.textTheme.titleMedium),
                    TextButton.icon(
                      icon: Icon(_isEditingTemplate ? Icons.check : Icons.edit),
                      label: Text(_isEditingTemplate ? 'Done' : 'Edit'),
                      onPressed: isViewer ? null : () => setState(() => _isEditingTemplate = !_isEditingTemplate),
                    )
                  ],
                ),
                if (_isEditingTemplate) 
                  TextField(
                    controller: _templateController,
                    maxLines: 3,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Template...'),
                  )
                else
                   Container(
                     padding: const EdgeInsets.all(8),
                     width: double.infinity,
                     decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
                     child: Text(_templateController.text, style: const TextStyle(fontFamily: 'monospace')),
                   )
              ],
            ),
          ),
        ),

        // Bottom: Member List
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(8),
            child: duesAsync.when(
              data: (items) {
                 if (items.isEmpty) return const Center(child: Text('No outstanding dues found.'));
                 
                 return Column(
                   children: [
                      CheckboxListTile(
                        title: const Text('Select All Candidates'),
                        value: _selectAll,
                        onChanged: isViewer ? null : (val) => _handleSelectAll(items),
                        controlAffinity: ListTileControlAffinity.leading,
                        secondary: ElevatedButton.icon(
                          onPressed: (_isSending || isViewer) ? null : () => _sendDueAlerts(items),
                          icon: _isSending 
                            ? const SizedBox(width:16, height:16, child: CircularProgressIndicator(strokeWidth:2)) 
                            : (isViewer ? const Icon(Icons.block) : const Icon(Icons.send)),
                          label: Text(isViewer ? 'Disabled' : 'Send Alerts'),
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final member = item.member;
                            if (member == null) return const SizedBox.shrink();

                            final isSelected = _selectedEnrollments.contains(item.arrear.enrollmentNumber);
                            
                            return CheckboxListTile(
                              value: isSelected,
                              onChanged: isViewer ? null : (val) {
                                setState(() {
                                  if (isSelected) {
                                    _selectedEnrollments.remove(item.arrear.enrollmentNumber);
                                  } else {
                                    _selectedEnrollments.add(item.arrear.enrollmentNumber);
                                  }
                                  _selectAll = false;
                                });
                              },
                              title: Text('${member.firstName} ${member.surname}'),
                              subtitle: Text('Due: ₹${item.arrear.amount} • ${item.arrear.periodLabel}'),
                              secondary: member.mobileNumber.isEmpty 
                                ? const Tooltip(message: 'No Mobile', child: Icon(Icons.error_outline, color: Colors.red))
                                : const Icon(Icons.smartphone, color: Colors.green),
                            );
                          },
                        ),
                      ),
                   ],
                 );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ),
      ],
    );
  }
}

