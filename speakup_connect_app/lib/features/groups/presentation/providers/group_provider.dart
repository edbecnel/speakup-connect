import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/groups/data/datasources/group_membership_remote_datasource.dart';
import 'package:speakup_connect/features/groups/data/datasources/group_remote_datasource.dart';
import 'package:speakup_connect/features/groups/data/repositories/group_repository_impl.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_member_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_membership_policy.dart';
import 'package:speakup_connect/features/groups/domain/entities/my_group_membership.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_position_role.dart';
import 'package:speakup_connect/features/groups/domain/repositories/group_repository.dart';
import 'package:speakup_connect/features/groups/domain/usecases/add_group_member_usecase.dart';
import 'package:speakup_connect/features/groups/domain/usecases/create_group_usecase.dart';
import 'package:speakup_connect/features/groups/domain/usecases/get_groups_usecase.dart';
import 'package:speakup_connect/features/groups/domain/usecases/get_my_groups_usecase.dart';
import 'package:speakup_connect/features/organization/data/models/user_profile_model.dart';
import 'package:speakup_connect/features/organization/domain/entities/user_profile_entity.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';

// ── Infrastructure ───────────────────────────────────────────────────────────

final groupRemoteDataSourceProvider = Provider<GroupRemoteDataSource>((ref) {
  return GroupRemoteDataSource(FirebaseFirestore.instance);
});

final groupMembershipRemoteDataSourceProvider =
    Provider<GroupMembershipRemoteDataSource>((ref) {
  return GroupMembershipRemoteDataSource(FirebaseFirestore.instance);
});

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepositoryImpl(
    ref.watch(groupRemoteDataSourceProvider),
    ref.watch(groupMembershipRemoteDataSourceProvider),
  );
});

final createGroupUseCaseProvider = Provider<CreateGroupUseCase>((ref) {
  return CreateGroupUseCase(ref.watch(groupRepositoryProvider));
});

final addGroupMemberUseCaseProvider = Provider<AddGroupMemberUseCase>((ref) {
  return AddGroupMemberUseCase(ref.watch(groupRepositoryProvider));
});

final getGroupsUseCaseProvider = Provider<GetGroupsUseCase>((ref) {
  return GetGroupsUseCase(ref.watch(groupRepositoryProvider));
});

final getMyGroupsUseCaseProvider = Provider<GetMyGroupsUseCase>((ref) {
  return GetMyGroupsUseCase(ref.watch(groupRepositoryProvider));
});

// ── Streams ──────────────────────────────────────────────────────────────────

/// All active groups in the default org — drives admin list and reminder picker.
final orgGroupsProvider = StreamProvider.autoDispose<List<GroupEntity>>((ref) {
  return ref
      .watch(getGroupsUseCaseProvider)
      .call(AppConfig.defaultOrganizationId);
});

/// Groups the signed-in user belongs to.
final myGroupsProvider = StreamProvider.autoDispose<List<GroupEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(getMyGroupsUseCaseProvider).call(
        organizationId: AppConfig.defaultOrganizationId,
        userId: user.uid,
      );
});

/// Memberships with group details — for My Groups UI.
final myGroupMembershipsProvider =
    StreamProvider.autoDispose<List<MyGroupMembership>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(groupRepositoryProvider).watchMyGroupMemberships(
        organizationId: AppConfig.defaultOrganizationId,
        userId: user.uid,
      );
});

/// Member roster for a single group.
final groupMembersProvider = StreamProvider.autoDispose
    .family<List<GroupMemberEntity>, String>((ref, groupId) {
  return ref.watch(groupRepositoryProvider).watchGroupMembers(
        organizationId: AppConfig.defaultOrganizationId,
        groupId: groupId,
      );
});

/// Loads a single group document for detail / member screens.
final groupByIdProvider = FutureProvider.autoDispose
    .family<GroupEntity?, String>((ref, groupId) {
  return ref.watch(groupRepositoryProvider).getGroup(
        organizationId: AppConfig.defaultOrganizationId,
        groupId: groupId,
      );
});

