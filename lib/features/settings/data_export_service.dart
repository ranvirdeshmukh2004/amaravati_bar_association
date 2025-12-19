import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';

final dataExportServiceProvider = Provider<DataExportService>((ref) {
  return DataExportService(ref.read(databaseProvider));
});

class DataExportService {
  final AppDatabase _db;

  DataExportService(this._db);

  /// Helper to pick a save location (for Desktop) or return a temp path (for sharing logic if adding later)
  /// For Windows, we use FilePicker.platform.saveFile
  Future<String?> _pickSavePath({required String fileName}) async {
    return await FilePicker.platform.saveFile(
      dialogTitle: 'Save Export',
      fileName: fileName,
    );
  }

  Future<void> exportMembersCsv() async {
    final members = await _db.membersDao.getAllMembers();

    final List<List<dynamic>> rows = [];
    // Header
    rows.add([
      'ID',
      'Registration Number',
      'First Name',
      'Surname',
      'Middle Name',
      'Age',
      'Mobile Number',
      'Address',
      'Email',
      'Enrollment Date ABA',
      'Enrollment Date BAR',
      'Date of Birth',
      'Blood Group',
      'Created At',
    ]);

    for (var m in members) {
      rows.add([
        m.id,
        m.registrationNumber,
        m.firstName,
        m.surname,
        m.middleName,
        m.age,
        m.mobileNumber,
        m.address,
        m.email,
        m.enrollmentDateAba?.toIso8601String(),
        m.enrollmentDateBar?.toIso8601String(),
        m.dateOfBirth?.toIso8601String(),
        m.bloodGroup,
        m.createdAt.toIso8601String(),
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);
    final fileName =
        'members_export_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
    final path = await _pickSavePath(fileName: fileName);

    if (path != null) {
      final file = File(path);
      await file.writeAsString(csvData);
      debugPrint('Members exported to $path');
    }
  }

  Future<void> exportSubscriptionsCsv() async {
    final subs = await _db.subscriptionsDao.getAllSubscriptions();

    final List<List<dynamic>> rows = [];
    rows.add([
      'ID',
      'Receipt Number',
      'Date',
      'Enrollment Number',
      'Name',
      'Amount',
      'Payment Mode',
      'Transaction Info',
      'Mobile',
      'Email',
      'Address',
    ]);

    for (var s in subs) {
      rows.add([
        s.id,
        s.receiptNumber,
        s.subscriptionDate.toIso8601String(),
        s.enrollmentNumber,
        '${s.firstName} ${s.lastName}',
        s.amount,
        s.paymentMode,
        s.transactionInfo,
        s.mobileNumber,
        s.email,
        s.address,
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);
    final fileName =
        'subscriptions_export_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
    final path = await _pickSavePath(fileName: fileName);

    if (path != null) {
      final file = File(path);
      await file.writeAsString(csvData);
      debugPrint('Subscriptions exported to $path');
    }
  }

  /// Exports ALL data (Members, Subscriptions, Config) to a single JSON file
  /// This file is intended for Backup/Restore purposes.
  Future<void> exportFullDataJson() async {
    final members = await _db.membersDao.getAllMembers();
    final subs = await _db.subscriptionsDao.getAllSubscriptions();
    final config = await _db.subscriptionConfigDao.getConfig();

    final Map<String, dynamic> data = {
      'meta': {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'app_version': 4, // Schema version
      },
      'members': members.map((m) => m.toJson()).toList(),
      'subscriptions': subs.map((s) => s.toJson()).toList(),
      'config': config?.toJson(),
    };

    final jsonString = jsonEncode(data);
    final fileName =
        'full_backup_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.json';
    final path = await _pickSavePath(fileName: fileName);

    if (path != null) {
      final file = File(path);
      await file.writeAsString(jsonString);
      debugPrint('Full backup exported to $path');
    }
  }

  /// Restores data from a JSON file.
  /// returns true if successful, false otherwise.
  Future<bool> restoreFullDataJson() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) {
      return false; // User canceled
    }

    final file = File(result.files.single.path!);
    final content = await file.readAsString();

    try {
      final Map<String, dynamic> data = jsonDecode(content);

      // Validate structure basic
      if (!data.containsKey('members') || !data.containsKey('subscriptions')) {
        throw Exception('Invalid backup file format');
      }

      final List<dynamic> membersJson = data['members'];
      final List<dynamic> subsJson = data['subscriptions'];
      final Map<String, dynamic>? configJson = data['config'];

      await _db.transaction(() async {
        // 1. Clear existing data
        await _db.deleteMembers();
        await _db.deleteSubscriptions();
        await _db.delete(_db.subscriptionConfig).go();

        // 2. Insert Members
        for (var m in membersJson) {
          await _db.membersDao.insertMember(
            MembersCompanion(
              surname: Value(m['surname']),
              firstName: Value(m['firstName']),
              middleName: Value(m['middleName']),
              age: Value(m['age']),
              dateOfBirth: Value(
                m['dateOfBirth'] != null
                    ? DateTime.parse(m['dateOfBirth'])
                    : null,
              ),
              bloodGroup: Value(m['bloodGroup']),
              enrollmentDateAba: Value(
                m['enrollmentDateAba'] != null
                    ? DateTime.parse(m['enrollmentDateAba'])
                    : null,
              ),
              enrollmentDateBar: Value(
                m['enrollmentDateBar'] != null
                    ? DateTime.parse(m['enrollmentDateBar'])
                    : null,
              ),
              registrationNumber: Value(m['registrationNumber']),
              address: Value(m['address']),
              mobileNumber: Value(m['mobileNumber']),
              email: Value(m['email']),
              createdAt: Value(DateTime.parse(m['createdAt'])),
            ),
          );
        }

        // 3. Insert Subscriptions
        for (var s in subsJson) {
          // Check if 'amount' is int or double in JSON and handle safe cast
          final amount = (s['amount'] as num).toDouble();

          await _db.subscriptionsDao.insertSubscription(
            SubscriptionsCompanion(
              firstName: Value(s['firstName']),
              lastName: Value(s['lastName']),
              address: Value(s['address']),
              mobileNumber: Value(s['mobileNumber']),
              email: Value(s['email']),
              enrollmentNumber: Value(s['enrollmentNumber']),
              amount: Value(amount),
              paymentMode: Value(s['paymentMode']),
              transactionInfo: Value(s['transactionInfo']),
              subscriptionDate: Value(DateTime.parse(s['subscriptionDate'])),
              receiptNumber: Value(s['receiptNumber']),
            ),
          );
        }

        // 4. Insert Config
        if (configJson != null) {
          await _db.subscriptionConfigDao.updateConfig(
            (configJson['monthlyAmount'] as num).toDouble(),
            DateTime.parse(configJson['subscriptionStartDate']),
          );
        }
      });
      return true;
    } catch (e) {
      debugPrint('Restore failed: $e');
      return false; // Or rethrow
    }
  }
}
