import 'package:flutter/services.dart';

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
