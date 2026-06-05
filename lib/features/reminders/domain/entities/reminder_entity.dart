/// Domain entity representing a broadcast reminder.
///
/// Stored in Firestore at:
///   `organizations/{orgId}/reminders/{reminderId}`
///
/// A reminder is a short broadcast message sent to a target audience
/// (the whole org, a group, or everyone holding a role). Depending on the
/// org's `requireReminderApproval` setting and the author's permissions, a
/// reminder is either published directly or queued for approval.
class ReminderEntity {
  const ReminderEntity({
    required this.reminderId,
    required this.organizationId,
    required this.title,
    required this.body,
    required this.audience,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.createdByName,
    this.scheduledAt,
    this.publishedAt,
    this.reviewedBy,
    this.reviewedByName,
    this.reviewedAt,
    this.rejectionReason,
  });

  final String reminderId;
  final String organizationId;
  final String title;
  final String body;

  /// Who should receive this reminder.
  final ReminderAudience audience;

  final ReminderStatus status;

  /// UID of the member who composed the reminder.
  final String createdBy;

  /// Denormalized display name of the author (for the approval queue).
  final String? createdByName;

  /// When the reminder should be published. Null means "send now".
  /// A future value means the scheduled Cloud Function will publish it.
  final DateTime? scheduledAt;

  /// When the reminder actually transitioned to `published`.
  final DateTime? publishedAt;

  /// UID of the approver who approved or rejected this reminder.
  final String? reviewedBy;

  /// Denormalized display name of the reviewer.
  final String? reviewedByName;

  final DateTime? reviewedAt;

  /// Reason supplied by the approver when [status] is [ReminderStatus.rejected].
  final String? rejectionReason;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// True when this reminder is scheduled for a future time and has not yet
  /// been published.
  bool get isScheduled =>
      scheduledAt != null && scheduledAt!.isAfter(DateTime.now());

  bool get isPending => status == ReminderStatus.pending;
  bool get isPublished => status == ReminderStatus.published;
}

/// Lifecycle states of a reminder.
enum ReminderStatus {
  /// Saved but not submitted (author can keep editing). Reserved for future
  /// use — the compose flow currently publishes or submits directly.
  draft('draft', 'Draft'),

  /// Submitted for approval; awaiting an approver's decision.
  pending('pending', 'Pending Approval'),

  /// Live — delivered to the audience (immediately or at the scheduled time).
  published('published', 'Published'),

  /// Rejected by an approver; not delivered.
  rejected('rejected', 'Rejected');

  const ReminderStatus(this.value, this.label);

  final String value;
  final String label;

  static ReminderStatus fromValue(String value) {
    return ReminderStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => ReminderStatus.draft,
    );
  }
}

/// The set of members a reminder is delivered to.
class ReminderAudience {
  const ReminderAudience({
    required this.type,
    this.targetId,
    this.targetLabel,
  });

  /// Convenience constructor for the whole organization.
  const ReminderAudience.all()
      : type = ReminderAudienceType.all,
        targetId = null,
        targetLabel = 'Everyone';

  final ReminderAudienceType type;

  /// The group or role document ID this reminder targets.
  /// Null when [type] is [ReminderAudienceType.all].
  final String? targetId;

  /// Denormalized display name of the target group/role (for UI + the feed).
  final String? targetLabel;

  /// Human-readable summary used in list tiles and the feed.
  String get displayLabel => switch (type) {
        ReminderAudienceType.all => 'Everyone',
        ReminderAudienceType.group => targetLabel ?? 'A group',
        ReminderAudienceType.role => targetLabel ?? 'A role',
      };
}

/// How a reminder's audience is selected.
enum ReminderAudienceType {
  /// Every approved member of the organization.
  all('all'),

  /// Members of a specific `groups/{groupId}`.
  group('group'),

  /// Every member who currently holds a specific role.
  role('role');

  const ReminderAudienceType(this.value);

  final String value;

  static ReminderAudienceType fromValue(String value) {
    return ReminderAudienceType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => ReminderAudienceType.all,
    );
  }
}
