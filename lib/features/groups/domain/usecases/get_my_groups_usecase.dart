import 'package:speakup_connect/features/groups/domain/entities/group_entity.dart';
import 'package:speakup_connect/features/groups/domain/repositories/group_repository.dart';

class GetMyGroupsUseCase {
  const GetMyGroupsUseCase(this._repository);

  final GroupRepository _repository;

  Stream<List<GroupEntity>> call({
    required String organizationId,
    required String userId,
  }) {
    return _repository.watchMyGroups(
      organizationId: organizationId,
      userId: userId,
    );
  }
}
