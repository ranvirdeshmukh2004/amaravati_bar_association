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

/// Custom serializer that writes DateTime as ISO 8601 strings
/// instead of Drift's default Unix millisecond timestamps.
class _IsoDateSerializer extends ValueSerializer {
  const _IsoDateSerializer();

  static const _fallback = ValueSerializer.defaults();

  @override
  T fromJson<T>(dynamic json) {
    if (json is int && T == DateTime) {
      return DateTime.fromMillisecondsSinceEpoch(json) as T;
    }
    if (json is int && null is T && T != int && T != double && T != num && T != bool) {
      // T is likely DateTime? — a nullable DateTime
      return DateTime.fromMillisecondsSinceEpoch(json) as T;
    }
    return _fallback.fromJson<T>(json);
  }

  @override
  dynamic toJson<T>(T value) {
    if (value is DateTime) return value.toIso8601String();
    return _fallback.toJson<T>(value);
  }
}

class DataExportService {
  final AppDatabase _db;
  static const _isoSerializer = _IsoDateSerializer();

  DataExportService(this._db);

  /// Safely parses DateTime from JSON — handles both int (Unix ms) and String (ISO 8601).
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static DateTime _parseDateRequired(dynamic value) {
    return _parseDate(value) ?? DateTime.now();
  }

  /// Helper to pick a save location (for Desktop).
  /// [allowedExtensions] ensures Windows enforces the file extension.
  Future<String?> _pickSavePath({
    required String fileName,
    List<String>? allowedExtensions,
  }) async {
    return await FilePicker.platform.saveFile(
      dialogTitle: 'Save Export',
      fileName: fileName,
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
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
      'Member Status',
      'Profile Photo Path',
      'Remarks',
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
        m.memberStatus,
        m.profilePhotoPath,
        m.remarks,
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
      'Receipt Type',
      'Daily Sequence',
      'Notes',
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
        s.receiptType,
        s.dailySequence,
        s.notes,
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);
    final fileName =
        'subscriptions_export_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
    final path = await _pickSavePath(fileName: fileName);

    if (path != null) {
      final file = File(path);
      await file.writeAsString(csvData);
      await file.writeAsString(csvData);
      debugPrint('Subscriptions exported to $path');
    }
  }

