/// Domain entity representing a submitted report.
///
/// All fields map 1:1 with the Firestore report document schema
/// defined in docs/DATABASE_DESIGN.md.
class ReportEntity {
  const ReportEntity({
    required this.reportId,
    required this.organizationId,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.status,
    required this.isAnonymous,
    required this.createdAt,
    required this.updatedAt,
    this.referenceNumber,
    this.submittedBy,
    this.submitterDisplayName,
    this.photoUrls = const [],
    this.adminNotes = const [],
    this.statusHistory = const [],
    this.assignedTo,
    this.priority = ReportPriority.medium,
    this.resolvedAt,
  });

  final String reportId;
  final String organizationId;
  final String title;
  final String description;
  final String categoryId;
  final ReportStatus status;
  final ReportPriority priority;
  final bool isAnonymous;

  /// Firebase Auth UID of the submitter. Null for anonymous reports.
  final String? submittedBy;

  /// Display name of the submitter. Null for anonymous reports.
  final String? submitterDisplayName;

  /// Human-readable reference number (e.g., 'MONHS-2026-000001').
  final String? referenceNumber;

  /// Firebase Storage download URLs for attached photos.
  final List<String> photoUrls;

  /// Admin-added notes (visible to admins only).
  final List<AdminNote> adminNotes;

  /// Immutable log of all status transitions.
  final List<StatusHistoryEntry> statusHistory;

  /// UID of the admin this report is assigned to.
  final String? assignedTo;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;

  bool get hasPhotos => photoUrls.isNotEmpty;
  bool get isResolved => status == ReportStatus.resolved || status == ReportStatus.closed;
}

/// Report status enum matching Firestore status field values.
enum ReportStatus {
  submitted('submitted', 'Submitted'),
  underReview('under_review', 'Under Review'),
  inProgress('in_progress', 'In Progress'),
  resolved('resolved', 'Resolved'),
  closed('closed', 'Closed');

  const ReportStatus(this.value, this.label);

  final String value;
  final String label;

  static ReportStatus fromValue(String value) {
    return ReportStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => ReportStatus.submitted,
    );
  }
}

/// Report priority levels.
enum ReportPriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High'),
  urgent('urgent', 'Urgent');

  const ReportPriority(this.value, this.label);

  final String value;
  final String label;

  static ReportPriority fromValue(String value) {
    return ReportPriority.values.firstWhere(
      (p) => p.value == value,
      orElse: () => ReportPriority.medium,
    );
  }
}

/// An admin note attached to a report.
class AdminNote {
  const AdminNote({
    required this.noteId,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });

  final String noteId;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;
}

/// An entry in the report's status change history.
class StatusHistoryEntry {
  const StatusHistoryEntry({
    required this.toStatus,
    required this.changedBy,
    required this.changedAt,
    this.fromStatus,
    this.note,
  });

  final ReportStatus? fromStatus;
  final ReportStatus toStatus;
  final String changedBy;
  final DateTime changedAt;
  final String? note;
}
