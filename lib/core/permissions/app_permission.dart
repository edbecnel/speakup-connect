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

  /// View the organization audit log.
  viewAuditLogs;

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
}
