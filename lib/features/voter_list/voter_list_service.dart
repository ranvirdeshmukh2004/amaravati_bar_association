import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../subscription/subscription_service.dart';

final voterListServiceProvider = Provider<VoterListService>((ref) {
  final db = ref.watch(databaseProvider);
  final subService = ref.watch(subscriptionServiceProvider);
  return VoterListService(db, subService);
});

// ---------------------------------------------------------------------------
// Isolate-safe data class — holds everything needed to build one voter row.
// Drift's Member objects aren't sendable across isolates, so we extract
// the fields we need into this plain class.
// ---------------------------------------------------------------------------
class _VoterEntry {
  final String fullName;
  final String registrationNumber;
  final String mobileNumber;
  final Uint8List? photoBytes; // pre-loaded on main thread

  const _VoterEntry({
    required this.fullName,
    required this.registrationNumber,
    required this.mobileNumber,
    this.photoBytes,
  });
}

// ---------------------------------------------------------------------------
// Payload sent to the background isolate via compute()
// ---------------------------------------------------------------------------
class _PdfPayload {
  final List<_VoterEntry> voters;
  final String financialYear;
  final String generatedDate;
  final int chunkSize;

  const _PdfPayload({
    required this.voters,
    required this.financialYear,
    required this.generatedDate,
    this.chunkSize = 500,
  });
}

class VoterListService {
  final AppDatabase _db;
  final SubscriptionService _subscriptionService;

  VoterListService(this._db, this._subscriptionService);

  // -------------------------------------------------------------------------
  // PUBLIC API — called from the UI
  // -------------------------------------------------------------------------

