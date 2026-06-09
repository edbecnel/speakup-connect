import 'package:speakup_connect/features/groups/domain/entities/group_entity.dart';
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
  }) {
    return _repository.createGroup(
      organizationId: organizationId,
      name: name,
      createdBy: createdBy,
      description: description,
      avatarUrl: avatarUrl,
    );
  }
}
