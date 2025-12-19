import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../database/app_database.dart';

class ReceiptService {
  Future<Uint8List> generateReceipt(Subscription subscription) async {
    final doc = pw.Document();

    // Load fonts if necessary or use standard ones
    final font = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      AppConstants.organizationName.toUpperCase(),
                      style: pw.TextStyle(font: fontBold, fontSize: 24),
                    ),
                    pw.Text(
                      'Amaravati, Andhra Pradesh',
                      style: pw.TextStyle(font: font, fontSize: 12),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'SUBSCRIPTION RECEIPT',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 18,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 40),

              // Receipt Details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Receipt No: ${subscription.receiptNumber}',
                    style: pw.TextStyle(font: font),
                  ),
                  pw.Text(
                    'Date: ${DateFormat('dd MMM yyyy').format(subscription.subscriptionDate)}',
                    style: pw.TextStyle(font: font),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Content
              pw.Text(
                'Received with thanks from:',
                style: pw.TextStyle(font: font, fontSize: 14),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                '${subscription.firstName} ${subscription.lastName}',
                style: pw.TextStyle(font: fontBold, fontSize: 16),
              ),
              pw.Text(subscription.address, style: pw.TextStyle(font: font)),
              if (subscription.mobileNumber.isNotEmpty)
                pw.Text(
                  'Mobile: ${subscription.mobileNumber}',
                  style: pw.TextStyle(font: font),
                ),
              pw.Text(
                'Enrollment No: ${subscription.enrollmentNumber}',
                style: pw.TextStyle(font: font),
              ),

              pw.SizedBox(height: 20),
              pw.Text(
                'The sum of Rupees ${NumberFormat.currency(locale: "en_IN", symbol: "").format(subscription.amount)}',
                style: pw.TextStyle(font: font, fontSize: 14),
              ),
              pw.Text(
                '(${_convertNumberToWords(subscription.amount.toInt())} Only)',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 12,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),

              pw.SizedBox(height: 20),
              pw.Row(
                children: [
                  pw.Text(
                    'Payment Mode: ',
                    style: pw.TextStyle(font: fontBold),
                  ),
                  pw.Text(
                    subscription.paymentMode,
                    style: pw.TextStyle(font: font),
                  ),
                ],
              ),
              if (subscription.transactionInfo != null &&
                  subscription.transactionInfo!.isNotEmpty)
                pw.Row(
                  children: [
                    pw.Text('Ref ID: ', style: pw.TextStyle(font: fontBold)),
                    pw.Text(
                      subscription.transactionInfo!,
                      style: pw.TextStyle(font: font),
                    ),
                  ],
                ),

              pw.SizedBox(height: 40),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'This is to certify that the above-mentioned individual has paid the subscription fee to the Amaravati Bar Association.',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              ),

              pw.Spacer(),

              // Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    children: [
                      pw.Container(
                        width: 150,
                        height: 1,
                        color: PdfColors.black,
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Authorized Signature',
                        style: pw.TextStyle(font: fontBold),
                      ),
                      pw.Text(
                        'Amaravati Bar Association',
                        style: pw.TextStyle(font: font, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  String _convertNumberToWords(int number) {
    // Basic implementation placeholder - ideally use a library like 'number_to_words' if added or write a mapper.
    // For now returning simple text to avoiding complex logic bug.
    return "Rupees ..."; // TODO: Implement number to words
  }
}
