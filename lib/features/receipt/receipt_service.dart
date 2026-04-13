import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../core/constants.dart';

import '../database/app_database.dart';
import '../database/tables.dart';
import '../database/daos/members_dao.dart';
import '../database/database_provider.dart';

final receiptServiceProvider = Provider<ReceiptService>((ref) {
  final db = ref.watch(databaseProvider);
  return ReceiptService(db.membersDao);
});

class ReceiptService {
  final MembersDao _membersDao;


  ReceiptService(this._membersDao);

  /// Saves a PDF file to the Downloads directory.
  Future<void> saveToDownloads(BuildContext context, Uint8List pdfBytes, String fileName) async {
    try {
      final directory = await getDownloadsDirectory();
      if (directory != null) {
        final filePath = '${directory.path}\\$fileName';
        final file = File(filePath);
        
        await file.writeAsBytes(pdfBytes);

        if (context.mounted) {
           ScaffoldMessenger.of(context).clearSnackBars();
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Saved to: $filePath'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              showCloseIcon: true,
              margin: const EdgeInsets.all(16),
              action: SnackBarAction(
                label: 'OPEN FOLDER',
                textColor: Colors.white,
                onPressed: () {
                   Process.run('explorer.exe', ['/select,', filePath]);
                },
              ),
            ),
          );
        }
      } else {
        throw Exception('Could not access Downloads folder');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving receipt: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<Uint8List> generateReceipt(Subscription subscription, {String title = 'SUBSCRIPTION RECEIPT'}) async {
    final doc = pw.Document();

    final fontSerif = pw.Font.times();
    final fontSerifBold = pw.Font.timesBold();
    final fontSerifBoldItalic = pw.Font.timesBoldItalic();
    // Use Courier Bold Oblique for Bold+Italic look on filled values
    final fontFilled = pw.Font.courierBoldOblique(); 

    // Fetch Full Member Details for Name
    // Default fallback
    String fullName = '${subscription.lastName} ${subscription.firstName}';
    try {
      // Lookup using enrollment number (which matches registrationNumber in Member table)
      final member = await _membersDao.getMemberByRegNo(subscription.enrollmentNumber);
      if (member != null) {
         // Format: Surname-Firstname-Middlename
         fullName = '${member.surname} ${member.firstName} ${member.middleName ?? ""}';
      }
    } catch (e) {
      // Fallback to subscription name if lookup fails
      debugPrint('Error fetching member name: $e');
    }
    
    // Determine Receipt Type Label (Subscription / Arrear / Donation)
    String receiptType = 'Subscription';
    if (title.toUpperCase().contains('ARREAR')) {
       receiptType = 'Arrear';
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a6.landscape,
        margin: const pw.EdgeInsets.all(6 * PdfPageFormat.mm), 
        build: (pw.Context context) {
          return _buildTraditionalReceipt(
            context,
            receiptNo: subscription.receiptNumber,
            date: subscription.subscriptionDate,
            name: fullName.trim(),
            amount: subscription.amount,
            amountWords: '${_convertNumberToWords(subscription.amount.toInt())} Only',
            // Strip "being subscription for..." if it's redundant, or just pass the details
            purpose: 'period ${DateFormat('MMM yyyy').format(subscription.subscriptionDate)}', 
            mode: subscription.paymentMode,
            refId: subscription.transactionInfo,
            receiptType: receiptType,
            fontSerif: fontSerif,
            fontSerifBold: fontSerifBold,
            fontSerifBoldItalic: fontSerifBoldItalic,
            fontFilled: fontFilled,
          );
        },
      ),
    );

    return doc.save();
  }

