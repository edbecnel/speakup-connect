import 'package:speakup_connect/features/groups/domain/entities/group_entity.dart';
import 'package:speakup_connect/features/groups/domain/repositories/group_repository.dart';

class GetGroupsUseCase {
  const GetGroupsUseCase(this._repository);

  final GroupRepository _repository;

  Stream<List<GroupEntity>> call(String organizationId) {
    return _repository.watchOrgGroups(organizationId);
  }
}
