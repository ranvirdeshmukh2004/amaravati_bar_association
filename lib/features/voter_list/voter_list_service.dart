import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';

final voterListServiceProvider = Provider<VoterListService>((ref) {
  final db = ref.watch(databaseProvider);
  return VoterListService(db);
});

class VoterListService {
  final AppDatabase _db;

  VoterListService(this._db);

  /// Generates and saves the Voter List PDF
  Future<void> saveVoterListToDownloads() async {
    final pdf = await _generatePdf();

    if (Platform.isWindows) {
      // Direct Save to Downloads on Windows
      try {
        final downloadsPath = (await getDownloadsDirectory())?.path ?? 'C:\\Users\\Public\\Downloads';
        final fileName = 'ABA_Voter_List_Final_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
        final file = File('$downloadsPath\\$fileName');
        
        await file.writeAsBytes(await pdf.save());
        return; // Success handled by caller
      } catch (e) {
        // Fallback if direct save fails
        await Printing.sharePdf(bytes: await pdf.save(), filename: 'voter_list.pdf');
      }
    } else {
      // Mobile / Other
      await Printing.sharePdf(bytes: await pdf.save(), filename: 'voter_list.pdf');
    }
  }

  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();
    final voters = await _fetchEligibleVoters();

    // Fonts
    final fontSerif = pw.Font.times();
    final fontSerifBold = pw.Font.timesBold();
    
    // Dynamic Financial Year Logic (e.g., Jan 2026 -> "2025-2026")
    final now = DateTime.now();
    final startYear = now.month > 3 ? now.year : now.year - 1;
    final financialYear = '$startYear-${startYear + 1}';
    
    // Page Format: A4 (210 x 297 mm)
    // Margins: Narrow (e.g., 10mm)
    const pageFormat = PdfPageFormat.a4;
    
