import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import '../../../../core/utils/app_directories.dart';
import '../../../../core/utils/formatters.dart';
import '../../settings/domain/entities/business_profile.dart';
import '../domain/entities/invoice.dart';
import '../domain/entities/invoice_status.dart';
import '../domain/services/invoice_calculator.dart';
import 'pdf_text_formatter.dart';
/// Generates a professional PDF document for an invoice.
/// Handles multi-page table layouts, caching, and PDF-safe text rendering.
class ArabicInvoicePdfGenerator {
  static String _getPdfStatusString(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft: return PdfTextFormatter.formatUserTextForPdf('مسودة');
      case InvoiceStatus.unpaid: return PdfTextFormatter.formatUserTextForPdf('غير مدفوعة');
      case InvoiceStatus.partiallyPaid: return PdfTextFormatter.formatUserTextForPdf('مدفوعة جزئياً');
      case InvoiceStatus.paid: return PdfTextFormatter.formatUserTextForPdf('مدفوعة');
      case InvoiceStatus.overdue: return PdfTextFormatter.formatUserTextForPdf('متأخرة');
      case InvoiceStatus.cancelled: return PdfTextFormatter.formatUserTextForPdf('ملغاة');
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
    pw.Widget textWidget = pw.Text(text, style: const pw.TextStyle(fontSize: 10), softWrap: true);
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

    // 2. Load Fallback Font for RTL Text (Arabic/Urdu)
    pw.Font? fallbackFont;
    try {
      final fontData = await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
      fallbackFont = pw.Font.ttf(fontData);
    } catch (e) {
      // Proceed without fallback font if it fails to load
    }

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
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
          fontFallback: fallbackFont != null ? [fallbackFont] : [],
        ),
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
                    pw.Text(PdfTextFormatter.formatUserTextForPdf('فاتورة'),
                        style: pw.TextStyle(
                            fontSize: 32,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800)),
                    pw.SizedBox(height: 8),
                    pw.Text('${invoice.invoiceNumber} #',
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                        '${dateFormat.format(invoice.issueDate)} :${PdfTextFormatter.formatUserTextForPdf('تاريخ الإصدار')}',
                        style: const pw.TextStyle(color: PdfColors.grey700)),
                    pw.Text('${dateFormat.format(invoice.dueDate)} :${PdfTextFormatter.formatUserTextForPdf('تاريخ الاستحقاق')}',
                        style: const pw.TextStyle(color: PdfColors.grey700)),
                    pw.SizedBox(height: 4),
                    pw.Text('${_getPdfStatusString(invoice.effectiveStatus)} :${PdfTextFormatter.formatUserTextForPdf('الحالة')}',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: _getPdfStatusColor(invoice.effectiveStatus),
                        )),
                  ],
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      if (logoImage != null)
                        pw.Container(
                          width: 80,
                          height: 80,
                          child: pw.Image(logoImage),
                        ),
                      pw.SizedBox(height: 8),
                      PdfTextFormatter.buildWrappedPdfText(
                          profile.businessName,
                          maxLines: 3,
                          maxCharsPerLine: 40,
                          alignment: pw.Alignment.centerRight,
                          style: pw.TextStyle(
                              fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      if (profile.taxId != null && profile.taxId!.isNotEmpty)
                        pw.Text('${profile.taxId} :${PdfTextFormatter.formatUserTextForPdf('الرقم الضريبي')}',
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
                        PdfTextFormatter.buildWrappedPdfText(
                            profile.address!,
                            maxLines: 4,
                            maxCharsPerLine: 50,
                            alignment: pw.Alignment.centerRight,
                            style: const pw.TextStyle(color: PdfColors.grey700)),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 32),

            // --- BILL TO ---
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(PdfTextFormatter.formatUserTextForPdf('العميل:'),
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                  pw.SizedBox(height: 4),
                  pw.Container(
                    width: 300,
                    alignment: pw.Alignment.centerRight,
                    child: PdfTextFormatter.buildWrappedPdfText(
                        invoice.customerName,
                        maxLines: 3,
                        maxCharsPerLine: 50,
                        alignment: pw.Alignment.centerRight,
                        style:
                            pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // --- LINE ITEMS TABLE ---
            pw.Table(
              border: null,
              columnWidths: {
                0: const pw.FlexColumnWidth(1.8), // Total
                1: const pw.FlexColumnWidth(1.0), // Tax
                2: const pw.FlexColumnWidth(1.8), // Unit Price
                3: const pw.FlexColumnWidth(1.2), // Qty
                4: const pw.FlexColumnWidth(3.2), // Description
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blue800),
                  children: [
                    _tableHeaderCell(PdfTextFormatter.formatUserTextForPdf('الإجمالي'), pw.Alignment.centerLeft),
                    _tableHeaderCell(PdfTextFormatter.formatUserTextForPdf('الضريبة'), pw.Alignment.center),
                    _tableHeaderCell(PdfTextFormatter.formatUserTextForPdf('سعر الوحدة'), pw.Alignment.centerLeft),
                    _tableHeaderCell(PdfTextFormatter.formatUserTextForPdf('الكمية'), pw.Alignment.center),
                    _tableHeaderCell(PdfTextFormatter.formatUserTextForPdf('الوصف'), pw.Alignment.centerRight),
                  ],
                ),
                // Data rows
                if (calc.itemBreakdowns.isEmpty)
                  pw.TableRow(
                    children: [
                      _tableBodyCell('-', pw.Alignment.centerLeft),
                      _tableBodyCell('-', pw.Alignment.center),
                      _tableBodyCell('-', pw.Alignment.centerLeft),
                      _tableBodyCell('-', pw.Alignment.center),
                      _tableBodyCell(PdfTextFormatter.formatUserTextForPdf('لا توجد عناصر'), pw.Alignment.centerRight),
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
                        _tableBodyCell(total, pw.Alignment.centerLeft, useFittedBox: true),
                        _tableBodyCell(taxString, pw.Alignment.center),
                        _tableBodyCell(AppFormatters.formatCurrencyPdf(item.unitPrice, displayCurrency), pw.Alignment.centerLeft, useFittedBox: true),
                        _tableBodyCell(qtyString, pw.Alignment.center),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          child: PdfTextFormatter.buildWrappedPdfText(
                            item.description,
                            maxCharsPerLine: 35,
                            alignment: pw.Alignment.centerRight,
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ),
                      ]
                    );
                  }),
              ],
            ),
            pw.Divider(),
            pw.SizedBox(height: 16),

            // --- SUMMARY TOTALS ---
            pw.Container(
              alignment: pw.Alignment.centerLeft,
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 5,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.FittedBox(
                              fit: pw.BoxFit.scaleDown,
                              child: pw.Text(AppFormatters.formatCurrencyPdf(calc.subtotal, displayCurrency)),
                            ),
                            pw.Text(PdfTextFormatter.formatUserTextForPdf('المجموع الفرعي:'),
                                style: const pw.TextStyle(
                                    color: PdfColors.grey700)),
                          ],
                        ),
                        if (calc.discountValue > 0) ...[
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.FittedBox(
                                fit: pw.BoxFit.scaleDown,
                                child: pw.Text(
                                    '- ${AppFormatters.formatCurrencyPdf(calc.discountValue, displayCurrency)}',
                                    style: const pw.TextStyle(
                                        color: PdfColors.red700)),
                              ),
                              pw.Text(invoice.discountType == 'percentage' 
                                  ? PdfTextFormatter.formatUserTextForPdf('الخصم (${invoice.discountAmount}%):') 
                                  : PdfTextFormatter.formatUserTextForPdf('الخصم:'),
                                  style: const pw.TextStyle(
                                      color: PdfColors.red700)),
                            ],
                          ),
                        ],
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.FittedBox(
                              fit: pw.BoxFit.scaleDown,
                              child: pw.Text(
                                  '+ ${AppFormatters.formatCurrencyPdf(calc.totalTax, displayCurrency)}'),
                            ),
                            pw.Text(PdfTextFormatter.formatUserTextForPdf('الضريبة:'),
                                style: const pw.TextStyle(
                                    color: PdfColors.grey700)),
                          ],
                        ),
                        pw.Divider(),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.FittedBox(
                              fit: pw.BoxFit.scaleDown,
                              child: pw.Text(AppFormatters.formatCurrencyPdf(calc.grandTotal, displayCurrency),
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 16,
                                      color: PdfColors.blue800)),
                            ),
                            pw.Text(PdfTextFormatter.formatUserTextForPdf('الإجمالي:'),
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 14)),
                          ],
                        ),
                        if (calc.paidAmount > 0) ...[
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.FittedBox(
                                fit: pw.BoxFit.scaleDown,
                                child: pw.Text(
                                    AppFormatters.formatCurrencyPdf(calc.paidAmount, displayCurrency)),
                              ),
                              pw.Text(PdfTextFormatter.formatUserTextForPdf('المبلغ المدفوع:'),
                                  style: const pw.TextStyle(
                                      color: PdfColors.grey700)),
                            ],
                          ),
                        ],
                        pw.SizedBox(height: 4),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.FittedBox(
                              fit: pw.BoxFit.scaleDown,
                              child: pw.Text(
                                  AppFormatters.formatCurrencyPdf(calc.balanceDue, displayCurrency),
                                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            ),
                            pw.Text(PdfTextFormatter.formatUserTextForPdf('الرصيد المستحق:'),
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.black)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.Spacer(flex: 5),
                ],
              ),
            ),
            pw.SizedBox(height: 32),

            // --- NOTES ---
            if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(PdfTextFormatter.formatUserTextForPdf('ملاحظات / شروط الدفع:'),
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700)),
              ),
              pw.SizedBox(height: 4),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                width: 400,
                child: PdfTextFormatter.buildWrappedPdfText(
                    invoice.notes!,
                    maxCharsPerLine: 70,
                    alignment: pw.Alignment.centerRight),
              ),
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
