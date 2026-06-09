import 'package:speakup_connect/features/groups/domain/entities/group_member_entity.dart';

/// Denormalized membership row under
/// `organizations/{orgId}/users/{userId}/groupMemberships/{groupId}`.
class UserGroupMembershipIndexModel {
  const UserGroupMembershipIndexModel({
    required this.organizationId,
    required this.userId,
    required this.groupId,
    required this.groupName,
    required this.groupRole,
    this.positionRoleId,
  });

  final String organizationId;
  final String userId;
  final String groupId;
  final String groupName;
  final GroupRole groupRole;
  final String? positionRoleId;
}
