import 'package:speakup_connect/core/permissions/entities/effective_permission_set.dart';
import 'package:speakup_connect/features/roles/domain/entities/custom_capability_entity.dart';
import 'package:speakup_connect/features/roles/domain/entities/role_assignment_entity.dart';
import 'package:speakup_connect/features/roles/domain/entities/role_entity.dart';

/// Repository interface for loading and resolving RBAC permission data.
abstract class PermissionsRepository {
  // ── Role Assignments ───────────────────────────────────────────────────────

  /// Watches a user's role assignment subcollection for real-time updates.
  ///
  /// Emits a new list whenever an admin adds, modifies, or removes an
  /// assignment for this user.
  Stream<List<RoleAssignmentEntity>> watchRoleAssignments({
    required String orgId,
    required String userId,
  });

  // ── Roles ──────────────────────────────────────────────────────────────────

  /// Fetches role documents by their IDs in a single batch read.
  Future<List<RoleEntity>> getRolesByIds({
    required String orgId,
    required List<String> roleIds,
  });

  // ── Custom Capabilities ────────────────────────────────────────────────────

  /// Fetches custom capability documents by their IDs in a single batch read.
  Future<List<CustomCapabilityEntity>> getCustomCapabilitiesByIds({
    required String orgId,
    required List<String> capabilityIds,
  });

  // ── Resolution ─────────────────────────────────────────────────────────────

  /// Resolves a list of raw role assignments into a fully computed
  /// [EffectivePermissionSet] by loading role definitions and custom
  /// capability documents and expanding all aliases.
  ///
  /// This is a one-shot async operation. Call it inside the stream pipeline
  /// whenever [watchRoleAssignments] emits a new list.
  Future<EffectivePermissionSet> resolvePermissions({
    required String orgId,
    required List<RoleAssignmentEntity> assignments,
  });
}
