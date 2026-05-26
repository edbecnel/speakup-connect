import 'package:speakup_connect/core/permissions/org_scope_type.dart';

/// Domain entity representing a single role assignment for a user.
///
/// Stored in Firestore at:
///   `organizations/{orgId}/users/{userId}/roleAssignments/{assignmentId}`
///
/// A user may hold multiple assignments. Effective permissions are the
/// union of all assignments — see [EffectivePermissionSet].
class RoleAssignmentEntity {
  const RoleAssignmentEntity({
    required this.assignmentId,
    required this.roleId,
    required this.scopeType,
    this.scopeId,
    required this.assignedBy,
    required this.assignedAt,
  });

  /// Firestore document ID for this assignment.
  final String assignmentId;

  /// The role granted by this assignment. References
  /// `organizations/{orgId}/roles/{roleId}`.
  final String roleId;

  /// The scope type that constrains where this role's capabilities apply.
  final OrgScopeType scopeType;

  /// The specific resource this assignment is scoped to.
  ///
  /// Null when [scopeType] is [OrgScopeType.org] (org-wide assignment).
  /// For [OrgScopeType.tag] this is the tag value (e.g. "guidance").
  /// For [OrgScopeType.classUnit] this is the classId.
  /// For [OrgScopeType.group] this is the groupId.
  final String? scopeId;

  /// UID of the admin who created this assignment.
  final String assignedBy;

  final DateTime assignedAt;
}
