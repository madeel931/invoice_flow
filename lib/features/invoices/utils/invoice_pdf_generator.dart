import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/utils/app_directories.dart';
import '../../../../core/utils/formatters.dart';
import '../../settings/domain/entities/business_profile.dart';
import '../domain/entities/invoice.dart';

class InvoicePdfGenerator {
  // ---  Smart Memory Cache ---
  // Stores generated PDFs in RAM to prevent CPU-heavy rebuilds
  static final Map<String, Uint8List> _pdfCache = {};

  static Future<Uint8List> generate(
      Invoice invoice, BusinessProfile profile) async {
    // 1. Generate Unique Cache Key
    // Safely determine the display currency for this specific invoice
    final displayCurrency = invoice.currencyCode?.trim().isNotEmpty == true ? invoice.currencyCode! : profile.currencyCode;
    
    // If the invoice is updated, the timestamp changes and forces a new PDF generation.
    // Include displayCurrency so changing fallback currency invalidates cache
    final cacheKey =
        '${invoice.id}_${invoice.status.name}_${invoice.updatedAt?.millisecondsSinceEpoch}_$displayCurrency';

    // 2. Check Cache First
    if (_pdfCache.containsKey(cacheKey)) {
      return _pdfCache[cacheKey]!; // Instantly return cached PDF!
    }

    final pdf = pw.Document();

    // 3. Currency Formatter
    final dateFormat = DateFormat('MMM dd, yyyy');

    // 4. Load Logo if it exists
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

    // 5. Build Document
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
            pw.Table(
              border: null,
              columnWidths: {
                0: const pw.FlexColumnWidth(3), // Description
                1: const pw.FlexColumnWidth(1), // Qty
                2: const pw.FlexColumnWidth(1), // Unit
                3: const pw.FlexColumnWidth(2), // Unit Price
                4: const pw.FlexColumnWidth(1), // Tax %
                5: const pw.FlexColumnWidth(2), // Total
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blue800),
                  children: ['Description', 'Qty', 'Unit', 'Unit Price', 'Tax %', 'Total']
                      .map((header) => pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                            child: pw.Text(header,
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.white,
                                    fontSize: 10)),
                          ))
                      .toList(),
                ),
                // Data rows
                ...invoice.items.map((item) {
                  final unitPrice = AppFormatters.formatCurrencyPdf(item.unitPrice, displayCurrency);
                  final total = AppFormatters.formatCurrencyPdf(item.total, displayCurrency);
                  final cells = [
                    // Description - left aligned
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: pw.Text(item.description, style: const pw.TextStyle(fontSize: 10)),
                    ),
                    // Qty - right aligned
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(item.quantity.toStringAsFixed(2), style: const pw.TextStyle(fontSize: 10)),
                      ),
                    ),
                    // Unit - right aligned
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(item.unitType?.toLowerCase() ?? '-', style: const pw.TextStyle(fontSize: 10)),
                      ),
                    ),
                    // Unit Price - right aligned with FittedBox
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.FittedBox(
                          fit: pw.BoxFit.scaleDown,
                          child: pw.Text(unitPrice, style: const pw.TextStyle(fontSize: 10)),
                        ),
                      ),
                    ),
                    // Tax % - right aligned
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text('${item.taxRate.toStringAsFixed(1)}%', style: const pw.TextStyle(fontSize: 10)),
                      ),
                    ),
                    // Total - right aligned with FittedBox
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.FittedBox(
                          fit: pw.BoxFit.scaleDown,
                          child: pw.Text(total, style: const pw.TextStyle(fontSize: 10)),
                        ),
                      ),
                    ),
                  ];
                  return pw.TableRow(children: cells);
                }),
              ],
            ),
            pw.Divider(),
            pw.SizedBox(height: 16),

            // --- SUMMARY TOTALS ---
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Row(
                children: [
                  pw.Spacer(flex: 5),
                  pw.Expanded(
                    flex: 5,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Subtotal:',
                                style: const pw.TextStyle(
                                    color: PdfColors.grey700)),
                            pw.FittedBox(
                              fit: pw.BoxFit.scaleDown,
                              child: pw.Text(AppFormatters.formatCurrencyPdf(invoice.subtotal, displayCurrency)),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Total Tax:',
                                style: const pw.TextStyle(
                                    color: PdfColors.grey700)),
                            pw.FittedBox(
                              fit: pw.BoxFit.scaleDown,
                              child: pw.Text(
                                  '+ ${AppFormatters.formatCurrencyPdf(invoice.totalTax, displayCurrency)}'),
                            ),
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
                              pw.FittedBox(
                                fit: pw.BoxFit.scaleDown,
                                child: pw.Text(
                                    '- ${AppFormatters.formatCurrencyPdf(invoice.discountAmount, displayCurrency)}',
                                    style: const pw.TextStyle(
                                        color: PdfColors.red700)),
                              ),
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
                            pw.FittedBox(
                              fit: pw.BoxFit.scaleDown,
                              child: pw.Text(AppFormatters.formatCurrencyPdf(invoice.totalAmount, displayCurrency),
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 16,
                                      color: PdfColors.blue800)),
                            ),
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

    // 6. Save PDF to bytes, store in Cache, and return
    final bytes = await pdf.save();
    _pdfCache[cacheKey] = bytes;
    return bytes;
  }
}
