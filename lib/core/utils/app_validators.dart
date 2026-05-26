/// Centralized validation logic for all forms in the app.
/// Ensures database integrity by strictly enforcing max lengths before data is saved to Isar.
class AppValidators {
  AppValidators._();

  static String? requiredText(
    String? value, {
    int min = 2,
    int max = 100,
    String fieldName = 'Field',
    String? errorRequired,
    String? errorMinLength,
    String? errorMaxLength,
  }) {
    final val = value?.trim();
    if (val == null || val.isEmpty) {
      return errorRequired ?? '$fieldName is required';
    }
    if (val.length < min) {
      return errorMinLength ?? '$fieldName must be at least $min characters';
    }
    if (val.length > max) {
      return errorMaxLength ?? '$fieldName must be less than $max characters';
    }
    return null;
  }

  static String? optionalText(
    String? value, {
    int max = 250,
    String fieldName = 'Field',
    String? errorMaxLength,
  }) {
    final val = value?.trim();
    if (val != null && val.isNotEmpty) {
      if (val.length > max) {
        return errorMaxLength ?? '$fieldName must be less than $max characters';
      }
    }
    return null;
  }

  static String? email(
    String? value, {
    bool required = false,
    int max = 120,
    String? errorRequired,
    String? errorMaxLength,
    String? errorInvalid,
  }) {
    final val = value?.trim();
    if (val == null || val.isEmpty) {
      if (required) return errorRequired ?? 'Email is required';
      return null;
    }
    if (val.length > max) {
      return errorMaxLength ?? 'Email must be less than $max characters';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(val)) {
      return errorInvalid ?? 'Enter a valid email address';
    }
    return null;
  }

  static String? phone(
    String? value, {
    bool required = false,
    int max = 20,
    String? errorRequired,
    String? errorMaxLength,
    String? errorInvalid,
    String? errorMinLength,
  }) {
    final val = value?.trim();
    if (val == null || val.isEmpty) {
      if (required) return errorRequired ?? 'Phone number is required';
      return null;
    }
    if (val.length > max) {
      return errorMaxLength ?? 'Phone number is too long';
    }
    final phoneRegex = RegExp(r'^[0-9+\-\s()]+$');
    if (!phoneRegex.hasMatch(val)) {
      return errorInvalid ?? 'Enter a valid phone number';
    }
    if (val.length < 7) {
      return errorMinLength ?? 'Phone number is too short';
    }
    return null;
  }

  static String? amount(
    String? value, {
    bool required = true,
    double min = 0,
    double max = 99999999.99,
    String fieldName = 'Amount',
    String? errorRequired,
    String? errorInvalid,
    String? errorMin,
    String? errorMax,
  }) {
    final val = value?.trim();
    if (val == null || val.isEmpty) {
      if (required) return errorRequired ?? '$fieldName is required';
      return null;
    }
    final number = double.tryParse(val);
    if (number == null) {
      return errorInvalid ?? 'Enter a valid amount';
    }
    if (number < min) {
      return errorMin ?? '$fieldName must be at least $min';
    }
    if (number > max) {
      return errorMax ?? '$fieldName is too large';
    }
    return null;
  }

  static String? quantity(
    String? value, {
    bool required = true,
    int min = 1,
    int max = 999999,
    String? errorRequired,
    String? errorInvalid,
    String? errorMin,
    String? errorMax,
  }) {
    final val = value?.trim();
    if (val == null || val.isEmpty) {
      if (required) return errorRequired ?? 'Quantity is required';
      return null;
    }
    final number = int.tryParse(val);
    if (number == null) {
      return errorInvalid ?? 'Enter a valid quantity';
    }
    if (number < min) {
      return errorMin ?? 'Quantity must be at least $min';
    }
    if (number > max) {
      return errorMax ?? 'Quantity is too large';
    }
    return null;
  }

  static String? percentage(
    String? value, {
    bool required = false,
    double min = 0,
    double max = 100,
    String fieldName = 'Percentage',
    String? errorRequired,
    String? errorInvalid,
    String? errorMin,
    String? errorMax,
  }) {
    final val = value?.trim();
    if (val == null || val.isEmpty) {
      if (required) return errorRequired ?? '$fieldName is required';
      return null;
    }
    final number = double.tryParse(val);
    if (number == null) {
      return errorInvalid ?? 'Enter a valid percentage';
    }
    if (number < min) {
      return errorMin ?? '$fieldName cannot be negative';
    }
    if (number > max) {
      return errorMax ?? '$fieldName cannot exceed $max';
    }
    return null;
  }
}
