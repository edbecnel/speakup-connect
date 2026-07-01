import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/entities/effective_permission_set.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
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
final permissionProvider = StreamProvider<EffectivePermissionSet>((ref) async* {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    yield EffectivePermissionSet.empty;
    return;
  }

  final orgId = AppConfig.defaultOrganizationId;
  final repo = ref.read(permissionsRepositoryProvider);

  await for (final assignments in repo.watchRoleAssignments(
    orgId: orgId,
    userId: user.uid,
  )) {
    final resolved = await repo.resolvePermissions(
      orgId: orgId,
      assignments: assignments,
    );
    FirebaseAuth.instance.currentUser?.getIdToken(true).ignore();
    yield resolved;
  }
});

// ── Convenience Providers ───────────────────────────────────────────────────

/// Returns true if the current user holds [permission] under any scope.
final hasPermissionProvider =
    Provider.family<bool, AppPermission>((ref, permission) {
  return ref.watch(permissionProvider).asData?.value.has(permission) ?? false;
});

/// True when the user may open the Admin Dashboard and triage org reports.
final canAccessAdminReportsProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  if (profile?.isAdmin == true) return true;
  return ref.watch(permissionProvider).asData?.value.canAccessAdminReports ??
      false;
});

/// Category IDs the current user may access for report triage.
/// `null` = unrestricted (org admin).
final allowedReportCategoryIdsProvider = Provider<Set<String>?>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  if (profile?.isAdmin == true) return null;
  return ref.watch(permissionProvider).asData?.value.allowedCategoryIds;
});

/// True when the user may view/act on a report in [categoryId].
final canAccessReportCategoryProvider = Provider.family<bool, String>(
  (ref, categoryId) {
    final profile = ref.watch(userProfileProvider).value;
    if (profile?.isAdmin == true) return true;
    final perms =
        ref.watch(permissionProvider).asData?.value ?? EffectivePermissionSet.empty;
    return perms.canViewReport(categoryId);
  },
);

/// True when the user may perform [permission] on a report in [categoryId].
final reportPermissionProvider = Provider.family<bool, ReportPermissionQuery>(
  (ref, query) {
    final profile = ref.watch(userProfileProvider).value;
    if (profile?.isAdmin == true) return true;
    final perms =
        ref.watch(permissionProvider).asData?.value ?? EffectivePermissionSet.empty;
    return perms.can(query.permission, categoryId: query.categoryId);
  },
);

/// Query key for [reportPermissionProvider].
class ReportPermissionQuery {
  const ReportPermissionQuery({
    required this.permission,
    required this.categoryId,
  });

  final AppPermission permission;
  final String categoryId;

  @override
  bool operator ==(Object other) =>
      other is ReportPermissionQuery &&
      other.permission == permission &&
      other.categoryId == categoryId;

  @override
  int get hashCode => Object.hash(permission, categoryId);
}

/// True when the user may review reminders in the approval queue.
final canReviewPendingRemindersProvider = Provider<bool>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  final profile = profileAsync.value;
  if (profile?.isAdmin == true) return true;
  if (profileAsync.isLoading && profile == null) return false;
  return ref.watch(hasPermissionProvider(AppPermission.approveReminders));
});