/// Approved org members for the add-member picker.
///
/// Only fetched when the user may manage at least one group roster.
final approvedOrgUsersProvider =
    FutureProvider.autoDispose<List<UserProfileEntity>>((ref) async {
  final canPick =
      ref.watch(canManageGroupsProvider) ||
      ref.watch(isLeaderOfAnyGroupProvider);
  if (!canPick) return const [];

  final snap = await FirebaseFirestore.instance
      .collection(AppConstants.organizationsCollection)
      .doc(AppConfig.defaultOrganizationId)
      .collection(AppConstants.usersCollection)
      .where('approvalStatus', isEqualTo: 'approved')
      .orderBy('displayName')
      .get();
  return snap.docs
      .map((d) => UserProfileModel.fromFirestore(d.data(), d.id))
      .where((u) => u.isApproved)
      .toList();
});

/// Client-side search filter for the groups list screen.
final groupsSearchQueryProvider =
    NotifierProvider<GroupsSearchQueryNotifier, String>(
  GroupsSearchQueryNotifier.new,
);

class GroupsSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;

  void clear() => state = '';
}

/// True when the user may create groups or manage all org rosters (admin/RBAC).
final canManageGroupsProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  if (profile?.isAdmin == true) return true;
  return ref.watch(hasPermissionProvider(AppPermission.manageGroupRoster));
});

/// Live roster row for the signed-in user in [groupId] (authoritative groupRole).
final myGroupMembershipInGroupProvider = StreamProvider.autoDispose
    .family<GroupMemberEntity?, String>((ref, groupId) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(groupRepositoryProvider).watchMyGroupMember(
        organizationId: AppConfig.defaultOrganizationId,
        groupId: groupId,
        userId: user.uid,
      );
});

/// Roster membership when loaded; otherwise the My Groups index row.
GroupMemberEntity? effectiveMyGroupMembership(Ref ref, String groupId) {
  final roster =
      ref.watch(myGroupMembershipInGroupProvider(groupId)).asData?.value;
  if (roster != null) return roster;

  final memberships =
      ref.watch(myGroupMembershipsProvider).asData?.value ?? const [];
  for (final entry in memberships) {
    if (entry.group.groupId == groupId) return entry.membership;
  }
  return null;
}

/// True when the user may manage roster for [groupId] (admin, RBAC, or leader).
final canManageGroupRosterProvider =
    Provider.autoDispose.family<bool, String>((ref, groupId) {
  if (ref.watch(canManageGroupsProvider)) return true;
  return effectiveMyGroupMembership(ref, groupId)?.isLeader ?? false;
});

/// Groups the signed-in user leads (live roster `groupRole == leader`).
final ledGroupMembershipsProvider = Provider.autoDispose<List<MyGroupMembership>>((ref) {
  final memberships =
      ref.watch(myGroupMembershipsProvider).asData?.value ?? const [];
  return memberships
      .where(
        (m) =>
            effectiveMyGroupMembership(ref, m.group.groupId)?.isLeader ??
            m.membership.isLeader,
      )
      .toList();
});

/// True when the user leads at least one group.
final isLeaderOfAnyGroupProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(ledGroupMembershipsProvider).isNotEmpty;
});

/// True when the user may broadcast to the whole org or any group (RBAC/admin).
final canBroadcastOrgWideProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  if (profile?.isAdmin == true) return true;
  return ref.watch(hasPermissionProvider(AppPermission.broadcastReminders));
});

/// True when the user may open the compose-reminder flow (org-wide or as a leader).
final canComposeRemindersProvider = Provider<bool>((ref) {
  return ref.watch(canBroadcastOrgWideProvider) ||
      ref.watch(isLeaderOfAnyGroupProvider);
});

/// True when compose is limited to groups this user leads (no org-wide broadcast).
final isGroupLeaderOnlyComposerProvider = Provider<bool>((ref) {
  return !ref.watch(canBroadcastOrgWideProvider) &&
      ref.watch(isLeaderOfAnyGroupProvider);
});

/// True when the user may send a reminder to [groupId].
final canBroadcastToGroupProvider =
    Provider.autoDispose.family<bool, String>((ref, groupId) {
  if (ref.watch(canBroadcastOrgWideProvider)) return true;
  return effectiveMyGroupMembership(ref, groupId)?.isLeader ?? false;
});

