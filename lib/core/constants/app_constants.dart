/// App-wide constants for SpeakUp Connect.
///
/// No organization-specific values should be added here.
/// Organization names, colors, and settings come from Firestore org config.
abstract class AppConstants {
  // --- App Info ---
  static const String appName = 'SpeakUp Connect';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // --- Report Constraints ---
  /// Maximum number of photos allowed per report submission.
  static const int maxPhotosPerReport = 3;

  /// Maximum character length for report titles.
  static const int maxTitleLength = 200;

  /// Maximum character length for report descriptions.
  static const int maxDescriptionLength = 1000;

  /// Maximum file size per photo in bytes (10 MB).
  static const int maxPhotoSizeBytes = 10 * 1024 * 1024;

  /// Target compressed photo size in bytes (1 MB).
  static const int targetCompressedPhotoSizeBytes = 1 * 1024 * 1024;

  /// Maximum number of reports a user can submit per day (anti-spam).
  static const int maxReportsPerDay = 5;

  // --- Firestore Collection Names ---
  static const String organizationsCollection = 'organizations';
  static const String reportsCollection = 'reports';
  static const String categoriesCollection = 'categories';
  static const String usersCollection = 'users';
  static const String adminsCollection = 'admins';
  static const String configCollection = 'config';
  static const String auditLogCollection = 'audit_log';
  static const String rolesCollection = 'roles';
  static const String customCapabilitiesCollection = 'customCapabilities';
  static const String roleAssignmentsCollection = 'roleAssignments';
  static const String remindersCollection = 'reminders';
  static const String bulletinsCollection = 'bulletins';

  /// Per-user responses to a broadcast reminder:
  /// `organizations/{orgId}/reminders/{reminderId}/responses/{userId}`.
  static const String reminderResponsesCollection = 'responses';
  static const String groupsCollection = 'groups';
  static const String groupMembersCollection = 'members';
  static const String groupJoinRequestsCollection = 'joinRequests';
  static const String groupLeaveRequestsCollection = 'leaveRequests';

  /// Per-user index of group rosters for "My Groups" (denormalized):
  /// `organizations/{orgId}/users/{userId}/groupMemberships/{groupId}`.
  static const String userGroupMembershipsCollection = 'groupMemberships';
  static const String rosterCollection = 'roster';

  /// Per-user in-app notification feed:
  /// `organizations/{orgId}/users/{userId}/notifications/{notificationId}`.
  static const String notificationsCollection = 'notifications';

  /// Archived notifications (expired, recalled, dismissed):
  /// `organizations/{orgId}/notification_history/{historyId}`.
  static const String notificationHistoryCollection = 'notification_history';

  // --- Firestore Document IDs ---
  static const String mainConfigDocId = 'main';

  // --- Firestore Field Names ---
  static const String fieldOrganizationId = 'organizationId';
  static const String fieldStatus = 'status';
  static const String fieldCreatedAt = 'createdAt';
  static const String fieldUpdatedAt = 'updatedAt';
  static const String fieldSubmittedBy = 'submittedBy';
  static const String fieldCategoryId = 'categoryId';
  static const String fieldIsAnonymous = 'isAnonymous';
  static const String fieldIsActive = 'isActive';
  static const String fieldRole = 'role';

  // --- Report Statuses ---
  static const String statusSubmitted = 'submitted';
  static const String statusUnderReview = 'under_review';
  static const String statusInProgress = 'in_progress';
  static const String statusResolved = 'resolved';
  static const String statusClosed = 'closed';

  // --- User Roles ---
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';
  static const String roleSuperAdmin = 'super_admin';

  // --- Default Categories (used when creating a new organization) ---
  static const List<Map<String, dynamic>> defaultCategories = [
    {'categoryId': 'safety', 'label': 'Safety', 'icon': 'shield', 'sortOrder': 0},
    {'categoryId': 'bullying', 'label': 'Bullying', 'icon': 'person_off', 'sortOrder': 1},
    {'categoryId': 'maintenance', 'label': 'Maintenance', 'icon': 'build', 'sortOrder': 2},
    {'categoryId': 'facilities', 'label': 'Facilities', 'icon': 'business', 'sortOrder': 3},
    {'categoryId': 'harassment', 'label': 'Harassment', 'icon': 'report', 'sortOrder': 4},
    {'categoryId': 'suggestions', 'label': 'Suggestions', 'icon': 'lightbulb', 'sortOrder': 5},
    {'categoryId': 'cleanliness', 'label': 'Cleanliness', 'icon': 'cleaning_services', 'sortOrder': 6},
    {'categoryId': 'security', 'label': 'Security', 'icon': 'security', 'sortOrder': 7},
    {'categoryId': 'other', 'label': 'Other', 'icon': 'more_horiz', 'sortOrder': 8},
  ];

  // --- Firebase Storage Paths ---
  static String reportPhotosStoragePath(String orgId, String reportId) =>
      'organizations/$orgId/reports/$reportId';

  static String orgLogoStoragePath(String orgId) =>
      'organizations/$orgId/assets/logo';

  // --- Pagination ---
  static const int defaultPageSize = 20;

  // --- Animation Durations ---
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // --- Reference Number ---
  /// Formats a report reference number.
  /// Format: {ORG_CODE}-{YEAR}-{SEQUENCE}
  /// Example: MONHS-2026-000001
  static String formatReferenceNumber(
    String orgCode,
    int year,
    int sequence,
  ) {
    final seq = sequence.toString().padLeft(6, '0');
    return '$orgCode-$year-$seq';
  }
}
