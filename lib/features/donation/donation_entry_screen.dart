import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database_provider.dart';
import '../database/app_database.dart';
import '../members/widgets/member_search_autocomplete.dart';
import '../../core/app_gradients.dart';
import '../receipt/receipt_service.dart';
import '../subscription/export_service.dart'; // for receiptServiceProvider
import '../settings/data_export_service.dart';
import 'package:printing/printing.dart';
import '../../core/widgets/responsive_split_view.dart';

class DonationEntryScreen extends ConsumerStatefulWidget {
  const DonationEntryScreen({super.key});

  @override
  ConsumerState<DonationEntryScreen> createState() => _DonationEntryScreenState();
}

class _DonationEntryScreenState extends ConsumerState<DonationEntryScreen> {
  // Toggle
  bool _isMemberDonation = true;

  // Member Selection
  Member? _selectedMember;

  // Non-Member Details
  final _nmNameController = TextEditingController();
  final _nmMobileController = TextEditingController();
  final _nmEmailController = TextEditingController();
  final _nmAddressController = TextEditingController();
  final _nmOrgController = TextEditingController();

  // Donation Details
  final _amountController = TextEditingController();
  String _paymentMode = 'Cash';
  final _txnRefController = TextEditingController();
  final _purposeController = TextEditingController();
  bool _generateReceipt = true;

  // Recent Donations
  bool _isLoading = false;
  final _searchQueryController = TextEditingController();

