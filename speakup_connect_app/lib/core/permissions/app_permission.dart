import 'package:speakup_connect/core/permissions/org_type.dart';

/// Defines every elevated action available in SpeakUp Connect.
///
/// This enum is the authoritative source of truth for all capability checks.
/// Adding a new value requires:
///   1. Adding the enum value here
///   2. Writing the UI widget / action it unlocks
///   3. Adding the Firestore Security Rule that enforces it
///   4. Deploying the app update
///
/// Org admins may create custom capability aliases that resolve to these
/// values, but they cannot create new behaviour without a code change.
/// See docs/RBAC_ARCHITECTURE.md for the full two-tier RBAC design.
enum AppPermission {
  // ── Reports ────────────────────────────────────────────────────────────────
  /// View all reports across the entire organization.
  viewAllReports,

  /// View reports from groups/classes the user is assigned to.
  viewGroupReports,

  /// Approve or close a report.
  approveReport,

  /// Update report status, escalate, reject, or add internal notes.
  manageReports,

  // ── Bulletins & News ───────────────────────────────────────────────────────
  /// Post a bulletin visible to the entire organization.
  postBulletinOrgWide,

  /// Post a bulletin scoped to a specific group or class.
  postBulletinToGroup,

  // ── Reminders ──────────────────────────────────────────────────────────────
  /// Compose and send broadcast reminders to members.
  broadcastReminders,

  /// Approve or reject reminders submitted for review.
  approveReminders,

  // ── Roster & Users ─────────────────────────────────────────────────────────
  /// Add or remove members from an extracurricular group/club.
  manageGroupRoster,

  /// Add or remove students from an academic class/section.
  manageClassRoster,

  /// Approve or reject membership join applications.
  approveApplications,

  /// Temporarily suspend or permanently block a user.
  blockUsers,

  // ── Org Administration ─────────────────────────────────────────────────────
  /// Edit organization-level settings and branding.
  manageOrganizationSettings,

  /// Create, edit, and delete roles; assign roles to users.
  manageRoles,

  /// Edit and approve UI translations for org-supported languages.
  manageTranslations,

  /// View the organization audit log.
  viewAuditLogs;

  /// Capabilities scoped to report [categoryId] when role defines
  /// [allowedCategoryIds]. See REPORT_CATEGORY_RBAC.md.
  static const Set<AppPermission> reportRelated = {
    viewAllReports,
    viewGroupReports,
    approveReport,
    manageReports,
  };

  /// True when this permission is subject to role-level report category scope.
  bool get isReportRelated => reportRelated.contains(this);

  // ── Serialization ──────────────────────────────────────────────────────────

  /// The string key stored in Firestore and written to Firebase Auth Custom
  /// Claims. Must remain stable — changing a key is a breaking schema change.
  String get key => name;

  /// Deserializes a Firestore / Custom Claims string back to an [AppPermission].
  /// Returns `null` for unknown keys so callers can gracefully skip stale values
  /// from older app versions without crashing.
  static AppPermission? fromKey(String key) {
    for (final permission in AppPermission.values) {
      if (permission.key == key) return permission;
    }
    return null;
  }

  // ── Org Type Relevance ─────────────────────────────────────────────────────

  /// The organization types for which this capability is meaningful.
  ///
  /// Used by the admin panel to filter the capability catalog so org-type-
  /// irrelevant capabilities are not shown to admins. All permissions are still
  /// evaluated regardless; this is a UX filter only.
  ///
  /// Most capabilities apply to all org types. Org-type-specific capabilities
  /// (e.g. [manageClassRoster] for schools) declare a restricted set.
  Set<OrgType> get supportedOrgTypes => switch (this) {
        AppPermission.manageClassRoster => const {OrgType.school},
        _ => _allOrgTypes,
      };

  static final Set<OrgType> _allOrgTypes =
      Set.unmodifiable(OrgType.values.toSet());

  // ── Display Metadata (UI layer only) ──────────────────────────────────────

  /// Human-readable label shown in the admin capabilities catalog.
  String get displayName => switch (this) {
        AppPermission.viewAllReports => 'View all org reports',
        AppPermission.viewGroupReports => 'View reports in assigned groups',
        AppPermission.approveReport => 'Approve / close reports',
        AppPermission.manageReports => 'Update status, escalate & add notes',
        AppPermission.postBulletinOrgWide => 'Post bulletins org-wide',
        AppPermission.postBulletinToGroup => 'Post bulletins to own groups',
        AppPermission.broadcastReminders => 'Broadcast reminders',
        AppPermission.approveReminders => 'Approve / reject reminders',
        AppPermission.manageGroupRoster => 'Manage own group roster',
        AppPermission.manageClassRoster => 'Manage class roster (school only)',
        AppPermission.approveApplications => 'Approve join applications',
        AppPermission.blockUsers => 'Suspend or block users',
        AppPermission.manageOrganizationSettings =>
          'Manage org settings & branding',
        AppPermission.manageRoles => 'Manage roles & assign permissions',
        AppPermission.manageTranslations =>
          'Translation moderator (edit UI strings)',
        AppPermission.viewAuditLogs => 'View audit logs',
      };

  /// Section label used to group capabilities in the admin UI.
  String get groupLabel => switch (this) {
        AppPermission.viewAllReports ||
        AppPermission.viewGroupReports ||
        AppPermission.approveReport ||
        AppPermission.manageReports =>
          'Reports',
        AppPermission.postBulletinOrgWide ||
        AppPermission.postBulletinToGroup =>
          'Bulletins & News',
        AppPermission.broadcastReminders ||
        AppPermission.approveReminders =>
          'Reminders',
        AppPermission.manageGroupRoster ||
        AppPermission.manageClassRoster ||
        AppPermission.approveApplications ||
        AppPermission.blockUsers =>
          'Roster & Users',
        AppPermission.manageOrganizationSettings ||
        AppPermission.manageRoles ||
        AppPermission.manageTranslations ||
        AppPermission.viewAuditLogs =>
          'Administration',
      };
}