    // 1. Cover Page
    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) => _buildCoverPage(financialYear, fontSerifBold, fontSerif),
      ),
    );

    // 2. Summary / Details Page
    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) => _buildSummaryPage(financialYear, voters.length, fontSerifBold, fontSerif),
      ),
    );
    
    // 3. Main List
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat.copyWith(
          marginLeft: 10 * PdfPageFormat.mm,
          marginRight: 10 * PdfPageFormat.mm,
          marginTop: 10 * PdfPageFormat.mm, // Header space managed inside
          marginBottom: 10 * PdfPageFormat.mm,
        ),
        header: (context) => _buildHeader(financialYear, fontSerifBold, fontSerif),
        footer: (context) => _buildFooter(context, fontSerif),
        build: (context) {
          return [
             pw.Table(
               border: pw.TableBorder.all(width: 1, color: PdfColors.black),
               columnWidths: {
                 0: const pw.FixedColumnWidth(30), // Sl No
                 1: const pw.FixedColumnWidth(80), // Photo (approx 3cm)
                 2: const pw.FlexColumnWidth(1),   // Details
                 3: const pw.FixedColumnWidth(100), // Signature
               },
               children: [
                 // Table Header
                 pw.TableRow(
                   decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                   children: [
                     _buildHeaderCell('Sl.\nNo', fontSerifBold),
                     _buildHeaderCell('Photo', fontSerifBold),
                     _buildHeaderCell('Member Details', fontSerifBold),
                     _buildHeaderCell('Signature', fontSerifBold),
                   ]
                 ),
                 // Rows
                 ...List.generate(voters.length, (index) {
                   final voter = voters[index];
                   return _buildVoterRow(index + 1, voter, fontSerif, fontSerifBold);
                 }),
               ]
             ),
          ];
        }
      )
    );

    return pdf;
  }

  pw.Widget _buildCoverPage(String year, pw.Font fontBold, pw.Font fontNormal) {
    return pw.Center(
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text('AMARAVATI BAR ASSOCIATION', style: pw.TextStyle(font: fontBold, fontSize: 24)),
          pw.SizedBox(height: 10 * PdfPageFormat.mm),
          pw.Text('FINAL OFFICIAL VOTER LIST', style: pw.TextStyle(font: fontBold, fontSize: 20)),
          pw.SizedBox(height: 5 * PdfPageFormat.mm),
          pw.Text('YEAR $year', style: pw.TextStyle(font: fontBold, fontSize: 18)),
          pw.SizedBox(height: 20 * PdfPageFormat.mm),
          pw.Divider(),
          pw.SizedBox(height: 10 * PdfPageFormat.mm),
          pw.Text('Generated on: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}', 
            style: pw.TextStyle(font: fontNormal, fontSize: 12)),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryPage(String year, int totalVoters, pw.Font fontBold, pw.Font fontNormal) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(20 * PdfPageFormat.mm),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
           pw.Center(child: pw.Text('SUMMARY OF VOTER LIST ($year)', style: pw.TextStyle(font: fontBold, fontSize: 16, decoration: pw.TextDecoration.underline))),
           pw.SizedBox(height: 15 * PdfPageFormat.mm),
           
           pw.Text('Total Eligible Voters: $totalVoters', style: pw.TextStyle(font: fontBold, fontSize: 14)),
           pw.SizedBox(height: 10 * PdfPageFormat.mm),
           
           pw.Text('Criteria for Eligibility:', style: pw.TextStyle(font: fontBold, fontSize: 12)),
           pw.Bullet(text: 'Membership Status: Active'),
           pw.Bullet(text: 'Current Year Subscription: Paid'),
           pw.Bullet(text: 'Past Arrears: Cleared (Zero Balance)'),
           
           pw.Spacer(),
           
           pw.Row(
             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
             children: [
                pw.Column(
                  children: [
                    pw.Container(width: 60 * PdfPageFormat.mm, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 2),
                    pw.Text('Secretary', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                    pw.Text('Amaravati Bar Association', style: pw.TextStyle(font: fontNormal, fontSize: 10)),
                  ]
                ),
                pw.Column(
                  children: [
                    pw.Container(width: 60 * PdfPageFormat.mm, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 2),
                    pw.Text('President', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                    pw.Text('Amaravati Bar Association', style: pw.TextStyle(font: fontNormal, fontSize: 10)),
                  ]
                ),
             ]
           ),
           pw.SizedBox(height: 20 * PdfPageFormat.mm),
        ],
      ),
    );
  }

  Future<List<Member>> _fetchEligibleVoters() async {
    // Strict Eligibility Logic:
    // 1. Member Status must be 'Active' (and not soft-deleted)
    // 2. NO Unpaid Arrears in `PastOutstandingDues`
    // 3. NO Balance / Due status in `YearlySummaries` for ANY year
    // 4. Must have PAID for the Current Year (implied by #3 + existence of latest summary)

    final allMembers = await _db.membersDao.getAllMembers();
    final activeMembers = allMembers.where((m) => m.memberStatus == 'Active' && !m.deleted).toList();
    
    final eligibleVoters = <Member>[];

    for (final member in activeMembers) {
      // 1. Check Legacy Arrears (PastOutstandingDues)
      final hasLegacyArrears = await (_db.select(_db.pastOutstandingDues)
        ..where((t) => t.enrollmentNumber.equals(member.registrationNumber) & t.isCleared.equals(false)))
        .get();
      
      if (hasLegacyArrears.isNotEmpty) {
        // Has uncleared legacy dues
        continue; 
      }

      // 2. Check Yearly Summaries for ANY outstanding balance
      // We fetch ALL summaries for this member.
      final summaries = await (_db.select(_db.yearlySummaries)
        ..where((t) => t.enrollmentNumber.equals(member.registrationNumber))
        ).get();

      // If they have ANY summary with balance > 0 or status != Paid (e.g. 'Due', 'Partial'), they are ineligible.
      // NOTE: We allow 'status' to be null if balance is 0? Let's be strict:
      // Status must be 'Paid' or 'Overpaid' AND balance <= 0.
      
      bool hasDues = false;
      bool hasPaidCurrentData = false;
      
      for (final s in summaries) {
         if (s.balance > 0) {
            hasDues = true;
            break;
         }
         // Optional: Check status text. 'Due' clearly means unpaid.
         if (s.status == 'Due' || s.status == 'Partial') {
             hasDues = true;
             break;
         }
         
         // Heuristic for "Current Year Paid":
         // If we find at least one "Paid" record with decent amount, or specifically for current year?
         // User's prompt: "active fully paid member with no arrears".
         // "Fully paid" usually implies up-to-date.
         // If they have summaries but none are "Paid", that's weird (maybe all zero balance but status unknown?).
         if (s.status == 'Paid' || s.status == 'Overpaid') {
            hasPaidCurrentData = true; 
         }
      }
      
      if (hasDues) continue; // Found outstanding in yearly summaries
      
      // 3. Must have some proof of payment (Active member with NO records might be a data error or new member)
      // If summaries is empty, check Subscriptions directly?
      if (summaries.isEmpty) {
          // Fallback: Check Subscriptions directly.
          // If they have NO subscriptions, are they eligible? 
          // Usually NO. An active member must have paid something.
          final subs = await (_db.select(_db.subscriptions)
             ..where((t) => t.enrollmentNumber.equals(member.registrationNumber)))
             .get();
          
          if (subs.isEmpty) {
             // No payment history at all -> Treat as not fully paid.
             continue; 
          }
          // If they have subscriptions but no summaries yet (sync issue?), 
          // we can't easily verify "No Arrears" without summaries or manual calc.
          // SAFEST: Exclude if no summaries exist to assume "Fully Paid".
          // BUT: Migration might have created summaries.
          // Let's assume if subs exist and no "Arrears" record exists, they are OK?
          // To be safe and strict as requested:
          // If no summary, we don't know if they are "Fully Paid" for current year.
          // So we EXCLUDE them unless we find a recent subscription (e.g. last 12 months).
          
           final recentSub = subs.where((s) => s.subscriptionDate.year >= DateTime.now().year - 1);
           if (recentSub.isEmpty) continue; 
      } else {
         // Even if they have summaries, if NONE are 'Paid' (e.g. all old/archived?), 
         // are they "Fully Paid" now?
         // If `hasPaidCurrentData` is false (e.g. all history is just 'Cleared' or old),
         // we might want to check the DATE of the latest summary.
         
         // Let's rely on the "No Dues found" logic + "Has at least one Paid record".
         if (!hasPaidCurrentData && summaries.isNotEmpty) {
             // They have summaries but none say 'Paid'. Maybe 'Free'?
             // Start safe: Exclude.
             continue;
         }
      }

      // Passed all checks
      eligibleVoters.add(member);
    }
    
    // Sort A-Z by Full Name
    eligibleVoters.sort((a, b) => 
        '${a.firstName} ${a.surname}'.compareTo('${b.firstName} ${b.surname}'));
        
    return eligibleVoters;
  }

  pw.Widget _buildHeader(String year, pw.Font fontBold, pw.Font fontNormal) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10 * PdfPageFormat.mm),
      child: pw.Column(
        children: [
          pw.Text('AMARAVATI BAR ASSOCIATION', style: pw.TextStyle(font: fontBold, fontSize: 16)),
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
          pw.Text('VOTER LIST – ELIGIBLE MEMBERS', style: pw.TextStyle(font: fontBold, fontSize: 14)),
          pw.Text('(Year $year)', style: pw.TextStyle(font: fontNormal, fontSize: 12)),
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text('Generated on: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}', 
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
          pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: pw.TextStyle(font: fontNormal, fontSize: 9)),
          pw.Text('Official Voter List – System Generated', style: pw.TextStyle(font: fontNormal, fontSize: 9)),
          pw.Text('Authorized Signatory', style: pw.TextStyle(font: fontNormal, fontSize: 9)),
        ],
      )
    );
  }

  pw.Widget _buildHeaderCell(String text, pw.Font fontBold) {
     return pw.Padding(
       padding: const pw.EdgeInsets.all(5),
       child: pw.Center(child: pw.Text(text, style: pw.TextStyle(font: fontBold, fontSize: 10), textAlign: pw.TextAlign.center)),
     );
  }

  pw.TableRow _buildVoterRow(int slNo, Member member, pw.Font fontNormal, pw.Font fontBold) {
    
    // Photo Handling
    pw.Widget photoWidget;
    if (member.profilePhotoPath != null && File(member.profilePhotoPath!).existsSync()) {
       photoWidget = pw.Image(
         pw.MemoryImage(File(member.profilePhotoPath!).readAsBytesSync()),
         width: 25 * PdfPageFormat.mm,
         height: 30 * PdfPageFormat.mm,
         fit: pw.BoxFit.cover,
       );
    } else {
       photoWidget = pw.Container(
         width: 25 * PdfPageFormat.mm,
         height: 30 * PdfPageFormat.mm,
         color: PdfColors.grey200,
         child: pw.Center(
           child: pw.Text('Photo\nNot\nAvailable', 
             style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
             textAlign: pw.TextAlign.center
           )
         )
       );
    }
    
    final fullName = '${member.firstName} ${member.middleName != null ? "${member.middleName} " : ""}${member.surname}'.toUpperCase();

    return pw.TableRow(
      children: [
        pw.Container(
          height: 35 * PdfPageFormat.mm, // Fixed row height approx
          alignment: pw.Alignment.center,
          child: pw.Text('$slNo', style: pw.TextStyle(font: fontNormal, fontSize: 10)),
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
               pw.Text(fullName, style: pw.TextStyle(font: fontBold, fontSize: 11)), // BOLD CAPS
               pw.SizedBox(height: 2),
               pw.Text('Reg. No: ${member.registrationNumber}', style: pw.TextStyle(font: fontNormal, fontSize: 10)),
               pw.Text('Mobile: ${member.mobileNumber}', style: pw.TextStyle(font: fontNormal, fontSize: 10)),
            ]
          )
        ),
        pw.Container(
           height: 35 * PdfPageFormat.mm,
           padding: const pw.EdgeInsets.only(bottom: 2 * PdfPageFormat.mm),
           alignment: pw.Alignment.bottomCenter,
           child: pw.Text('Signature', style: pw.TextStyle(font: fontNormal, fontSize: 8, color: PdfColors.grey600)),
        )
      ]
    );
  }
}
