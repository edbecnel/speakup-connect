/// Domain entity representing a user's profile within an organization.
///
/// Stored in Firestore at:
///   `organizations/{organizationId}/users/{userId}`
///
/// `approvalStatus` drives the post-signup routing:
///   - [ApprovalStatus.pending]  → pending-approval screen
///   - [ApprovalStatus.approved] → home dashboard
///   - [ApprovalStatus.rejected] → pending-approval screen (with rejection note)
enum ApprovalStatus { pending, approved, rejected, unenrolled }

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
    this.gradeLevel,
    this.email,
    this.role = 'user',
    this.approvalStatus = ApprovalStatus.pending,
    this.applicationSubmitted = false,
    this.isActive = true,
    this.blockReason,
    this.blockedAt,
    this.blockedBy,
    this.unenrollReason,
    this.unenrolledAt,
    this.unenrolledBy,
    this.permissions = const {},
    this.avatarUrl,
    this.officialPhotoUrl,
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

  /// Grade level (e.g. 7–12). May come from profile or org roster.
  final int? gradeLevel;

  /// Email address (may be null for anonymous accounts).
  final String? email;

  /// Role within the organization: 'user' | 'admin' | 'super_admin'.
  final String role;

  /// Current approval state for apply-to-join organisations.
  final ApprovalStatus approvalStatus;

  /// True once the user has submitted the apply-to-join form.
  final bool applicationSubmitted;

  /// Whether this account is currently active.
  final bool isActive;

  /// Why the account was blocked, when [isActive] is false.
  final String? blockReason;

  /// When the account was last blocked.
  final DateTime? blockedAt;

  /// UID of the admin who last blocked this account.
  final String? blockedBy;

  /// Why the member was unenrolled (e.g. graduation).
  final String? unenrollReason;

  /// When the member was unenrolled.
  final DateTime? unenrolledAt;

  /// UID of the admin who unenrolled this account.
  final String? unenrolledBy;

  /// Delegated permissions granted by a [super_admin].
  ///
  /// Use [UserPermission] constants as values, e.g. [UserPermission.editTheme].
  /// Always empty for regular users; [super_admin] is not restricted by this
  /// field (they have all permissions implicitly).
  final Set<String> permissions;

  /// Member-chosen personal badge (Settings). Stored separately from
  /// [officialPhotoUrl]; never overwrites the school record. Only writable
  /// when the org enables [OrganizationConfigEntity.allowMemberProfilePhotos].
  final String? avatarUrl;

  /// Permanent school/org official photo (admin-managed only). Faculty use this
  /// as the authoritative student record. Members cannot change or delete it.
  final String? officialPhotoUrl;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Photo shown in avatars: personal badge, then official school photo.
  String? get displayPhotoUrl {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) return avatarUrl;
    if (officialPhotoUrl != null && officialPhotoUrl!.isNotEmpty) {
      return officialPhotoUrl;
    }
    return null;
  }

  bool get isPending => approvalStatus == ApprovalStatus.pending;
  bool get isApproved => approvalStatus == ApprovalStatus.approved;
  bool get isRejected => approvalStatus == ApprovalStatus.rejected;
  bool get isUnenrolled => approvalStatus == ApprovalStatus.unenrolled;

  /// Whether this user is waiting for admin review in the join queue.
  ///
  /// Excludes approved admins and accounts that have not submitted the join
  /// form (sign-up alone is not enough).
  bool get isAwaitingJoinApproval =>
      !isApproved &&
      !isRejected &&
      !isAdmin &&
      (applicationSubmitted || fullName.isNotEmpty);
  bool get isAdmin => role == 'admin' || role == 'super_admin' || role == 'owner';
  bool get isBlocked => !isActive;
  bool get isEnrolled => isApproved;

  /// Whether this user may edit the organisation's visual theme.
  ///
  /// Always `true` for `super_admin` and `owner`.
  /// For `admin`, only `true` if [UserPermission.editTheme] has been
  /// explicitly granted by a `super_admin`.
  bool get canEditTheme =>
      role == 'super_admin' ||
      role == 'owner' ||
      permissions.contains(UserPermission.editTheme);
}
