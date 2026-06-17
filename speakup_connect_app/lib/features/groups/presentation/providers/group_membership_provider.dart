import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_join_request_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_leave_request_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_membership_policy.dart';
import 'package:speakup_connect/features/groups/domain/entities/my_group_membership.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';

/// Whether the user may review join/leave requests for [groupId].
final canReviewGroupMembershipRequestsProvider =
    Provider.autoDispose.family<bool, String>((ref, groupId) {
  return ref.watch(canManageGroupRosterProvider(groupId));
});

final pendingJoinRequestsProvider = StreamProvider.autoDispose
    .family<List<GroupJoinRequestEntity>, String>((ref, groupId) {
  return ref.watch(groupRepositoryProvider).watchPendingJoinRequests(
        organizationId: AppConfig.defaultOrganizationId,
        groupId: groupId,
      );
});

final pendingLeaveRequestsProvider = StreamProvider.autoDispose
    .family<List<GroupLeaveRequestEntity>, String>((ref, groupId) {
  return ref.watch(groupRepositoryProvider).watchPendingLeaveRequests(
        organizationId: AppConfig.defaultOrganizationId,
        groupId: groupId,
      );
});

final myJoinRequestForGroupProvider = StreamProvider.autoDispose
    .family<GroupJoinRequestEntity?, String>((ref, groupId) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(groupRepositoryProvider).watchMyJoinRequest(
        organizationId: AppConfig.defaultOrganizationId,
        groupId: groupId,
        userId: user.uid,
      );
});

final myLeaveRequestForGroupProvider = StreamProvider.autoDispose
    .family<GroupLeaveRequestEntity?, String>((ref, groupId) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(groupRepositoryProvider).watchMyLeaveRequest(
        organizationId: AppConfig.defaultOrganizationId,
        groupId: groupId,
        userId: user.uid,
      );
});

/// Membership status for browse list rows.
enum GroupBrowseStatus {
  member,
  joinPending,
  canRequestJoin,
  invitationOnly,
}

/// Combines org groups with the signed-in user's membership and join requests.
final groupBrowseEntriesProvider =
    Provider.autoDispose<AsyncValue<List<GroupBrowseEntry>>>((ref) {
  final groupsAsync = ref.watch(orgGroupsProvider);
  final membershipsAsync = ref.watch(myGroupMembershipsProvider);

  if (groupsAsync.isLoading || membershipsAsync.isLoading) {
    return const AsyncLoading();
  }
  if (groupsAsync.hasError) {
    return AsyncError(groupsAsync.error!, groupsAsync.stackTrace!);
  }
  if (membershipsAsync.hasError) {
    return AsyncError(membershipsAsync.error!, membershipsAsync.stackTrace!);
  }

  final groups = groupsAsync.requireValue;
  final memberships = membershipsAsync.requireValue;
  final memberIds = memberships.map((m) => m.group.groupId).toSet();

  final entries = groups.map((group) {
    final isMember = memberIds.contains(group.groupId);
    GroupBrowseStatus status;
    if (isMember) {
      status = GroupBrowseStatus.member;
    } else {
      final joinReq =
          ref.watch(myJoinRequestForGroupProvider(group.groupId)).asData?.value;
      if (joinReq?.status.isPending == true) {
        status = GroupBrowseStatus.joinPending;
      } else if (group.allowJoinRequests) {
        status = GroupBrowseStatus.canRequestJoin;
      } else {
        status = GroupBrowseStatus.invitationOnly;
      }
    }
    return GroupBrowseEntry(group: group, status: status);
  }).toList();

  return AsyncData(entries);
});

class GroupBrowseEntry {
  const GroupBrowseEntry({required this.group, required this.status});

  final GroupEntity group;
  final GroupBrowseStatus status;
}

/// True when user can edit membership policies for [groupId].
final canEditGroupMembershipPoliciesProvider =
    Provider.autoDispose.family<bool, String>((ref, groupId) {
  return ref.watch(canManageGroupRosterProvider(groupId));
});

