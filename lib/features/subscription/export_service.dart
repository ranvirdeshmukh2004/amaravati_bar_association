import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'subscription_service.dart';

/// Additional optional fields that can be toggled on for both list types.
class ExtraField {
  final String label;
  final String key;
  bool selected;

  ExtraField({required this.label, required this.key, this.selected = false});
}

/// Returns the list of extra fields available for the Voter List download.
List<ExtraField> voterListExtraFields() => [
  ExtraField(label: 'Registration Number', key: 'regNo'),
  ExtraField(label: 'Email', key: 'email'),
  ExtraField(label: 'Address', key: 'address'),
  ExtraField(label: 'Enrollment Date (ABA)', key: 'enrollDateAba'),
  ExtraField(label: 'Enrollment Date (Bar)', key: 'enrollDateBar'),
  ExtraField(label: 'Blood Group', key: 'bloodGroup'),
  ExtraField(label: 'Age', key: 'age'),
  ExtraField(label: 'Member Status', key: 'memberStatus'),
];

/// Returns the list of extra fields available for the Pending People download.
List<ExtraField> pendingListExtraFields() => [
  ExtraField(label: 'Registration Number', key: 'regNo'),
  ExtraField(label: 'Email', key: 'email'),
  ExtraField(label: 'Address', key: 'address'),
  ExtraField(label: 'Arrears Amount', key: 'arrears'),
  ExtraField(label: 'Total Expected', key: 'totalExpected'),
  ExtraField(label: 'Total Paid', key: 'totalPaid'),
  ExtraField(label: 'Enrollment Date (ABA)', key: 'enrollDateAba'),
  ExtraField(label: 'Member Status', key: 'memberStatus'),
];

class SubscriptionExportService {
  /// Exports the Provisional Voter List (fully paid members only) as XLSX.
  Future<bool> exportVoterListXlsx(
    List<SubscriptionStatus> allStatuses, {
    List<ExtraField>? extraFields,
  }) async {
    try {
      // Filter only fully paid members (balance <= 0)
      final paidMembers =
          allStatuses.where((s) => s.balance <= 0).toList();

      final excel = Excel.createExcel();
      final sheetName = 'Provisional Voter List';
      final sheet = excel[sheetName];
      // Remove default "Sheet1" if it exists
      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      // --- Build header row ---
      final headers = <String>['Sr. No.', 'Name', 'Phone Number'];
      final selectedExtras =
          extraFields?.where((f) => f.selected).toList() ?? [];
      for (final extra in selectedExtras) {
        headers.add(extra.label);
      }

      // Title row
      sheet.appendRow([TextCellValue('Provisional Voter List')]);
      // Merge title across header cols
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
        CellIndex.indexByColumnRow(
          columnIndex: headers.length - 1,
          rowIndex: 0,
        ),
      );
      // Style title
      final titleCell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      );
      titleCell.cellStyle = CellStyle(
        bold: true,
        fontSize: 16,
        horizontalAlign: HorizontalAlign.Center,
      );

      // Empty row for spacing
      sheet.appendRow([TextCellValue('')]);

