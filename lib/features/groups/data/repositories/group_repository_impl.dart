import 'package:speakup_connect/features/groups/data/datasources/group_remote_datasource.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_member_entity.dart';
import 'package:speakup_connect/features/groups/domain/repositories/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  GroupRepositoryImpl(this._remoteDataSource);

  final GroupRemoteDataSource _remoteDataSource;

  @override
  Future<GroupEntity> createGroup({
    required String organizationId,
    required String name,
    required String createdBy,
    String? description,
    String? avatarUrl,
  }) {
    return _remoteDataSource.createGroup(
      organizationId: organizationId,
      name: name,
      createdBy: createdBy,
      description: description,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Stream<List<GroupEntity>> watchOrgGroups(String organizationId) {
    return _remoteDataSource.watchOrgGroups(organizationId);
  }

  @override
  Stream<List<GroupEntity>> watchMyGroups({
    required String organizationId,
    required String userId,
  }) {
    return _remoteDataSource
        .watchMembershipsForUser(
          organizationId: organizationId,
          userId: userId,
        )
        .asyncMap((memberships) async {
      final groupIds =
          memberships.map((m) => m.groupId).toSet().toList(growable: false);
      return _remoteDataSource.getGroupsByIds(
        organizationId: organizationId,
        groupIds: groupIds,
      );
    });
  }

  @override
  Future<GroupEntity?> getGroup({
    required String organizationId,
    required String groupId,
  }) {
    return _remoteDataSource.getGroup(
      organizationId: organizationId,
      groupId: groupId,
    );
  }

  @override
  Stream<List<GroupMemberEntity>> watchGroupMembers({
    required String organizationId,
    required String groupId,
  }) {
    return _remoteDataSource.watchGroupMembers(
      organizationId: organizationId,
      groupId: groupId,
    );
  }

  @override
  Future<void> addGroupMember({
    required String organizationId,
    required String groupId,
    required String userId,
    required String displayName,
    required String addedBy,
    GroupRole groupRole = GroupRole.member,
  }) {
    return _remoteDataSource.addGroupMember(
      organizationId: organizationId,
      groupId: groupId,
      userId: userId,
      displayName: displayName,
      addedBy: addedBy,
      groupRole: groupRole,
    );
  }

  @override
  Future<void> removeGroupMember({
    required String organizationId,
    required String groupId,
    required String userId,
  }) {
    return _remoteDataSource.removeGroupMember(
      organizationId: organizationId,
      groupId: groupId,
      userId: userId,
    );
  }

  @override
  Future<void> updateMemberRole({
    required String organizationId,
    required String groupId,
    required String userId,
    required GroupRole groupRole,
  }) {
    return _remoteDataSource.updateMemberRole(
      organizationId: organizationId,
      groupId: groupId,
      userId: userId,
      groupRole: groupRole,
    );
  }
}
