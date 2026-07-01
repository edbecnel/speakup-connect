import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/org_scope_type.dart';

/// A single resolved permission grant within an effective permission set.
///
/// Captures one capability that a user has, and the exact scope constraints
/// under which it applies. Both constraints must be satisfied for the
/// permission to be granted in a given context:
///
///   1. [scopeType] / [scopeId] — from the role assignment (where does the
///      role apply: org-wide, a specific class, group, tag, etc.)
///   2. [tagRestriction] — from a custom capability's `tagScope` field
///      (legacy; report enforcement uses role [allowedCategoryIds] in v1)
class PermissionGrant {
  const PermissionGrant({
    required this.permission,
    required this.scopeType,
    this.scopeId,
    this.tagRestriction,
  });

  final AppPermission permission;

  /// Scope from the role assignment.
  final OrgScopeType scopeType;

  /// Resource ID from the role assignment.
  /// Null when [scopeType] is [OrgScopeType.org].
  final String? scopeId;

  /// Additional tag constraint from a custom capability's `tagScope`.
  /// Null means the permission is not tag-restricted beyond the scope above.
  final String? tagRestriction;
}

/// The fully resolved set of permissions for a signed-in user.
///
/// Built by the [permissionProvider] from the user's role assignments,
/// role definitions, and custom capability registry.
class EffectivePermissionSet {
  const EffectivePermissionSet({
    required this.grants,
    this.allowedCategoryIds,
  });

  /// An empty set returned when the user has no role assignments.
  static const EffectivePermissionSet empty = EffectivePermissionSet(
    grants: [],
    allowedCategoryIds: {},
  );

  final List<PermissionGrant> grants;

  /// Union of report category IDs from all role definitions.
  ///
  /// `null` = unrestricted (org-admin). Empty set = no report category access.
  final Set<String>? allowedCategoryIds;

  bool get isEmpty => grants.isEmpty;

  /// True when the user may act on reports in any category.
  bool get hasUnrestrictedReportAccess => allowedCategoryIds == null;

  // ── Permission Checks ──────────────────────────────────────────────────────

  /// Returns true if the user holds [permission] under any scope.
  ///
  /// Use for coarse UI gates (e.g. show the Roles admin link). For data
  /// access decisions where content context is known, prefer [can].
  bool has(AppPermission permission) =>
      grants.any((g) => g.permission == permission);

  /// True when the user holds any report read/triage capability.
  bool get hasReportViewPermission =>
      has(AppPermission.viewAllReports) ||
      has(AppPermission.viewGroupReports) ||
      has(AppPermission.manageReports) ||
      has(AppPermission.approveReport);

  /// True when the user may open the admin reports dashboard.
  bool get canAccessAdminReports {
    if (!hasReportViewPermission) return false;
    if (hasUnrestrictedReportAccess) return true;
    return allowedCategoryIds!.isNotEmpty;
  }

  /// True when [categoryId] is within the user's allowed report categories.
  bool canAccessReportCategory(String categoryId) {
    if (hasUnrestrictedReportAccess) return true;
    return allowedCategoryIds!.contains(categoryId);
  }

  /// True when the user may view/triage a report in [categoryId].
  bool canViewReport(String categoryId) {
    if (!hasReportViewPermission) return false;
    return canAccessReportCategory(categoryId);
  }

  /// Returns true if the user may perform [permission] in the given context.
  ///
  /// [categoryId] — the report's `categoryId` for report-related permissions.
  /// [tag]        — legacy custom-capability tag (non-report paths).
  bool can(
    AppPermission permission, {
    String? tag,
    String? categoryId,
    OrgScopeType? scopeType,
    String? scopeId,
  }) {
    if (permission.isReportRelated &&
        categoryId != null &&
        !canAccessReportCategory(categoryId)) {
      return false;
    }

    for (final grant in grants) {
      if (grant.permission != permission) continue;

      final scopeOk = grant.scopeType == OrgScopeType.org ||
          (grant.scopeType == OrgScopeType.tag && grant.scopeId == tag) ||
          (scopeType != null &&
              grant.scopeType == scopeType &&
              grant.scopeId == scopeId);

      final tagOk =
          grant.tagRestriction == null || grant.tagRestriction == tag;

      if (scopeOk && tagOk) return true;
    }
    return false;
  }

  /// Returns all unique [AppPermission]s this user holds (any scope).
  Set<AppPermission> get allPermissions =>
      grants.map((g) => g.permission).toSet();
}