      // Header row
      sheet.appendRow(
        headers.map((h) => TextCellValue(h)).toList(),
      );
      // Style header cells
      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 2),
        );
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#4472C4'),
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        );
      }

      // --- Data rows ---
      for (int i = 0; i < paidMembers.length; i++) {
        final s = paidMembers[i];
        final row = <CellValue>[
          IntCellValue(i + 1),
          TextCellValue(
            '${s.member.firstName} ${s.member.surname}'.trim(),
          ),
          TextCellValue(s.member.mobileNumber),
        ];

        for (final extra in selectedExtras) {
          row.add(_getMemberExtraValue(s, extra.key));
        }

        sheet.appendRow(row);
      }

      // --- Save file ---
      return await _saveExcelFile(
        excel,
        'provisional_voter_list_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}',
      );
    } catch (e) {
      debugPrint('Error exporting voter list: $e');
      return false;
    }
  }

  /// Exports Pending People Details (members with balance > 0) as XLSX.
  Future<bool> exportPendingListXlsx(
    List<SubscriptionStatus> allStatuses, {
    List<ExtraField>? extraFields,
  }) async {
    try {
      // Filter only pending members (balance > 0)
      final pendingMembers =
          allStatuses.where((s) => s.balance > 0).toList();
      pendingMembers.sort((a, b) => b.balance.compareTo(a.balance));

      final excel = Excel.createExcel();
      final sheetName = 'Pending People Details';
      final sheet = excel[sheetName];
      if (excel.sheets.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      // --- Build header row ---
      final headers = <String>[
        'Sr. No.',
        'Name',
        'Phone Number',
        'Due Amount',
      ];
      final selectedExtras =
          extraFields?.where((f) => f.selected).toList() ?? [];
      for (final extra in selectedExtras) {
        headers.add(extra.label);
      }

      // Title row
      sheet.appendRow([TextCellValue('Pending People Details')]);
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
        CellIndex.indexByColumnRow(
          columnIndex: headers.length - 1,
          rowIndex: 0,
        ),
      );
      final titleCell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      );
      titleCell.cellStyle = CellStyle(
        bold: true,
        fontSize: 16,
        horizontalAlign: HorizontalAlign.Center,
      );

      // Empty row
      sheet.appendRow([TextCellValue('')]);

      // Header row
      sheet.appendRow(
        headers.map((h) => TextCellValue(h)).toList(),
      );
      for (int col = 0; col < headers.length; col++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 2),
        );
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#C0504D'),
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        );
      }

      // --- Data rows ---
      for (int i = 0; i < pendingMembers.length; i++) {
        final s = pendingMembers[i];
        final row = <CellValue>[
          IntCellValue(i + 1),
          TextCellValue(
            '${s.member.firstName} ${s.member.surname}'.trim(),
          ),
          TextCellValue(s.member.mobileNumber),
          DoubleCellValue(s.balance),
        ];

        for (final extra in selectedExtras) {
          row.add(_getMemberExtraValue(s, extra.key));
        }

        sheet.appendRow(row);
      }

      // --- Save file ---
      return await _saveExcelFile(
        excel,
        'pending_people_details_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}',
      );
    } catch (e) {
      debugPrint('Error exporting pending list: $e');
      return false;
    }
  }

  /// Resolves an extra field key to its CellValue from a SubscriptionStatus.
  CellValue _getMemberExtraValue(SubscriptionStatus s, String key) {
    switch (key) {
      case 'regNo':
        return TextCellValue(s.member.registrationNumber);
      case 'email':
        return TextCellValue(s.member.email ?? '');
      case 'address':
        return TextCellValue(s.member.address);
      case 'enrollDateAba':
        return TextCellValue(
          s.member.enrollmentDateAba != null
              ? DateFormat('dd-MM-yyyy').format(s.member.enrollmentDateAba!)
              : '-',
        );
      case 'enrollDateBar':
        return TextCellValue(
          s.member.enrollmentDateBar != null
              ? DateFormat('dd-MM-yyyy').format(s.member.enrollmentDateBar!)
              : '-',
        );
      case 'bloodGroup':
        return TextCellValue(s.member.bloodGroup ?? '');
      case 'age':
        return IntCellValue(s.member.age);
      case 'memberStatus':
        return TextCellValue(s.member.memberStatus);
      case 'arrears':
        return DoubleCellValue(s.pastOutstanding);
      case 'totalExpected':
        return DoubleCellValue(s.totalExpected);
      case 'totalPaid':
        return DoubleCellValue(s.totalPaid);
      default:
        return TextCellValue('');
    }
  }

  /// Saves an Excel object to disk via a file picker dialog.
  Future<bool> _saveExcelFile(Excel excel, String defaultName) async {
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Download List',
      fileName: '$defaultName.xlsx',
      allowedExtensions: ['xlsx'],
      type: FileType.custom,
    );

    if (outputFile != null) {
      if (!outputFile.toLowerCase().endsWith('.xlsx')) {
        outputFile = '$outputFile.xlsx';
      }
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final file = File(outputFile);
        await file.writeAsBytes(fileBytes);
        return true;
      }
    }
    return false;
  }
}

final subscriptionExportProvider = Provider(
  (ref) => SubscriptionExportService(),
);
