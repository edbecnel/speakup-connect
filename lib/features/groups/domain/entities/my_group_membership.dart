import 'package:speakup_connect/features/groups/domain/entities/group_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_member_entity.dart';

/// A user's membership in a group, with the group document attached for display.
class MyGroupMembership {
  const MyGroupMembership({
    required this.group,
    required this.membership,
  });

  final GroupEntity group;
  final GroupMemberEntity membership;

  String? positionLabel() => group.positionLabel(membership.positionRoleId);
}
