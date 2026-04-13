import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import 'subscription_controller.dart';
import '../receipt/receipt_service.dart';
import 'package:printing/printing.dart';
import '../database/database_provider.dart';
import '../database/app_database.dart';
import '../../core/app_gradients.dart';
import '../../core/auth/app_session.dart';

class SubscriptionFormScreen extends ConsumerStatefulWidget {
  const SubscriptionFormScreen({super.key});

  @override
  ConsumerState<SubscriptionFormScreen> createState() =>
      _SubscriptionFormScreenState();
}

class _SubscriptionFormScreenState
    extends ConsumerState<SubscriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _transactionInfoController = TextEditingController();

  // Selected Member
  Member? _selectedMember;

  String _paymentMode = 'Cash';
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _transactionInfoController.dispose();
    super.dispose();
  }

  Future<void> _submitFormat() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedMember == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select a member')));
        return;
      }

      setState(() => _isLoading = true);

      try {
        final amount = double.parse(_amountController.text);

        // We use the selected member's details to populate the subscription record
        // This maintains the original schema requirement while simplifying the UI
        final subscription = await ref
            .read(subscriptionControllerProvider)
            .saveSubscription(
              firstName: _selectedMember!.firstName,
              lastName: _selectedMember!.surname, // Using surname as lastName
              address: _selectedMember!.address,
              mobileNumber: _selectedMember!.mobileNumber,
              email: _selectedMember!.email,
              enrollmentNumber: _selectedMember!.registrationNumber,
              amount: amount,
              paymentMode: _paymentMode,
              transactionInfo: _transactionInfoController.text.isNotEmpty
                  ? _transactionInfoController.text
                  : null,
            );

        if (mounted) {
          _showSuccessDialog(subscription);
          _clearForm();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _clearForm() {
    _amountController.clear();
    _transactionInfoController.clear();
    setState(() {
      _selectedMember = null;
      _paymentMode = 'Cash';
    });
  }

  void _showSuccessDialog(Subscription subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Subscription Saved'),
          ],
        ),
        content: const Text(
          'Subscription has been recorded successfully. You can now download the receipt.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Generating Receipt...')),
              );

              try {
                // Generate PDF
                final receiptService = ref.read(receiptServiceProvider);
                final pdfBytes = await receiptService.generateReceipt(
                  subscription,
                );

                if (context.mounted) {
                  await receiptService.saveToDownloads(
                    context,
                    pdfBytes,
                    'ABA_Subscription_Receipt_${subscription.receiptNumber}.pdf',
                  );
                }
              } catch (e) {
                 // Error handled in helper or here if needed
              }
            },
            icon: const Icon(Icons.download),
            label: const Text('Download Receipt'),
          ),
        ],
      ),
    );
  }



