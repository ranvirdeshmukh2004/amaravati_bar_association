import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import '../database/database_provider.dart';
import '../database/app_database.dart'; // For YearlySummary

class YearHistoryScreen extends ConsumerStatefulWidget {
  const YearHistoryScreen({super.key});

  @override
  ConsumerState<YearHistoryScreen> createState() => _YearHistoryScreenState();
}

class _YearHistoryScreenState extends ConsumerState<YearHistoryScreen> {
  String? _selectedYear;

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription History')),
      body: Column(
        children: [
          // Year Filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<List<YearlySummary>>(
              future: db.yearlySummariesDao.watchAllSummaries().first,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                
                final summaries = snapshot.data!;
                final years = summaries.map((e) => e.financialYear).toSet().toList();
                years.sort(); // Sorting years might be needed

                if (years.isEmpty) return const Text("No history available.");

                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Financial Year',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedYear,
                  items: years.map((y) {
                    return DropdownMenuItem(value: y, child: Text(y));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedYear = val;
                    });
                  },
                );
              },
            ),
          ),

          // Data Table
          Expanded(
            child: _selectedYear == null
                ? const Center(child: Text("Select a year to view details"))
                : FutureBuilder<List<YearlySummary>>(
                    future: db.yearlySummariesDao.getSummariesForYear(_selectedYear!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("No data found for selected year."));
                      }

                      final data = snapshot.data!;

                      return Card(
                        margin: const EdgeInsets.all(16),
                        child: DataTable2(
                          columnSpacing: 12,
                          horizontalMargin: 12,
                          minWidth: 800,
                          columns: const [
                            DataColumn2(label: Text('REG NO'), fixedWidth: 100),
                            DataColumn2(label: Text('EXPECTED'), size: ColumnSize.S),
                            DataColumn2(label: Text('PAID'), size: ColumnSize.S),
                            DataColumn2(label: Text('BALANCE'), size: ColumnSize.S),
                            DataColumn2(label: Text('STATUS'), size: ColumnSize.S),
                          ],
                          rows: data.map((s) {
                            return DataRow(cells: [
                              DataCell(Text(s.enrollmentNumber)),
                              DataCell(Text('₹${s.totalExpected.toStringAsFixed(0)}')),
                              DataCell(Text('₹${s.totalPaid.toStringAsFixed(0)}')),
                              DataCell(Text(
                                '₹${s.balance.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: s.balance > 0 ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                              DataCell(Text(s.status)),
                            ]);
                          }).toList(),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
