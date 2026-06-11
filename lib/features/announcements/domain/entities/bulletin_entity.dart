import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_config.dart';

/// Organization-wide announcement on the bulletin board.
///
/// Stored at `organizations/{orgId}/bulletins/{bulletinId}`.
/// All announcements are visible to every approved org member once published.
class BulletinEntity {
  const BulletinEntity({
    required this.bulletinId,
    required this.organizationId,
    required this.title,
    required this.body,
    required this.status,
    required this.authorId,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.sourceGroupId,
    this.sourceGroupName,
    this.isPinned = false,
    this.scheduledAt,
    this.expiresAt,
    this.publishedAt,
    this.reviewedBy,
    this.reviewedByName,
    this.reviewedAt,
    this.rejectionReason,
    this.responseConfig,
    this.imageUrl,
  });

  final String bulletinId;
  final String organizationId;
  final String title;
  final String body;
  final BulletinStatus status;
  final String authorId;
  final String? authorName;

  /// When a group leader posts, the club they represent (recruitment, etc.).
  final String? sourceGroupId;
  final String? sourceGroupName;

  final bool isPinned;

  /// When the announcement should be published. Null means send now.
  final DateTime? scheduledAt;

  final DateTime? expiresAt;
  final DateTime? publishedAt;
  final String? reviewedBy;
  final String? reviewedByName;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final ReminderResponseConfig? responseConfig;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isPending => status == BulletinStatus.pending;
  bool get isPublished => status == BulletinStatus.published;

  bool get isScheduled =>
      scheduledAt != null && scheduledAt!.isAfter(DateTime.now());

  bool get isExpired =>
      expiresAt != null && !expiresAt!.isAfter(DateTime.now());

  bool get acceptsResponses => responseConfig?.enabled ?? false;

  bool get responseRequired =>
      acceptsResponses && (responseConfig?.responseRequired ?? false);
}

enum BulletinStatus {
  pending('pending', 'Pending Approval'),
  published('published', 'Published'),
  rejected('rejected', 'Rejected');

  const BulletinStatus(this.value, this.label);

  final String value;
  final String label;

  static BulletinStatus fromValue(String value) {
    return BulletinStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => BulletinStatus.pending,
    );
  }
}
