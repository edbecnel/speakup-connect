import 'package:speakup_connect/features/notifications/domain/entities/notification_history_entity.dart';

abstract class NotificationHistoryRepository {
  /// All archived notifications for the organization (admin view).
  Stream<List<NotificationHistoryEntity>> watchOrgHistory(String organizationId);

  /// Broadcasts archived from reminders authored by [userId].
  Stream<List<NotificationHistoryEntity>> watchAuthorHistory({
    required String organizationId,
    required String userId,
  });
}
