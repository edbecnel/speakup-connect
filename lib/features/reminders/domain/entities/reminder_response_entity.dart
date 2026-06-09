import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_config.dart';

/// A recipient's submitted response to a broadcast reminder.
///
/// Stored at:
///   `organizations/{orgId}/reminders/{reminderId}/responses/{userId}`
class ReminderResponseEntity {
  const ReminderResponseEntity({
    required this.userId,
    required this.organizationId,
    required this.reminderId,
    required this.responseType,
    required this.submittedAt,
    this.userDisplayName,
    this.text,
    this.selectedOptionIds = const [],
    this.selectedOptionId,
  });

  final String userId;
  final String organizationId;
  final String reminderId;
  final String? userDisplayName;
  final ReminderResponseType responseType;

  final String? text;
  final List<String> selectedOptionIds;
  final String? selectedOptionId;

  final DateTime submittedAt;

  String displayValue(ReminderResponseConfig config) {
    return switch (responseType) {
      ReminderResponseType.freeText => text ?? '',
      ReminderResponseType.checkbox => _labelsForIds(
          config,
          selectedOptionIds,
        ).join(', '),
      ReminderResponseType.multipleChoice => _labelsForIds(
          config,
          selectedOptionId == null ? const [] : [selectedOptionId!],
        ).join(', '),
    };
  }

  List<String> _labelsForIds(
    ReminderResponseConfig config,
    List<String> ids,
  ) {
    return ids
        .map(
          (id) => config.options
              .where((o) => o.id == id)
              .map((o) => o.label)
              .firstOrNull,
        )
        .whereType<String>()
        .toList();
  }
}
