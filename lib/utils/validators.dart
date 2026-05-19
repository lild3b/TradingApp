class AppValidators {
  AppValidators._();

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? number(String? value, [String fieldName = 'Value']) {
    if (value == null || value.trim().isEmpty) return null;
    if (double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }

  static String? positiveNumber(String? value, [String fieldName = 'Value']) {
    final numErr = number(value, fieldName);
    if (numErr != null) return numErr;
    if (value != null && double.tryParse(value) != null) {
      if (double.parse(value) <= 0) return '$fieldName must be positive';
    }
    return null;
  }

  static String? pin(String? value) {
    if (value == null || value.isEmpty) return 'PIN is required';
    if (value.length < 4) return 'PIN must be at least 4 digits';
    if (value.length > 8) return 'PIN must be at most 8 digits';
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'PIN must contain only digits';
    return null;
  }

  static String? pinConfirm(String? value, String original) {
    final err = pin(value);
    if (err != null) return err;
    if (value != original) return 'PINs do not match';
    return null;
  }
}
