/// Domain entity representing a user's profile within an organization.
///
/// Stored in Firestore at:
///   `organizations/{organizationId}/users/{userId}`
///
/// `approvalStatus` drives the post-signup routing:
///   - [ApprovalStatus.pending]  → pending-approval screen
///   - [ApprovalStatus.approved] → home dashboard
///   - [ApprovalStatus.rejected] → pending-approval screen (with rejection note)
enum ApprovalStatus { pending, approved, rejected }

class UserProfileEntity {
  const UserProfileEntity({
    required this.userId,
    required this.organizationId,
    required this.displayName,
    required this.fullName,
    this.studentId,
    this.email,
    this.role = 'user',
    this.approvalStatus = ApprovalStatus.pending,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firebase Auth UID — also the Firestore document ID.
  final String userId;

  /// Organization this profile belongs to (e.g. 'monhs-ph-001').
  final String organizationId;

  /// Short display name (usually from Firebase Auth).
  final String displayName;

  /// Full legal name as entered during sign-up.
  final String fullName;

  /// School/org-issued student ID for roster verification.
  final String? studentId;

  /// Email address (may be null for anonymous accounts).
  final String? email;

  /// Role within the organization: 'user' | 'admin' | 'super_admin'.
  final String role;

  /// Current approval state for apply-to-join organisations.
  final ApprovalStatus approvalStatus;

  /// Whether this account is currently active.
  final bool isActive;

  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isPending => approvalStatus == ApprovalStatus.pending;
  bool get isApproved => approvalStatus == ApprovalStatus.approved;
  bool get isRejected => approvalStatus == ApprovalStatus.rejected;
  bool get isAdmin => role == 'admin' || role == 'super_admin';
}
