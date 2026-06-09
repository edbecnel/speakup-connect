/// Optional configuration for collecting recipient responses on a broadcast.
class ReminderResponseConfig {
  const ReminderResponseConfig({
    this.enabled = false,
    this.responseRequired = false,
    this.type = ReminderResponseType.freeText,
    this.maxTextLength = AppReminderResponseLimits.defaultMaxTextLength,
    this.options = const [],
  });

  final bool enabled;

  /// When true, recipients must submit a response before dismissing the alert.
  /// Only applies when [enabled] is true.
  final bool responseRequired;

  final ReminderResponseType type;

  /// Max characters for [ReminderResponseType.freeText].
  final int maxTextLength;

  /// Checkbox labels or multiple-choice options.
  final List<ReminderResponseOption> options;

  bool get isValid {
    if (!enabled) return true;
    return switch (type) {
      ReminderResponseType.freeText =>
        maxTextLength >= AppReminderResponseLimits.minMaxTextLength &&
            maxTextLength <= AppReminderResponseLimits.maxMaxTextLength,
      ReminderResponseType.checkbox ||
      ReminderResponseType.multipleChoice =>
        _validOptionLabels.length >= 2 &&
            _validOptionLabels.length <= AppReminderResponseLimits.maxOptions,
    };
  }

  List<ReminderResponseOption> get validOptions => _validOptionLabels;

  List<ReminderResponseOption> get _validOptionLabels => options
      .where((o) => o.label.trim().isNotEmpty)
      .take(AppReminderResponseLimits.maxOptions)
      .toList();

  String get typeLabel => type.label;

  ReminderResponseConfig copyWith({
    bool? enabled,
    bool? responseRequired,
    ReminderResponseType? type,
    int? maxTextLength,
    List<ReminderResponseOption>? options,
  }) {
    return ReminderResponseConfig(
      enabled: enabled ?? this.enabled,
      responseRequired: responseRequired ?? this.responseRequired,
      type: type ?? this.type,
      maxTextLength: maxTextLength ?? this.maxTextLength,
      options: options ?? this.options,
    );
  }
}

enum ReminderResponseType {
  freeText('free_text', 'Free text'),
  checkbox('checkbox', 'Checkboxes'),
  multipleChoice('multiple_choice', 'Multiple choice');

  const ReminderResponseType(this.value, this.label);

  final String value;
  final String label;

  static ReminderResponseType fromValue(String value) {
    return ReminderResponseType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => ReminderResponseType.freeText,
    );
  }
}

class ReminderResponseOption {
  const ReminderResponseOption({required this.id, required this.label});

  final String id;
  final String label;

  ReminderResponseOption copyWith({String? id, String? label}) {
    return ReminderResponseOption(
      id: id ?? this.id,
      label: label ?? this.label,
    );
  }
}

/// Limits for reminder response configuration and submission.
abstract class AppReminderResponseLimits {
  static const int defaultMaxTextLength = 500;
  static const int minMaxTextLength = 50;
  static const int maxMaxTextLength = 1000;
  static const int maxOptions = 10;
}
