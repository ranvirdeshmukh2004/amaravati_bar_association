import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import '../../database/app_database.dart';

/// Service that generates Experience Certificate .docx files
/// for individual members by filling a template with member-specific data.
class ExperienceCertificateService {
  /// Generates an experience certificate for the given [member],
  /// saves it to the Documents folder, and opens the file.
  ///
  /// Returns the saved file path on success, or null on failure.
  static Future<String?> generateAndOpen(Member member) async {
    try {
      // 1. Build the member-specific values
      final fullName =
          'Adv. ${member.firstName} ${member.middleName ?? ''} ${member.surname}'
              .trim()
              .replaceAll(RegExp(r'\s+'), ' ');

      final enrollDateBar = member.enrollmentDateBar != null
          ? DateFormat('dd/MM/yyyy').format(member.enrollmentDateBar!)
          : '___________';

      final enrollDateAba = member.enrollmentDateAba != null
          ? DateFormat('dd/MM/yyyy').format(member.enrollmentDateAba!)
          : '___________';

      final regNo = member.registrationNumber;
      final today = DateFormat('dd/MM/yyyy').format(DateTime.now());

      // 2. Read template from assets
      final templateBytes = await rootBundle
          .load('assets/experience_certificate_template.docx');
      final templateData = templateBytes.buffer.asUint8List();

      // 3. Decode the ZIP (docx is a ZIP archive)
      final archive = ZipDecoder().decodeBytes(templateData);

      // 4. Find document.xml and replace placeholders
      final newArchive = Archive();
      for (final file in archive) {
        if (file.name == 'word/document.xml') {
          // Decode the XML content
          String xmlContent = utf8.decode(file.content as List<int>);

          // Replace placeholders
          xmlContent = xmlContent
              .replaceAll('{{MEMBER_NAME}}', _escapeXml(fullName))
              .replaceAll('{{MEMBER_NAME_2}}', _escapeXml(fullName))
              .replaceAll('{{ENROLLMENT_DATE_BAR}}', _escapeXml(enrollDateBar))
              .replaceAll('{{ENROLLMENT_DATE_ABA}}', _escapeXml(enrollDateAba))
              .replaceAll('{{REG_NO}}', _escapeXml(regNo))
              .replaceAll('{{TODAY_DATE}}', _escapeXml(today));

          // Add modified file back
          final modifiedBytes = utf8.encode(xmlContent);
          newArchive.addFile(
            ArchiveFile(file.name, modifiedBytes.length, modifiedBytes),
          );
        } else {
          // Copy other files as-is
          newArchive.addFile(
            ArchiveFile(file.name, file.size, file.content),
          );
        }
      }

      // 5. Encode the modified archive
      final outputBytes = ZipEncoder().encode(newArchive);
      if (outputBytes == null) return null;

      // 6. Build the filename: {MemberName}_Experience_Certificate_{date}.docx
      final sanitizedName =
          '${member.firstName}_${member.surname}'
              .replaceAll(RegExp(r'[^\w]'), '_')
              .replaceAll(RegExp(r'_+'), '_');
      final dateStr = DateFormat('dd_MM_yyyy').format(DateTime.now());
      final fileName = '${sanitizedName}_Experience_Certificate_$dateStr.docx';

      // 7. Save to user's Documents/experienceCertificate folder
      final userProfile = Platform.environment['USERPROFILE'] ?? '';
      final docsPath = userProfile.isNotEmpty
          ? '$userProfile\\Documents'
          : '.'; // fallback to current directory
      final certDir = Directory('$docsPath\\experienceCertificate');
      if (!await certDir.exists()) {
        await certDir.create(recursive: true);
      }
      final filePath = '${certDir.path}\\$fileName';
      final savedFile = File(filePath);
      await savedFile.writeAsBytes(outputBytes);

      // 8. Open the file with default application
      await Process.run('cmd', ['/c', 'start', '', filePath]);

      debugPrint('Certificate saved and opened: $filePath');
      return filePath;
    } on FileSystemException catch (e) {
      final isDiskFull = e.osError?.errorCode == 112 ||
          e.message.toLowerCase().contains('no space');
      debugPrint(isDiskFull
          ? 'Storage full! Cannot save certificate.'
          : 'Error saving certificate: ${e.message}');
      return null;
    } catch (e, stack) {
      debugPrint('Error generating certificate: $e\n$stack');
      return null;
    }
  }

  /// Escapes special XML characters in a string.
  static String _escapeXml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}
