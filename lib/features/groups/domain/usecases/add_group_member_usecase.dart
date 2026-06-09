import 'package:speakup_connect/features/groups/domain/entities/group_member_entity.dart';
import 'package:speakup_connect/features/groups/domain/repositories/group_repository.dart';

class AddGroupMemberUseCase {
  const AddGroupMemberUseCase(this._repository);

  final GroupRepository _repository;

  Future<void> call({
    required String organizationId,
    required String groupId,
    required String userId,
    required String displayName,
    required String addedBy,
    GroupRole groupRole = GroupRole.member,
    String? positionRoleId,
  }) {
    return _repository.addGroupMember(
      organizationId: organizationId,
      groupId: groupId,
      userId: userId,
      displayName: displayName,
      addedBy: addedBy,
      groupRole: groupRole,
      positionRoleId: positionRoleId,
    );
  }
}
