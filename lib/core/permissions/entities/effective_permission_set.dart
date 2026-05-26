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
///      (which content tags the action is further restricted to, if any)
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
///
/// Usage:
/// ```dart
/// final perms = ref.watch(permissionProvider).valueOrNull;
///
/// // Rough check — show/hide a sidebar item:
/// if (perms?.has(AppPermission.viewAuditLogs) ?? false) ...
///
/// // Contextual check — before rendering an action on a specific report:
/// if (perms?.can(AppPermission.approveReport, tag: report.tag) ?? false) ...
/// ```
class EffectivePermissionSet {
  const EffectivePermissionSet({required this.grants});

  /// An empty set returned when the user has no role assignments.
  static const EffectivePermissionSet empty =
      EffectivePermissionSet(grants: []);

  final List<PermissionGrant> grants;

  bool get isEmpty => grants.isEmpty;

  // ── Permission Checks ──────────────────────────────────────────────────────

  /// Returns true if the user holds [permission] under any scope.
  ///
  /// Use for coarse UI gates (e.g. show the Roles admin link). For data
  /// access decisions where content context is known, prefer [can].
  bool has(AppPermission permission) =>
      grants.any((g) => g.permission == permission);

  /// Returns true if the user may perform [permission] in the given context.
  ///
  /// [tag]      — the content tag of the resource being acted on.
  /// [scopeType] + [scopeId] — the resource type and ID being acted on
  ///              (e.g. OrgScopeType.classUnit, "class-7a").
  ///
  /// A grant satisfies the context when:
  ///   - The permission matches, AND
  ///   - The grant's scope covers the context (org-wide always covers
  ///     everything; narrower scopes must match exactly), AND
  ///   - The grant's tag restriction (if any) matches the provided tag.
  bool can(
    AppPermission permission, {
    String? tag,
    OrgScopeType? scopeType,
    String? scopeId,
  }) {
    for (final grant in grants) {
      if (grant.permission != permission) continue;

      // Scope constraint: org-wide grants cover all contexts.
      final scopeOk = grant.scopeType == OrgScopeType.org ||
          // Tag-scoped role assignment: the scopeId is the required tag.
          (grant.scopeType == OrgScopeType.tag && grant.scopeId == tag) ||
          // Resource-scoped: both type and ID must match.
          (scopeType != null &&
              grant.scopeType == scopeType &&
              grant.scopeId == scopeId);

      // Tag restriction: from the custom capability's tagScope field.
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
