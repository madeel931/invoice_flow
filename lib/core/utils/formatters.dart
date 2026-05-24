import 'package:intl/intl.dart';

class AppFormatters {
  static final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  static final NumberFormat _numberFormat = NumberFormat('#,##0.##');

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  // Global Currency Formatter
  static String formatCurrency(double amount, [String? currencyCode]) {
    final code = (currencyCode == null || currencyCode.trim().isEmpty) ? 'AED' : currencyCode;
    final format = NumberFormat.simpleCurrency(name: code);
    return format.format(amount);
  }

  static String formatNumber(double number) {
    return _numberFormat.format(number);
  }
}
