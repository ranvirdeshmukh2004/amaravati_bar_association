import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'subscription_service.dart';

class SubscriptionExportService {
  Future<bool> exportToCsv(List<SubscriptionStatus> data) async {
    try {
      // 1. Convert data to List<List<dynamic>>
      List<List<dynamic>> rows = [];

      // Header
      rows.add([
        'Member Name',
        'Registration Number',
        'Mobile Number',
        'Enrollment Date',
        'Months Active',
        'Total Expected',
        'Total Paid',
        'Balance Due',
        'Status',
      ]);

      // Rows
      for (var status in data) {
        rows.add([
          '${status.member.firstName} ${status.member.surname}',
          status.member.registrationNumber,
          status.member.mobileNumber,
          status.member.enrollmentDateAba != null
              ? DateFormat(
                  'dd-MM-yyyy',
                ).format(status.member.enrollmentDateAba!)
              : '-',
          status.totalMonths,
          status.totalExpected.toStringAsFixed(2),
          status.totalPaid.toStringAsFixed(2),
          status.balance.toStringAsFixed(2),
          status.statusText,
        ]);
      }

      // 2. Generate CSV String
      String csv = const ListToCsvConverter().convert(rows);

      // 3. Save to File
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Subscription Report',
        fileName:
            'subscription_report_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv',
        allowedExtensions: ['csv'],
        type: FileType.custom,
      );

      if (outputFile != null) {
        // Ensure extension
        if (!outputFile.toLowerCase().endsWith('.csv')) {
          outputFile = '$outputFile.csv';
        }
        final file = File(outputFile);
        await file.writeAsString(csv);
        return true;
      }
      return false; // User cancelled
    } catch (e) {
      // Handle errors
      return false;
    }
  }
}

final subscriptionExportProvider = Provider(
  (ref) => SubscriptionExportService(),
);