  Future<void> exportDonationsCsv() async {
    final donations = await _db.donationsDao.getAllDonations();

    final List<List<dynamic>> rows = [];
    rows.add([
      'Receipt Number',
      'Date',
      'Donor Name',
      'Donor Type',
      'Member ID',
      'Amount',
      'Payment Mode',
      'Reference',
      'Purpose',
      'Daily Sequence',
      'Donor Mobile',
      'Donor Email',
      'Donor Address',
      'Organization',
    ]);

    for (var d in donations) {
      rows.add([
        d.receiptNumber,
        d.donationDate.toIso8601String(),
        d.donorName,
        d.donorType,
        d.memberId ?? '',
        d.amount,
        d.paymentMode,
        d.transactionRef ?? '',
        d.purpose ?? '',
        d.dailySequence,
        d.donorMobile ?? '',
        d.donorEmail ?? '',
        d.donorAddress ?? '',
        d.organization ?? '',
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);
    final fileName = 'donations_export_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
    final path = await _pickSavePath(fileName: fileName);

    if (path != null) {
      final file = File(path);
      await file.writeAsString(csvData);
      debugPrint('Donations exported to $path');
    }
  }

  /// Exports ALL data (Members, Subscriptions, Config) to a single JSON file
  /// This file is intended for Backup/Restore purposes.
  Future<void> exportFullDataJson() async {
    final members = await _db.membersDao.getAllMembers();
    final subs = await _db.subscriptionsDao.getAllSubscriptions();
    final donations = await _db.donationsDao.getAllDonations();
    final arrears = await _db.pastOutstandingDao.getAllOutstanding();
    final history = await _db.yearlySummariesDao.watchAllSummaries().first;
    final settings = await _db.select(_db.adminSettings).get();
    final config = await _db.subscriptionConfigDao.getConfig();

    final Map<String, dynamic> data = {
      'meta': {
        'version': 2, // Bump version
        'timestamp': DateTime.now().toIso8601String(),
        'app_version': 12, // Schema version
      },
      'members': members.map((m) => m.toJson(serializer: _isoSerializer)).toList(),
      'subscriptions': subs.map((s) => s.toJson(serializer: _isoSerializer)).toList(),
      'donations': donations.map((d) => d.toJson(serializer: _isoSerializer)).toList(),
      'arrears': arrears.map((a) => a.toJson(serializer: _isoSerializer)).toList(),
      'history': history.map((h) => h.toJson(serializer: _isoSerializer)).toList(),
      'settings': settings.map((s) => s.toJson(serializer: _isoSerializer)).toList(),
      'config': config?.toJson(serializer: _isoSerializer),
    };

    final jsonString = jsonEncode(data);
    final fileName =
        'full_backup_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.json';
    var path = await _pickSavePath(
      fileName: fileName,
      allowedExtensions: ['json'],
    );

    // Safety net: ensure the file ends with .json even if user stripped it
    if (path != null && !path.toLowerCase().endsWith('.json')) {
      path = '$path.json';
    }

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
      final List<dynamic> donationsJson = data['donations'] ?? [];
      final List<dynamic> arrearsJson = data['arrears'] ?? [];
      final List<dynamic> historyJson = data['history'] ?? [];
      final List<dynamic> settingsJson = data['settings'] ?? [];
      final Map<String, dynamic>? configJson = data['config'];

      await _db.transaction(() async {
        // 1. Clear existing data
        await _db.deleteMembers();
        await _db.deleteSubscriptions();
        await _db.deleteDonations();
        await _db.deletePastOutstanding();
        await _db.yearlySummariesDao.deleteAllSummaries();
        await _db.delete(_db.adminSettings).go();
        await _db.delete(_db.subscriptionConfig).go();

        // 2. Insert Members
        for (var m in membersJson) {
          await _db.membersDao.insertMember(
            MembersCompanion(
              surname: Value(m['surname']),
              firstName: Value(m['firstName']),
              middleName: Value(m['middleName']),
              age: Value(m['age']),
              dateOfBirth: Value(_parseDate(m['dateOfBirth'])),
              bloodGroup: Value(m['bloodGroup']),
              enrollmentDateAba: Value(_parseDate(m['enrollmentDateAba'])),
              enrollmentDateBar: Value(_parseDate(m['enrollmentDateBar'])),
              registrationNumber: Value(m['registrationNumber']),
              address: Value(m['address']),
              mobileNumber: Value(m['mobileNumber']),
              email: Value(m['email']),
              createdAt: Value(_parseDateRequired(m['createdAt'])),
              memberStatus: Value(m['memberStatus'] ?? 'Active'),
              profilePhotoPath: Value(m['profilePhotoPath']),
              remarks: Value(m['remarks']),
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
              subscriptionDate: Value(_parseDateRequired(s['subscriptionDate'])),
              receiptNumber: Value(s['receiptNumber']),
              receiptType: Value(s['receiptType']),
              dailySequence: Value(s['dailySequence'] != null ? (s['dailySequence'] as num).toInt() : 0),
              notes: Value(s['notes']),
            ),
          );
        }

        // 4. Insert Config
        if (configJson != null) {
          await _db.subscriptionConfigDao.updateConfig(
            (configJson['monthlyAmount'] as num).toDouble(),
            _parseDateRequired(configJson['subscriptionStartDate']),
          );
        }

        // 5. Insert Donations
        for (var d in donationsJson) {
           await _db.donationsDao.insertDonation(
             DonationsCompanion(
               donorName: Value(d['donorName']),
               donorType: Value(d['donorType']),
               memberId: Value(d['memberId']),
               amount: Value((d['amount'] as num).toDouble()),
               donationDate: Value(_parseDateRequired(d['donationDate'])),
               paymentMode: Value(d['paymentMode']),
               transactionRef: Value(d['transactionRef']),
               purpose: Value(d['purpose']),
               receiptNumber: Value(d['receiptNumber']),
               dailySequence: Value(d['dailySequence'] != null ? (d['dailySequence'] as num).toInt() : 0),
               donorMobile: Value(d['donorMobile']),
               donorEmail: Value(d['donorEmail']),
               donorAddress: Value(d['donorAddress']),
               organization: Value(d['organization']),
             )
           );
        }

        // 6. Insert Arrears
        for (var a in arrearsJson) {
           await _db.pastOutstandingDao.insertOutstanding(
             PastOutstandingDuesCompanion(
               enrollmentNumber: Value(a['enrollmentNumber']),
               amount: Value((a['amount'] as num).toDouble()),
               // Handle newly added columns
               periodLabel: Value(a['periodLabel'] ?? 'Unknown Period'),
               type: Value(a['type'] ?? 'Arrears'),
               notes: Value(a['notes']),
               isCleared: Value(a['isCleared'] ?? false),
               clearedAt: Value(_parseDate(a['clearedAt'])),
               linkedPaymentId: Value(a['linkedPaymentId']),
             )
           );
        }

        // 7. Insert History
        for (var h in historyJson) {
           await _db.yearlySummariesDao.insertSummary(
             YearlySummariesCompanion(
               enrollmentNumber: Value(h['enrollmentNumber']),
               financialYear: Value(h['financialYear']),
               totalExpected: Value((h['totalExpected'] as num).toDouble()),
               totalPaid: Value((h['totalPaid'] as num).toDouble()),
               balance: Value((h['balance'] as num).toDouble()),
               status: Value(h['status']),
               closedAt: Value(_parseDate(h['closedAt']) ?? DateTime.now()),
             )
           );
        }

        // 8. Insert Settings
        for (var s in settingsJson) {
           await _db.into(_db.adminSettings).insert(
             AdminSettingsCompanion(
               key: Value(s['key']),
               value: Value(s['value']),
             )
           );
        }
      });
      return true;
    } catch (e) {
      debugPrint('Restore failed: $e');
      return false; // Or rethrow
    }
  }

  /// Import members from a CSV file.
  /// Returns a summary string of the operation.
  Future<String> importMembersFromCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.single.path == null) {
      return 'Import cancelled';
    }

