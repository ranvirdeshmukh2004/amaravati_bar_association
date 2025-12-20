import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import 'member_form_screen.dart';

final memberSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);
final memberBloodGroupFilterProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);
final memberYearFilterProvider = StateProvider.autoDispose<int?>((ref) => null);
final memberFilterTypeProvider = StateProvider.autoDispose<String?>(
  (ref) => null,
);

final memberListStreamProvider = StreamProvider.autoDispose<List<Member>>((
  ref,
) {
  final db = ref.watch(databaseProvider);
  final search = ref.watch(memberSearchQueryProvider);
  final bg = ref.watch(memberBloodGroupFilterProvider);
  final year = ref.watch(memberYearFilterProvider);

  return db.membersDao.watchAllMembers(
    searchQuery: search,
    filterBloodGroup: bg,
    filterYear: year,
  );
});

class MemberListScreen extends ConsumerStatefulWidget {
  const MemberListScreen({super.key});

  @override
  ConsumerState<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends ConsumerState<MemberListScreen> {
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(memberListStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Member Records')),
      body: Column(
        children: [
          // Filters
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search (Name, RegNo, Mobile)',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) =>
                        ref.read(memberSearchQueryProvider.notifier).state =
                            val,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // 1. Filter Type Selector
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Filter By',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: ref.watch(memberFilterTypeProvider),
                          items: const [
                            DropdownMenuItem(value: null, child: Text('None')),
                            DropdownMenuItem(
                              value: 'blood_group',
                              child: Text('Blood Group'),
                            ),
                            DropdownMenuItem(
                              value: 'enrollment_year',
                              child: Text('Enrollment Year'),
                            ),
                          ],
                          onChanged: (val) {
                            // Reset values when type changes
                            ref.read(memberFilterTypeProvider.notifier).state =
                                val;
                            ref
                                    .read(
                                      memberBloodGroupFilterProvider.notifier,
                                    )
                                    .state =
                                null;
                            ref.read(memberYearFilterProvider.notifier).state =
                                null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),

                      // 2. Dynamic Value Selector
                      Expanded(
                        flex: 2,
                        child: Consumer(
                          builder: (context, ref, child) {
                            final type = ref.watch(memberFilterTypeProvider);

                            if (type == 'blood_group') {
                              return DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Select Blood Group',
                                  border: OutlineInputBorder(),
                                ),
                                initialValue: ref.watch(
                                  memberBloodGroupFilterProvider,
                                ),
                                items:
                                    [
                                          'A+',
                                          'A-',
                                          'B+',
                                          'B-',
                                          'AB+',
                                          'AB-',
                                          'O+',
                                          'O-',
                                        ]
                                        .map(
                                          (bg) => DropdownMenuItem(
                                            value: bg,
                                            child: Text(bg),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (val) {
                                  ref
                                          .read(
                                            memberBloodGroupFilterProvider
                                                .notifier,
                                          )
                                          .state =
                                      val;
                                },
                              );
                            } else if (type == 'enrollment_year') {
                              return DropdownButtonFormField<int>(
                                decoration: const InputDecoration(
                                  labelText: 'Select Year',
                                  border: OutlineInputBorder(),
                                ),
                                initialValue: ref.watch(
                                  memberYearFilterProvider,
                                ),
                                items: List.generate(50, (index) {
                                  final year = DateTime.now().year - index;
                                  return DropdownMenuItem(
                                    value: year,
                                    child: Text(year.toString()),
                                  );
                                }),
                                onChanged: (val) {
                                  ref
                                          .read(
                                            memberYearFilterProvider.notifier,
                                          )
                                          .state =
                                      val;
                                },
                              );
                            } else {
                              return const SizedBox.shrink(); // No secondary input needed
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 3. Clear Filter Button (only visible if filter is active)
                      if (ref.watch(memberFilterTypeProvider) != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: "Clear Filter",
                          onPressed: () {
                            ref.read(memberFilterTypeProvider.notifier).state =
                                null;
                            ref
                                    .read(
                                      memberBloodGroupFilterProvider.notifier,
                                    )
                                    .state =
                                null;
                            ref.read(memberYearFilterProvider.notifier).state =
                                null;
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: membersAsync.when(
              data: (members) {
                if (members.isEmpty) {
                  return const Center(child: Text('No members found.'));
                }
                return Scrollbar(
                  controller: _verticalController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    controller: _verticalController,
                    scrollDirection: Axis.vertical,
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columnSpacing: 20,
                        horizontalMargin: 12,
                        columns: const [
                          DataColumn(label: Text('Reg No')),
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Mobile')),
                          DataColumn(label: Text('Blood Group')),
                          DataColumn(label: Text('Enrolled')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: members.map((m) {
                          return DataRow(
                            cells: [
                              DataCell(Text(m.registrationNumber)),
                              DataCell(
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    [m.surname, m.firstName, m.middleName ?? '']
                                        .join(' ')
                                        .trim()
                                        .replaceAll(RegExp(r'\s+'), ' '),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(Text(m.mobileNumber)),
                              DataCell(Text(m.bloodGroup ?? '-')),
                              DataCell(
                                Text(
                                  m.enrollmentDateAba != null
                                      ? DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(m.enrollmentDateAba!)
                                      : '-',
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.visibility),
                                  onPressed: () {
                                    // Open Details
                                    showDialog(
                                      context: context,
                                      builder: (c) =>
                                          _MemberDetailDialog(member: m),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberDetailDialog extends StatelessWidget {
  final Member member;
  const _MemberDetailDialog({required this.member});

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullName = [
      member.surname,
      member.firstName,
      member.middleName ?? '',
    ].join(' ').trim().replaceAll(RegExp(r'\s+'), ' ');

    return AlertDialog(
      title: Text(fullName),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row('Registration No:', member.registrationNumber),
              const Divider(),
              _row('Full Name:', fullName),
              _row('Age:', '${member.age}'),
              if (member.dateOfBirth != null)
                _row(
                  'Date of Birth:',
                  DateFormat('dd/MM/yyyy').format(member.dateOfBirth!),
                ),
              _row('Blood Group:', member.bloodGroup ?? '-'),
              const Divider(),
              _row(
                'Enrollment (ABA):',
                member.enrollmentDateAba != null
                    ? DateFormat('dd/MM/yyyy').format(member.enrollmentDateAba!)
                    : '-',
              ),
              _row(
                'Enrollment (Bar):',
                member.enrollmentDateBar != null
                    ? DateFormat('dd/MM/yyyy').format(member.enrollmentDateBar!)
                    : '-',
              ),
              const Divider(),
              _row('Mobile:', member.mobileNumber),
              _row('Email:', member.email ?? '-'),
              _row('Address:', member.address),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton.tonalIcon(
          onPressed: () {
            Navigator.pop(context); // Close dialog
            // Navigate to edit
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MemberFormScreen(member: member),
              ),
            );
          },
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
