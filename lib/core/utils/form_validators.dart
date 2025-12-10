/// Form validation utilities for the FPL Assistant app
class FormValidators {
  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain a lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number';
    }

    return null;
  }

  /// Validates password confirmation
  static String? validatePasswordConfirmation(
    String? value,
    String? password,
  ) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validates display name
  static String? validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Display name is required';
    }

    if (value.length < 2) {
      return 'Display name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Display name must be less than 50 characters';
    }

    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(value)) {
      return 'Display name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  /// Validates non-empty text field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  /// Validates text field length
  static String? validateLength(
    String? value,
    int minLength,
    int maxLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    if (value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }

    return null;
  }

  /// Validates numeric input
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return '$fieldName must contain only numbers';
    }

    return null;
  }

  /// Validates phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^[+]?[(]?[0-9]{3}[)]?[-\s.]?[0-9]{3}[-\s.]?[0-9]{4,6}$');

    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validates URL format
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }

    try {
      Uri.parse(value);
      if (!value.startsWith('http://') && !value.startsWith('https://')) {
        return 'URL must start with http:// or https://';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid URL';
    }
  }

  /// Validates match note length
  static String? validateMatchNote(String? value) {
    if (value == null || value.isEmpty) {
      return 'Note is required';
    }

    if (value.length > 500) {
      return 'Note must be less than 500 characters';
    }

    return null;
  }

  /// Validates team name
  static String? validateTeamName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Team name is required';
    }

    if (value.length < 2) {
      return 'Team name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Team name must be less than 50 characters';
    }

    return null;
  }
}
