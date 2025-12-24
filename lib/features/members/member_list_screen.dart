import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../../core/app_gradients.dart';
import 'member_form_screen.dart';
import 'member_controller.dart';

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

final memberListStreamProvider = StreamProvider<List<Member>>((
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
            elevation: 4,
            child: Container( // Using Container for gradient
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: AppGradients.filterDrawer(context),
              ),
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
                return Card(
                    margin: const EdgeInsets.all(16),
                    elevation: 4,
                    child: Container(
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: AppGradients.tableContainer(context),
                      ),
                      child: DataTable2(
                          scrollController: _verticalController,
                          headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                          columnSpacing: 12,
                          horizontalMargin: 12,
                          minWidth: 1000,
                          fixedLeftColumns: 1,
                          columns: const [
                            DataColumn2(label: Text('NAME'), size: ColumnSize.L), // Flexible width for equality
                            DataColumn2(label: Text('REG NO'), size: ColumnSize.L),
                            DataColumn2(label: Text('MOBILE'), size: ColumnSize.L),
                            DataColumn2(label: Text('ENROLLED'), size: ColumnSize.L),
                            DataColumn2(label: Text('ACTIONS'), fixedWidth: 150),
                          ],
                          rows: members.map((m) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    [
                                      m.surname,
                                      m.firstName,
                                      m.middleName ?? '',
                                    ]
                                        .join(' ')
                                        .trim()
                                        .replaceAll(RegExp(r'\s+'), ' '),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DataCell(Text(m.registrationNumber)),
                                DataCell(Text(m.mobileNumber)),
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
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
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
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  MemberFormScreen(member: m),
                                            ),
                                          );
                                        },
                                      ),

                                      PopupMenuButton<String>(
                                        icon: Icon(
                                          Icons.verified_user,
                                          color: _getStatusColor(m.memberStatus),
                                        ),
                                        tooltip: 'Change Status',
                                        onSelected: (String newStatus) {
                                          if (newStatus != m.memberStatus) {
                                            ref
                                                .read(memberControllerProvider)
                                                .updateMemberStatus(
                                                  m,
                                                  newStatus,
                                                );
                                          }
                                        },
                                        itemBuilder: (BuildContext context) {
                                          return MemberController.memberStatuses
                                              .map((String status) {
                                            return PopupMenuItem<String>(
                                              value: status,
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.circle,
                                                    size: 12,
                                                    color: _getStatusColor(status),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(status),
                                                  if (m.memberStatus == status) ...[
                                                    const Spacer(),
                                                    const Icon(Icons.check, size: 16),
                                                  ],
                                                ],
                                              ),
                                            );
                                          }).toList();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Inactive':
        return Colors.grey;
      case 'Suspended':
        return Colors.red;
      case 'Expired':
        return Colors.orange;
      case 'Deceased':
        return Colors.black;
      default:
        return Colors.blue;
    }
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
