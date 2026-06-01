import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/permissions/org_scope_type.dart';
import 'package:speakup_connect/features/roles/data/models/custom_capability_model.dart';
import 'package:speakup_connect/features/roles/data/models/role_model.dart';
import 'package:speakup_connect/features/roles/domain/entities/custom_capability_entity.dart';
import 'package:speakup_connect/features/roles/domain/entities/role_entity.dart';

// ── Shortcuts ────────────────────────────────────────────────────────────────

CollectionReference<Map<String, dynamic>> _rolesRef() =>
    FirebaseFirestore.instance
        .collection(AppConstants.organizationsCollection)
        .doc(AppConfig.defaultOrganizationId)
        .collection(AppConstants.rolesCollection);

CollectionReference<Map<String, dynamic>> _capsRef() =>
    FirebaseFirestore.instance
        .collection(AppConstants.organizationsCollection)
        .doc(AppConfig.defaultOrganizationId)
        .collection(AppConstants.customCapabilitiesCollection);

// ── Stream Providers ─────────────────────────────────────────────────────────

/// Streams all role definitions for the default organisation.
final rolesProvider = StreamProvider.autoDispose<List<RoleEntity>>((ref) {
  return _rolesRef().orderBy('displayName').snapshots().map(
        (snap) => snap.docs
            .map((d) => RoleModel.fromFirestore(d.data(), d.id))
            .toList(),
      );
});

/// Streams a single role by [roleId].
final roleByIdProvider =
    StreamProvider.autoDispose.family<RoleEntity?, String>((ref, roleId) {
  return _rolesRef().doc(roleId).snapshots().map((snap) {
    if (!snap.exists || snap.data() == null) return null;
    return RoleModel.fromFirestore(snap.data()!, snap.id);
  });
});

/// Fetches all custom capability definitions for the default organisation.
/// Uses a one-shot get() instead of snapshots() — Firestore streams on
/// empty collections can hang indefinitely. Use ref.invalidate() to refresh.
final customCapabilitiesProvider =
    FutureProvider<List<CustomCapabilityEntity>>((ref) async {
  final snap = await _capsRef().get();
  final items = snap.docs
      .map((d) => CustomCapabilityModel.fromFirestore(d.data(), d.id))
      .toList()
    ..sort((a, b) => a.displayName.compareTo(b.displayName));
  return items;
});

// ── Role Writer ───────────────────────────────────────────────────────────────

