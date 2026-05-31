import 'package:arabic_reshaper/arabic_reshaper.dart';
import 'package:bidi/bidi.dart' as bidi;

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
}
