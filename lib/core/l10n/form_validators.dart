import 'package:speakup_connect/l10n/app_localizations.dart';

/// Localized form validators — use via `context.l10n.validateEmail(value)`.
extension FormValidators on AppLocalizations {
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return validationEmailRequired;
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return validationEmailInvalid;
    }
    return null;
  }

  String? validateRequired(String? value, {required String fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return validationFieldRequired(fieldName);
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return validationPasswordRequired;
    }
    if (value.length < 8) {
      return validationPasswordMin8;
    }
    return null;
  }

  String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return validationPasswordRequired;
    }
    if (value.length < 6) {
      return validationPasswordMin6;
    }
    return null;
  }

  String? validateLoginIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return validationLoginIdentifierRequired;
    }
    final trimmed = value.trim();
    if (trimmed.contains('@')) {
      return validateEmail(trimmed);
    }
    return validateStudentId(trimmed);
  }

  String? validateOptionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return validateEmail(value.trim());
  }

  String? validateStudentId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return validationStudentIdRequired;
    }
    final trimmed = value.trim();
    if (trimmed.length < 6) {
      return validationStudentIdMin6;
    }
    if (!RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(trimmed)) {
      return validationStudentIdInvalidChars;
    }
    return null;
  }

  String? validateConfirmPassword(String? confirmValue, String? originalValue) {
    if (confirmValue == null || confirmValue.isEmpty) {
      return validationConfirmPasswordRequired;
    }
    if (confirmValue != originalValue) {
      return validationPasswordsDoNotMatch;
    }
    return null;
  }

  String? validateMaxLength(
    String? value,
    int maxLength, {
    required String fieldName,
  }) {
    if (value != null && value.length > maxLength) {
      return validationMaxLength(fieldName, maxLength);
    }
    return null;
  }

  String? validateMinLength(
    String? value,
    int minLength, {
    required String fieldName,
  }) {
    if (value == null || value.trim().length < minLength) {
      return validationMinLength(fieldName, minLength);
    }
    return null;
  }

  String? validateReportTitle(String? value) {
    return _combine([
      (v) => validateRequired(v, fieldName: validationReportTitleField),
      (v) => validateMinLength(v, 5, fieldName: validationReportTitleField),
      (v) => validateMaxLength(v, 200, fieldName: validationReportTitleField),
    ])(value);
  }

  String? validateReportDescription(String? value) {
    return _combine([
      (v) =>
          validateRequired(v, fieldName: validationReportDescriptionField),
      (v) =>
          validateMinLength(v, 10, fieldName: validationReportDescriptionField),
      (v) => validateMaxLength(
        v,
        1000,
        fieldName: validationReportDescriptionField,
      ),
    ])(value);
  }

  String? Function(String?) _combine(
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
}
