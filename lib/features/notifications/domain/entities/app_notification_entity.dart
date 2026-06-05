/// Domain entity for a single in-app notification (feed item).
///
/// Stored in Firestore at:
///   `organizations/{orgId}/users/{userId}/notifications/{notificationId}`
///
/// Notifications are written server-side by Cloud Functions (e.g. when a
/// reminder is published) so the feed stays consistent with push delivery.
class AppNotificationEntity {
  const AppNotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
    this.readAt,
    this.data = const {},
  });

  final String id;

  /// Logical category, e.g. `reminder` or `status_update`. Drives the icon and
  /// any tap navigation.
  final String type;

  final String title;
  final String body;

  /// Whether the recipient has opened/seen this notification.
  final bool read;
  final DateTime? readAt;

  /// Type-specific payload (e.g. `{ 'reminderId': '...' }`).
  final Map<String, dynamic> data;

  final DateTime createdAt;
}
