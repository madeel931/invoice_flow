import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/utils/app_directories.dart';
import '../../settings/domain/entities/business_profile.dart';
import '../domain/entities/invoice.dart';

class InvoicePdfGenerator {
  static Future<Uint8List> generate(
      Invoice invoice, BusinessProfile profile) async {
    final pdf = pw.Document();

    // 1. Currency Formatter
    final formatCurrency =
        NumberFormat.simpleCurrency(name: profile.currencyCode);
    final dateFormat = DateFormat('MMM dd, yyyy');

    // 2. Load Logo if it exists
    pw.MemoryImage? logoImage;
    if (profile.logoPath != null) {
      try {
        final file = File(AppDirectories.constructImagePath(profile.logoPath!));
        if (file.existsSync()) {
          logoImage = pw.MemoryImage(file.readAsBytesSync());
        }
      } catch (e) {
        // Silently fail logo load so the invoice still generates
      }
    }

    // 3. Build Document
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            // --- HEADER ---
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (logoImage != null)
                      pw.Container(
                        width: 80,
                        height: 80,
                        child: pw.Image(logoImage),
                      ),
                    pw.SizedBox(height: 8),
                    pw.Text(profile.businessName,
                        style: pw.TextStyle(
                            fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    if (profile.taxId != null && profile.taxId!.isNotEmpty)
                      pw.Text('Tax ID: ${profile.taxId}',
                          style: const pw.TextStyle(color: PdfColors.grey700)),
                    if (profile.email != null && profile.email!.isNotEmpty)
                      pw.Text(profile.email!,
                          style: const pw.TextStyle(color: PdfColors.grey700)),
                    if (profile.phone != null && profile.phone!.isNotEmpty)
                      pw.Text(profile.phone!,
                          style: const pw.TextStyle(color: PdfColors.grey700)),
                    if (profile.website != null && profile.website!.isNotEmpty)
                      pw.Text(profile.website!,
                          style: const pw.TextStyle(color: PdfColors.grey700)),
                    if (profile.address != null && profile.address!.isNotEmpty)
                      pw.Text(profile.address!,
                          style: const pw.TextStyle(color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('INVOICE',
                        style: pw.TextStyle(
                            fontSize: 32,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800)),
                    pw.SizedBox(height: 8),
                    pw.Text('# ${invoice.invoiceNumber}',
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                        'Issue Date: ${dateFormat.format(invoice.issueDate)}',
                        style: const pw.TextStyle(color: PdfColors.grey700)),
                    pw.Text('Due Date: ${dateFormat.format(invoice.dueDate)}',
                        style: const pw.TextStyle(color: PdfColors.grey700)),
                    pw.SizedBox(height: 4),
                    pw.Text('Status: ${invoice.status.name.toUpperCase()}',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: invoice.status.name == 'paid'
                              ? PdfColors.green700
                              : PdfColors.red700,
                        )),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 32),

            // --- BILL TO ---
            pw.Text('BILLED TO:',
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
            pw.SizedBox(height: 4),
            pw.Text(invoice.customerName,
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 24),

            // --- LINE ITEMS TABLE ---
            pw.TableHelper.fromTextArray(
              headers: ['Description', 'Qty', 'Unit Price', 'Tax %', 'Total'],
              data: invoice.items
                  .map((item) => [
                        item.description,
                        item.quantity.toStringAsFixed(2),
                        formatCurrency.format(item.unitPrice),
                        '${item.taxRate.toStringAsFixed(1)}%',
                        formatCurrency.format(item.total),
                      ])
                  .toList(),
              border: null,
              headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.blue800),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerRight,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerRight,
              },
            ),
            pw.Divider(),
            pw.SizedBox(height: 16),

            // --- SUMMARY TOTALS ---
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Row(
                children: [
                  pw.Spacer(flex: 6),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Subtotal:',
                                style: const pw.TextStyle(
                                    color: PdfColors.grey700)),
                            pw.Text(formatCurrency.format(invoice.subtotal)),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total Tax:',
                                style: const pw.TextStyle(
                                    color: PdfColors.grey700)),
                            pw.Text(
                                '+ ${formatCurrency.format(invoice.totalTax)}'),
                          ],
                        ),
                        if (invoice.discountAmount > 0) ...[
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Discount:',
                                  style: const pw.TextStyle(
                                      color: PdfColors.red700)),
                              pw.Text(
                                  '- ${formatCurrency.format(invoice.discountAmount)}',
                                  style: const pw.TextStyle(
                                      color: PdfColors.red700)),
                            ],
                          ),
                        ],
                        pw.Divider(),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('GRAND TOTAL:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 14)),
                            pw.Text(formatCurrency.format(invoice.totalAmount),
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 16,
                                    color: PdfColors.blue800)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 32),

            // --- NOTES ---
            if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
              pw.Text('Notes / Payment Terms:',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700)),
              pw.SizedBox(height: 4),
              pw.Text(invoice.notes!),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }
}
