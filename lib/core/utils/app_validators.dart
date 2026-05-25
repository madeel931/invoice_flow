class AppValidators {
  AppValidators._();

  static String? requiredText(
    String? value, {
    int min = 2,
    int max = 100,
    String fieldName = 'Field',
  }) {
    final val = value?.trim();
    if (val == null || val.isEmpty) {
      return '$fieldName is required';
    }
    if (val.length < min) {
      return '$fieldName must be at least $min characters';
    }
    if (val.length > max) {
      return '$fieldName must be less than $max characters';
    }
    return null;
  }

  static String? optionalText(
    String? value, {
    int max = 250,
    String fieldName = 'Field',
  }) {
    final val = value?.trim();
    if (val != null && val.isNotEmpty) {
      if (val.length > max) {
        return '$fieldName must be less than $max characters';
      }
    }
    return null;
  }

  static String? email(
    String? value, {
    bool required = false,
    int max = 120,
  }) {
    final val = value?.trim();
    if (val == null || val.isEmpty) {
      if (required) return 'Email is required';
      return null;
    }
    if (val.length > max) {
      return 'Email must be less than $max characters';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(val)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? phone(
    String? value, {
    bool required = false,
    int max = 20,
  }) {
    final val = value?.trim();
    if (val == null || val.isEmpty) {
      if (required) return 'Phone number is required';
      return null;
    }
    if (val.length > max) {
      return 'Phone number is too long';
    }
    final phoneRegex = RegExp(r'^[0-9+\-\s()]+$');
    if (!phoneRegex.hasMatch(val)) {
      return 'Enter a valid phone number';
    }
    if (val.length < 7) {
      return 'Phone number is too short';
    }
    return null;
  }

  static String? amount(
    String? value, {
    bool required = true,
    double min = 0,
    double max = 99999999.99,
    String fieldName = 'Amount',
  }) {
    final val = value?.trim();
    if (val == null || val.isEmpty) {
      if (required) return '$fieldName is required';
      return null;
    }
    final number = double.tryParse(val);
    if (number == null) {
      return 'Enter a valid amount';
    }
    if (number < min) {
      return '$fieldName must be at least $min';
    }
    if (number > max) {
      return '$fieldName is too large';
    }
    return null;
  }

  static String? quantity(
    String? value, {
    bool required = true,
    int min = 1,
    int max = 999999,
  }) {
    final val = value?.trim();
    if (val == null || val.isEmpty) {
      if (required) return 'Quantity is required';
      return null;
    }
    final number = int.tryParse(val);
    if (number == null) {
      return 'Enter a valid quantity';
    }
    if (number < min) {
      return 'Quantity must be at least $min';
    }
    if (number > max) {
      return 'Quantity is too large';
    }
    return null;
  }

  static String? percentage(
    String? value, {
    bool required = false,
    double min = 0,
    double max = 100,
    String fieldName = 'Percentage',
  }) {
    final val = value?.trim();
    if (val == null || val.isEmpty) {
      if (required) return '$fieldName is required';
      return null;
    }
    final number = double.tryParse(val);
    if (number == null) {
      return 'Enter a valid percentage';
    }
    if (number < min) {
      return '$fieldName cannot be negative';
    }
    if (number > max) {
      return '$fieldName cannot exceed $max';
    }
    return null;
  }
}
