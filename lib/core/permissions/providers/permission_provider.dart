import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/entities/effective_permission_set.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/roles/data/repositories/permissions_repository_impl.dart';
import 'package:speakup_connect/features/roles/domain/repositories/permissions_repository.dart';

// ── Infrastructure ─────────────────────────────────────────────────────────

/// Provides the [PermissionsRepository] implementation.
final permissionsRepositoryProvider = Provider<PermissionsRepository>((ref) {
  return PermissionsRepositoryImpl(FirebaseFirestore.instance);
});

// ── Effective Permissions Stream ────────────────────────────────────────────

/// Watches the current user's role assignments and resolves them into a fully
/// computed [EffectivePermissionSet].
///
/// - Emits [EffectivePermissionSet.empty] when the user is signed out or has
///   no role assignments.
/// - Re-resolves automatically whenever an admin modifies the user's
///   assignments in Firestore (e.g. adds/removes a role).
/// - The [AsyncValue] wrapper lets call sites handle the loading and error
///   states gracefully without crashing.
///
/// Example — watching in a widget:
/// ```dart
/// final perms = ref.watch(permissionProvider).valueOrNull
///     ?? EffectivePermissionSet.empty;
/// if (perms.has(AppPermission.manageRoles)) { ... }
/// ```
final permissionProvider = StreamProvider<EffectivePermissionSet>((ref) async* {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    yield EffectivePermissionSet.empty;
    return;
  }

  const orgId = AppConfig.defaultOrganizationId;
  final repo = ref.read(permissionsRepositoryProvider);

  await for (final assignments in repo.watchRoleAssignments(
    orgId: orgId,
    userId: user.uid,
  )) {
    final resolved = await repo.resolvePermissions(
      orgId: orgId,
      assignments: assignments,
    );
    // Force-refresh the Firebase Auth ID token so Firestore Security Rules
    // immediately see the updated custom claims written by syncCustomClaims.
    // Fire-and-forget — the UI update (yield) is not blocked by the refresh.
    FirebaseAuth.instance.currentUser?.getIdToken(true).ignore();
    yield resolved;
  }
});

// ── Convenience Providers ───────────────────────────────────────────────────

/// Returns true if the current user holds [permission] under any scope.
///
/// Defaults to false while permissions are loading or if the user is signed
/// out. Use for coarse UI gates (show/hide navigation items, action buttons).
///
/// For data-access decisions where context matters (e.g. which tag a report
/// belongs to), use [permissionProvider] directly and call [can()].
///
/// Example:
/// ```dart
/// final canManageRoles = ref.watch(
///   hasPermissionProvider(AppPermission.manageRoles),
/// );
/// ```
final hasPermissionProvider =
    Provider.family<bool, AppPermission>((ref, permission) {
  return ref.watch(permissionProvider).asData?.value.has(permission) ?? false;
});