/// True when the user may edit group settings for [groupId] (not roster).
final canEditGroupSettingsProvider =
    Provider.autoDispose.family<bool, String>((ref, groupId) {
  return ref.watch(canManageGroupRosterProvider(groupId));
});

/// True when the user may deactivate/reactivate a group (org admin only).
final canDeactivateGroupProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider).value?.isAdmin ?? false;
});

// ── Actions ──────────────────────────────────────────────────────────────────

class CreateGroupNotifier extends Notifier<AsyncValue<GroupEntity?>> {
  @override
  AsyncValue<GroupEntity?> build() => const AsyncData(null);

  Future<GroupEntity?> submit({
    required String name,
    String? description,
    List<GroupPositionRole> positionRoles = const [],
    bool allowJoinRequests = false,
    String? joinRequestHint,
    MemberLeavePolicy memberLeavePolicy = MemberLeavePolicy.requestRequired,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return null;

    state = const AsyncLoading();
    try {
      final group = await ref.read(createGroupUseCaseProvider).call(
            organizationId: AppConfig.defaultOrganizationId,
            name: name.trim(),
            createdBy: user.uid,
            description: () {
              final trimmed = description?.trim();
              return trimmed == null || trimmed.isEmpty ? null : trimmed;
            }(),
            positionRoles: positionRoles,
            allowJoinRequests: allowJoinRequests,
            joinRequestHint: joinRequestHint,
            memberLeavePolicy: memberLeavePolicy,
          );
      state = AsyncData(group);
      return group;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final createGroupActionProvider =
    NotifierProvider<CreateGroupNotifier, AsyncValue<GroupEntity?>>(
  CreateGroupNotifier.new,
);

class UpdateGroupNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> submit({
    required String groupId,
    required String name,
    String? description,
    List<GroupPositionRole>? positionRoles,
    bool? allowJoinRequests,
    MemberLeavePolicy? memberLeavePolicy,
    String? joinRequestHint,
    bool? isActive,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(groupRepositoryProvider).updateGroup(
            organizationId: AppConfig.defaultOrganizationId,
            groupId: groupId,
            name: name.trim(),
            description: description,
            positionRoles: positionRoles,
            allowJoinRequests: allowJoinRequests,
            memberLeavePolicy: memberLeavePolicy,
            joinRequestHint: joinRequestHint,
            isActive: isActive,
          );
      ref.invalidate(groupByIdProvider(groupId));
      ref.invalidate(orgGroupsProvider);
      ref.invalidate(myGroupsProvider);
      ref.invalidate(myGroupMembershipsProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final updateGroupActionProvider =
    NotifierProvider<UpdateGroupNotifier, AsyncValue<void>>(
  UpdateGroupNotifier.new,
);

class UpdateGroupPositionRolesNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> submit({
    required String groupId,
    required List<GroupPositionRole> positionRoles,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(groupRepositoryProvider).updateGroupPositionRoles(
            organizationId: AppConfig.defaultOrganizationId,
            groupId: groupId,
            positionRoles: positionRoles,
          );
      ref.invalidate(groupByIdProvider(groupId));
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final updateGroupPositionRolesProvider =
    NotifierProvider<UpdateGroupPositionRolesNotifier, AsyncValue<void>>(
  UpdateGroupPositionRolesNotifier.new,
);

class GroupMemberActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> addMember({
    required String groupId,
    required UserProfileEntity user,
    GroupRole groupRole = GroupRole.member,
    String? positionRoleId,
  }) async {
    final added = await addMembers(
      groupId: groupId,
      users: [user],
      groupRole: groupRole,
      positionRoleId: positionRoleId,
    );
    return added > 0;
  }

  /// Adds [users] to the group roster. Returns how many were added successfully.
  Future<int> addMembers({
    required String groupId,
    required List<UserProfileEntity> users,
    GroupRole groupRole = GroupRole.member,
    String? positionRoleId,
  }) async {
    final actor = ref.read(currentUserProvider);
    if (actor == null || users.isEmpty) return 0;

    state = const AsyncLoading();
    var added = 0;
    Object? lastError;
    StackTrace? lastStack;

    for (final user in users) {
      try {
        await ref.read(addGroupMemberUseCaseProvider).call(
              organizationId: AppConfig.defaultOrganizationId,
              groupId: groupId,
              userId: user.userId,
              displayName: user.displayName,
              addedBy: actor.uid,
              groupRole: groupRole,
              positionRoleId: positionRoleId,
            );
        added++;
      } catch (e, st) {
        lastError = e;
        lastStack = st;
      }
    }

    if (added == 0 && lastError != null) {
      state = AsyncError(lastError, lastStack ?? StackTrace.current);
    } else {
      state = const AsyncData(null);
    }
    return added;
  }

  Future<bool> removeMember({
    required String groupId,
    required String userId,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(groupRepositoryProvider).removeMemberWithNotification(
            organizationId: AppConfig.defaultOrganizationId,
            groupId: groupId,
            userId: userId,
          );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> updateRole({
    required String groupId,
    required String userId,
    required GroupRole groupRole,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(groupRepositoryProvider).updateMemberRole(
            organizationId: AppConfig.defaultOrganizationId,
            groupId: groupId,
            userId: userId,
            groupRole: groupRole,
          );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> updatePosition({
    required String groupId,
    required String userId,
    String? positionRoleId,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(groupRepositoryProvider).updateMemberPosition(
            organizationId: AppConfig.defaultOrganizationId,
            groupId: groupId,
            userId: userId,
            positionRoleId: positionRoleId,
          );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final groupMemberActionsProvider =
    NotifierProvider<GroupMemberActionsNotifier, AsyncValue<void>>(
  GroupMemberActionsNotifier.new,
);

// ── One-time demo seed (MONHS walkthrough) ───────────────────────────────────

/// Idempotent seed for SPJ, Drum and Lyre Corps, and SSLG — same data as
/// `scripts/seed_groups.js`, runnable from the app without Admin SDK keys.
class SeedDemoGroups extends Notifier<AsyncValue<void>> {
  static const _demoGroups = [
    (
      id: 'spj',
      name: 'Special Program in Journalism (SPJ)',
      description:
          'Students participating in the Special Program in Journalism. '
          'This is a program cohort group.',
    ),
    (
      id: 'drum-and-lyre-corps',
      name: 'Drum and Lyre Corps',
      description: 'Marching drum and lyre ensemble.',
    ),
    (
      id: 'sslg',
      name: 'Supreme Secondary Learner Government (SSLG)',
      description:
          'Student government organization representing the secondary student body.',
    ),
  ];

  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> seed() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncLoading();
    try {
      final groupsRef = FirebaseFirestore.instance
          .collection(AppConstants.organizationsCollection)
          .doc(AppConfig.defaultOrganizationId)
          .collection(AppConstants.groupsCollection);
      final now = FieldValue.serverTimestamp();
      final orgId = AppConfig.defaultOrganizationId;

      for (final group in _demoGroups) {
        final docRef = groupsRef.doc(group.id);
        final snap = await docRef.get();

        final payload = <String, dynamic>{
          'groupId': group.id,
          'organizationId': orgId,
          'name': group.name,
          'description': group.description,
          'isActive': true,
          'createdBy': user.uid,
          'updatedAt': now,
        };

        if (group.id == 'sslg') {
          payload['positionRoles'] = SslgDefaultPositionRoles.toFirestoreMaps();
        }

        if (!snap.exists) {
          payload['memberCount'] = 0;
          payload['createdAt'] = now;
          await docRef.set(payload);
        } else {
          await docRef.set(payload, SetOptions(merge: true));
        }
      }

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final seedDemoGroupsProvider =
    NotifierProvider<SeedDemoGroups, AsyncValue<void>>(SeedDemoGroups.new);

/// Repairs per-user groupMembership indexes so members can see My Groups.
class BackfillGroupMembershipIndexes extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<int> run() async {
    state = const AsyncLoading();
    try {
      final count = await ref
          .read(groupRepositoryProvider)
          .backfillGroupMembershipIndexes(
            organizationId: AppConfig.defaultOrganizationId,
          );
      state = const AsyncData(null);
      return count;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final backfillGroupMembershipIndexesProvider =
    NotifierProvider<BackfillGroupMembershipIndexes, AsyncValue<void>>(
  BackfillGroupMembershipIndexes.new,
);
