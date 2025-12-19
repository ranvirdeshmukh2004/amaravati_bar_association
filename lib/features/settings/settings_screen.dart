import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../auth/auth_controller.dart';
import '../database/database_provider.dart';
import '../database/app_database.dart';

import 'data_export_service.dart';
// Needed for export sharing if we want or just file writing.
// User mentioned Export all donation data (CSV / Excel).

import '../../core/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _showChangePasswordDialog() {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final success = await ref
                    .read(authProvider.notifier)
                    .changePassword(currentController.text, newController.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Password Changed Successfully'
                            : 'Incorrect Current Password',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showRestoreConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This will overwrite ALL existing data (members, subscriptions, settings) with the backup file.',
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 16),
            Text('Are you sure you want to proceed?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(dataExportServiceProvider)
                  .restoreFullDataJson();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Restore Successful'
                          : 'Restore Failed/Cancelled',
                    ),
                    backgroundColor: success ? Colors.green : Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmationDialog() {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool deleteMembers = false;
    bool deleteSubscriptions = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Reset Data'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Select data to delete and confirm with password. This action cannot be undone.',
                      style: TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Delete All Members'),
                      value: deleteMembers,
                      onChanged: (v) =>
                          setState(() => deleteMembers = v == true),
                    ),
                    CheckboxListTile(
                      title: const Text('Delete All Subscriptions'),
                      value: deleteSubscriptions,
                      onChanged: (v) =>
                          setState(() => deleteSubscriptions = v == true),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Admin Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    if (!deleteMembers && !deleteSubscriptions) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Select at least one option'),
                        ),
                      );
                      return;
                    }

                    if (formKey.currentState!.validate()) {
                      final isValid = await ref
                          .read(authProvider.notifier)
                          .validatePassword(passwordController.text);

                      if (!context.mounted) return;

                      if (isValid) {
                        if (deleteMembers) {
                          await ref.read(databaseProvider).deleteMembers();
                        }
                        if (deleteSubscriptions) {
                          await ref
                              .read(databaseProvider)
                              .deleteSubscriptions();
                        }

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selected Data Reset Successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Incorrect Password'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Delete Selected'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSubscriptionConfigDialog() {
    final amountController = TextEditingController();
    final passwordController = TextEditingController();
    DateTime? selectedDate;
    final formKey = GlobalKey<FormState>();

    // Fetch current config
    final db = ref.read(databaseProvider);
    db.subscriptionConfigDao.getConfig().then((config) {
      if (mounted) {
        amountController.text = config?.monthlyAmount.toString() ?? '100.0';
        selectedDate =
            config?.subscriptionStartDate ??
            DateTime(DateTime.now().year, 4, 1);

        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: const Text('Subscription Configuration'),
                  content: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: amountController,
                            decoration: const InputDecoration(
                              labelText: 'Monthly Subscription Amount (₹)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (double.tryParse(v) == null)
                                return 'Invalid Number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              selectedDate == null
                                  ? 'Select Start Date'
                                  : 'Start Date: ${selectedDate!.toLocal().toString().split(' ')[0]}',
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() => selectedDate = picked);
                              }
                            },
                          ),
                          const Divider(),
                          const Text(
                            'Enter Admin Password to Save',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Admin Password',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v?.isEmpty == true ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          if (selectedDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a start date'),
                              ),
                            );
                            return;
                          }

                          // Validate Password
                          final isValid = await ref
                              .read(authProvider.notifier)
                              .validatePassword(passwordController.text);

                          if (!context.mounted) return;

                          if (isValid) {
                            await ref
                                .read(databaseProvider)
                                .subscriptionConfigDao
                                .updateConfig(
                                  double.parse(amountController.text),
                                  selectedDate!,
                                );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Configuration Saved'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Incorrect Password'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                );
              },
            );
          },
        );
      }
    });
  }

  void _showSecurityQuestionDialog() {
    final questionController = TextEditingController();
    final answerController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Pre-fill if exists (optional, keeping it blank for security typically)
    // But we can check if one is set.

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Security Question'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'This question will be used to recover your password if you forget it.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: questionController,
                    decoration: const InputDecoration(
                      labelText: 'Question (e.g., First Pet Name)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: answerController,
                    decoration: const InputDecoration(
                      labelText: 'Answer',
                      helperText: 'Case insensitive',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const Divider(),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Current Admin Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final isValid = await ref
                      .read(authProvider.notifier)
                      .validatePassword(passwordController.text);

                  if (!context.mounted) return;

                  if (isValid) {
                    final success = await ref
                        .read(authProvider.notifier)
                        .setSecurityQuestion(
                          questionController.text,
                          answerController.text,
                        );

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Security Question Updated'
                                : 'Error updating',
                          ),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Incorrect Password'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _seedMembers() async {
    try {
      final db = ref.read(databaseProvider);
      final now = DateTime.now();
      final random = now.millisecondsSinceEpoch;

      final firstNames = [
        'Aarav',
        'Vihaan',
        'Aditya',
        'Arjun',
        'Sai',
        'Rohan',
        'Ishaan',
        'Rahul',
        'Ananya',
        'Diya',
        'Sana',
        'Kavya',
        'Meera',
        'Priya',
        'Riya',
        'Sneha',
        'Zara',
        'Pooja',
        'Neha',
        'Tanvi',
      ];
      final lastNames = [
        'Sharma',
        'Verma',
        'Gupta',
        'Patel',
        'Singh',
        'Kumar',
        'Reddy',
        'Rao',
        'Nair',
        'Menon',
        'Iyer',
        'Joshi',
        'Mehta',
        'Shah',
        'Modi',
        'Gandhi',
        'Bose',
        'Dutta',
        'Das',
        'Roy',
      ];
      final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

      int count = 0;
      for (int i = 0; i < 20; i++) {
        final f = firstNames[i % firstNames.length];
        final l = lastNames[i % lastNames.length];
        // Unique Identifiers
        final reg = 'ABA/${2024}/$random-${i + 1}';
        final mobile = '98${(10000000 + i).toString()}';
        final email =
            '${f.toLowerCase()}.${l.toLowerCase()}${i + 1}@example.com';

        // Dates
        final dob = DateTime(1980 + (i % 20), (i % 12) + 1, (i % 28) + 1);
        final enrollBar = dob.add(
          const Duration(days: 365 * 22),
        ); // Enrolled at ~22
        final enrollAba = enrollBar.add(
          Duration(days: i * 15),
        ); // Joined ABA later

        await db.membersDao.insertMember(
          MembersCompanion(
            firstName: drift.Value(f),
            middleName: drift.Value(
              i % 3 == 0 ? 'Kumar' : (i % 3 == 1 ? 'Chandra' : null),
            ), // Occasional middle name
            surname: drift.Value(l),
            registrationNumber: drift.Value(reg),
            mobileNumber: drift.Value(mobile),
            email: drift.Value(email),
            address: drift.Value(
              'Flat ${101 + i}, Tower ${String.fromCharCode(65 + (i % 5))}, Amaravati, AP - 522020',
            ),
            age: drift.Value(now.year - dob.year),
            dateOfBirth: drift.Value(dob),
            bloodGroup: drift.Value(bloodGroups[i % bloodGroups.length]),
            enrollmentDateBar: drift.Value(enrollBar),
            enrollmentDateAba: drift.Value(enrollAba),
          ),
        );
        count++;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully seeded $count members with rich unique data',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error seeding members: $e')));
      }
    }
  }

  Future<void> _seedSubscriptions() async {
    try {
      final db = ref.read(databaseProvider);
      final members = await db.membersDao.getAllMembers();

      if (members.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No members found. Seed members first.'),
            ),
          );
        }
        return;
      }

      int count = 0;
      for (int i = 0; i < members.length; i++) {
        final member = members[i];

        // Logic:
        // 1 subscription per member
        // Amount: Multiples of 100 below 600 => 100, 200, 300, 400, 500
        final amount = ((i % 5) + 1) * 100.0;

        // Unique Date: Offset by i days to ensure every subscription has a different date
        // Use a base date of today and go backwards
        final date = DateTime.now().subtract(Duration(days: i + 1));

        // Unique receipt: REC-{MemberID}-{Random}-{i}
        final receipt =
            "REC-${member.id}-${DateTime.now().millisecondsSinceEpoch}-$i";

        await db.subscriptionsDao.insertSubscription(
          SubscriptionsCompanion(
            firstName: drift.Value(member.firstName),
            lastName: drift.Value(member.surname),
            mobileNumber: drift.Value(member.mobileNumber),
            enrollmentNumber: drift.Value(member.registrationNumber),
            address: drift.Value(member.address),
            amount: drift.Value(amount),
            paymentMode: drift.Value(i % 2 == 0 ? 'Cash' : 'UPI'),
            subscriptionDate: drift.Value(date),
            receiptNumber: drift.Value(receipt),
          ),
        );
        count++;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully added $count test subscriptions'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error seeding subscriptions: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionHeader(title: 'General'),
          Consumer(
            builder: (context, ref, child) {
              final themeMode = ref.watch(themeProvider);
              final isDark = themeMode == ThemeMode.dark;
              return SwitchListTile(
                title: const Text('Dark Mode'),
                value: isDark,
                onChanged: (value) {
                  ref.read(themeProvider.notifier).toggleTheme(value);
                },
              );
            },
          ),
          const Divider(),
          const _SectionHeader(title: 'Security'),
          ListTile(
            leading: const Icon(Icons.password),
            title: const Text('Change Admin Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showChangePasswordDialog,
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Set Security Question'),
            subtitle: const Text('For password recovery'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showSecurityQuestionDialog,
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Subscription Configuration'),
            subtitle: const Text('Set Amount & Start Date'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showSubscriptionConfigDialog,
          ),
          const Divider(),
          const _SectionHeader(title: 'Data Management'),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Export Members (CSV)'),
            subtitle: const Text('Download member list'),
            onTap: () async {
              await ref.read(dataExportServiceProvider).exportMembersCsv();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Members export prompt opened')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Export Subscriptions (CSV)'),
            subtitle: const Text('Download subscription records'),
            onTap: () async {
              await ref
                  .read(dataExportServiceProvider)
                  .exportSubscriptionsCsv();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Subscriptions export prompt opened'),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Full Backup (JSON)'),
            subtitle: const Text('Export all data for backup'),
            onTap: () async {
              await ref.read(dataExportServiceProvider).exportFullDataJson();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Full backup prompt opened')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore, color: Colors.orange),
            title: const Text(
              'Restore Data (JSON)',
              style: TextStyle(color: Colors.orange),
            ),
            subtitle: const Text('Overwrite app data from backup'),
            onTap: _showRestoreConfirmationDialog,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Reset All Data',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Warning: This cannot be undone'),
            onTap: _showResetConfirmationDialog,
          ),
          ListTile(
            leading: const Icon(Icons.science, color: Colors.purple),
            title: const Text(
              'Seed Test Data (Debug)',
              style: TextStyle(color: Colors.purple),
            ),
            subtitle: const Text('Insert 20 random members'),
            onTap: _seedMembers,
          ),
          ListTile(
            leading: const Icon(Icons.science, color: Colors.deepPurple),
            title: const Text(
              'Seed Subscriptions (Debug)',
              style: TextStyle(color: Colors.deepPurple),
            ),
            subtitle: const Text(
              'Add 1 subscription per member (Unique Date/Amount)',
            ),
            onTap: _seedSubscriptions,
          ),
          const Divider(),
          const _SectionHeader(title: 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Amaravati Bar Association'),
            subtitle: Text('Donation Management System v1.0.0'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
