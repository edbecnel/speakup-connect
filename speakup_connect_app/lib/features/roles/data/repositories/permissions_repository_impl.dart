import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/entities/effective_permission_set.dart';
import 'package:speakup_connect/features/roles/data/models/custom_capability_model.dart';
import 'package:speakup_connect/features/roles/data/models/role_assignment_model.dart';
import 'package:speakup_connect/features/roles/data/models/role_model.dart';
import 'package:speakup_connect/features/roles/domain/entities/custom_capability_entity.dart';
import 'package:speakup_connect/features/roles/domain/entities/role_assignment_entity.dart';
import 'package:speakup_connect/features/roles/domain/entities/role_entity.dart';
import 'package:speakup_connect/features/roles/domain/repositories/permissions_repository.dart';

/// Firestore implementation of [PermissionsRepository].
class PermissionsRepositoryImpl implements PermissionsRepository {
  PermissionsRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  // ── Collection References ──────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _assignmentsRef(
    String orgId,
    String userId,
  ) =>
      _firestore
          .collection(AppConstants.organizationsCollection)
          .doc(orgId)
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.roleAssignmentsCollection);

  CollectionReference<Map<String, dynamic>> _rolesRef(String orgId) =>
      _firestore
          .collection(AppConstants.organizationsCollection)
          .doc(orgId)
          .collection(AppConstants.rolesCollection);

  CollectionReference<Map<String, dynamic>> _customCapsRef(String orgId) =>
      _firestore
          .collection(AppConstants.organizationsCollection)
          .doc(orgId)
          .collection(AppConstants.customCapabilitiesCollection);

  // ── Role Assignments ───────────────────────────────────────────────────────

  @override
  Stream<List<RoleAssignmentEntity>> watchRoleAssignments({
    required String orgId,
    required String userId,
  }) {
    return _assignmentsRef(orgId, userId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => RoleAssignmentModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // ── Roles ──────────────────────────────────────────────────────────────────

  @override
  Future<List<RoleEntity>> getRolesByIds({
    required String orgId,
    required List<String> roleIds,
  }) async {
    if (roleIds.isEmpty) return [];

    try {
      // Firestore `whereIn` is limited to 30 items; chunk if necessary.
      final results = <RoleEntity>[];
      for (var i = 0; i < roleIds.length; i += 30) {
        final chunk = roleIds.sublist(
          i,
          (i + 30).clamp(0, roleIds.length),
        );
        final snapshot = await _rolesRef(orgId)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        results.addAll(
          snapshot.docs.map((d) => RoleModel.fromFirestore(d.data(), d.id)),
        );
      }
      return results;
    } on FirebaseException catch (e) {
      throw DatabaseException(
        message: e.message ?? 'Failed to load roles',
        code: e.code,
      );
    }
  }

  // ── Custom Capabilities ────────────────────────────────────────────────────

  @override
  Future<List<CustomCapabilityEntity>> getCustomCapabilitiesByIds({
    required String orgId,
    required List<String> capabilityIds,
  }) async {
    if (capabilityIds.isEmpty) return [];

    try {
      final results = <CustomCapabilityEntity>[];
      for (var i = 0; i < capabilityIds.length; i += 30) {
        final chunk = capabilityIds.sublist(
          i,
          (i + 30).clamp(0, capabilityIds.length),
        );
        final snapshot = await _customCapsRef(orgId)
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        results.addAll(
          snapshot.docs
              .map((d) => CustomCapabilityModel.fromFirestore(d.data(), d.id)),
        );
      }
      return results;
    } on FirebaseException catch (e) {
      throw DatabaseException(
        message: e.message ?? 'Failed to load custom capabilities',
        code: e.code,
      );
    }
  }

  // ── Resolution ─────────────────────────────────────────────────────────────

  @override
  Future<EffectivePermissionSet> resolvePermissions({
    required String orgId,
    required List<RoleAssignmentEntity> assignments,
  }) async {
    if (assignments.isEmpty) return EffectivePermissionSet.empty;

    // 1. Collect all unique role IDs and custom capability IDs.
    final roleIds = assignments.map((a) => a.roleId).toSet().toList();

    final roles = await getRolesByIds(orgId: orgId, roleIds: roleIds);

    final allCustomCapIds = roles
        .expand((r) => r.customCapabilities)
        .toSet()
        .toList();

    final customCaps = await getCustomCapabilitiesByIds(
      orgId: orgId,
      capabilityIds: allCustomCapIds,
    );

    final capIndex = {for (final c in customCaps) c.id: c};

    // 2. Build a map of roleId → RoleEntity for quick lookup.
    final roleIndex = {for (final r in roles) r.id: r};

    // 3. Expand each assignment into PermissionGrants.
    final grants = <PermissionGrant>[];

    for (final assignment in assignments) {
      final role = roleIndex[assignment.roleId];
      if (role == null) continue; // role may have been deleted

      // Direct capabilities.
      for (final capKey in role.capabilities) {
        final permission = AppPermission.fromKey(capKey);
        if (permission == null) continue; // unknown key from older version
        grants.add(PermissionGrant(
          permission: permission,
          scopeType: assignment.scopeType,
          scopeId: assignment.scopeId,
        ));
      }

      // Custom capability aliases.
      for (final capId in role.customCapabilities) {
        final cap = capIndex[capId];
        if (cap == null) continue;
        final permission = AppPermission.fromKey(cap.resolvedAction);
        if (permission == null) continue;
        grants.add(PermissionGrant(
          permission: permission,
          scopeType: assignment.scopeType,
          scopeId: assignment.scopeId,
          tagRestriction: cap.tagScope,
        ));
      }
    }

    // 4. Union allowedCategoryIds across all roles (org-admin null = unrestricted).
    var unrestrictedCategories = false;
    final categoryUnion = <String>{};
    for (final role in roles) {
      if (role.allowedCategoryIds == null) {
        if (role.id == 'org-admin') unrestrictedCategories = true;
      } else {
        categoryUnion.addAll(role.allowedCategoryIds!);
      }
    }

    return EffectivePermissionSet(
      grants: grants,
      allowedCategoryIds:
          unrestrictedCategories ? null : categoryUnion,
    );
  }
}