  @override
  void dispose() {
    _nmNameController.dispose();
    _nmMobileController.dispose();
    _nmEmailController.dispose();
    _nmAddressController.dispose();
    _nmOrgController.dispose();
    _amountController.dispose();
    _txnRefController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _selectedMember = null;
      _nmNameController.clear();
      _nmMobileController.clear();
      _nmEmailController.clear();
      _nmAddressController.clear();
      _nmOrgController.clear();
      _amountController.clear();
      _txnRefController.clear();
      _purposeController.clear();
      _paymentMode = 'Cash';
      _generateReceipt = true;
    });
  }

  Future<void> _saveDonation() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    String donorName;
    String donorType = _isMemberDonation ? 'Member' : 'Non-Member';
    int? memberId;

    if (_isMemberDonation) {
      if (_selectedMember == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a member')),
        );
        return;
      }
      donorName = '${_selectedMember!.firstName} ${_selectedMember!.surname}';
      memberId = _selectedMember!.id;
    } else {
      if (_nmNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter donor name')),
        );
        return;
      }
      donorName = _nmNameController.text;
    }

    setState(() => _isLoading = true);
    final db = ref.read(databaseProvider);

    try {
      // Standardized Receipt: DON-YYYYMMDD-SEQ
      final now = DateTime.now();
      const type = 'DON';
      final seq = await db.donationsDao.getNextSequence(now);
      
      final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final seqStr = seq.toString().padLeft(3, '0');
      final receiptNo = '$type-$dateStr-$seqStr';
      
      final entry = DonationsCompanion(
        donorName: drift.Value(donorName),
        donorType: drift.Value(donorType),
        memberId: drift.Value(memberId),
        amount: drift.Value(amount),
        donationDate: drift.Value(now),
        paymentMode: drift.Value(_paymentMode),
        transactionRef: drift.Value(_txnRefController.text.isNotEmpty ? _txnRefController.text : null),
        purpose: drift.Value(_purposeController.text.isNotEmpty ? _purposeController.text : null),
        receiptNumber: drift.Value(receiptNo),
        dailySequence: drift.Value(seq),
        // Non-Member Details
        donorMobile: drift.Value(!_isMemberDonation ? _nmMobileController.text : null),
        donorEmail: drift.Value(!_isMemberDonation ? _nmEmailController.text : null),
        donorAddress: drift.Value(!_isMemberDonation ? _nmAddressController.text : null),
        organization: drift.Value(!_isMemberDonation ? _nmOrgController.text : null),
        isSynced: const drift.Value(false), // New entries are unsynced initially
        lastUpdatedAt: drift.Value(now),
        deleted: const drift.Value(false),
      );

      await db.donationsDao.insertDonation(entry);
      
      final savedDonation = Donation(
        id: 0, // Placeholder
        donorName: donorName,
        donorType: donorType,
        memberId: memberId,
        amount: amount,
        donationDate: DateTime.now(),
        paymentMode: _paymentMode,
        transactionRef: _txnRefController.text.isNotEmpty ? _txnRefController.text : null,
        purpose: _purposeController.text.isNotEmpty ? _purposeController.text : null,
        receiptNumber: receiptNo,
        createdAt: DateTime.now(),
        dailySequence: seq,
        donorMobile: !_isMemberDonation ? _nmMobileController.text : null,
        donorEmail: !_isMemberDonation ? _nmEmailController.text : null,
        donorAddress: !_isMemberDonation ? _nmAddressController.text : null,
        organization: !_isMemberDonation ? _nmOrgController.text : null,
        isSynced: false,
        lastUpdatedAt: now,
        deleted: false,
      );

      _resetForm();

      if (mounted) {
        _showSuccessDialog(savedDonation);
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving donation: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(Donation donation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Donation Saved'),
          ],
        ),
        content: Text(
          'Donation from ${donation.donorName} recorded successfully.\nReceipt No: ${donation.receiptNumber}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (_generateReceipt)
            FilledButton.icon(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                final receiptService = ref.read(receiptServiceProvider);
                final pdfBytes = await receiptService.generateDonationReceipt(donation);
                
                if (context.mounted) {
                   await receiptService.saveToDownloads(
                     context, 
                     pdfBytes, 
                     'ABA_Donation_Receipt_${donation.receiptNumber}.pdf'
                   );
                }
              },
              icon: const Icon(Icons.download),
              label: const Text('Download Receipt'),
            ),
        ],
      ),
    );
  }




  void _showDonorDetailsDialog(Donation d) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person_outline, color: Colors.blue),
            const SizedBox(width: 8),
            Text(d.donorName),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(Icons.phone, 'Mobile', d.donorMobile ?? 'N/A'),
            const SizedBox(height: 8),
            _detailRow(Icons.email, 'Email', d.donorEmail ?? 'N/A'),
            const SizedBox(height: 8),
            _detailRow(Icons.location_on, 'Address', d.donorAddress ?? 'N/A'),
            const SizedBox(height: 8),
            _detailRow(Icons.business, 'Organization', d.organization ?? 'N/A'),
            const Divider(),
             _detailRow(Icons.receipt, 'Receipt', d.receiptNumber),
             _detailRow(Icons.currency_rupee, 'Amount', d.amount.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Donations to CSV',
            onPressed: () async {
              final exportService = ref.read(dataExportServiceProvider);
              await exportService.exportDonationsCsv();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export initiated...')),
                );
              }
            },
          ),
        ],
      ),
      body: ResponsiveSplitView(
        left: Card(
          elevation: 4,
          margin: EdgeInsets.zero, // Padding handled by view
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Donation Entry', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 24),

                // Section 1: Donor Type
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Member Donation'), icon: Icon(Icons.person)),
                    ButtonSegment(value: false, label: Text('Non-Member Donation'), icon: Icon(Icons.person_outline)),
                  ],
                  selected: {_isMemberDonation},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setState(() {
                      _isMemberDonation = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Section 2: Donor Details
                if (_isMemberDonation) ...[
                  MemberSearchAutocomplete(
                    onMemberSelected: (m) => setState(() => _selectedMember = m),
                  ),
                  if (_selectedMember != null) ...[
                    const SizedBox(height: 16),
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
                                   child: _selectedMember!.profilePhotoPath != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: Image.file(
                                                File(_selectedMember!.profilePhotoPath!),
                                                width: 40, height: 40, fit: BoxFit.cover,
                                              ),
                                            )
                                          : Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                                 ),
                                 const SizedBox(width: 12),
                                 Expanded(
                                   child: Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Text(
                                         '${_selectedMember!.firstName} ${_selectedMember!.surname}',
                                         style: const TextStyle(fontWeight: FontWeight.bold),
                                       ),
                                       Text(
                                          'Reg: ${_selectedMember!.registrationNumber}\nMobile: ${_selectedMember!.mobileNumber}',
                                          style: Theme.of(context).textTheme.bodySmall,
                                       ),
                                     ],
                                   ),
                                 ),
                                 IconButton(
                                   icon: const Icon(Icons.close), 
                                   onPressed: () => setState(() => _selectedMember = null)
                                 ),
                               ],
                             ),
                          ),
                  ],
                ] else ...[
                  TextFormField(
                    controller: _nmNameController,
                    decoration: const InputDecoration(labelText: 'Donor Name *', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: TextFormField(
                        controller: _nmMobileController,
                        decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder()),
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: TextFormField(
                        controller: _nmEmailController,
                        decoration: const InputDecoration(labelText: 'Email (Optional)', border: OutlineInputBorder()),
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nmAddressController,
                    decoration: const InputDecoration(labelText: 'Address (Optional)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nmOrgController,
                    decoration: const InputDecoration(labelText: 'Organization / Firm (Optional)', border: OutlineInputBorder()),
                  ),
                ],
                const Divider(height: 48),

                // Section 3: Donation Details
                Text('Transaction Details', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(labelText: 'Amount (₹) *', border: OutlineInputBorder(), prefixText: '₹ '),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _paymentMode,
                        decoration: const InputDecoration(labelText: 'Payment Mode', border: OutlineInputBorder()),
                        items: ['Cash', 'UPI', 'Cheque', 'Bank Transfer']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _paymentMode = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _txnRefController,
                  decoration: const InputDecoration(labelText: 'Transaction Reference (Optional)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _purposeController,
                  decoration: const InputDecoration(labelText: 'Purpose / Remarks (Optional)', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                 // Section 4: Actions
                 Row(
                   children: [
                     Expanded(
                       child: FilledButton.icon(
                         onPressed: _isLoading ? null : _saveDonation,
                         icon: const Icon(Icons.save),
                         label: Text(_isLoading ? 'Saving...' : 'Save Donation'),
                         style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                       ),
                     ),
                   ],
                 ),
              ],
            ),
          ),
        ),
        right: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                 Text('Recent Donations', style: Theme.of(context).textTheme.titleMedium),
               const SizedBox(height: 16),
               // Search Bar
               TextField(
                 controller: _searchQueryController,
                 decoration: const InputDecoration(
                   labelText: 'Search Donations',
                   hintText: 'Name, Amount, Receipt No...',
                   prefixIcon: Icon(Icons.search),
                   border: OutlineInputBorder(),
                   isDense: true,
                 ),
                 onChanged: (val) => setState(() {}),
               ),
               const SizedBox(height: 16),
               Expanded(
                 child: Consumer(
                   builder: (context, ref, child) {
                     final db = ref.watch(databaseProvider);
                     return StreamBuilder<List<Donation>>(
                       stream: db.donationsDao.watchAllDonations(),
                       builder: (context, snapshot) {
                         if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                         if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                         
                         final allDonations = snapshot.data!;
                         final query = _searchQueryController.text.toLowerCase();
                         
                         final donations = allDonations.where((d) {
                           return d.donorName.toLowerCase().contains(query) ||
                                  d.receiptNumber.toLowerCase().contains(query) ||
                                  d.amount.toString().contains(query) ||
                                  d.paymentMode.toLowerCase().contains(query);
                         }).toList();

                         if (donations.isEmpty && allDonations.isNotEmpty) {
                            return const Center(child: Text('No matching donations found.'));
                         }
                         if (allDonations.isEmpty) {
                            return const Center(child: Text('No donations recorded yet.'));
                         }

                         return Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text('Showing ${donations.length} result(s)', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: donations.length,
                                  itemBuilder: (context, index) {
                                    final d = donations[index];
                                    return Card(
                                      child: ListTile(
                                        leading: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: d.donorType == 'Member' 
                                               ? Theme.of(context).colorScheme.primaryContainer 
                                               : Theme.of(context).colorScheme.secondaryContainer,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Icon(
                                              d.donorType == 'Member' ? Icons.person : Icons.business, 
                                              color: d.donorType == 'Member' 
                                                   ? Theme.of(context).colorScheme.onPrimaryContainer 
                                                   : Theme.of(context).colorScheme.onSecondaryContainer
                                          ),
                                        ),
                                        title: Row(
                                          children: [
                                            Expanded(child: Text(d.donorName, style: const TextStyle(fontWeight: FontWeight.bold))),
                                            const SizedBox(width: 8),
                                            Text('₹ ${d.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('${DateFormat('dd MMM yyyy').format(d.donationDate)} • ${d.paymentMode}'),
                                            Text('Receipt: ${d.receiptNumber}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                             // View Details (Eye) Button for Non-Members
                                             if (d.donorType != 'Member')
                                               IconButton(
                                                 icon: const Icon(Icons.visibility, color: Colors.blueGrey),
                                                 tooltip: 'View Donor Details',
                                                 onPressed: () => _showDonorDetailsDialog(d),
                                               ),
                                              IconButton(
                                               icon: const Icon(Icons.download),
                                               tooltip: 'Download Receipt',
                                               onPressed: () async {
                                                 final receiptService = ref.read(receiptServiceProvider);
                                                 final pdfBytes = await receiptService.generateDonationReceipt(d);
                                                 
                                                 if (context.mounted) {
                                                    await receiptService.saveToDownloads(context, pdfBytes, 'ABA_Donation_Receipt_${d.receiptNumber}.pdf');
                                                 }
                                               },
                                             ),
                                          ],
                                        ),
                                        onTap: () async {
                                           final receiptService = ref.read(receiptServiceProvider);
                                           final pdfBytes = await receiptService.generateDonationReceipt(d);
                                           if (context.mounted) {
                                              await receiptService.saveToDownloads(context, pdfBytes, 'ABA_Donation_Receipt_${d.receiptNumber}.pdf');
                                           }
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                           ],
                         );
                       },
                     );
                   },
                 ),
               ),
             ],
           ),
        ),
      ),
    );
  }
}
