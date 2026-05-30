import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/utils/app_directories.dart';
import '../../../../core/utils/formatters.dart';
import '../../settings/domain/entities/business_profile.dart';
import '../domain/entities/invoice.dart';
import '../domain/entities/invoice_status.dart';
import '../domain/services/invoice_calculator.dart';

/// Generates a professional PDF document for an invoice.
/// Handles multi-page table layouts, caching, and PDF-safe text rendering.
class InvoicePdfGenerator {
  static String _getPdfStatusString(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft: return 'DRAFT';
      case InvoiceStatus.unpaid: return 'UNPAID';
      case InvoiceStatus.partiallyPaid: return 'PARTIALLY PAID';
      case InvoiceStatus.paid: return 'PAID';
      case InvoiceStatus.overdue: return 'OVERDUE';
      case InvoiceStatus.cancelled: return 'CANCELLED';
    }
  }

  static PdfColor _getPdfStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft: return PdfColors.grey700;
      case InvoiceStatus.unpaid: return PdfColors.orange700;
      case InvoiceStatus.partiallyPaid: return PdfColors.blue700;
      case InvoiceStatus.paid: return PdfColors.green700;
      case InvoiceStatus.overdue: return PdfColors.red700;
      case InvoiceStatus.cancelled: return PdfColors.grey700;
    }
  }

  static String _formatQuantity(double quantity) {
    if (quantity % 1 == 0) {
      return quantity.toInt().toString();
    }
    return quantity.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  static String _formatTax(double tax) {
    if (tax % 1 == 0) {
      return '${tax.toInt()}%';
    }
    return '${tax.toStringAsFixed(2).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '')}%';
  }

  static pw.Widget _tableHeaderCell(String text, pw.Alignment alignment) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: pw.Align(
        alignment: alignment,
        child: pw.Text(text,
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 10)),
      ),
    );
  }

  static pw.Widget _tableBodyCell(String text, pw.Alignment alignment, {bool useFittedBox = false}) {
    pw.Widget textWidget = pw.Text(text, style: const pw.TextStyle(fontSize: 10));
    if (useFittedBox) {
      // Prevents massive numbers (e.g., 100,000,000) from breaking the PDF table layout
      textWidget = pw.FittedBox(
        fit: pw.BoxFit.scaleDown,
        alignment: alignment,
        child: textWidget,
      );
    }
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Align(
        alignment: alignment,
        child: textWidget,
      ),
    );
  }

  static Future<Uint8List> generate(
      Invoice invoice, BusinessProfile profile) async {
    try {
      // Safely determine the display currency for this specific invoice
      final displayCurrency = invoice.currencyCode?.trim().isNotEmpty == true ? invoice.currencyCode! : profile.currencyCode;

    final calc = InvoiceCalculator.calculate(invoice);
    final pdf = pw.Document();

    // 3. Currency Formatter
    final dateFormat = DateFormat('MMM dd, yyyy');

    // 4. Load Logo if it exists safely
    pw.MemoryImage? logoImage;
    if (profile.logoPath != null && profile.logoPath!.trim().isNotEmpty) {
      try {
        final file = File(AppDirectories.constructImagePath(profile.logoPath!));
        if (await file.exists()) {
          logoImage = pw.MemoryImage(await file.readAsBytes());
        }
      } catch (e) {
        // Silently fail logo load so the invoice still generates without it
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
                    pw.Text('Status: ${_getPdfStatusString(invoice.effectiveStatus)}',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: _getPdfStatusColor(invoice.effectiveStatus),
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
                0: const pw.FlexColumnWidth(3.2), // Description
                1: const pw.FlexColumnWidth(1.2), // Qty
                2: const pw.FlexColumnWidth(1.8), // Unit Price
                3: const pw.FlexColumnWidth(1.0), // Tax
                4: const pw.FlexColumnWidth(1.8), // Total
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blue800),
                  children: [
                    _tableHeaderCell('Description', pw.Alignment.centerLeft),
                    _tableHeaderCell('Qty', pw.Alignment.center),
                    _tableHeaderCell('Unit Price', pw.Alignment.centerRight),
                    _tableHeaderCell('Tax %', pw.Alignment.center),
                    _tableHeaderCell('Total', pw.Alignment.centerRight),
                  ],
                ),
                // Data rows
                if (calc.itemBreakdowns.isEmpty)
                  pw.TableRow(
                    children: [
                      _tableBodyCell('No items added', pw.Alignment.centerLeft),
                      _tableBodyCell('-', pw.Alignment.center),
                      _tableBodyCell('-', pw.Alignment.centerRight),
                      _tableBodyCell('-', pw.Alignment.center),
                      _tableBodyCell('-', pw.Alignment.centerRight),
                    ]
                  )
                else
                  ...calc.itemBreakdowns.map((calcItem) {
                    final item = calcItem.item;
                    final total = AppFormatters.formatCurrencyPdf(
                        calcItem.itemTotal, displayCurrency);
                        
                    // We append the unit to the quantity string for clear professional display (e.g. "5 kg")
                    final qtyString = '${_formatQuantity(item.quantity)}${item.unitType != null ? ' ${item.unitType!.toLowerCase()}' : ''}';
                    final taxString = _formatTax(item.taxRate);

                    return pw.TableRow(
                      children: [
                        _tableBodyCell(item.description, pw.Alignment.centerLeft),
                        _tableBodyCell(qtyString, pw.Alignment.center),
                        _tableBodyCell(AppFormatters.formatCurrencyPdf(item.unitPrice, displayCurrency), pw.Alignment.centerRight, useFittedBox: true),
                        _tableBodyCell(taxString, pw.Alignment.center),
                        _tableBodyCell(total, pw.Alignment.centerRight, useFittedBox: true),
                      ]
                    );
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
                              child: pw.Text(AppFormatters.formatCurrencyPdf(calc.subtotal, displayCurrency)),
                            ),
                          ],
                        ),
                        if (calc.discountValue > 0) ...[
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(invoice.discountType == 'percentage' ? 'Discount (${invoice.discountAmount}%):' : 'Discount:',
                                  style: const pw.TextStyle(
                                      color: PdfColors.red700)),
                              pw.FittedBox(
                                fit: pw.BoxFit.scaleDown,
                                child: pw.Text(
                                    '- ${AppFormatters.formatCurrencyPdf(calc.discountValue, displayCurrency)}',
                                    style: const pw.TextStyle(
                                        color: PdfColors.red700)),
                              ),
                            ],
                          ),
                        ],
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
                                  '+ ${AppFormatters.formatCurrencyPdf(calc.totalTax, displayCurrency)}'),
                            ),
                          ],
                        ),
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
                              child: pw.Text(AppFormatters.formatCurrencyPdf(calc.grandTotal, displayCurrency),
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 16,
                                      color: PdfColors.blue800)),
                            ),
                          ],
                        ),
                        if (calc.paidAmount > 0) ...[
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Paid Amount:',
                                  style: const pw.TextStyle(
                                      color: PdfColors.grey700)),
                              pw.FittedBox(
                                fit: pw.BoxFit.scaleDown,
                                child: pw.Text(
                                    AppFormatters.formatCurrencyPdf(calc.paidAmount, displayCurrency)),
                              ),
                            ],
                          ),
                        ],
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Balance Due:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.black)),
                            pw.FittedBox(
                              fit: pw.BoxFit.scaleDown,
                              child: pw.Text(
                                  AppFormatters.formatCurrencyPdf(calc.balanceDue, displayCurrency),
                                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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

    // 6. Save PDF to bytes and return
    final bytes = await pdf.save();
    return bytes;
    } catch (e) {
      throw Exception('Failed to generate PDF. Please verify invoice details or remove problematic characters and try again.');
    }
  }
}
