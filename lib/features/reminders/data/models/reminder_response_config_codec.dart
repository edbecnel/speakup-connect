import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_config.dart';

/// Serializes [ReminderResponseConfig] to/from Firestore maps.
abstract class ReminderResponseConfigCodec {
  static ReminderResponseConfig? fromMap(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    final enabled = raw['enabled'] as bool? ?? false;
    if (!enabled) return const ReminderResponseConfig();

    final type = ReminderResponseType.fromValue(
      raw['type'] as String? ?? ReminderResponseType.freeText.value,
    );
    final maxTextLength =
        (raw['maxTextLength'] as num?)?.toInt() ??
            AppReminderResponseLimits.defaultMaxTextLength;
    final optionsRaw = raw['options'] as List<dynamic>? ?? const [];
    final options = optionsRaw
        .whereType<Map<String, dynamic>>()
        .map(
          (o) => ReminderResponseOption(
            id: o['id'] as String? ?? '',
            label: o['label'] as String? ?? '',
          ),
        )
        .where((o) => o.id.isNotEmpty)
        .toList();

    return ReminderResponseConfig(
      enabled: true,
      responseRequired: raw['responseRequired'] as bool? ?? false,
      type: type,
      maxTextLength: maxTextLength,
      options: options,
    );
  }

  static Map<String, dynamic>? toMap(ReminderResponseConfig? config) {
    if (config == null || !config.enabled || !config.isValid) return null;
    return {
      'enabled': true,
      if (config.responseRequired) 'responseRequired': true,
      'type': config.type.value,
      if (config.type == ReminderResponseType.freeText)
        'maxTextLength': config.maxTextLength,
      if (config.type != ReminderResponseType.freeText)
        'options': config.validOptions
            .map((o) => {'id': o.id, 'label': o.label.trim()})
            .toList(),
    };
  }
}
