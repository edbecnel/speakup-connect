import 'package:speakup_connect/features/groups/domain/entities/group_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_join_request_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_leave_request_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_member_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_membership_policy.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_position_role.dart';
import 'package:speakup_connect/features/groups/domain/entities/my_group_membership.dart';

/// Abstract repository for org groups and their member rosters.
abstract class GroupRepository {
  /// Creates a new group document with [memberCount] initialized to 0.
  Future<GroupEntity> createGroup({
    required String organizationId,
    required String name,
    required String createdBy,
    String? description,
    String? avatarUrl,
    List<GroupPositionRole> positionRoles = const [],
    bool allowJoinRequests = false,
    String? joinRequestHint,
    MemberLeavePolicy memberLeavePolicy = MemberLeavePolicy.requestRequired,
  });

  /// Updates editable group settings (not the member roster).
  Future<void> updateGroup({
    required String organizationId,
    required String groupId,
    required String name,
    String? description,
    List<GroupPositionRole>? positionRoles,
    bool? allowJoinRequests,
    MemberLeavePolicy? memberLeavePolicy,
    String? joinRequestHint,
    bool? isActive,
  });

  Future<void> updateGroupMembershipPolicies({
    required String organizationId,
    required String groupId,
    required bool allowJoinRequests,
    required MemberLeavePolicy memberLeavePolicy,
    String? joinRequestHint,
  });

  /// Replaces the group's customizable position roles (club offices).
  Future<void> updateGroupPositionRoles({
    required String organizationId,
    required String groupId,
    required List<GroupPositionRole> positionRoles,
  });

  /// Streams all active groups in the organization, sorted by name.
  Stream<List<GroupEntity>> watchOrgGroups(String organizationId);

  /// Streams groups the [userId] belongs to within [organizationId].
  Stream<List<GroupEntity>> watchMyGroups({
    required String organizationId,
    required String userId,
  });

  /// Streams group memberships for [userId] with group details for display.
  Stream<List<MyGroupMembership>> watchMyGroupMemberships({
    required String organizationId,
    required String userId,
  });

  /// Fetches a single group by ID. Returns null when not found.
  Future<GroupEntity?> getGroup({
    required String organizationId,
    required String groupId,
  });

  /// Streams the member roster for a group, leaders first then by name.
  Stream<List<GroupMemberEntity>> watchGroupMembers({
    required String organizationId,
    required String groupId,
  });

  /// Live roster row for the signed-in user in one group.
  Stream<GroupMemberEntity?> watchMyGroupMember({
    required String organizationId,
    required String groupId,
    required String userId,
  });

  /// Adds [userId] to the group roster and increments [memberCount].
  Future<void> addGroupMember({
    required String organizationId,
    required String groupId,
    required String userId,
    required String displayName,
    required String addedBy,
    GroupRole groupRole = GroupRole.member,
    String? positionRoleId,
  });

  /// Removes [userId] from the roster and decrements [memberCount].
  Future<void> removeGroupMember({
    required String organizationId,
    required String groupId,
    required String userId,
  });

  /// Updates a member's [groupRole] within the group.
  Future<void> updateMemberRole({
    required String organizationId,
    required String groupId,
    required String userId,
    required GroupRole groupRole,
  });

  Future<void> updateMemberPosition({
    required String organizationId,
    required String groupId,
    required String userId,
    String? positionRoleId,
  });

  /// Repairs per-user groupMemberships indexes from roster data (admin only).
  Future<int> backfillGroupMembershipIndexes({
    required String organizationId,
  });

  Stream<List<GroupJoinRequestEntity>> watchPendingJoinRequests({
    required String organizationId,
    required String groupId,
  });

  Stream<List<GroupLeaveRequestEntity>> watchPendingLeaveRequests({
    required String organizationId,
    required String groupId,
  });

  Stream<GroupJoinRequestEntity?> watchMyJoinRequest({
    required String organizationId,
    required String groupId,
    required String userId,
  });

  Stream<GroupLeaveRequestEntity?> watchMyLeaveRequest({
    required String organizationId,
    required String groupId,
    required String userId,
  });

  Future<void> submitJoinRequest({
    required String organizationId,
    required String groupId,
    String? message,
  });

  Future<void> withdrawJoinRequest({
    required String organizationId,
    required String groupId,
  });

  Future<void> reviewJoinRequest({
    required String organizationId,
    required String groupId,
    required String userId,
    required bool approve,
    String? rejectionReason,
  });

  Future<void> voluntaryLeave({
    required String organizationId,
    required String groupId,
  });

  Future<void> submitLeaveRequest({
    required String organizationId,
    required String groupId,
    required String reason,
  });

  Future<void> withdrawLeaveRequest({
    required String organizationId,
    required String groupId,
  });

  Future<void> reviewLeaveRequest({
    required String organizationId,
    required String groupId,
    required String userId,
    required bool approve,
    String? rejectionReason,
  });

  Future<void> removeMemberWithNotification({
    required String organizationId,
    required String groupId,
    required String userId,
  });
}
