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

/// Typed constants for delegated permissions.
///
/// A [super_admin] may grant any of these to an [admin] user, allowing
/// them to perform privileged actions without full super_admin access.
/// Stored as a list of strings in the `permissions` field on the user document.
abstract class UserPermission {
  UserPermission._();

  /// Allows an `admin` to update `primaryColor`, `secondaryColor`, `logoUrl`,
  /// `tagline`, and `welcomeMessage` on the organization document.
  static const String editTheme = 'edit_theme';
}

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
    this.permissions = const {},
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

  /// Delegated permissions granted by a [super_admin].
  ///
  /// Use [UserPermission] constants as values, e.g. [UserPermission.editTheme].
  /// Always empty for regular users; [super_admin] is not restricted by this
  /// field (they have all permissions implicitly).
  final Set<String> permissions;

  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isPending => approvalStatus == ApprovalStatus.pending;
  bool get isApproved => approvalStatus == ApprovalStatus.approved;
  bool get isRejected => approvalStatus == ApprovalStatus.rejected;
  bool get isAdmin => role == 'admin' || role == 'super_admin' || role == 'owner';

  /// Whether this user may edit the organisation's visual theme.
  ///
  /// Always `true` for `super_admin`.
  /// For `admin`, only `true` if [UserPermission.editTheme] has been
  /// explicitly granted by a `super_admin`.
  bool get canEditTheme =>
      role == 'super_admin' || permissions.contains(UserPermission.editTheme);
}
