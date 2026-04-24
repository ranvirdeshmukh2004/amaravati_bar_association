import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import 'package:printing/printing.dart';
import '../../core/constants.dart';
import '../../core/app_gradients.dart';
import '../database/database_provider.dart';
import '../database/app_database.dart';
import '../database/daos/past_outstanding_dao.dart';
import '../receipt/receipt_service.dart';
import '../../core/widgets/responsive_split_view.dart';

class PastOutstandingScreen extends ConsumerStatefulWidget {
  const PastOutstandingScreen({super.key});

  @override
  ConsumerState<PastOutstandingScreen> createState() => _PastOutstandingScreenState();
}

class _PastOutstandingScreenState extends ConsumerState<PastOutstandingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _periodController = TextEditingController();
  final _notesController = TextEditingController();

  Member? _selectedMember;
  String _type = 'Subscription Areaars';
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _periodController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedMember == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a member')));
        return;
      }

      final confirm = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Confirm Arrears Addition'),
          content: Text(
            'Add ₹${_amountController.text} as Past Outstanding for ${_selectedMember!.firstName}?\n\nThis will permanently increase their Total Due.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
            FilledButton(
               onPressed: () => Navigator.pop(c, true),
               child: const Text('Confirm'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      setState(() => _isLoading = true);

      try {
        final db = ref.read(databaseProvider);
        await db.pastOutstandingDao.insertOutstanding(
          PastOutstandingDuesCompanion.insert(
            enrollmentNumber: _selectedMember!.registrationNumber,
            amount: double.parse(_amountController.text),
            periodLabel: _periodController.text,
            type: _type,
            notes: drift.Value(_notesController.text.isEmpty ? null : _notesController.text),
          ),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Past Outstanding Added Successfully'), backgroundColor: Colors.green));
          _clearForm();
          // Refresh provider? The stream should auto-update.
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _clearForm() {
    _amountController.clear();
    _periodController.clear();
    _notesController.clear();
    setState(() {
      _selectedMember = null;
      _type = 'Subscription Areaars';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Past Outstanding Management')),
      body: ResponsiveSplitView(
        left: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               _buildMemberSearchCard(),
               const SizedBox(height: 24),
               _buildDetailsCard(),
               const SizedBox(height: 24),
               SizedBox(
                 height: 50,
                 child: FilledButton.icon(
                   icon: const Icon(Icons.add_task),
                   label: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('ADD PAST OUTSTANDING'),
                   style: FilledButton.styleFrom(backgroundColor: Colors.orange[800]),
                   onPressed: _isLoading ? null : _submit,
                 ),
               ),
            ],
          ),
        ),
        right: _buildRecentList(),
      ),
    );
  }

  Widget _buildMemberSearchCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('1. Select Member', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            if (_selectedMember == null)
              Consumer(
                builder: (context, ref, child) {
                  return Autocomplete<Member>(
                    optionsBuilder: (textEditingValue) async {
                      if (textEditingValue.text.isEmpty) return const Iterable<Member>.empty();
                      final db = ref.read(databaseProvider);
                      return await db.membersDao.searchMembers(textEditingValue.text, onlyActive: false);
                    },
                    displayStringForOption: (option) => '${option.firstName} ${option.surname} - ${option.registrationNumber}',
                    onSelected: (selection) => setState(() => _selectedMember = selection),
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        onFieldSubmitted: (_) => onFieldSubmitted(),
                        decoration: const InputDecoration(
                          labelText: 'Search Member',
                          hintText: 'Name, Mobile, or Reg No',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            child: SizedBox(
                              width: 300,
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  return ListTile(
                                    title: Text('${option.firstName} ${option.surname}'),
                                    subtitle: Text(option.registrationNumber),
                                    onTap: () => onSelected(option),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                    },
                  );
                },
              )
            else
              Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                 ),
                 child: Row(
                   children: [
                     Container(
                       width: 40,
                       height: 40,
                       decoration: BoxDecoration(
                         color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(4),
                       ),
                       child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                     ),
                     const SizedBox(width: 12),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text('${_selectedMember!.firstName} ${_selectedMember!.surname}', style: const TextStyle(fontWeight: FontWeight.bold)),
                           Text('Reg: ${_selectedMember!.registrationNumber}'),
                         ],
                       ),
                     ),
                     IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _selectedMember = null)),
                   ],
                 ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const Text('2. Arrears Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
             const SizedBox(height: 16),
             Row(
               children: [
                 Expanded(
                   child: DropdownButtonFormField<String>(
                     isExpanded: true,
                     value: _type,
                     decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                     items: const [
                       DropdownMenuItem(value: 'Subscription Areaars', child: Text('Subscription Arrears')),
                       DropdownMenuItem(value: 'Donation Pending', child: Text('Donation Pending')),
                       DropdownMenuItem(value: 'Penalty', child: Text('Penalty')),
                       DropdownMenuItem(value: 'Other', child: Text('Other')),
                     ],
                     onChanged: (v) => setState(() => _type = v!),
                   ),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: TextFormField(
                     controller: _amountController,
                     keyboardType: TextInputType.number,
                     decoration: const InputDecoration(labelText: 'Amount (₹) *', border: OutlineInputBorder(), prefixText: '₹ '),
                     inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                     validator: (v) => v?.isEmpty == true ? 'Required' : null,
                   ),
                 ),
               ],
             ),
             const SizedBox(height: 16),
             TextFormField(
               controller: _periodController,
               decoration: const InputDecoration(labelText: 'Period Label *', border: OutlineInputBorder(), hintText: 'e.g. 2018-2022 or Oct 2023'),
               validator: (v) => v?.isEmpty == true ? 'Required' : null,
             ),
             const SizedBox(height: 16),
             TextFormField(
               controller: _notesController,
               decoration: const InputDecoration(labelText: 'Notes / Reason', border: OutlineInputBorder()),
               maxLines: 2,
             ),
          ],
        ),
      ),
    );
  }

  // Add Search Query State
  String _searchQuery = '';

  Widget _buildRecentList() {
    final db = ref.watch(databaseProvider);
    
    return Container(
      // color: Colors.transparent, // Inherit scaffold background
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RECENT ARREARS LIST',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by Name or Reg No...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<PastArrearWithMember>>( 
              stream: db.pastOutstandingDao.watchAllOutstandingWithMembers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var list = snapshot.data!;
                
                // Filter
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  list = list.where((item) {
                     final name = '${item.member?.firstName ?? ''} ${item.member?.surname ?? ''}'.toLowerCase();
                     final reg = item.arrear.enrollmentNumber.toLowerCase();
                     return name.contains(q) || reg.contains(q);
                  }).toList();
                }

                // Sort
                list.sort((a, b) => b.arrear.id.compareTo(a.arrear.id));

                if (list.isEmpty) return const Center(child: Text('No records found.'));

                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      child: Text('Showing ${list.length} result(s)', style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: list.length,
                        separatorBuilder: (c, i) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final wrapper = list[index];
                          final item = wrapper.arrear;
                          final member = wrapper.member;

                          final displayName = member != null ? '${member.firstName} ${member.surname}' : item.enrollmentNumber;

                          return ListTile(
                            leading: Container(
                               width: 40,
                               height: 40,
                               decoration: BoxDecoration(
                                 color: Theme.of(context).colorScheme.tertiaryContainer,
                                 borderRadius: BorderRadius.circular(4),
                               ),
                               child: Icon(Icons.history_edu, color: Theme.of(context).colorScheme.onTertiaryContainer),
                            ),
                            title: Row(
                              children: [
                                Expanded(child: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold))),
                              ],
                            ), 
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${item.type} • ${item.periodLabel}'),
                                if (item.isCleared)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        Container(
                                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                           decoration: BoxDecoration(
                                             color: Colors.green.withOpacity(0.1),
                                             borderRadius: BorderRadius.circular(4),
                                             border: Border.all(color: Colors.green.withOpacity(0.5)),
                                           ),
                                           child: const Text('CLEARED', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: const Text('PENDING', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '₹${item.amount.toStringAsFixed(0)}', 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                                ),
                                const SizedBox(width: 16),
                                
                                // ACTIONS ONLY
                                if (item.isCleared && item.linkedPaymentId != null)
                                   IconButton(
                                     tooltip: 'Download Receipt',
                                     icon: const Icon(Icons.download, color: Colors.blue),
                                      onPressed: () async {
                                        // Fetch linked subscription
                                        final sub = await db.subscriptionsDao.getSubscriptionById(item.linkedPaymentId!);
                                        if (sub != null && context.mounted) {
                                           final pdfBytes = await ref.read(receiptServiceProvider).generateReceipt(sub, title: 'ARREARS RECEIPT');
                                           
                                           // Use direct download helper
                                           await ref.read(receiptServiceProvider).saveToDownloads(
                                             context, 
                                             pdfBytes, 
                                             'ABA_Arrears_Receipt_${sub.receiptNumber}.pdf',
                                             subFolder: 'arrearsReceipts',
                                           );
                                        } else if (context.mounted) {
                                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Linked receipt not found!')));
                                        }
                                     },
                                   ),

                                if (!item.isCleared) 
                                   IconButton(
                                     icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                     onPressed: () => _confirmDelete(item),
                                   ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(PastOutstandingDue item) { // Check generated class name
     showDialog(
       context: context,
       builder: (c) => AlertDialog(
         title: const Text('Delete Arrear Record?'),
         content: const Text('This will reduce the member\'s outstanding balance.'),
         actions: [
           TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
           FilledButton(
             style: FilledButton.styleFrom(backgroundColor: Colors.red),
             onPressed: () {
               ref.read(databaseProvider).pastOutstandingDao.deleteOutstanding(item.id);
               Navigator.pop(c);
             },
              child: const Text('Delete'),
           ),
         ],
       ),
     );
  }
}
