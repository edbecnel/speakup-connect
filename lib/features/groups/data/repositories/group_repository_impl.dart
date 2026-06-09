import 'package:speakup_connect/features/groups/data/datasources/group_remote_datasource.dart';

import 'package:speakup_connect/features/groups/data/models/group_member_model.dart';

import 'package:speakup_connect/features/groups/data/models/group_model.dart';

import 'package:speakup_connect/features/groups/data/models/user_group_membership_index_model.dart';

import 'package:speakup_connect/features/groups/domain/entities/group_entity.dart';

import 'package:speakup_connect/features/groups/domain/entities/group_member_entity.dart';

import 'package:speakup_connect/features/groups/domain/entities/group_position_role.dart';

import 'package:speakup_connect/features/groups/domain/entities/my_group_membership.dart';

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

    List<GroupPositionRole> positionRoles = const [],

  }) {

    return _remoteDataSource.createGroup(

      organizationId: organizationId,

      name: name,

      createdBy: createdBy,

      description: description,

      avatarUrl: avatarUrl,

      positionRoles: positionRoles,

    );

  }



  @override

  Future<void> updateGroupPositionRoles({

    required String organizationId,

    required String groupId,

    required List<GroupPositionRole> positionRoles,

  }) {

    return _remoteDataSource.updateGroupPositionRoles(

      organizationId: organizationId,

      groupId: groupId,

      positionRoles: positionRoles,

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

    return _watchIndexWithRepair(organizationId: organizationId, userId: userId)

        .asyncMap(

          (indexRows) => _groupsFromIndex(

            organizationId: organizationId,

            indexRows: indexRows,

          ),

        );

  }



  @override

  Stream<List<MyGroupMembership>> watchMyGroupMemberships({

    required String organizationId,

    required String userId,

  }) {

    return _watchIndexWithRepair(organizationId: organizationId, userId: userId)

        .asyncMap(

          (indexRows) => _myGroupMembershipsFromIndex(

            organizationId: organizationId,

            userId: userId,

            indexRows: indexRows,

          ),

        );

  }



  /// Watches the per-user index; syncs from rosters once per stream attach.
  ///
  /// Repair runs even when some indexes exist (e.g. Journalism) but others
  /// (e.g. SSLG) are missing after roster changes.
  Stream<List<UserGroupMembershipIndexModel>> _watchIndexWithRepair({
    required String organizationId,
    required String userId,
  }) {
    var repairAttempted = false;

    return _remoteDataSource
        .watchUserGroupMembershipIndex(
          organizationId: organizationId,
          userId: userId,
        )
        .asyncMap((rows) async {
      if (repairAttempted) return rows;

      repairAttempted = true;
      try {
        await _remoteDataSource.syncMyGroupMembershipIndexForUser(
          organizationId: organizationId,
          userId: userId,
        );
        return _remoteDataSource.getUserGroupMembershipIndex(
          organizationId: organizationId,
          userId: userId,
        );
      } catch (_) {
        return rows;
      }
    });
  }



  Future<List<GroupEntity>> _groupsFromIndex({

    required String organizationId,

    required List<UserGroupMembershipIndexModel> indexRows,

  }) async {

    if (indexRows.isEmpty) return const <GroupEntity>[];



    final groupIds =

        indexRows.map((r) => r.groupId).toSet().toList(growable: false);

    final groups = await _remoteDataSource.getGroupsByIds(

      organizationId: organizationId,

      groupIds: groupIds,

    );

    final groupsById = {for (final g in groups) g.groupId: g};



    return indexRows

        .map((row) {

          final group = groupsById[row.groupId];

          if (group != null) return group;

          return GroupModel(

            groupId: row.groupId,

            organizationId: organizationId,

            name: row.groupName,

            isActive: true,

            memberCount: 0,

            createdBy: '',

            createdAt: DateTime.now(),

            updatedAt: DateTime.now(),

          );

        })

        .where((g) => g.isActive)

        .toList()

      ..sort((a, b) => a.name.compareTo(b.name));

  }



  Future<List<MyGroupMembership>> _myGroupMembershipsFromIndex({

    required String organizationId,

    required String userId,

    required List<UserGroupMembershipIndexModel> indexRows,

  }) async {

    if (indexRows.isEmpty) return const <MyGroupMembership>[];



    final groupIds =

        indexRows.map((r) => r.groupId).toSet().toList(growable: false);

    final groups = await _remoteDataSource.getGroupsByIds(

      organizationId: organizationId,

      groupIds: groupIds,

    );

    final groupsById = {for (final g in groups) g.groupId: g};



    final entries = <MyGroupMembership>[];

    for (final indexRow in indexRows) {

      final group = groupsById[indexRow.groupId] ??

          GroupModel(

            groupId: indexRow.groupId,

            organizationId: organizationId,

            name: indexRow.groupName,

            isActive: true,

            memberCount: 0,

            createdBy: '',

            createdAt: DateTime.now(),

            updatedAt: DateTime.now(),

          );

      if (!group.isActive) continue;



      final membership = GroupMemberModel(

        userId: userId,

        organizationId: organizationId,

        groupId: indexRow.groupId,

        displayName: '',

        groupRole: indexRow.groupRole,

        positionRoleId: indexRow.positionRoleId,

        joinedAt: DateTime.now(),

        addedBy: '',

      );

      entries.add(MyGroupMembership(group: group, membership: membership));

    }



    entries.sort((a, b) => a.group.name.compareTo(b.group.name));

    return entries;

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

    String? positionRoleId,

  }) {

    return _remoteDataSource.addGroupMember(

      organizationId: organizationId,

      groupId: groupId,

      userId: userId,

      displayName: displayName,

      addedBy: addedBy,

      groupRole: groupRole,

      positionRoleId: positionRoleId,

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



  @override

  Future<void> updateMemberPosition({

    required String organizationId,

    required String groupId,

    required String userId,

    String? positionRoleId,

  }) {

    return _remoteDataSource.updateMemberPosition(

      organizationId: organizationId,

      groupId: groupId,

      userId: userId,

      positionRoleId: positionRoleId,

    );

  }



  @override

  Future<int> backfillGroupMembershipIndexes({

    required String organizationId,

  }) {

    return _remoteDataSource.backfillGroupMembershipIndexes(

      organizationId: organizationId,

    );

  }

}


