/// Archived notification record (expired, recalled, or dismissed).
///
/// Stored in Firestore at:
///   `organizations/{orgId}/notification_history/{historyId}`
///
/// Written server-side only when a notification or broadcast is removed.
class NotificationHistoryEntity {
  const NotificationHistoryEntity({
    required this.historyId,
    required this.organizationId,
    required this.sourceType,
    required this.sourceId,
    required this.title,
    required this.body,
    required this.type,
    required this.removalReason,
    required this.removedAt,
    this.reminderId,
    this.userId,
    this.audienceType,
    this.audienceLabel,
    this.createdBy,
    this.createdByName,
    this.publishedAt,
    this.expiresAt,
    this.removedBy,
    this.feedCopiesAffected,
  });

  final String historyId;
  final String organizationId;

  /// `reminder` for broadcast archives; `notification` for per-user dismissals.
  final String sourceType;
  final String sourceId;

  final String? reminderId;
  final String? userId;

  final String title;
  final String body;
  final String type;

  final String? audienceType;
  final String? audienceLabel;

  final String? createdBy;
  final String? createdByName;

  final DateTime? publishedAt;
  final DateTime? expiresAt;

  final DateTime removedAt;

  /// `expired`, `recalled`, `user_dismissed`, or `cleared_all`.
  final String removalReason;
  final String? removedBy;
  final int? feedCopiesAffected;

  String get removalReasonLabel => switch (removalReason) {
        'expired' => 'Expired',
        'recalled' => 'Recalled',
        'user_dismissed' => 'Dismissed',
        'cleared_all' => 'Cleared',
        _ => removalReason,
      };
}