/// Total pending requests across groups the user can review.
final myReviewablePendingMembershipCountProvider = Provider.autoDispose<int>((ref) {
  final canManageAll = ref.watch(canManageGroupsProvider);
  final led =
      ref.watch(ledGroupMembershipsProvider);

  var count = 0;
  Iterable<MyGroupMembership> sources;
  if (canManageAll) {
    final groups = ref.watch(orgGroupsProvider).asData?.value ?? const [];
    for (final group in groups) {
      count += group.pendingJoinRequestCount + group.pendingLeaveRequestCount;
    }
    return count;
  }

  sources = led;
  for (final entry in sources) {
    final group = entry.group;
    count += group.pendingJoinRequestCount + group.pendingLeaveRequestCount;
  }
  return count;
});

class GroupMembershipActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// Human-readable message from the most recent failed membership action.
  String? get lastErrorMessage {
    final err = state.error;
    if (err is AppException) return err.message;
    return err?.toString();
  }

  Future<bool> submitJoinRequest({
    required String groupId,
    String? message,
  }) =>
      _run(() => ref.read(groupRepositoryProvider).submitJoinRequest(
            organizationId: AppConfig.defaultOrganizationId,
            groupId: groupId,
            message: message,
          ));

  Future<bool> withdrawJoinRequest({required String groupId}) =>
      _run(() => ref.read(groupRepositoryProvider).withdrawJoinRequest(
            organizationId: AppConfig.defaultOrganizationId,
            groupId: groupId,
          ));

  Future<bool> reviewJoinRequest({
    required String groupId,
    required String userId,
    required bool approve,
    String? rejectionReason,
  }) =>
      _run(() => ref.read(groupRepositoryProvider).reviewJoinRequest(
            organizationId: AppConfig.defaultOrganizationId,
            groupId: groupId,
            userId: userId,
            approve: approve,
            rejectionReason: rejectionReason,
          ));

  Future<bool> voluntaryLeave({required String groupId}) =>
      _run(() => ref.read(groupRepositoryProvider).voluntaryLeave(
            organizationId: AppConfig.defaultOrganizationId,
            groupId: groupId,
          ));

  Future<bool> submitLeaveRequest({
    required String groupId,
    required String reason,
  }) =>
      _run(() => ref.read(groupRepositoryProvider).submitLeaveRequest(
            organizationId: AppConfig.defaultOrganizationId,
            groupId: groupId,
            reason: reason,
          ));

  Future<bool> withdrawLeaveRequest({required String groupId}) =>
      _run(() => ref.read(groupRepositoryProvider).withdrawLeaveRequest(
            organizationId: AppConfig.defaultOrganizationId,
            groupId: groupId,
          ));

  Future<bool> reviewLeaveRequest({
    required String groupId,
    required String userId,
    required bool approve,
    String? rejectionReason,
  }) =>
      _run(() => ref.read(groupRepositoryProvider).reviewLeaveRequest(
            organizationId: AppConfig.defaultOrganizationId,
            groupId: groupId,
            userId: userId,
            approve: approve,
            rejectionReason: rejectionReason,
          ));

  Future<bool> updatePolicies({
    required String groupId,
    required bool allowJoinRequests,
    required MemberLeavePolicy memberLeavePolicy,
    String? joinRequestHint,
  }) =>
      _run(() => ref.read(groupRepositoryProvider).updateGroupMembershipPolicies(
            organizationId: AppConfig.defaultOrganizationId,
            groupId: groupId,
            allowJoinRequests: allowJoinRequests,
            memberLeavePolicy: memberLeavePolicy,
            joinRequestHint: joinRequestHint,
          ));
}

final groupMembershipActionsProvider =
    NotifierProvider<GroupMembershipActionsNotifier, AsyncValue<void>>(
  GroupMembershipActionsNotifier.new,
);
