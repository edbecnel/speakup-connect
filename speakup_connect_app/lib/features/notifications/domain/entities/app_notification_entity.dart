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
    this.expiresAt,
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

  /// When this feed item should be auto-removed. Mirrors the source reminder.
  final DateTime? expiresAt;

  /// Type-specific payload (e.g. `{ 'reminderId': '...' }`).
  final Map<String, dynamic> data;

  final DateTime createdAt;

  String? get reminderId => data['reminderId'] as String?;

  String? get bulletinId => data['bulletinId'] as String?;

  /// Group membership event from Cloud Functions, e.g. `leave_approved`.
  String? get groupMembershipEvent => data['event'] as String?;

  /// True when tapping should open the leader/admin membership review queue.
  bool get opensGroupMembershipRequests =>
      type == 'group_membership' &&
      groupMembershipEvent == 'membership_review';

  /// Informational group alerts (left, removed, join outcome) — view only.
  bool get isInformationalGroupMembership =>
      type == 'group_membership' && !opensGroupMembershipRequests;

  bool get responseRequired => data['responseRequired'] == true;

  /// True when this item should appear in the alerts badge count.
  bool needsAttention({required bool hasResponded}) {
    if (responseRequired && reminderId != null && !hasResponded) {
      return true;
    }
    return !read;
  }
}
