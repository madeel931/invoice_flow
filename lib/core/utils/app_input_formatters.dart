import 'package:flutter/services.dart';

/// Restricts keyboard input to prevent malformed data from entering the UI text fields.
/// Protects against invalid string-to-number parsing errors during calculations.
class AppInputFormatters {
  AppInputFormatters._();

  static final phone = FilteringTextInputFormatter.allow(
    RegExp(r'[0-9+\-\s()]'),
  );

  static final quantity = FilteringTextInputFormatter.digitsOnly;

  static final amount = FilteringTextInputFormatter.allow(
    RegExp(r'^\d*\.?\d{0,2}'),
  );

  static final percentage = FilteringTextInputFormatter.allow(
    RegExp(r'^\d*\.?\d{0,2}'),
  );
}
