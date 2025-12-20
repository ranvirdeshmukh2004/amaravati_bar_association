import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import 'member_controller.dart';
import '../database/app_database.dart';

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
  DateTime? _dob;
  DateTime? _enrollmentAba;
  DateTime? _enrollmentBar;

  bool _isLoading = false;

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
            enrollmentDateAba: drift.Value(_enrollmentAba),
            enrollmentDateBar: drift.Value(_enrollmentBar),
            registrationNumber: _regNoController.text,
            address: _addressController.text,
            mobileNumber: _mobileController.text,
            email: drift.Value(
              _emailController.text.isNotEmpty ? _emailController.text : null,
            ),
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
      _enrollmentAba = null;
      _enrollmentBar = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Member')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Personal Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                              decoration: const InputDecoration(
                                labelText: 'Surname *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) =>
                                  v?.isEmpty == true ? 'Required' : null,
                              onChanged: (val) {
                                final capped = _capitalize(val);
                                if (capped != val) {
                                  _surnameController.value = TextEditingValue(
                                    text: capped,
                                    selection: TextSelection.collapsed(
                                      offset: capped.length,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'First Name *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) =>
                                  v?.isEmpty == true ? 'Required' : null,
                              onChanged: (val) {
                                final capped = _capitalize(val);
                                if (capped != val) {
                                  _firstNameController.value = TextEditingValue(
                                    text: capped,
                                    selection: TextSelection.collapsed(
                                      offset: capped.length,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _middleNameController,
                              decoration: const InputDecoration(
                                labelText: 'Middle Name',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) {
                                final capped = _capitalize(val);
                                if (capped != val) {
                                  _middleNameController.value =
                                      TextEditingValue(
                                        text: capped,
                                        selection: TextSelection.collapsed(
                                          offset: capped.length,
                                        ),
                                      );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _ageController,
                              decoration: const InputDecoration(
                                labelText: 'Age *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) =>
                                  v?.isEmpty == true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _bloodGroup,
                              decoration: const InputDecoration(
                                labelText: 'Blood Group',
                                border: OutlineInputBorder(),
                              ),
                              items: _bloodGroups
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() => _bloodGroup = v),
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enrollment Details',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _regNoController,
                        decoration: const InputDecoration(
                          labelText: 'Registration Number *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(
                                context,
                                onPicked: (d) => _enrollmentAba = d,
                              ),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date of Enrollment (ABA)',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _enrollmentAba == null
                                      ? 'Select Date'
                                      : DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(_enrollmentAba!),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(
                                context,
                                onPicked: (d) => _enrollmentBar = d,
                              ),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date of Enrollment (Bar Council)',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _enrollmentBar == null
                                      ? 'Select Date'
                                      : DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(_enrollmentBar!),
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                        decoration: const InputDecoration(
                          labelText: 'Address *',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (v) =>
                            v?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _mobileController,
                              decoration: const InputDecoration(
                                labelText: 'Mobile Number *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              validator: (v) =>
                                  (v?.isEmpty == true || v!.length != 10)
                                  ? 'Valid 10-digit number required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v != null && v.isNotEmpty) {
                                  if (!v.contains('@') || !v.contains('.')) {
                                    return 'Invalid Email';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _resetForm,
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text('Save Member'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