  /// Generates and saves the Voter List PDF.
  ///
  /// [onProgress] is called with status messages so the UI can show a live
  /// progress dialog ("Loading data...", "Generating PDF chunk 2/8...", etc.).
  Future<void> saveVoterListToDownloads({
    void Function(String message, double progress)? onProgress,
  }) async {
    // ---- Step 1: Fetch eligible voters (DB + subscription checks) --------
    onProgress?.call('Loading member data...', 0.0);
    final voters = await _fetchEligibleVoters();
    debugPrint('📋 Eligible voters found: ${voters.length}');

    if (voters.isEmpty) {
      throw Exception(
        'No eligible voters found. Ensure there are active members with fully paid subscriptions.',
      );
    }

    // ---- Step 2: Pre-load photo bytes asynchronously ---------------------
    onProgress?.call('Loading ${voters.length} member photos...', 0.10);
    final voterEntries = await _preloadVoterEntries(voters, onProgress);

    // ---- Step 3: Prepare financial year & date strings -------------------
    final now = DateTime.now();
    final startYear = now.month > 3 ? now.year : now.year - 1;
    final financialYear = '$startYear-${startYear + 1}';
    final generatedDate = DateFormat('dd MMMM yyyy').format(now);

    // ---- Step 4: Generate PDF in background isolate ---------------------
    onProgress?.call('Generating PDF...', 0.30);

    final payload = _PdfPayload(
      voters: voterEntries,
      financialYear: financialYear,
      generatedDate: generatedDate,
      chunkSize: 500,
    );

    final pdfBytes = await compute(_generatePdfInIsolate, payload);

    // ---- Step 5: Save to Documents/FinalVoterList/ -----------------------
    onProgress?.call('Saving file...', 0.95);

    if (Platform.isWindows) {
      try {
        final userProfile = Platform.environment['USERPROFILE'] ?? '';
        final docsPath = userProfile.isNotEmpty
            ? '$userProfile\\Documents'
            : (await getDownloadsDirectory())?.path ??
                'C:\\Users\\Public\\Downloads';

        final targetDir = Directory('$docsPath\\FinalVoterList');
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }

        final fileName =
            'ABA_Voter_List_Final_${DateFormat('yyyyMMdd_HHmm').format(now)}.pdf';
        final file = File('${targetDir.path}\\$fileName');

        await file.writeAsBytes(pdfBytes);
        debugPrint('✅ Voter list saved to: ${file.path}');
        onProgress?.call('Done! Saved to Documents\\FinalVoterList.', 1.0);
        return;
      } on FileSystemException catch (e) {
        final isDiskFull = e.osError?.errorCode == 112 ||
            e.message.toLowerCase().contains('no space');
        if (isDiskFull) {
          throw Exception(
              'Storage full! Please free up disk space and try again.');
        }
        debugPrint('⚠️ Direct save failed, falling back to share: $e');
        await Printing.sharePdf(bytes: pdfBytes, filename: 'voter_list.pdf');
      } catch (e) {
        debugPrint('⚠️ Direct save failed, falling back to share: $e');
        await Printing.sharePdf(bytes: pdfBytes, filename: 'voter_list.pdf');
      }
    } else {
      await Printing.sharePdf(bytes: pdfBytes, filename: 'voter_list.pdf');
    }
    onProgress?.call('Done!', 1.0);
  }

  // -------------------------------------------------------------------------
  // STEP 1 — Fetch eligible voters (unchanged business logic)
  // -------------------------------------------------------------------------

  /// Fetch eligible voters: Active + Fully Paid + No Arrears
  Future<List<Member>> _fetchEligibleVoters() async {
    // Get current financial year
    final now = DateTime.now();
    final startYear = now.month > 3 ? now.year : now.year - 1;
    final currentFY = '$startYear-${startYear + 1}';
    debugPrint('📅 Current Financial Year: $currentFY');

    // 1. Fetch live subscription statuses (this is the single source of truth for balances)
    final statuses = await _subscriptionService.watchMemberStatuses().first;
    debugPrint('👥 Total members in status snapshot: ${statuses.length}');

    final eligibleVoters = <Member>[];

    for (final status in statuses) {
      final member = status.member;

      try {
        // 2. Must be Active
        if (member.memberStatus != 'Active') {
          continue;
        }

        // 3. Check live calculated balances
        // isDefaulter is true if (totalExpected + pastOutstanding) - totalPaid > 0
        if (status.isDefaulter || status.balance > 0) {
          debugPrint('❌ ${member.firstName} ${member.surname}: Is Defaulter (Balance: ₹${status.balance}, Arrears: ₹${status.pastOutstanding})');
          continue;
        }

        // 4. Must have NO past outstanding dues whatsoever
        if (status.pastOutstanding > 0) {
          debugPrint('❌ ${member.firstName} ${member.surname}: Has past outstanding arrears (₹${status.pastOutstanding})');
          continue;
        }

        // 5. Must have at least one valid subscription payment on record
        // This ensures fully waived/0-expected members who never paid aren't accidentally included
        final subs = await (_db.select(_db.subscriptions)
          ..where((t) => t.enrollmentNumber.equals(member.registrationNumber))
          ..where((t) => t.deleted.equals(false)))
          .get();

        if (subs.isEmpty) {
          debugPrint('❌ ${member.firstName} ${member.surname}: No subscription history');
          continue;
        }

        // Passed all checks
        debugPrint('✅ ${member.firstName} ${member.surname}: Eligible');
        eligibleVoters.add(member);
      } catch (e) {
        debugPrint('⚠️ Error checking member ${member.registrationNumber}: $e');
        continue;
      }
    }
    
    // Sort A-Z by surname then first name
    eligibleVoters.sort((a, b) {
      final cmp = a.surname.compareTo(b.surname);
      return cmp != 0 ? cmp : a.firstName.compareTo(b.firstName);
    });
        
    return eligibleVoters;
  }

  // -------------------------------------------------------------------------
  // STEP 2 — Pre-load photo bytes asynchronously on the main thread
  // -------------------------------------------------------------------------

  Future<List<_VoterEntry>> _preloadVoterEntries(
    List<Member> voters,
    void Function(String message, double progress)? onProgress,
  ) async {
    final entries = <_VoterEntry>[];
    final total = voters.length;

    for (int i = 0; i < total; i++) {
      final member = voters[i];

      // Update progress every 50 members
      if (onProgress != null && i % 50 == 0) {
        onProgress(
          'Loading photos... (${i + 1}/$total)',
          0.10 + (0.20 * (i / total)), // 10% → 30%
        );
        // Yield to event loop to keep UI responsive
        await Future.delayed(Duration.zero);
      }

      Uint8List? photoBytes;
      try {
        if (member.profilePhotoPath != null &&
            member.profilePhotoPath!.isNotEmpty) {
          final file = File(member.profilePhotoPath!);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            if (bytes.isNotEmpty) {
              photoBytes = bytes;
            }
          }
        }
      } catch (e) {
        debugPrint('⚠️ Error loading photo for ${member.registrationNumber}: $e');
      }

      final fullName =
          '${member.firstName} ${member.middleName != null ? "${member.middleName} " : ""}${member.surname}'
              .toUpperCase();

      entries.add(_VoterEntry(
        fullName: fullName,
        registrationNumber: member.registrationNumber,
        mobileNumber: member.mobileNumber,
        photoBytes: photoBytes,
      ));
    }

    return entries;
  }
}

