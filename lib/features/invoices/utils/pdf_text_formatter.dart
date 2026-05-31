import 'package:arabic_reshaper/arabic_reshaper.dart';
import 'package:bidi/bidi.dart' as bidi;

import 'package:pdf/widgets.dart' as pw;

/// Formats text specifically for the `pdf` package by handling Complex Text Layout (CTL).
/// The dart `pdf` package plots strings left-to-right visually.
/// This helper shapes Arabic/Urdu contextual ligatures and applies the Bidi algorithm 
/// to reverse RTL string sections visually so they print correctly.
class PdfTextFormatter {
  static final _reshaper = ArabicReshaper();

  /// Detects if the string contains Arabic/Urdu characters.
  static bool isRtlText(String text) {
    return RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]').hasMatch(text);
  }

  /// Shapes and bidirectionally orders text for PDF rendering.
  static String formatUserTextForPdf(String text) {
    if (text.isEmpty) return text;
    if (!isRtlText(text)) return text;
    
    // 1. Shape Arabic/Urdu characters to connect properly
    final reshaped = _reshaper.reshape(text);
    
    // 2. Convert logical string to visual rendering string (reverses RTL chunks, keeps LTR unchanged)
    final visualChars = bidi.logicalToVisual(reshaped);
    return String.fromCharCodes(visualChars);
  }

  /// Splits logical RTL text into lines based on word boundaries without applying bidi yet.
  static List<String> splitRtlTextIntoLogicalLines(String text, {required int maxCharsPerLine}) {
    if (text.length <= maxCharsPerLine) return [text];
    
    final words = text.split(' ');
    final lines = <String>[];
    String currentLine = '';
    
    for (final word in words) {
      if ((currentLine.length + word.length + 1) > maxCharsPerLine) {
        if (currentLine.isNotEmpty) {
          lines.add(currentLine.trim());
          currentLine = word;
        } else {
          // Single word is longer than maxCharsPerLine
          lines.add(word);
          currentLine = '';
        }
      } else {
        currentLine = currentLine.isEmpty ? word : '$currentLine $word';
      }
    }
    
    if (currentLine.isNotEmpty) {
      lines.add(currentLine.trim());
    }
    
    return lines;
  }

  /// Builds a pw.Widget that safely wraps long RTL text in its logical visual order.
  static pw.Widget buildWrappedPdfText(
    String text, {
    pw.TextStyle? style,
    int? maxLines,
    int maxCharsPerLine = 50,
    pw.Alignment alignment = pw.Alignment.centerRight,
  }) {
    if (text.isEmpty) return pw.SizedBox();

    // If it's pure English/LTR, fallback to standard soft wrap.
    if (!isRtlText(text)) {
      return pw.Text(
        text,
        style: style,
        maxLines: maxLines,
        softWrap: true,
        textAlign: alignment == pw.Alignment.centerLeft
            ? pw.TextAlign.left
            : alignment == pw.Alignment.center
                ? pw.TextAlign.center
                : pw.TextAlign.right,
      );
    }

    // For RTL, split into logical lines BEFORE bidi transform
    final lines = splitRtlTextIntoLogicalLines(text, maxCharsPerLine: maxCharsPerLine);
    final limit = maxLines != null && lines.length > maxLines ? maxLines : lines.length;

    return pw.Column(
      crossAxisAlignment: alignment == pw.Alignment.centerLeft
          ? pw.CrossAxisAlignment.start
          : alignment == pw.Alignment.center
              ? pw.CrossAxisAlignment.center
              : pw.CrossAxisAlignment.end,
      children: lines.take(limit).map((line) {
        final formattedLine = formatUserTextForPdf(line);
        return pw.Text(
          formattedLine,
          style: style,
          softWrap: false, // Wrapping is handled manually via the Column chunks
        );
      }).toList(),
    );
  }
}
