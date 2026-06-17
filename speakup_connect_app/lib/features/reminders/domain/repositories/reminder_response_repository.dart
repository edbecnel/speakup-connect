import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_entity.dart';

abstract class ReminderResponseRepository {
  /// Submits or updates the current user's response to a reminder.
  Future<void> submitResponse({
    required String organizationId,
    required String reminderId,
    String? text,
    List<String>? selectedOptionIds,
    String? selectedOptionId,
  });

  /// Streams the current user's response, if any.
  Stream<ReminderResponseEntity?> watchMyResponse({
    required String organizationId,
    required String reminderId,
    required String userId,
  });

  /// Streams all responses for a reminder (author/admin).
  Stream<List<ReminderResponseEntity>> watchResponses({
    required String organizationId,
    required String reminderId,
  });
}