// ===========================================================================
// TOP-LEVEL FUNCTION — runs inside background isolate via compute()
// ===========================================================================

Future<Uint8List> _generatePdfInIsolate(_PdfPayload payload) async {
  final pdf = pw.Document();

  // Fonts
  final fontSerif = pw.Font.times();
  final fontSerifBold = pw.Font.timesBold();

  const pageFormat = PdfPageFormat.a4;
  final voters = payload.voters;
  final financialYear = payload.financialYear;
  final generatedDate = payload.generatedDate;
  final generatedShort = DateFormat('dd/MM/yyyy').format(DateTime.now());

  // ---- 1. Cover Page ----------------------------------------------------
  pdf.addPage(
    pw.Page(
      pageFormat: pageFormat,
      build: (context) => _buildCoverPage(
        financialYear, generatedDate, fontSerifBold, fontSerif,
      ),
    ),
  );

  // ---- 2. Summary Page --------------------------------------------------
  pdf.addPage(
    pw.Page(
      pageFormat: pageFormat,
      build: (context) => _buildSummaryPage(
        financialYear, voters.length, fontSerifBold, fontSerif,
      ),
    ),
  );

  // ---- 3. Voter Table — built in chunks ---------------------------------
  final chunkSize = payload.chunkSize;
  final totalChunks = (voters.length / chunkSize).ceil();

  for (int chunkIdx = 0; chunkIdx < totalChunks; chunkIdx++) {
    final start = chunkIdx * chunkSize;
    final end = (start + chunkSize).clamp(0, voters.length);
    final chunk = voters.sublist(start, end);

    pdf.addPage(
      pw.MultiPage(
        maxPages: 100, // Safety per chunk (500 members ≈ 20 pages)
        pageFormat: pageFormat.copyWith(
          marginLeft: 10 * PdfPageFormat.mm,
          marginRight: 10 * PdfPageFormat.mm,
          marginTop: 10 * PdfPageFormat.mm,
          marginBottom: 10 * PdfPageFormat.mm,
        ),
        header: (context) => pw.Column(
          children: [
            _buildHeader(
              financialYear, generatedShort, fontSerifBold, fontSerif,
            ),
            // Table column header — repeats on every page
            pw.Table(
              border: pw.TableBorder.all(width: 1, color: PdfColors.black),
              columnWidths: {
                0: const pw.FixedColumnWidth(30),
                1: const pw.FixedColumnWidth(80),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FixedColumnWidth(100),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildHeaderCell('Sl.\nNo', fontSerifBold),
                    _buildHeaderCell('Photo', fontSerifBold),
                    _buildHeaderCell('Member Details', fontSerifBold),
                    _buildHeaderCell('Signature', fontSerifBold),
                  ],
                ),
              ],
            ),
          ],
        ),
        footer: (context) => _buildFooter(context, fontSerif),
        build: (context) {
          return [
            pw.Table(
              border: pw.TableBorder.all(width: 1, color: PdfColors.black),
              columnWidths: {
                0: const pw.FixedColumnWidth(30),  // Sl No
                1: const pw.FixedColumnWidth(80),  // Photo
                2: const pw.FlexColumnWidth(1),    // Details
                3: const pw.FixedColumnWidth(100), // Signature
              },
              children: [
                // Data Rows only (header is in the page header above)
                ...List.generate(chunk.length, (index) {
                  final globalIndex = start + index;
                  final voter = chunk[index];
                  return _buildVoterRow(
                    globalIndex + 1, voter, fontSerif, fontSerifBold,
                  );
                }),
              ],
            ),
          ];
        },
      ),
    );
  }

  return pdf.save();
}