/// Async state for role create / update / delete operations.
///
/// `AsyncData(null)` = idle.
/// `AsyncLoading`    = write in progress.
/// `AsyncError`      = write failed.
class RoleWriter extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> createRole({
    required String displayName,
    required String description,
    required List<String> capabilities,
    required List<String> customCapabilities,
  }) async {
    state = const AsyncLoading();
    try {
      await _rolesRef().add({
        'displayName': displayName,
        if (description.isNotEmpty) 'description': description,
        'isSystemRole': false,
        'capabilities': capabilities,
        'customCapabilities': customCapabilities,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateRole({
    required String roleId,
    required String displayName,
    required String description,
    required List<String> capabilities,
    required List<String> customCapabilities,
  }) async {
    state = const AsyncLoading();
    try {
      await _rolesRef().doc(roleId).update({
        'displayName': displayName,
        'description': description,
        'capabilities': capabilities,
        'customCapabilities': customCapabilities,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteRole(String roleId) async {
    state = const AsyncLoading();
    try {
      await _rolesRef().doc(roleId).delete();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final roleWriterProvider =
    NotifierProvider<RoleWriter, AsyncValue<void>>(RoleWriter.new);

// ── Custom Capability Writer ──────────────────────────────────────────────────

class CustomCapabilityWriter extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<String?> createCapability({
    required String displayName,
    required String description,
    required String resolvedAction,
    String? tagScope,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      state = AsyncError(Exception('Not authenticated'), StackTrace.current);
      return null;
    }
    state = const AsyncLoading();
    try {
      final doc = await _capsRef().add({
        'displayName': displayName,
        if (description.isNotEmpty) 'description': description,
        'resolvedAction': resolvedAction,
        if (tagScope != null && tagScope.isNotEmpty) 'tagScope': tagScope,
        'usedInRoles': <String>[],
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      state = const AsyncData(null);
      return doc.id;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<void> deleteCapability(String capId) async {
    state = const AsyncLoading();
    try {
      await _capsRef().doc(capId).delete();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final customCapabilityWriterProvider =
    NotifierProvider<CustomCapabilityWriter, AsyncValue<void>>(
  CustomCapabilityWriter.new,
);

// ── Role Assignment Writer ────────────────────────────────────────────────────

class RoleAssignmentWriter extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> assignRole({
    required String targetUserId,
    required String roleId,
    required OrgScopeType scopeType,
    String? scopeId,
  }) async {
    final assignedBy = FirebaseAuth.instance.currentUser?.uid;
    if (assignedBy == null) {
      state = AsyncError(Exception('Not authenticated'), StackTrace.current);
      return;
    }
    state = const AsyncLoading();
    try {
      await FirebaseFirestore.instance
          .collection(AppConstants.organizationsCollection)
          .doc(AppConfig.defaultOrganizationId)
          .collection(AppConstants.usersCollection)
          .doc(targetUserId)
          .collection(AppConstants.roleAssignmentsCollection)
          .add({
        'roleId': roleId,
        'scopeType': scopeType.key,
        if (scopeId != null && scopeId.isNotEmpty) 'scopeId': scopeId,
        'assignedBy': assignedBy,
        'assignedAt': FieldValue.serverTimestamp(),
      });
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> removeAssignment({
    required String targetUserId,
    required String assignmentId,
  }) async {
    state = const AsyncLoading();
    try {
      await FirebaseFirestore.instance
          .collection(AppConstants.organizationsCollection)
          .doc(AppConfig.defaultOrganizationId)
          .collection(AppConstants.usersCollection)
          .doc(targetUserId)
          .collection(AppConstants.roleAssignmentsCollection)
          .doc(assignmentId)
          .delete();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final roleAssignmentWriterProvider =
    NotifierProvider<RoleAssignmentWriter, AsyncValue<void>>(
  RoleAssignmentWriter.new,
);

// ── Seed Default Roles ────────────────────────────────────────────────────────

/// Writes the system roles and MONHS starter roles to Firestore in a
/// single batch. Safe to re-run — uses [SetOptions(merge: true)] so any
/// admin edits made after the initial seed are preserved.
///
/// System roles (`org-admin`, `member`) cannot be deleted via the admin UI.
/// Starter roles (guidance-counselor, etc.) are fully editable.
class SeedRoles extends Notifier<AsyncValue<void>> {
  static const _allPermissions = [
    // Reports
    'viewAllReports',
    'viewGroupReports',
    'approveReport',
    'manageReports',
    // Bulletins & News
    'postBulletinOrgWide',
    'postBulletinToGroup',
    // Reminders
    'broadcastReminders',
    // Roster & Users
    'manageGroupRoster',
    'manageClassRoster',
    'approveApplications',
    'blockUsers',
    // Org Administration
    'manageOrganizationSettings',
    'manageRoles',
    'viewAuditLogs',
  ];

  static const _roles = [
    // ── System roles ──────────────────────────────────────────────────────
    (
      id: 'org-admin',
      displayName: 'Organization Admin',
      description: 'Full administrative access to all organization features.',
      isSystemRole: true,
      capabilities: _allPermissions,
    ),
    (
      id: 'member',
      displayName: 'Member',
      description:
          'Standard member. Can submit reports and view their own submissions.',
      isSystemRole: true,
      capabilities: <String>[],
    ),
    // ── MONHS starter roles (editable) ────────────────────────────────────
    (
      id: 'guidance-counselor',
      displayName: 'Guidance Counselor',
      description:
          'Reviews and closes guidance referral reports. Can post to group boards.',
      isSystemRole: false,
      capabilities: [
        'viewGroupReports',
        'approveReport',
        'postBulletinToGroup',
      ],
    ),
    (
      id: 'discipline-officer',
      displayName: 'Discipline Officer',
      description:
          'Manages discipline-related reports. Can update status and add notes.',
      isSystemRole: false,
      capabilities: [
        'viewGroupReports',
        'approveReport',
        'manageReports',
        'blockUsers',
      ],
    ),
    (
      id: 'homeroom-teacher',
      displayName: 'Homeroom Teacher',
      description:
          'Views reports from their assigned class/section. Manages class roster.',
      isSystemRole: false,
      capabilities: [
        'viewGroupReports',
        'manageClassRoster',
      ],
    ),
    (
      id: 'club-adviser',
      displayName: 'Club / Org Adviser',
      description:
          'Manages extracurricular group roster. Can post to group bulletin board.',
      isSystemRole: false,
      capabilities: [
        'manageGroupRoster',
        'postBulletinToGroup',
        'broadcastReminders',
      ],
    ),
  ];

  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> seed() async {
    state = const AsyncLoading();
    try {
      final batch = FirebaseFirestore.instance.batch();
      final rolesRef = _rolesRef();
      final now = FieldValue.serverTimestamp();

      for (final role in _roles) {
        final doc = rolesRef.doc(role.id);
        batch.set(
          doc,
          {
            'displayName': role.displayName,
            'description': role.description,
            'isSystemRole': role.isSystemRole,
            'capabilities': role.capabilities,
            'customCapabilities': <String>[],
            'updatedAt': now,
          },
          SetOptions(merge: true),
        );
      }

      await batch.commit();

      // Set createdAt only on docs that don't have it yet.
      for (final role in _roles) {
        final snap = await rolesRef.doc(role.id).get();
        if (snap.exists && snap.data()?['createdAt'] == null) {
          await rolesRef.doc(role.id).update({'createdAt': now});
        } else if (!snap.exists) {
          await rolesRef.doc(role.id).set({'createdAt': now}, SetOptions(merge: true));
        }
      }

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final seedRolesProvider =
    NotifierProvider<SeedRoles, AsyncValue<void>>(SeedRoles.new);