    final file = File(result.files.single.path!);
    final input = await file.readAsString();
    
    // Parse CSV
    final List<List<dynamic>> rows = const CsvToListConverter().convert(input, eol: '\n');
    if (rows.isEmpty || rows.length < 2) {
      return 'CSV file is empty or missing data rows.';
    }

    // Headers verification (Optional strict check, or loose mapping)
    final headers = rows.first.map((e) => e.toString().trim().toLowerCase()).toList();
    
    // Minimal required headers
    final reqIndexReg = headers.indexOf('registration number');
    final reqIndexName = headers.indexOf('first name');
    final reqIndexSurname = headers.indexOf('surname');

    if (reqIndexReg == -1 || reqIndexName == -1 || reqIndexSurname == -1) {
      return 'Missing required columns: Registration Number, First Name, Surname.';
    }
    
    // Optional headers indices
    final indexMiddle = headers.indexOf('middle name');
    final indexAge = headers.indexOf('age');
    final indexMobile = headers.indexOf('mobile number');
    final indexAddress = headers.indexOf('address');
    final indexEmail = headers.indexOf('email');
    final indexDob = headers.indexOf('date of birth');
    final indexEnrollAba = headers.indexOf('enrollment date aba');
    final indexEnrollBar = headers.indexOf('enrollment date bar');
    final indexBlood = headers.indexOf('blood group');
    final indexStatus = headers.indexOf('member status');
    final indexRemarks = headers.indexOf('remarks');

    int success = 0;
    int skipped = 0;
    int errors = 0;

    final existingMembers = await _db.membersDao.getAllMembers();
    final existingRegNos = existingMembers.map((e) => e.registrationNumber.toLowerCase()).toSet();

    for (int i = 1; i < rows.length; i++) {
        try {
            final row = rows[i];
            // Safety check for row length
            if (row.length < headers.length) continue; 

            final regNo = row[reqIndexReg].toString().trim();
            if (regNo.isEmpty) {
                errors++;
                continue;
            }

            if (existingRegNos.contains(regNo.toLowerCase())) {
                skipped++; // Duplicate
                continue;
            }

            // Parsing helper
            String? getStr(int idx) => idx != -1 && idx < row.length ? row[idx].toString().trim() : null;
            
            final dobStr = getStr(indexDob);
            final enrollAbaStr = getStr(indexEnrollAba);
            final enrollBarStr = getStr(indexEnrollBar);

            DateTime? parseDate(String? s) {
                if (s == null || s.isEmpty) return null;
                try { return DateTime.tryParse(s); } catch (e) { return null; }
            }

            await _db.membersDao.insertMember(
                MembersCompanion(
                    registrationNumber: Value(regNo),
                    firstName: Value(row[reqIndexName].toString().trim()),
                    surname: Value(row[reqIndexSurname].toString().trim()),
                    middleName: Value(getStr(indexMiddle)),
                    age: Value(int.tryParse(getStr(indexAge) ?? '0') ?? 0),
                    mobileNumber: Value(getStr(indexMobile) ?? ''),
                    address: Value(getStr(indexAddress) ?? ''),
                    email: Value(getStr(indexEmail)),
                    dateOfBirth: Value(parseDate(dobStr)),
                    enrollmentDateAba: Value(parseDate(enrollAbaStr)),
                    enrollmentDateBar: Value(parseDate(enrollBarStr)),
                    bloodGroup: Value(getStr(indexBlood)),
                    createdAt: Value(DateTime.now()),
                    memberStatus: Value(getStr(indexStatus) ?? 'Active'),
                    remarks: Value(getStr(indexRemarks)),
                ),
            );
            success++;
        } catch (e) {
            errors++;
            debugPrint('Error importing row $i: $e');
        }
    }

    return 'Import Complete: $success added, $skipped skipped (duplicate), $errors failed.';
  }
}