// ===========================================================================
// PDF BUILDING HELPERS — all top-level functions (isolate-compatible)
// Design is 100% preserved from the original implementation.
// ===========================================================================

pw.Widget _buildCoverPage(
  String year, String generatedDate,
  pw.Font fontBold, pw.Font fontNormal,
) {
  return pw.Center(
    child: pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text('AMARAVATI BAR ASSOCIATION',
            style: pw.TextStyle(font: fontBold, fontSize: 24)),
        pw.SizedBox(height: 10 * PdfPageFormat.mm),
        pw.Text('FINAL OFFICIAL VOTER LIST',
            style: pw.TextStyle(font: fontBold, fontSize: 20)),
        pw.SizedBox(height: 5 * PdfPageFormat.mm),
        pw.Text('YEAR $year',
            style: pw.TextStyle(font: fontBold, fontSize: 18)),
        pw.SizedBox(height: 20 * PdfPageFormat.mm),
        pw.Divider(),
        pw.SizedBox(height: 10 * PdfPageFormat.mm),
        pw.Text('Generated on: $generatedDate',
            style: pw.TextStyle(font: fontNormal, fontSize: 12)),
      ],
    ),
  );
}

pw.Widget _buildSummaryPage(
  String year, int totalVoters,
  pw.Font fontBold, pw.Font fontNormal,
) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(20 * PdfPageFormat.mm),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(
          child: pw.Text(
            'SUMMARY OF VOTER LIST ($year)',
            style: pw.TextStyle(
              font: fontBold, fontSize: 16,
              decoration: pw.TextDecoration.underline,
            ),
          ),
        ),
        pw.SizedBox(height: 15 * PdfPageFormat.mm),
        pw.Text('Total Eligible Voters: $totalVoters',
            style: pw.TextStyle(font: fontBold, fontSize: 14)),
        pw.SizedBox(height: 10 * PdfPageFormat.mm),
        pw.Text('Criteria for Eligibility:',
            style: pw.TextStyle(font: fontBold, fontSize: 12)),
        pw.Bullet(text: 'Membership Status: Active'),
        pw.Bullet(text: 'Current Year Subscription: Paid'),
        pw.Bullet(text: 'Past Arrears: Cleared (Zero Balance)'),
        pw.Spacer(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(children: [
              pw.Container(
                  width: 60 * PdfPageFormat.mm, height: 1,
                  color: PdfColors.black),
              pw.SizedBox(height: 2),
              pw.Text('Secretary',
                  style: pw.TextStyle(font: fontBold, fontSize: 12)),
              pw.Text('Amaravati Bar Association',
                  style: pw.TextStyle(font: fontNormal, fontSize: 10)),
            ]),
            pw.Column(children: [
              pw.Container(
                  width: 60 * PdfPageFormat.mm, height: 1,
                  color: PdfColors.black),
              pw.SizedBox(height: 2),
              pw.Text('President',
                  style: pw.TextStyle(font: fontBold, fontSize: 12)),
              pw.Text('Amaravati Bar Association',
                  style: pw.TextStyle(font: fontNormal, fontSize: 10)),
            ]),
          ],
        ),
        pw.SizedBox(height: 20 * PdfPageFormat.mm),
      ],
    ),
  );
}

