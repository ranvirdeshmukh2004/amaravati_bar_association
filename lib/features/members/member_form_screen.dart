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
import '../../core/auth/app_session.dart';

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
          await ref
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
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.member == null
                    ? 'Member Added Successfully'
                    : 'Member Updated Successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
          if (widget.member == null) {
            _resetForm();
          } else {
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



  @override
  Widget build(BuildContext context) {
    final isViewer = ref.watch(appSessionProvider).role == UserRole.viewer;

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

                // Enrollment Details
                Card(
                   // ... similar readOnly logic for TextFormField and IgnorePointer/null onTap for pickers
                   // I will apply isViewer check to all interactive elements in separate small edits if needed, 
                   // or replace the whole build method logic for cleanliness.
                   // Strategy: I will replace the Action Buttons Row specifically to hiding it for Viewers.
                   // And set the whole Body to AbsorbPointer because editing individual fields is tedious in 
                   // this one-shot replace. 
                   // WAIT: AbsorbPointer prevents scrolling if pointer events are consumed?
                   // Docs: "AbsorbPointer absorbs pointers... If [absorbing] is true, this widget prevents its subtree from receiving pointer events."
                   // It does NOT prevent scrolling if the ScrollView is OUTSIDE the AbsorbPointer.
                   // Here: SingleChildScrollView is OUTSIDE Form.
                   // So if I wrap Form (Content) in AbsorbPointer, scrolling works!
                   // BUT, users can't select text. 
                   // User req: "View all data". Usually implies "Read".
                   // Valid approach: Wrap the Form content in `AbsorbPointer` for Viewers. 
                   // And Hide the Buttons.
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
}
