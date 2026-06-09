import 'package:speakup_connect/features/notifications/domain/entities/app_notification_entity.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_entity.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_entity.dart';

/// Resolved read / response state for a single alerts feed item.
class NotificationAttention {
  const NotificationAttention({
    required this.read,
    required this.responseRequired,
    required this.hasResponded,
  });

  final bool read;
  final bool responseRequired;
  final bool hasResponded;

  /// Drives the red-dot badge and bold title styling.
  ///
  /// Mandatory-response alerts stay highlighted until the user submits a
  /// response, even if they have already opened the alert.
  bool get needsAttention {
    if (responseRequired && !hasResponded) return true;
    return !read;
  }

  bool get canDismiss => !responseRequired || hasResponded;

  bool get responsePending => responseRequired && !hasResponded;

  static NotificationAttention resolve({
    required AppNotificationEntity notification,
    ReminderEntity? reminder,
    ReminderResponseEntity? myResponse,
    bool reminderStillLoading = false,
  }) {
    final reminderId = notification.reminderId;
    final responded =
        notification.data['hasResponded'] == true || myResponse != null;

    final responseRequired = reminderId == null
        ? false
        : notification.responseRequired ||
            (reminder?.responseRequired ?? false) ||
            (reminderStillLoading &&
                notification.type == 'reminder' &&
                !responded);

    final hasResponded = !responseRequired || responded;

    return NotificationAttention(
      read: notification.read,
      responseRequired: responseRequired,
      hasResponded: hasResponded,
    );
  }
}
