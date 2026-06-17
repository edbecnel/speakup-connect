import 'package:speakup_connect/features/groups/domain/entities/group_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_membership_policy.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_position_role.dart';
import 'package:speakup_connect/features/groups/domain/repositories/group_repository.dart';

class CreateGroupUseCase {
  const CreateGroupUseCase(this._repository);

  final GroupRepository _repository;

  Future<GroupEntity> call({
    required String organizationId,
    required String name,
    required String createdBy,
    String? description,
    String? avatarUrl,
    List<GroupPositionRole> positionRoles = const [],
    bool allowJoinRequests = false,
    String? joinRequestHint,
    MemberLeavePolicy memberLeavePolicy = MemberLeavePolicy.requestRequired,
  }) {
    return _repository.createGroup(
      organizationId: organizationId,
      name: name,
      createdBy: createdBy,
      description: description,
      avatarUrl: avatarUrl,
      positionRoles: positionRoles,
      allowJoinRequests: allowJoinRequests,
      joinRequestHint: joinRequestHint,
      memberLeavePolicy: memberLeavePolicy,
    );
  }
}
