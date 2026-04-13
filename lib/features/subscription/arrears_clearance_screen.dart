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
import '../receipt/receipt_service.dart';
import 'export_service.dart';

class ArrearsClearanceScreen extends ConsumerStatefulWidget {
  const ArrearsClearanceScreen({super.key});

  @override
  ConsumerState<ArrearsClearanceScreen> createState() => _ArrearsClearanceScreenState();
}

class _ArrearsClearanceScreenState extends ConsumerState<ArrearsClearanceScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _amountController = TextEditingController();
  final _refController = TextEditingController();
  final _notesController = TextEditingController();

  // State
  Member? _selectedMember;
  PastOutstandingDue? _selectedArrear;
  String _paymentMode = 'Cash';
  DateTime _paymentDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onMemberSelected(Member member) {
    setState(() {
      _selectedMember = member;
      _selectedArrear = null; // Reset selection
      _clearFormRequest();
    });
  }

  void _onArrearSelected(PastOutstandingDue arrear) {
    setState(() {
      _selectedArrear = arrear;
      _amountController.text = arrear.amount.toStringAsFixed(0);
      _notesController.text = "Clearance of ${arrear.type} (${arrear.periodLabel})";
    });
  }

  void _clearFormRequest() {
    _amountController.clear();
    _refController.clear();
    _notesController.clear();
    _paymentMode = 'Cash';
    _paymentDate = DateTime.now();
    _selectedArrear = null;
  }

  void _resetAll() {
    setState(() {
      _selectedMember = null;
      _clearFormRequest();
    });
  }

  Future<void> _processPayment() async {
    if (_selectedMember == null || _selectedArrear == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);
      final receiptService = ref.read(receiptServiceProvider);
      
      int? paymentId;
      String receiptNo = '';

      await db.transaction(() async {
        // Generate Standardized Receipt Number: ARR-YYYYMMDD-SEQ
        const type = 'ARR';
        final seq = await db.subscriptionsDao.getNextSequence(type, _paymentDate);
        
        final dateStr = '${_paymentDate.year}${_paymentDate.month.toString().padLeft(2, '0')}${_paymentDate.day.toString().padLeft(2, '0')}';
        final seqStr = seq.toString().padLeft(3, '0');
        receiptNo = '$type-$dateStr-$seqStr';
        
        final subEntry = SubscriptionsCompanion(
            enrollmentNumber: drift.Value(_selectedMember!.registrationNumber),
            firstName: drift.Value(_selectedMember!.firstName),
            lastName: drift.Value(_selectedMember!.surname),
            address: drift.Value(_selectedMember!.address),
            mobileNumber: drift.Value(_selectedMember!.mobileNumber),
            email: drift.Value(_selectedMember!.email),
            amount: drift.Value(_selectedArrear!.amount),
            subscriptionDate: drift.Value(_paymentDate),
            paymentMode: drift.Value(_paymentMode),
            transactionInfo: drift.Value(_refController.text.isEmpty ? _notesController.text : "${_refController.text} - ${_notesController.text}"),
            receiptNumber: drift.Value(receiptNo),
            receiptType: drift.Value(type),
            dailySequence: drift.Value(seq), 
        );

        // 1. Create Subscription Entry
        paymentId = await db.subscriptionsDao.insertSubscription(subEntry);
        
        if (paymentId == null) throw Exception("Failed to create subscription entry");

        // 2. Mark Arrear as Cleared
        await db.pastOutstandingDao.markAsCleared(_selectedArrear!.id, paymentId!, _paymentDate);
      });

      if (mounted) {
        // Success Logic
        await showDialog(
          context: context,
          builder: (c) => AlertDialog(
            title: const Row(children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 8), Text('Arrears Cleared')]),
            content: const Text('Payment recorded and arrears marked as cleared.\nReceipt generated successfully.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close')),
              FilledButton.icon(
                onPressed: () async {
                   Navigator.pop(c);
                   // Generate Receipt
                   final sub = await db.subscriptionsDao.getSubscriptionById(paymentId!);
                   if (sub != null) {
                      final pdfBytes = await receiptService.generateReceipt(sub, title: 'ARREARS RECEIPT');
                      if (context.mounted) {
                        await receiptService.saveToDownloads(
                          context,
                          pdfBytes,
                          'ABA_Arrears_Receipt_$receiptNo.pdf',
                        );
                      }
                   }
                }, 
                icon: const Icon(Icons.download), 
                label: const Text('Download Receipt')
              ),
            ],
          ),
        );
        
        // Refresh UI
        setState(() {
           _selectedArrear = null; // Deselect to force user to choose next
           _clearFormRequest();
        });
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clear Past Arrears')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Member Search Card
            _buildMemberSearchCard(),
            const SizedBox(height: 24),

            // 2. Pending Arrears List (Only if member selected)
            if (_selectedMember != null) ...[
              const Text('Pending Arrears', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildPendingList(),
              const SizedBox(height: 24),
            ],

            // 3. Payment Form (Only if arrear selected)
            if (_selectedArrear != null)
               _buildPaymentForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberSearchCard() {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: AppGradients.formPanel(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Member Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                    onSelected: _onMemberSelected,
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
                          filled: true,
                          // remove hardcoded Colors.white
                        ),
                      );
                    },
                     optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            color: Theme.of(context).cardColor,
                            child: SizedBox(
                              width: 400,
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  return ListTile(
                                    leading: const CircleAvatar(child: Icon(Icons.person)),
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${_selectedMember!.firstName} ${_selectedMember!.surname}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          Text('Reg: ${_selectedMember!.registrationNumber} • Mob: ${_selectedMember!.mobileNumber}'),
                          Text(_selectedMember!.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close), 
                      onPressed: _resetAll,
                      tooltip: 'Change Member',
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingList() {
    final db = ref.watch(databaseProvider);
    return StreamBuilder<List<PastOutstandingDue>>(
      stream: db.pastOutstandingDao.watchPendingByMember(_selectedMember!.registrationNumber),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;
        if (list.isEmpty) return Container(
           padding: const EdgeInsets.all(24),
           alignment: Alignment.center,
           decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
           child: const Text('No pending arrears found.', style: TextStyle(fontSize: 16)),
        );

        return SizedBox(
          height: 150, // Fixed height for scrolling if many
          child: ListView.separated(
            itemCount: list.length,
            scrollDirection: Axis.horizontal,
            separatorBuilder: (c, i) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = list[index];
              final isSelected = _selectedArrear?.id == item.id;
              return GestureDetector(
                onTap: () => _onArrearSelected(item),
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.errorContainer : Theme.of(context).cardColor,
                    border: Border.all(
                      color: isSelected ? Theme.of(context).colorScheme.error : Theme.of(context).dividerColor,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      if (isSelected) BoxShadow(color: Theme.of(context).colorScheme.error.withOpacity(0.2), blurRadius: 8, spreadRadius: 2)
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Expanded(child: Text(item.periodLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
                           if (isSelected) Icon(Icons.check_circle, color: Theme.of(context).colorScheme.error, size: 20),
                         ],
                       ),
                       const SizedBox(height: 8),
                       Text(
                         '₹${item.amount.toStringAsFixed(0)}',
                         style: TextStyle(
                           fontSize: 24,
                           fontWeight: FontWeight.bold,
                           color: isSelected ? Theme.of(context).colorScheme.error : Theme.of(context).textTheme.bodyLarge?.color,
                         ),
                       ),
                       const SizedBox(height: 4),
                       Text(item.type, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPaymentForm() {
    return Form(
      key: _formKey,
      child: Card(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: AppGradients.formPanel(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payment Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                     child: TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(labelText: 'Amount (Locked)', border: OutlineInputBorder(), prefixText: '₹ '),
                        readOnly: true, // Amount is locked to arrear amount!
                        style: const TextStyle(fontWeight: FontWeight.bold),
                     ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _paymentMode,
                      decoration: const InputDecoration(labelText: 'Payment Mode', border: OutlineInputBorder()),
                      items: const ['Cash', 'UPI', 'Cheque', 'Bank Transfer', 'DD'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => setState(() => _paymentMode = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_paymentMode != 'Cash') ...[
                 TextFormField(
                    controller: _refController,
                    decoration: const InputDecoration(labelText: 'Transaction / Cheque Reference ID', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required for non-cash modes' : null,
                 ),
                 const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes / Remarks', border: OutlineInputBorder()),
                maxLines: 1,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _processPayment,
                  icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.payment),
                  label: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('PAY & GENERATE RECEIPT'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
