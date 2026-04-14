import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import 'member_controller.dart';
import '../database/app_database.dart';
import '../../core/app_gradients.dart';
import '../../core/auth/app_session.dart';
import 'widgets/member_photo_card.dart';
import 'services/member_photo_service.dart';
import 'dart:io';
import '../subscription/subscription_controller.dart';
import '../receipt/receipt_service.dart';

class MemberFormScreen extends ConsumerStatefulWidget {
  final Member? member;
  const MemberFormScreen({super.key, this.member});

  @override
  ConsumerState<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends ConsumerState<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _surnameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _regNoController = TextEditingController();
  final _addressController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();

  String? _bloodGroup;
  String _status = 'Active'; // Default
  DateTime? _dob;
  DateTime? _enrollmentAba;
  DateTime? _enrollmentBar;

  bool _isLoading = false;
  File? _photoFile;

  // --- Subscription Step State ---
  bool _showSubscriptionStep = false;
  Member? _savedMember;
  final _subscriptionFormKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _transactionInfoController = TextEditingController();
  String _paymentMode = 'Cash';
  bool _isSubscriptionLoading = false;

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  final List<String> _statusOptions = [
    'Active',
    'Inactive',
    'Expired',
    'Retired',
    'Suspended',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      final m = widget.member!;
      _surnameController.text = m.surname;
      _firstNameController.text = m.firstName;
      _middleNameController.text = m.middleName ?? '';
      _ageController.text = m.age.toString();
      _regNoController.text = m.registrationNumber;
      _addressController.text = m.address;
      _mobileController.text = m.mobileNumber;
      _emailController.text = m.email ?? '';
      _bloodGroup = m.bloodGroup;
      _status = m.memberStatus;
      _dob = m.dateOfBirth;
      _enrollmentAba = m.enrollmentDateAba;
      _enrollmentBar = m.enrollmentDateBar;
    }
  }

  @override
  void dispose() {
    _surnameController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _ageController.dispose();
    _regNoController.dispose();
    _addressController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _amountController.dispose();
    _transactionInfoController.dispose();
    super.dispose();
  }

  // Capitalize words helper
  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  Future<void> _pickDate(
    BuildContext context, {
    required Function(DateTime) onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      onPicked(picked);
      setState(() {});
    }
  }

  void _calculateAge() {
    if (_dob != null) {
      final now = DateTime.now();
      int age = now.year - _dob!.year;
      if (now.month < _dob!.month ||
          (now.month == _dob!.month && now.day < _dob!.day)) {
        age--;
      }
      _ageController.text = age.toString();
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        String? savedPhotoPath;
        if (_photoFile != null) {
          // If it's a new file (not the initial path), save it
           if (widget.member?.profilePhotoPath != _photoFile!.path) {
             savedPhotoPath = await MemberPhotoService().savePhoto(_photoFile!, _regNoController.text);
           } else {
             savedPhotoPath = widget.member?.profilePhotoPath;
           }
        }

        if (widget.member == null) {
          // --- New Member: save and transition to subscription step ---
          final newMember = await ref
              .read(memberControllerProvider)
              .addMember(
                surname: _surnameController.text,
                firstName: _firstNameController.text,
                middleName: _middleNameController.text.isNotEmpty
                    ? _middleNameController.text
                    : null,
                age: int.parse(_ageController.text),
                dateOfBirth: _dob,
                bloodGroup: _bloodGroup,
                enrollmentDateAba: _enrollmentAba,
                enrollmentDateBar: _enrollmentBar,
                registrationNumber: _regNoController.text,
                address: _addressController.text,
                mobileNumber: _mobileController.text,
                email: _emailController.text.isNotEmpty
                    ? _emailController.text
                    : null,
                memberStatus: _status,
                profilePhotoPath: savedPhotoPath,
              );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Member Added Successfully'),
                backgroundColor: Colors.green,
              ),
            );
            // Transition to subscription step
            setState(() {
              _savedMember = newMember;
              _showSubscriptionStep = true;
            });
          }
        } else {
          // Update existing member
          final updatedMember = widget.member!.copyWith(
            surname: _surnameController.text,
            firstName: _firstNameController.text,
            middleName: drift.Value(
              _middleNameController.text.isNotEmpty
                  ? _middleNameController.text
                  : null,
            ),
            age: int.parse(_ageController.text),
            dateOfBirth: drift.Value(_dob),
            bloodGroup: drift.Value(_bloodGroup),
            memberStatus: _status,
            enrollmentDateAba: drift.Value(_enrollmentAba),
            enrollmentDateBar: drift.Value(_enrollmentBar),
            registrationNumber: _regNoController.text,
            address: _addressController.text,
            mobileNumber: _mobileController.text,
            email: drift.Value(
              _emailController.text.isNotEmpty ? _emailController.text : null,
            ),
            profilePhotoPath: drift.Value(savedPhotoPath),
          );
          await ref.read(memberControllerProvider).updateMember(updatedMember);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Member Updated Successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context); // Close edit screen if pushed
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _resetForm() {
    _surnameController.clear();
    _firstNameController.clear();
    _middleNameController.clear();
    _ageController.clear();
    _regNoController.clear();
    _addressController.clear();
    _mobileController.clear();
    _emailController.clear();
    setState(() {
      _bloodGroup = null;
      _dob = null;
      _enrollmentBar = null;
      _photoFile = null;
    });
  }

  /// Resets the subscription step and goes back to blank add-member form.
  void _skipSubscription() {
    _amountController.clear();
    _transactionInfoController.clear();
    setState(() {
      _showSubscriptionStep = false;
      _savedMember = null;
      _paymentMode = 'Cash';
      _isSubscriptionLoading = false;
    });
    _resetForm();
  }

  /// Saves the subscription for the just-added member using the same
  /// SubscriptionController that the standalone screen uses. This ensures
  /// identical receipt numbering, UUID generation, and sync flags.
  Future<void> _submitSubscription() async {
    if (!_subscriptionFormKey.currentState!.validate()) return;
    if (_savedMember == null) return;

    setState(() => _isSubscriptionLoading = true);

    try {
      final amount = double.parse(_amountController.text);

      final subscription = await ref
          .read(subscriptionControllerProvider)
          .saveSubscription(
            firstName: _savedMember!.firstName,
            lastName: _savedMember!.surname,
            address: _savedMember!.address,
            mobileNumber: _savedMember!.mobileNumber,
            email: _savedMember!.email,
            enrollmentNumber: _savedMember!.registrationNumber,
            amount: amount,
            paymentMode: _paymentMode,
            transactionInfo: _transactionInfoController.text.isNotEmpty
                ? _transactionInfoController.text
                : null,
          );

      if (mounted) {
        _showSubscriptionSuccessDialog(subscription);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubscriptionLoading = false);
      }
    }
  }

  void _showSubscriptionSuccessDialog(Subscription subscription) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
              _skipSubscription(); // Reset to blank add-member form
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
                // Error handled in helper
              }

              // Reset to blank add-member form after download
              _skipSubscription();
            },
            icon: const Icon(Icons.download),
            label: const Text('Download Receipt'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isViewer = ref.watch(appSessionProvider).role == UserRole.viewer;

    // --- Show subscription step if member was just saved ---
    if (_showSubscriptionStep && _savedMember != null && widget.member == null) {
      return _buildSubscriptionStep(isViewer);
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.member == null ? 'Add Member' : 'Member Details')),
      body: AbsorbPointer(
        absorbing: isViewer, // Disable interactions for Viewers
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Photo Card (Viewers can see, but interactions blocked by AbsorbPointer)
                MemberPhotoCard(
                  initialPhotoPath: widget.member?.profilePhotoPath,
                  onPhotoChanged: (file) {
                    if (!isViewer) _photoFile = file;
                  },
                ),
                const SizedBox(height: 24),

                // ... Fields (wrapped in AbsorbPointer, so readOnly visually not needed if we want total block, 
                // but readOnly looks better to allow selection. 
                // Actually AbsorbPointer prevents Selection too.
                // Let's use readOnly on fields instead for better UX (copy-paste).
                // Reverting AbsorbPointer and using individual readOnly.)
                
                // Personal Details
                Card(
                  elevation: 4,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: AppGradients.formPanel(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Details',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _surnameController,
                                readOnly: isViewer,
                                decoration: const InputDecoration(
                                  labelText: 'Surname *',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    v?.isEmpty == true ? 'Required' : null,
                                onChanged: (val) {
                                  // Capitalize logic...
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _firstNameController,
                                readOnly: isViewer,
                                decoration: const InputDecoration(
                                  labelText: 'First Name *',
                                  border: OutlineInputBorder(),
                                ),
                                // ...
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _middleNameController,
                                readOnly: isViewer,
                                decoration: const InputDecoration(
                                  labelText: 'Middle Name',
                                  border: OutlineInputBorder(),
                                ),
                                // ...
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: isViewer ? null : () => _pickDate(
                                  context,
                                  onPicked: (d) {
                                    _dob = d;
                                    _calculateAge();
                                  },
                                ),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Date of Birth',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  child: Text(
                                    _dob == null
                                        ? 'Select Date'
                                        : DateFormat('dd/MM/yyyy').format(_dob!),
                                  ),
                                ),
                              ),
                            ),
                            // ... Age Controller ...
                            const SizedBox(width: 16),
                            Expanded(
                                child: TextFormField(
                                  controller: _ageController,
                                  readOnly: isViewer,
                                  decoration: const InputDecoration(
                                    labelText: 'Age *',
                                    border: OutlineInputBorder(),
                                  ),
                                  // ...
                                ),
                            ),
                            // ... Blood Group Dropdown (Block if viewer)
                             const SizedBox(width: 16),
                            Expanded(
                              child: IgnorePointer(
                                ignoring: isViewer,
                                child: DropdownButtonFormField<String>(
                                  initialValue: _bloodGroup,
                                  decoration: const InputDecoration(
                                    labelText: 'Blood Group',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _bloodGroups.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                  onChanged: (v) => setState(() => _bloodGroup = v),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // ... Status Dropdown ...
                         const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: IgnorePointer(
                                ignoring: isViewer,
                                child: DropdownButtonFormField<String>(
                                  value: _status,
                                  decoration: const InputDecoration(
                                    labelText: 'Member Status',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.info_outline),
                                  ),
                                  items: _statusOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                  onChanged: (v) => setState(() => _status = v!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Enrollment & Registration Details
                Card(
                  elevation: 4,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: AppGradients.formPanel(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enrollment & Registration',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _regNoController,
                                readOnly: isViewer,
                                decoration: const InputDecoration(
                                  labelText: 'Registration Number *',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.badge),
                                ),
                                validator: (v) =>
                                    v?.isEmpty == true ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: isViewer ? null : () => _pickDate(
                                  context,
                                  onPicked: (d) {
                                    _enrollmentAba = d;
                                  },
                                ),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Enrollment Date (ABA)',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  child: Text(
                                    _enrollmentAba == null
                                        ? 'Select Date'
                                        : DateFormat('dd/MM/yyyy').format(_enrollmentAba!),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: InkWell(
                                onTap: isViewer ? null : () => _pickDate(
                                  context,
                                  onPicked: (d) {
                                    _enrollmentBar = d;
                                  },
                                ),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Enrollment Date (Bar Council)',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  child: Text(
                                    _enrollmentBar == null
                                        ? 'Select Date'
                                        : DateFormat('dd/MM/yyyy').format(_enrollmentBar!),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Contact Details
                Card(
                  elevation: 4,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: AppGradients.formPanel(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Details',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          readOnly: isViewer,
                          decoration: const InputDecoration(
                            labelText: 'Address *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          maxLines: 2,
                          validator: (v) =>
                              v?.isEmpty == true ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _mobileController,
                                readOnly: isViewer,
                                decoration: const InputDecoration(
                                  labelText: 'Mobile Number *',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.phone),
                                ),
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                validator: (v) =>
                                    v?.isEmpty == true ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _emailController,
                                readOnly: isViewer,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.email),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: isViewer ? null : null, // (We don't use FAB here)
      bottomNavigationBar: isViewer ? const SizedBox(height: 0) : Padding( // HIDE BUTTONS
         padding: const EdgeInsets.all(24),
         child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
               OutlinedButton(onPressed: _resetForm, child: const Text('Reset')),
               const SizedBox(width: 16),
               FilledButton(
                 onPressed: _isLoading ? null : _submit, 
                 child: _isLoading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('Save Member')
               ),
            ],
         ),
      ),
    );
  }

  // =====================================================================
  // SUBSCRIPTION STEP — shown after a new member is successfully saved
  // =====================================================================

  Widget _buildSubscriptionStep(bool isViewer) {
    final member = _savedMember!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Subscription'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Skip & Add Another Member',
          onPressed: _skipSubscription,
        ),
      ),
      body: AbsorbPointer(
        absorbing: isViewer,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _subscriptionFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Success Banner
                Card(
                  color: Colors.green.shade50,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.green.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Member Added Successfully!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.green.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'You can now add a subscription entry for this member, or skip to add another member.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Member Info Card (read-only display)
                Card(
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
                        const Text(
                          'Member Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${member.firstName} ${member.surname}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const Divider(),
                              const SizedBox(height: 8),
                              _buildDetailRow('Reg. Number', member.registrationNumber),
                              _buildDetailRow('Mobile', member.mobileNumber),
                              _buildDetailRow('Address', member.address),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Subscription Payment Card
                Card(
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
                        const Text(
                          'Subscription Payment',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
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
                              child: IgnorePointer(
                                ignoring: isViewer,
                                child: DropdownButtonFormField<String>(
                                  value: _paymentMode,
                                  decoration: const InputDecoration(
                                    labelText: 'Payment Mode',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: [
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
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: isViewer
          ? const SizedBox(height: 0)
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: _skipSubscription,
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Skip'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: _isSubscriptionLoading ? null : _submitSubscription,
                    icon: _isSubscriptionLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: const Text('Save Subscription'),
                  ),
                ],
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
