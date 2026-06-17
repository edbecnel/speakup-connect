import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/organization/data/repositories/user_profile_repository_impl.dart';
import 'package:speakup_connect/features/organization/domain/entities/enrolled_member.dart';
import 'package:speakup_connect/features/organization/domain/entities/roster_entry_entity.dart';
import 'package:speakup_connect/features/organization/domain/entities/user_profile_entity.dart';
import 'package:speakup_connect/features/organization/domain/repositories/user_profile_repository.dart';
import 'package:speakup_connect/features/organization/presentation/providers/roster_provider.dart'
    show rosterEntriesProvider, rosterRepositoryProvider;

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

/// Watches any org member profile by Firebase UID (admin edit screens).
final userProfileByIdProvider = StreamProvider.autoDispose
    .family<UserProfileEntity?, String>((ref, userId) {
  return ref.watch(userProfileRepositoryProvider).watchUserProfile(
        orgId: AppConfig.defaultOrganizationId,
        userId: userId,
      );
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
/// always share the same Firestore snapshot. Subscribes only for admins /
/// approvers — avoids a whole-collection listen for regular members.
final pendingMemberApplicationsProvider =
    StreamProvider<List<UserProfileEntity>>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  final canReview = profile?.isAdmin == true ||
      ref.watch(hasPermissionProvider(AppPermission.approveApplications));
  if (!canReview) return Stream.value(const []);

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

// --- Enrolled Users / Block Management ---

/// All approved members in the org.
final enrolledUsersProvider =
    StreamProvider<List<UserProfileEntity>>((ref) {
  final orgId = AppConfig.defaultOrganizationId;
  return ref
      .read(userProfileRepositoryProvider)
      .watchEnrolledUsers(orgId: orgId);
});

/// Approved and unenrolled members for the management screen.
final managedUsersProvider = StreamProvider<List<UserProfileEntity>>((ref) {
  final orgId = AppConfig.defaultOrganizationId;
  return ref
      .read(userProfileRepositoryProvider)
      .watchManagedMembers(orgId: orgId);
});

class UserBlockActionNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> block({
    required String targetUserId,
    required String reason,
  }) async {
    final actor = ref.read(currentUserProvider);
    if (actor == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(userProfileRepositoryProvider).setUserBlockStatus(
            orgId: AppConfig.defaultOrganizationId,
            targetUserId: targetUserId,
            isActive: false,
            actorId: actor.uid,
            reason: reason,
          ),
    );
  }

  Future<void> unblock({
    required String targetUserId,
    String? note,
  }) async {
    final actor = ref.read(currentUserProvider);
    if (actor == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(userProfileRepositoryProvider).setUserBlockStatus(
            orgId: AppConfig.defaultOrganizationId,
            targetUserId: targetUserId,
            isActive: true,
            actorId: actor.uid,
            reason: note,
          ),
    );
  }
}

final userBlockActionProvider =
    NotifierProvider<UserBlockActionNotifier, AsyncValue<void>>(
  UserBlockActionNotifier.new,
);

/// Unified roster view: imported roster rows plus users with a student ID who
/// do not yet have a roster document (common before bulk import).
final rosterViewEntriesProvider = Provider<List<RosterEntryEntity>>((ref) {
  final imported = ref.watch(rosterEntriesProvider).value ?? const [];
  final managed = ref.watch(managedUsersProvider).value ?? const [];
  final pending = ref.watch(pendingMemberApplicationsProvider).value ?? const [];

  final profilesByStudentId = <String, UserProfileEntity>{};
  for (final profile in [...managed, ...pending]) {
    final studentId = profile.studentId;
    if (studentId == null || studentId.isEmpty) continue;
    profilesByStudentId[studentId] = profile;
  }

  final merged = <String, RosterEntryEntity>{};
  for (final entry in imported) {
    final profile = profilesByStudentId[entry.studentId];
    merged[entry.studentId] =
        profile != null ? entry.mergedWith(profile) : entry;
  }

  for (final profile in profilesByStudentId.values) {
    final studentId = profile.studentId!;
    merged.putIfAbsent(studentId, () => RosterEntryEntity.fromProfile(profile));
  }

  final entries = merged.values.toList()
    ..sort(
      (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
    );
  return entries;
});

/// Roster studentId → grade level for enrolled-user filtering.
final rosterGradeMapProvider = StreamProvider<Map<String, int>>((ref) {
  final orgId = AppConfig.defaultOrganizationId;
  return FirebaseFirestore.instance
      .collection(AppConstants.organizationsCollection)
      .doc(orgId)
      .collection(AppConstants.rosterCollection)
      .snapshots()
      .map((snap) {
    final grades = <String, int>{};
    for (final doc in snap.docs) {
      final level = parseGradeLevel(doc.data()['grade'] as String?);
      if (level != null) grades[doc.id] = level;
    }
    return grades;
  });
});

/// Managed members with grade levels resolved from profile or roster.
final managedMembersProvider = Provider<List<EnrolledMember>>((ref) {
  final users = ref.watch(managedUsersProvider).value ?? const [];
  final rosterGrades = ref.watch(rosterGradeMapProvider).value ?? const {};
  return users
      .map(
        (user) => EnrolledMember(
          user: user,
          gradeLevel: user.gradeLevel ??
              (user.studentId != null
                  ? rosterGrades[user.studentId!]
                  : null),
        ),
      )
      .toList();
});

/// Back-compat alias for enrolled-only views.
final enrolledMembersProvider = Provider<List<EnrolledMember>>((ref) {
  return ref
      .watch(managedMembersProvider)
      .where((m) => m.user.isApproved)
      .toList();
});

class UserManagementActionNotifier extends Notifier<AsyncValue<int?>> {
  @override
  AsyncValue<int?> build() => const AsyncValue.data(null);

  Future<int> blockMany({
    required List<String> targetUserIds,
    required String reason,
  }) async {
    final actor = ref.read(currentUserProvider);
    if (actor == null || targetUserIds.isEmpty) return 0;
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(userProfileRepositoryProvider);
      final orgId = AppConfig.defaultOrganizationId;
      for (final userId in targetUserIds) {
        await repo.setUserBlockStatus(
          orgId: orgId,
          targetUserId: userId,
          isActive: false,
          actorId: actor.uid,
          reason: reason,
        );
      }
      state = AsyncValue.data(targetUserIds.length);
      return targetUserIds.length;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<int> unblockMany({required List<String> targetUserIds}) async {
    final actor = ref.read(currentUserProvider);
    if (actor == null || targetUserIds.isEmpty) return 0;
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(userProfileRepositoryProvider);
      final orgId = AppConfig.defaultOrganizationId;
      for (final userId in targetUserIds) {
        await repo.setUserBlockStatus(
          orgId: orgId,
          targetUserId: userId,
          isActive: true,
          actorId: actor.uid,
        );
      }
      state = AsyncValue.data(targetUserIds.length);
      return targetUserIds.length;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<int> assignGradesToMembers({
    required List<EnrolledMember> members,
    required int gradeLevel,
  }) async {
    if (members.isEmpty) return 0;
    state = const AsyncValue.loading();
    try {
      final rosterRepo = ref.read(rosterRepositoryProvider);
      final profileRepo = ref.read(userProfileRepositoryProvider);
      final orgId = AppConfig.defaultOrganizationId;

      final rosterGrades = <String, int>{};
      for (final member in members) {
        final studentId = member.user.studentId;
        if (studentId != null && studentId.isNotEmpty) {
          rosterGrades[studentId] = gradeLevel;
        } else {
          await profileRepo.setMemberGradeLevel(
            orgId: orgId,
            targetUserId: member.userId,
            gradeLevel: gradeLevel,
          );
        }
      }

      if (rosterGrades.isNotEmpty) {
        await rosterRepo.setStudentGrades(
          orgId: orgId,
          gradesByStudentId: rosterGrades,
        );
      }

      state = AsyncValue.data(members.length);
      return members.length;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<int> reEnrollMany({required List<String> targetUserIds}) async {
    final actor = ref.read(currentUserProvider);
    if (actor == null || targetUserIds.isEmpty) return 0;
    state = const AsyncValue.loading();
    try {
      final count = await ref.read(userProfileRepositoryProvider).reEnrollUsers(
            orgId: AppConfig.defaultOrganizationId,
            targetUserIds: targetUserIds,
            actorId: actor.uid,
          );
      state = AsyncValue.data(count);
      return count;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<int> unenrollMany({
    required List<String> targetUserIds,
    required String reason,
  }) async {
    final actor = ref.read(currentUserProvider);
    if (actor == null || targetUserIds.isEmpty) return 0;
    state = const AsyncValue.loading();
    try {
      final count = await ref.read(userProfileRepositoryProvider).unenrollUsers(
            orgId: AppConfig.defaultOrganizationId,
            targetUserIds: targetUserIds,
            actorId: actor.uid,
            reason: reason,
          );
      state = AsyncValue.data(count);
      return count;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final userManagementActionProvider =
    NotifierProvider<UserManagementActionNotifier, AsyncValue<int?>>(
  UserManagementActionNotifier.new,
);

class UpdateMemberContactEmailNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> update({String? email}) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;
    state = const AsyncValue.loading();
    try {
      await ref.read(userProfileRepositoryProvider).updateContactEmail(
            orgId: AppConfig.defaultOrganizationId,
            userId: user.uid,
            email: email,
          );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final updateMemberContactEmailProvider =
    NotifierProvider<UpdateMemberContactEmailNotifier, AsyncValue<void>>(
  UpdateMemberContactEmailNotifier.new,
);
