import 'package:flutter/material.dart';
import 'dart:io';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../../core/app_gradients.dart';
import 'member_form_screen.dart';
import 'member_controller.dart';
import 'services/experience_certificate_service.dart';
import '../../core/auth/app_session.dart';

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

final memberSortAscendingProvider = StateProvider.autoDispose<bool>((ref) => true);

final memberListStreamProvider = StreamProvider.autoDispose<List<Member>>((
  ref,
) {
  final db = ref.watch(databaseProvider);
  final search = ref.watch(memberSearchQueryProvider);
  final bg = ref.watch(memberBloodGroupFilterProvider);
  final year = ref.watch(memberYearFilterProvider);
  final sortAsc = ref.watch(memberSortAscendingProvider);

  return db.membersDao.watchAllMembers(
    searchQuery: search,
    filterBloodGroup: bg,
    filterYear: year,
    sortAscending: sortAsc,
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
    final sortAscending = ref.watch(memberSortAscendingProvider);
    final isViewer = ref.watch(appSessionProvider).role == UserRole.viewer;

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
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Text(
                            'Showing ${members.length} Members',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          const Spacer(),
                          // External Sort Control
                          InkWell(
                            onTap: () {
                              ref.read(memberSortAscendingProvider.notifier).state = !sortAscending;
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    sortAscending ? "A - Z" : "Z - A",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    sortAscending ? Icons.arrow_downward : Icons.arrow_upward,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Card(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                          // sortColumnIndex: 1, // Name Column - Removed to hide arrow
                          // sortAscending: sortAscending,
                          columns: [
                            const DataColumn2(label: Text('PHOTO'), fixedWidth: 60), // New Column
                            const DataColumn2(
                              label: Text('NAME'),
                              size: ColumnSize.L,
                            ), 
                            const DataColumn2(label: Text('REG NO'), size: ColumnSize.L),
                            const DataColumn2(label: Text('MOBILE'), size: ColumnSize.L),
                            const DataColumn2(label: Text('ENROLLED'), size: ColumnSize.L),
                            const DataColumn2(label: Text('ACTIONS'), fixedWidth: 220),
                          ],
                          rows: members.map((m) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: m.profilePhotoPath != null
                                        ? Image.file(
                                            File(m.profilePhotoPath!),
                                            width: 36,
                                            height: 36,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 36,
                                            height: 36,
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.person, size: 20, color: Colors.grey),
                                          ),
                                  ),
                                ),
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
                                          showDialog(
                                            context: context,
                                            builder: (c) => _MemberDetailDialog(member: m),
                                          );
                                        },
                                      ),
                                      if (!isViewer) ...[ // HIDE EDIT/STATUS FOR VIEWER
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => MemberFormScreen(member: m),
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
                                              ref.read(memberControllerProvider).updateMemberStatus(m, newStatus);
                                            }
                                          },
                                          itemBuilder: (context) => MemberController.memberStatuses.map((status) {
                                              return PopupMenuItem(
                                                value: status, 
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.circle, size: 12, color: _getStatusColor(status)),
                                                    const SizedBox(width: 8),
                                                    Text(status),
                                                  ],
                                                ),
                                              );
                                          }).toList(),
                                        ),
                                      ],
                                      // Certificate download - available to all roles
                                      IconButton(
                                        icon: const Icon(Icons.card_membership, color: Colors.deepPurple),
                                        tooltip: 'Download Experience Certificate',
                                        onPressed: () async {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Generating certificate...')),
                                          );
                                          final path = await ExperienceCertificateService.generateAndOpen(m);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  path != null
                                                      ? 'Certificate saved & opened!'
                                                      : 'Failed to generate certificate.',
                                                ),
                                                backgroundColor: path != null ? Colors.green[700] : Colors.red[400],
                                              ),
                                            );
                                          }
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
                  ),
                ),
              ],
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

class _MemberDetailDialog extends ConsumerWidget {
  final Member member;
  const _MemberDetailDialog({required this.member});

  // ... (Keep helper methods like _row)
  
  Widget _row(String label, String value) {
     return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isViewer = ref.watch(appSessionProvider).role == UserRole.viewer;
    final fullName = [member.surname, member.firstName, member.middleName ?? ''].join(' ').trim();

    return AlertDialog(
      title: Row(
        children: [
           // ... (Avatar same as before)
           ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: member.profilePhotoPath != null
                ? Image.file(
                    File(member.profilePhotoPath!),
                    width: 48, height: 48, fit: BoxFit.cover,
                  )
                : Container(width: 48, height: 48, color: Colors.grey[200], child: const Icon(Icons.person, color: Colors.grey)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(fullName)),
        ],
      ),
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
                _row('Date of Birth:', DateFormat('dd/MM/yyyy').format(member.dateOfBirth!)),
              _row('Blood Group:', member.bloodGroup ?? '-'),
              const Divider(),
              // ... Enrolment ...
              _row('Enrollment (ABA):', member.enrollmentDateAba != null ? DateFormat('dd/MM/yyyy').format(member.enrollmentDateAba!) : '-'),
              _row('Enrollment (Bar):', member.enrollmentDateBar != null ? DateFormat('dd/MM/yyyy').format(member.enrollmentDateBar!) : '-'),
              const Divider(),
              _row('Mobile:', member.mobileNumber),
              _row('Email:', member.email ?? '-'),
              _row('Address:', member.address),
            ],
          ),
        ),
      ),
      actions: [
        // Experience Certificate button - available to all
        FilledButton.tonalIcon(
          onPressed: () async {
            Navigator.pop(context);
            final ctx = context;
            final path = await ExperienceCertificateService.generateAndOpen(member);
            if (ctx.mounted) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text(
                    path != null
                        ? 'Certificate saved & opened!'
                        : 'Failed to generate certificate.',
                  ),
                  backgroundColor: path != null ? Colors.green[700] : Colors.red[400],
                ),
              );
            }
          },
          icon: const Icon(Icons.card_membership),
          label: const Text('Certificate'),
        ),
        if (!isViewer)
        FilledButton.tonalIcon(
          onPressed: () {
            Navigator.pop(context); 
            Navigator.push(context, MaterialPageRoute(builder: (_) => MemberFormScreen(member: member)));
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