  Future<Uint8List> generateDonationReceipt(Donation donation) async {
    final doc = pw.Document();
    
    final fontSerif = pw.Font.times();
    final fontSerifBold = pw.Font.timesBold();
    final fontSerifBoldItalic = pw.Font.timesBoldItalic();
    final fontFilled = pw.Font.courierBoldOblique();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a6.landscape,
        margin: const pw.EdgeInsets.all(6 * PdfPageFormat.mm),
        build: (pw.Context context) {
          return _buildTraditionalReceipt(
            context,
            receiptNo: donation.receiptNumber,
            date: donation.donationDate,
            name: donation.donorName,
            amount: donation.amount,
            amountWords: '${_convertNumberToWords(donation.amount.toInt())} Only',
            purpose: '${donation.purpose ?? ""}',
            mode: donation.paymentMode,
            refId: donation.transactionRef,
            receiptType: 'Donation', 
            fontSerif: fontSerif,
            fontSerifBold: fontSerifBold,
            fontSerifBoldItalic: fontSerifBoldItalic,
            fontFilled: fontFilled,
          );
        },
      ),
    );

    return doc.save();
  }

  pw.Widget _buildTraditionalReceipt(
    pw.Context context, {
    required String receiptNo,
    required DateTime date,
    required String name,
    required double amount,
    required String amountWords,
    required String purpose,
    required String mode,
    required String receiptType, // e.g., Subscription, Donation
    String? refId,
    required pw.Font fontSerif,
    required pw.Font fontSerifBold,
    required pw.Font fontSerifBoldItalic,
    required pw.Font fontFilled, 
  }) {
    final PdfColor borderColor = PdfColor.fromHex('#C97A87');
    final PdfColor textColor = PdfColors.black;
    
    // Bold & Underlined Style for filled fields
    final filledTextStyle = pw.TextStyle(
      font: fontFilled, 
      fontSize: 12, // Increased from 10
      color: textColor,
      decoration: pw.TextDecoration.underline,
      fontWeight: pw.FontWeight.bold,
    );

    // Determine Signature Labels
    String payerLabel = 'Signature of Payer';
    String receiverLabel = 'Person Receiving Subscription';

    if (receiptType == 'Donation') {
      payerLabel = 'Signature of Donator';
      receiverLabel = 'Person Receiving Donation';
    } else if (receiptType == 'Arrear') {
      receiverLabel = 'Person Receiving Subscriptions'; // Plural as requested
    }
    
    // A6 Landscape: 148 x 105 mm. margins 6mm.
    return pw.Container(
      width: double.infinity,
      height: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderColor, width: 1.2), // Outer border
      ),
      padding: const pw.EdgeInsets.all(2.5 * PdfPageFormat.mm), // Gap 2.5mm
      child: pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: borderColor, width: 0.6), // Inner border
        ),
        child: pw.Stack(
          children: [
            // 1. HEADER (Styled & Stretched)
            pw.Positioned(
              left: 4 * PdfPageFormat.mm,  // Padding from sides
              right: 4 * PdfPageFormat.mm, 
              top: 3 * PdfPageFormat.mm,
              child: pw.Center(
                child: pw.FittedBox( // Stretch to fit width
                  child: pw.Text(
                    'Amravati District Bar Association, Amravati',
                    style: pw.TextStyle(
                      font: fontSerifBoldItalic,
                      fontSize: 18, // Increased from 16
                      color: borderColor,
                    ),
                  ),
                ),
              ),
            ),

            // 2. Receipt Number
            pw.Positioned(
              left: 8 * PdfPageFormat.mm,
              top: 20 * PdfPageFormat.mm,
              child: pw.Text(
                'No. $receiptNo',
                style: pw.TextStyle(font: fontSerif, fontSize: 11, color: textColor), // Increased from 9
              ),
            ),

            // 3. Date
            pw.Positioned(
              right: 8 * PdfPageFormat.mm, // Moved right (was 15mm)
              top: 20 * PdfPageFormat.mm,
              child: pw.Text(
                'Date: ${DateFormat('dd/MM/yyyy').format(date)}',
                style: pw.TextStyle(font: fontSerif, fontSize: 11, color: textColor), // Increased from 9
              ),
            ),

            // 4. Received With Thanks
            // Shifted down to 36mm (was 30mm)
            // 4. Received With Thanks & Name
            // Shifted down to 36mm (was 30mm)
            pw.Positioned(
              left: 8 * PdfPageFormat.mm,
              top: 36 * PdfPageFormat.mm,
              right: 8 * PdfPageFormat.mm, // Constrain width
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end, // Align baseline
                children: [
                  pw.Text(
                    'Received with thanks from Adv/Shri/Smt  ',
                    style: pw.TextStyle(font: fontSerif, fontSize: 11, color: textColor), 
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      name,
                      style: filledTextStyle,
                      maxLines: 1,
                      overflow: pw.TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            ),

            // 5. Amount Numeric
            // Shifted down to 48mm (was 40mm)
            pw.Positioned(
              left: 8 * PdfPageFormat.mm,
              top: 48 * PdfPageFormat.mm,
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'A sum of Rs.  ',
                    style: pw.TextStyle(font: fontSerif, fontSize: 11, color: textColor), // Increased from 9
                  ),
                   pw.Text( 
                     '${NumberFormat.currency(locale: "en_IN", symbol: "").format(amount)}/-',
                     style: filledTextStyle.copyWith(fontSize: 12), // Increased from 10
                  ),
                ],
              ),
            ),

            // 6. Amount Words
            // Shifted down to 48mm (was 40mm)
            pw.Positioned(
              left: 55 * PdfPageFormat.mm,
              top: 48 * PdfPageFormat.mm,
              right: 8 * PdfPageFormat.mm,
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'in words Rs.  ',
                    style: pw.TextStyle(font: fontSerif, fontSize: 11, color: textColor), // Increased from 9
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      amountWords,
                      style: filledTextStyle.copyWith(fontSize: 11), // Increased from 9
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),

            // 7. Purpose (Dynamic Label)
            // Shifted down to 60mm (was 50mm)
            pw.Positioned(
              left: 8 * PdfPageFormat.mm,
              top: 60 * PdfPageFormat.mm,
              right: 8 * PdfPageFormat.mm,
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'being $receiptType for  ', // Dynamic Label
                    style: pw.TextStyle(font: fontSerif, fontSize: 11, color: textColor), // Increased from 9
                  ),
                  pw.Expanded(
                    child: pw.Text(
                       purpose,
                       style: filledTextStyle,
                       maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),

            // 8. Signatures
            pw.Positioned(
              left: 8 * PdfPageFormat.mm,
              bottom: 5 * PdfPageFormat.mm, // Moved down (was 10mm)
              child: pw.Column(
                 crossAxisAlignment: pw.CrossAxisAlignment.start,
                 children: [
                    pw.Text(payerLabel, style: pw.TextStyle(font: fontSerif, fontSize: 10, color: textColor)), // Increased from 8
                 ],
              ),
            ),

            pw.Positioned(
              right: 8 * PdfPageFormat.mm, // Moved right (was 15mm)
              bottom: 5 * PdfPageFormat.mm, // Moved down (was 10mm)
              child: pw.Column(
                 crossAxisAlignment: pw.CrossAxisAlignment.end,
                 children: [
                    pw.Text(receiverLabel, style: pw.TextStyle(font: fontSerif, fontSize: 10, color: textColor)), // Increased from 8
                 ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _convertNumberToWords(int number) {
    if (number == 0) return "Zero";

    final units = [
      "",
      "One",
      "Two",
      "Three",
      "Four",
      "Five",
      "Six",
      "Seven",
      "Eight",
      "Nine",
      "Ten",
      "Eleven",
      "Twelve",
      "Thirteen",
      "Fourteen",
      "Fifteen",
      "Sixteen",
      "Seventeen",
      "Eighteen",
      "Nineteen",
    ];

    final tens = [
      "",
      "",
      "Twenty",
      "Thirty",
      "Forty",
      "Fifty",
      "Sixty",
      "Seventy",
      "Eighty",
      "Ninety",
    ];

    String words = "";

    if (number >= 100000) {
      words += "${_convertNumberToWords(number ~/ 100000)} Lakh ";
      number %= 100000;
    }

    if (number >= 1000) {
      words += "${_convertNumberToWords(number ~/ 1000)} Thousand ";
      number %= 1000;
    }

    if (number >= 100) {
      words += "${_convertNumberToWords(number ~/ 100)} Hundred ";
      number %= 100;
    }

    if (number > 0) {
      if (words != "") words += "and ";

      if (number < 20) {
        words += units[number];
      } else {
        words += "${tens[number ~/ 10]} ";
        if (number % 10 > 0) {
          words += units[number % 10];
        }
      }
    }

    return words.trim();
  }
}
