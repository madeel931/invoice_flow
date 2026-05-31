import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:arabic_reshaper/arabic_reshaper.dart';
import 'package:bidi/bidi.dart' as bidi;

void main() async {
  final pdf = pw.Document();
  final fontData = File('assets/fonts/NotoSansArabic-Regular.ttf').readAsBytesSync();
  final ttf = pw.Font.ttf(fontData.buffer.asByteData());

  String shapeRtlForPdf(String input) {
    final reshaper = ArabicReshaper();
    final reshaped = reshaper.reshape(input);
    // 2. Convert logical to visual (reverses the RTL parts, keeps LTR numbers/English intact)
    final visualChars = bidi.logicalToVisual(reshaped);
    return String.fromCharCodes(visualChars);
  }

  // Define test cases
  final arabicTexts = [
    'شركة ممتازة للتجارة والخدمات',
    'تصميم وتطوير تطبيق جوال',
    'شكراً لتعاملكم معنا',
  ];

  final urduTexts = [
    'عدیل لیبز پرائیویٹ سروسز',
    'موبائل ایپ ڈویلپمنٹ سروس',
    'آپ کے کاروبار کا شکریہ',
    'پ، چ، ژ، گ، ں، ئ، ے',
  ];

  final mixedTexts = [
    'Invoice INV-001 - عدیل لیبز - USD 250.00',
    'فاتورة INV-002 - شركة ممتازة - USD 500.00',
  ];

  pw.Widget buildSection(String title, List<String> texts) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        pw.SizedBox(height: 8),
        ...texts.map((text) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 12),
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Raw: $text', style: pw.TextStyle(font: ttf, fontSize: 12)),
                pw.Text('Reshaped Only: ${ArabicReshaper().reshape(text)}', style: pw.TextStyle(font: ttf, fontSize: 12, color: PdfColors.blue)),
                pw.Text('Reshaped + Bidi (Visual): ${shapeRtlForPdf(text)}', style: pw.TextStyle(font: ttf, fontSize: 12, color: PdfColors.green)),
              ],
            ),
          );
        }),
        pw.SizedBox(height: 16),
      ],
    );
  }

  pdf.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    theme: pw.ThemeData(defaultTextStyle: pw.TextStyle(font: ttf)),
    build: (pw.Context context) {
      return [
        pw.Text('ADii Labs - RTL PDF Prototype', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, font: ttf)),
        pw.SizedBox(height: 20),
        buildSection('Arabic Test', arabicTexts),
        buildSection('Urdu Test', urduTexts),
        buildSection('Mixed LTR/RTL Test', mixedTexts),
      ];
    },
  ));

  final file = File('rtl_pdf_text_prototype.pdf');
  await file.writeAsBytes(await pdf.save());
  // ignore: avoid_print
  print('Prototype generated at: ${file.absolute.path}');
}
