import 'package:speakup_connect/features/notifications/domain/entities/app_notification_entity.dart';

/// Abstract repository for the per-user in-app notification feed.
abstract class NotificationRepository {
  /// Streams the user's notifications, newest first.
  Stream<List<AppNotificationEntity>> watchNotifications({
    required String organizationId,
    required String userId,
  });

  /// Merges the per-user notification feed with org-wide published broadcasts
  /// the user may have missed (e.g. approved after delivery).
  Stream<List<AppNotificationEntity>> watchAlertFeed({
    required String organizationId,
    required String userId,
  });

  /// Marks a single notification as read.
  Future<void> markAsRead({
    required String organizationId,
    required String userId,
    required String notificationId,
  });

  /// Marks all of the user's unread notifications as read.
  Future<void> markAllAsRead({
    required String organizationId,
    required String userId,
  });

  /// Permanently removes a single notification from the user's feed.
  Future<void> deleteNotification({
    required String organizationId,
    required String userId,
    required String notificationId,
  });

  /// Permanently removes every notification from the user's feed.
  Future<void> clearAll({
    required String organizationId,
    required String userId,
  });

  /// Permanently removes a set of notifications from the user's feed.
  ///
  /// Returns a summary of what was cleared vs skipped.
  Future<({int cleared, int skipped, int notFound})> clearSelected({
    required String organizationId,
    required String userId,
    required List<String> notificationIds,
  });
}
