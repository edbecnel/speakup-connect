import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/organization/data/repositories/user_profile_repository_impl.dart';
import 'package:speakup_connect/features/organization/domain/entities/user_profile_entity.dart';
import 'package:speakup_connect/features/organization/domain/repositories/user_profile_repository.dart';

// --- Infrastructure ---

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepositoryImpl(FirebaseFirestore.instance);
});

// --- User Profile Stream ---

/// Watches the current user's profile for the default organisation.
///
/// Emits [null] when:
///   - The user is not authenticated.
///   - No profile document exists (new sign-up, not yet applied).
///
/// Emits a [UserProfileEntity] with [ApprovalStatus.pending] while the
/// admin has not yet reviewed the application.
final userProfileProvider = StreamProvider<UserProfileEntity?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);

  final orgId = AppConfig.defaultOrganizationId;
  return ref
      .read(userProfileRepositoryProvider)
      .watchUserProfile(orgId: orgId, userId: user.uid);
});

// --- Join Application Notifier ---

/// State for the apply-to-join form submission.
class JoinApplicationNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> submitApplication({
    required String orgId,
    required String userId,
    required String displayName,
    required String fullName,
    String? studentId,
    String? email,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(userProfileRepositoryProvider).createUserProfile(
            orgId: orgId,
            userId: userId,
            displayName: displayName,
            fullName: fullName,
            studentId: studentId,
            email: email,
          ),
    );
  }
}

final joinApplicationProvider =
    NotifierProvider.autoDispose<JoinApplicationNotifier, AsyncValue<void>>(
  JoinApplicationNotifier.new,
);

// --- Permission Delegation Notifier ---

/// Allows a [super_admin] to grant or revoke delegated permissions on
/// another user's profile (e.g. [UserPermission.editTheme] for an `admin`).
///
/// Usage:
/// ```dart
/// ref.read(permissionDelegationProvider.notifier).grant(
///   orgId: AppConfig.defaultOrganizationId,
///   targetUserId: someAdminUid,
///   permission: UserPermission.editTheme,
/// );
/// ```
class PermissionDelegationNotifier
    extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> grant({
    required String orgId,
    required String targetUserId,
    required String permission,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(userProfileRepositoryProvider).grantPermission(
            orgId: orgId,
            targetUserId: targetUserId,
            permission: permission,
          ),
    );
  }

  Future<void> revoke({
    required String orgId,
    required String targetUserId,
    required String permission,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(userProfileRepositoryProvider).revokePermission(
            orgId: orgId,
            targetUserId: targetUserId,
            permission: permission,
          ),
    );
  }
}

final permissionDelegationProvider = NotifierProvider.autoDispose<
    PermissionDelegationNotifier, AsyncValue<void>>(
  PermissionDelegationNotifier.new,
);

// --- Member Application Review ---

/// Join applications awaiting admin approval.
///
/// Kept alive (non-autoDispose) so the dashboard badge and queue screen
/// always share the same Firestore snapshot.
final pendingMemberApplicationsProvider =
    StreamProvider<List<UserProfileEntity>>((ref) {
  final orgId = AppConfig.defaultOrganizationId;
  return ref
      .read(userProfileRepositoryProvider)
      .watchPendingApplications(orgId: orgId);
});

/// Count of pending join applications — for admin dashboard badges.
final pendingMemberApplicationCountProvider = Provider<int>((ref) {
  final async = ref.watch(pendingMemberApplicationsProvider);
  return async.value?.length ?? 0;
});

class MemberApplicationReviewNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> approve(String targetUserId) async {
    final reviewer = ref.read(currentUserProvider);
    if (reviewer == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(userProfileRepositoryProvider).updateApprovalStatus(
            orgId: AppConfig.defaultOrganizationId,
            targetUserId: targetUserId,
            status: ApprovalStatus.approved,
            reviewedBy: reviewer.uid,
          ),
    );
  }

  Future<void> reject(String targetUserId, {String? reason}) async {
    final reviewer = ref.read(currentUserProvider);
    if (reviewer == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(userProfileRepositoryProvider).updateApprovalStatus(
            orgId: AppConfig.defaultOrganizationId,
            targetUserId: targetUserId,
            status: ApprovalStatus.rejected,
            reviewedBy: reviewer.uid,
            rejectionReason: reason,
          ),
    );
  }
}

final memberApplicationReviewProvider =
    NotifierProvider<MemberApplicationReviewNotifier, AsyncValue<void>>(
  MemberApplicationReviewNotifier.new,
);
