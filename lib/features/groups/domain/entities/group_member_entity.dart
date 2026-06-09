/// Domain entity for a user's membership in a group.
///
/// Stored in Firestore at:
///   `organizations/{orgId}/groups/{groupId}/members/{userId}`
class GroupMemberEntity {
  const GroupMemberEntity({
    required this.userId,
    required this.organizationId,
    required this.groupId,
    required this.displayName,
    required this.groupRole,
    required this.joinedAt,
    required this.addedBy,
    this.positionRoleId,
  });

  final String userId;
  final String organizationId;
  final String groupId;
  final String displayName;
  final GroupRole groupRole;
  final DateTime joinedAt;

  /// UID of the admin or leader who added this member.
  final String addedBy;

  /// References [GroupEntity.positionRoles] when the group defines offices.
  final String? positionRoleId;

  bool get isLeader => groupRole == GroupRole.leader;
}

/// Role within a single group (distinct from org-wide RBAC roles).
enum GroupRole {
  leader('leader', 'Leader'),
  member('member', 'Member');

  const GroupRole(this.value, this.label);

  final String value;
  final String label;

  static GroupRole fromValue(String value) {
    return GroupRole.values.firstWhere(
      (r) => r.value == value,
      orElse: () => GroupRole.member,
    );
  }
}
