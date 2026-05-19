/// Form validation utility functions for SpeakUp Connect.
///
/// These are pure functions returning nullable String error messages,
/// compatible with Flutter's [FormField] validator signature.
abstract class Validators {
  /// Validates email address format.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates a required field is not empty.
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates password meets minimum requirements.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  /// Validates that [confirmValue] matches [originalValue].
  static String? confirmPassword(String? confirmValue, String? originalValue) {
    if (confirmValue == null || confirmValue.isEmpty) {
      return 'Please confirm your password';
    }
    if (confirmValue != originalValue) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates a text field does not exceed [maxLength] characters.
  static String? maxLength(String? value, int maxLength, {String fieldName = 'This field'}) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be $maxLength characters or fewer';
    }
    return null;
  }

  /// Validates a text field has at least [minLength] characters.
  static String? minLength(String? value, int minLength, {String fieldName = 'This field'}) {
    if (value == null || value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Combines multiple validators, returning the first error found.
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  /// Validates a report title.
  static String? reportTitle(String? value) {
    return combine([
      (v) => required(v, fieldName: 'Title'),
      (v) => minLength(v, 5, fieldName: 'Title'),
      (v) => maxLength(v, 200, fieldName: 'Title'),
    ])(value);
  }

  /// Validates a report description.
  static String? reportDescription(String? value) {
    return combine([
      (v) => required(v, fieldName: 'Description'),
      (v) => minLength(v, 10, fieldName: 'Description'),
      (v) => maxLength(v, 1000, fieldName: 'Description'),
    ])(value);
  }
}