pw.Widget _buildHeader(
  String year, String generatedShort,
  pw.Font fontBold, pw.Font fontNormal,
) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 10 * PdfPageFormat.mm),
    child: pw.Column(
      children: [
        pw.Text('AMARAVATI BAR ASSOCIATION',
            style: pw.TextStyle(font: fontBold, fontSize: 16)),
        pw.SizedBox(height: 2 * PdfPageFormat.mm),
        pw.Text('VOTER LIST - ELIGIBLE MEMBERS',
            style: pw.TextStyle(font: fontBold, fontSize: 14)),
        pw.Text('(Year $year)',
            style: pw.TextStyle(font: fontNormal, fontSize: 12)),
        pw.SizedBox(height: 2 * PdfPageFormat.mm),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Generated on: $generatedShort',
              style: pw.TextStyle(font: fontNormal, fontSize: 9)),
        ),
      ],
    ),
  );
}

pw.Widget _buildFooter(pw.Context context, pw.Font fontNormal) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 5 * PdfPageFormat.mm),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(font: fontNormal, fontSize: 9)),
        pw.Text('Official Voter List - System Generated',
            style: pw.TextStyle(font: fontNormal, fontSize: 9)),
        pw.Text('Authorized Signatory',
            style: pw.TextStyle(font: fontNormal, fontSize: 9)),
      ],
    ),
  );
}

pw.Widget _buildHeaderCell(String text, pw.Font fontBold) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(5),
    child: pw.Center(
      child: pw.Text(text,
          style: pw.TextStyle(font: fontBold, fontSize: 10),
          textAlign: pw.TextAlign.center),
    ),
  );
}

pw.TableRow _buildVoterRow(
  int slNo, _VoterEntry voter,
  pw.Font fontNormal, pw.Font fontBold,
) {
  // Photo widget — use pre-loaded bytes or placeholder
  pw.Widget photoWidget;
  try {
    if (voter.photoBytes != null && voter.photoBytes!.isNotEmpty) {
      photoWidget = pw.Image(
        pw.MemoryImage(voter.photoBytes!),
        width: 25 * PdfPageFormat.mm,
        height: 30 * PdfPageFormat.mm,
        fit: pw.BoxFit.cover,
      );
    } else {
      photoWidget = _buildPhotoPlaceholder();
    }
  } catch (e) {
    photoWidget = _buildPhotoPlaceholder();
  }

  return pw.TableRow(
    children: [
      pw.Container(
        height: 35 * PdfPageFormat.mm,
        alignment: pw.Alignment.center,
        child: pw.Text('$slNo',
            style: pw.TextStyle(font: fontNormal, fontSize: 10)),
      ),
      pw.Container(
        padding: const pw.EdgeInsets.all(2 * PdfPageFormat.mm),
        alignment: pw.Alignment.center,
        child: photoWidget,
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(4 * PdfPageFormat.mm),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(voter.fullName,
                style: pw.TextStyle(font: fontBold, fontSize: 11)),
            pw.SizedBox(height: 2),
            pw.Text('Reg. No: ${voter.registrationNumber}',
                style: pw.TextStyle(font: fontNormal, fontSize: 10)),
            pw.Text('Mobile: ${voter.mobileNumber}',
                style: pw.TextStyle(font: fontNormal, fontSize: 10)),
          ],
        ),
      ),
      pw.Container(
        height: 35 * PdfPageFormat.mm,
        padding: const pw.EdgeInsets.only(bottom: 2 * PdfPageFormat.mm),
        alignment: pw.Alignment.bottomCenter,
        child: pw.Text('Signature',
            style: pw.TextStyle(
              font: fontNormal, fontSize: 8,
              color: PdfColors.grey600,
            )),
      ),
    ],
  );
}

pw.Widget _buildPhotoPlaceholder() {
  return pw.Container(
    width: 25 * PdfPageFormat.mm,
    height: 30 * PdfPageFormat.mm,
    color: PdfColors.grey200,
    child: pw.Center(
      child: pw.Text('Photo\nNot\nAvailable',
          style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          textAlign: pw.TextAlign.center),
    ),
  );
}
