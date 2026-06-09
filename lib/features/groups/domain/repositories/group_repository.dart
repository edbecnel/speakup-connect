import 'package:speakup_connect/features/groups/domain/entities/group_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_member_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_position_role.dart';

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
}