// ...

  @override
  Widget build(BuildContext context) {
    final isViewer = ref.watch(appSessionProvider).role == UserRole.viewer;

    return Scaffold(
      appBar: AppBar(title: const Text('New Subscription Entry')),
      body: AbsorbPointer( // Disable all form interactions for Viewers
        absorbing: isViewer,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ... (Member Details Card)
                Card(
                  elevation: 4,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: AppGradients.formPanel(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Member Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Member Search Autocomplete
                        if (_selectedMember == null)
                           // If viewer, maybe show text saying "Member Selection Disabled" or just keep the disabled field
                           // Since AbsorbPointer handles clicks, the Autocomplete won't open.
                          Consumer(
                            builder: (context, ref, child) {
                              return Autocomplete<Member>(
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) async {
                                      if (textEditingValue.text.isEmpty) {
                                        return const Iterable<Member>.empty();
                                      }
                                      final db = ref.read(databaseProvider);
                                      return await db.membersDao.searchMembers(
                                        textEditingValue.text,
                                        onlyActive: true,
                                      );
                                    },
                                displayStringForOption: (Member option) =>
                                    '${option.firstName} ${option.surname} - ${option.registrationNumber}',
                                onSelected: (Member selection) {
                                  setState(() {
                                    _selectedMember = selection;
                                  });
                                },
                                fieldViewBuilder:
                                    (
                                      context,
                                      textEditingController,
                                      focusNode,
                                      onFieldSubmitted,
                                    ) {
                                      return TextFormField(
                                        controller: textEditingController,
                                        focusNode: focusNode,
                                        readOnly: isViewer, // Visual cue
                                        onFieldSubmitted: (String value) {
                                          onFieldSubmitted();
                                        },
                                        decoration: const InputDecoration(
                                          labelText: 'Search Member *',
                                          hintText: 'Name, Mobile, or Reg No',
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.search),
                                          helperText:
                                              'Select a member to proceed',
                                        ),
                                      );
                                    },
                                optionsViewBuilder: (context, onSelected, options) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      elevation: 4.0,
                                      child: SizedBox(
                                        width: 400,
                                        child: ListView.builder(
                                          padding: const EdgeInsets.all(8.0),
                                          shrinkWrap: true,
                                          itemCount: options.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            final Member option = options
                                                .elementAt(index);
                                            return ListTile(
                                              leading: const CircleAvatar(
                                                child: Icon(Icons.person),
                                              ),
                                              title: Text(
                                                '${option.firstName} ${option.surname}',
                                              ),
                                              subtitle: Text(
                                                'Reg: ${option.registrationNumber}\nMob: ${option.mobileNumber}',
                                              ),
                                              isThreeLine: true,
                                              onTap: () {
                                                onSelected(option);
                                              },
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
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.5),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${_selectedMember!.firstName} ${_selectedMember!.surname}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        setState(() {
                                          _selectedMember = null;
                                        });
                                      },
                                      tooltip: 'Change Member',
                                    ),
                                  ],
                                ),
                                const Divider(),
                                const SizedBox(height: 8),
                                _buildDetailRow(
                                  'Reg. Number',
                                  _selectedMember!.registrationNumber,
                                ),
                                _buildDetailRow(
                                  'Mobile',
                                  _selectedMember!.mobileNumber,
                                ),
                                _buildDetailRow(
                                  'Address',
                                  _selectedMember!.address,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: AppGradients.formPanel(context),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _amountController,
                                readOnly: isViewer,
                                decoration: const InputDecoration(
                                  labelText: 'Subscription Amount (₹) *',
                                  border: OutlineInputBorder(),
                                  prefixText: '₹ ',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}'),
                                  ),
                                ],
                                validator: (v) =>
                                    v?.isEmpty == true ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: IgnorePointer( // Since Dropdown doesn't have readOnly
                                ignoring: isViewer,
                                child: DropdownButtonFormField<String>(
                                  initialValue: _paymentMode,
                                  decoration: const InputDecoration(
                                    labelText: 'Payment Mode',
                                    border: OutlineInputBorder(),
                                  ),
                                  items:
                                      [
                                            'Cash',
                                            'UPI',
                                            'Cheque',
                                            'Bank Transfer',
                                            'DD',
                                          ]
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(e),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (v) =>
                                      setState(() => _paymentMode = v!),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_paymentMode != 'Cash') ...[
                          TextFormField(
                            controller: _transactionInfoController,
                            readOnly: isViewer,
                            decoration: const InputDecoration(
                              labelText: 'Transaction / Cheque Reference ID',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          initialValue: DateFormat(
                            'dd MMM yyyy',
                          ).format(DateTime.now()),
                          decoration: const InputDecoration(
                            labelText: 'Subscription Date',
                            border: OutlineInputBorder(),
                            helperText: 'Date is locked to Today',
                            filled: true,
                          ),
                          readOnly: true,
                          enabled: false,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (!isViewer) // HIDE BUTTON IF VIEWER
                SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _submitFormat,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('SAVE SUBSCRIPTION'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
