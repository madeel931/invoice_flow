import 'package:intl/intl.dart';

class AppFormatters {
  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  static final NumberFormat _numberFormat = NumberFormat('#,##0.##');

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// UI currency formatter. 
  /// Automatically renders Unicode currency symbols based on the device locale and the provided code.
  static String formatCurrency(double amount, [String? currencyCode]) {
    final code = (currencyCode == null || currencyCode.trim().isEmpty) ? 'AED' : currencyCode;
    final format = NumberFormat.simpleCurrency(name: code);
    return format.format(amount);
  }

  /// Compact currency for dashboard/stat cards only. NOT for invoices/PDF/exports.
  static String formatCurrencyCompact(double amount, [String? currencyCode]) {
    final code = (currencyCode == null || currencyCode.trim().isEmpty) ? 'AED' : currencyCode;
    final format = NumberFormat.compactCurrency(name: code, decimalDigits: 2);
    format.significantDigitsInUse = false;
    
    String formatted = format.format(amount);
    final decimalSeparator = format.symbols.DECIMAL_SEP;
    
    formatted = formatted.replaceAll(RegExp(r'\' + decimalSeparator + r'00(?=[^0-9]*$)'), '');
    formatted = formatted.replaceAllMapped(RegExp(r'(\' + decimalSeparator + r'[0-9]*[1-9])0+(?=[^0-9]*$)'), (match) {
      return match.group(1)!;
    });
    
    return formatted;
  }

  /// PDF-safe currency formatter. Uses ISO 3-letter code instead of Unicode symbols
  /// because PDF default font (Helvetica/WinAnsiEncoding) cannot render ₹, ﷼, ₨, etc.
  /// Output examples: INR 1,000.00 / USD 1,000.00 / SAR 1,000.00
  /// Use ONLY in PDF generation. UI should continue using formatCurrency.
  static String formatCurrencyPdf(double amount, [String? currencyCode]) {
    final code = (currencyCode == null || currencyCode.trim().isEmpty)
        ? 'AED'
        : currencyCode.trim().toUpperCase();
    final format = NumberFormat.currency(
      name: code,
      symbol: '$code ',
      decimalDigits: 2,
    );
    return format.format(amount);
  }


  static String formatNumber(double number) {
    return _numberFormat.format(number);
  }
}
