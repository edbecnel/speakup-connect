import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/groups/data/datasources/group_remote_datasource.dart';
import 'package:speakup_connect/features/groups/data/repositories/group_repository_impl.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_member_entity.dart';
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

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepositoryImpl(ref.watch(groupRemoteDataSourceProvider));
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
final approvedOrgUsersProvider =
    FutureProvider.autoDispose<List<UserProfileEntity>>((ref) async {
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

/// True when the user may create groups or manage rosters.
final canManageGroupsProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  if (profile?.isAdmin == true) return true;
  return ref.watch(hasPermissionProvider(AppPermission.manageGroupRoster));
});

// ── Actions ──────────────────────────────────────────────────────────────────

class CreateGroupNotifier extends Notifier<AsyncValue<GroupEntity?>> {
  @override
  AsyncValue<GroupEntity?> build() => const AsyncData(null);

  Future<GroupEntity?> submit({
    required String name,
    String? description,
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

class GroupMemberActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> addMember({
    required String groupId,
    required UserProfileEntity user,
    GroupRole groupRole = GroupRole.member,
  }) async {
    final added = await addMembers(
      groupId: groupId,
      users: [user],
      groupRole: groupRole,
    );
    return added > 0;
  }

  /// Adds [users] to the group roster. Returns how many were added successfully.
  Future<int> addMembers({
    required String groupId,
    required List<UserProfileEntity> users,
    GroupRole groupRole = GroupRole.member,
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
      await ref.read(groupRepositoryProvider).removeGroupMember(
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
}

final groupMemberActionsProvider =
    NotifierProvider<GroupMemberActionsNotifier, AsyncValue<void>>(
  GroupMemberActionsNotifier.new,
);
