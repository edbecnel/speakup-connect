import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';
import 'package:speakup_connect/features/groups/data/models/group_member_model.dart';
import 'package:speakup_connect/features/groups/data/models/user_group_membership_index_model.dart';
import 'package:speakup_connect/features/groups/data/models/group_model.dart';
import 'package:speakup_connect/features/groups/data/models/group_position_role_codec.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_member_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_position_role.dart';
import 'package:uuid/uuid.dart';

/// Low-level Firestore access for groups and member rosters.
class GroupRemoteDataSource {
  GroupRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _groupsRef(String orgId) =>
      _firestore
          .collection(AppConstants.organizationsCollection)
          .doc(orgId)
          .collection(AppConstants.groupsCollection);

  DocumentReference<Map<String, dynamic>> _groupDoc(
    String orgId,
    String groupId,
  ) =>
      _groupsRef(orgId).doc(groupId);

  CollectionReference<Map<String, dynamic>> _membersRef(
    String orgId,
    String groupId,
  ) =>
      _groupDoc(orgId, groupId)
          .collection(AppConstants.groupMembersCollection);

  DocumentReference<Map<String, dynamic>> _userGroupMembershipDoc(
    String orgId,
    String userId,
    String groupId,
  ) =>
      _firestore
          .collection(AppConstants.organizationsCollection)
          .doc(orgId)
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.userGroupMembershipsCollection)
          .doc(groupId);

  Map<String, dynamic> _userGroupMembershipIndexJson({
    required String organizationId,
    required String groupId,
    required String groupName,
    required GroupRole groupRole,
    String? positionRoleId,
  }) {
    return {
      'organizationId': organizationId,
      'groupId': groupId,
      'groupName': groupName,
      'groupRole': groupRole.value,
      if (positionRoleId != null) 'positionRoleId': positionRoleId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Future<GroupModel> createGroup({
    required String organizationId,
    required String name,
    required String createdBy,
    String? description,
    String? avatarUrl,
    List<GroupPositionRole> positionRoles = const [],
  }) async {
    try {
      final groupId = const Uuid().v4();
      final model = GroupModel(
        groupId: groupId,
        organizationId: organizationId,
        name: name,
        description: description,
        avatarUrl: avatarUrl,
        positionRoles: positionRoles,
        isActive: true,
        memberCount: 0,
        createdBy: createdBy,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _groupDoc(organizationId, groupId).set(model.toCreateJson());
      return model;
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e, 'Failed to create group');
    }
  }

  Stream<List<GroupModel>> watchOrgGroups(String organizationId) {
    return _groupsRef(organizationId)
        .where(AppConstants.fieldIsActive, isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => GroupModel.fromFirestore(d.data(), d.id))
              .toList(),
        );
  }

  CollectionReference<Map<String, dynamic>> _userGroupMembershipsRef(
    String organizationId,
    String userId,
  ) =>
      _firestore
          .collection(AppConstants.organizationsCollection)
          .doc(organizationId)
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.userGroupMembershipsCollection);

  List<UserGroupMembershipIndexModel> _mapMembershipIndexRows({
    required String organizationId,
    required String userId,
    required Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  }) {
    return docs.map((doc) {
      final data = doc.data();
      return UserGroupMembershipIndexModel(
        organizationId: organizationId,
        userId: userId,
        groupId: doc.id,
        groupName: data['groupName'] as String? ?? 'Group',
        groupRole: GroupRole.fromValue(
          data['groupRole'] as String? ?? GroupRole.member.value,
        ),
        positionRoleId: data['positionRoleId'] as String?,
      );
    }).toList();
  }

  /// Per-user index readable by the member — powers "My Groups & Clubs".
  Stream<List<UserGroupMembershipIndexModel>> watchUserGroupMembershipIndex({
    required String organizationId,
    required String userId,
  }) {
    return _userGroupMembershipsRef(organizationId, userId).snapshots().map(
          (snap) => _mapMembershipIndexRows(
            organizationId: organizationId,
            userId: userId,
            docs: snap.docs,
          ),
        );
  }

  /// One-shot read of the per-user group membership index.
  Future<List<UserGroupMembershipIndexModel>> getUserGroupMembershipIndex({
    required String organizationId,
    required String userId,
  }) async {
    final snap = await _userGroupMembershipsRef(organizationId, userId).get();
    return _mapMembershipIndexRows(
      organizationId: organizationId,
      userId: userId,
      docs: snap.docs,
    );
  }

  /// Server-side rebuild of the user's groupMemberships index (callable).
  Future<int> syncMyGroupMembershipIndexForUser({
    required String organizationId,
    required String userId,
  }) async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('syncMyGroupMemberships');
      final result = await callable.call<Map<String, dynamic>>({
        'orgId': organizationId,
      });
      return (result.data['synced'] as num?)?.toInt() ?? 0;
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') {
        throw const PermissionException();
      }
      throw DatabaseException(
        message: e.message ?? 'Failed to sync group memberships',
        code: e.code,
      );
    }
  }

  Stream<List<GroupMemberModel>> watchMembershipsForUser({
    required String organizationId,
    required String userId,
  }) {
    return _firestore
        .collectionGroup(AppConstants.groupMembersCollection)
        .where('userId', isEqualTo: userId)
        .where('organizationId', isEqualTo: organizationId)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) {
            final groupRef = d.reference.parent.parent;
            final groupId = groupRef?.id ?? '';
            return GroupMemberModel.fromFirestore(
              d.data(),
              d.id,
              groupId: groupId,
              organizationId: organizationId,
            );
          }).toList(),
        );
  }

  Future<GroupModel?> getGroup({
    required String organizationId,
    required String groupId,
  }) async {
    try {
      final doc = await _groupDoc(organizationId, groupId).get();
      if (!doc.exists || doc.data() == null) return null;
      return GroupModel.fromFirestore(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e, 'Failed to load group');
    }
  }

  Future<List<GroupModel>> getGroupsByIds({
    required String organizationId,
    required List<String> groupIds,
  }) async {
    if (groupIds.isEmpty) return const [];

    try {
      final docs = await Future.wait(
        groupIds.map((id) => _groupDoc(organizationId, id).get()),
      );
      final groups = docs
          .where((doc) => doc.exists && doc.data() != null)
          .map((doc) => GroupModel.fromFirestore(doc.data()!, doc.id))
          .where((group) => group.isActive)
          .toList();
      groups.sort((a, b) => a.name.compareTo(b.name));
      return groups;
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e, 'Failed to load groups');
    }
  }

  Stream<List<GroupMemberModel>> watchGroupMembers({
    required String organizationId,
    required String groupId,
  }) {
    return _membersRef(organizationId, groupId)
        .orderBy('displayName')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) => GroupMemberModel.fromFirestore(
                  d.data(),
                  d.id,
                  groupId: groupId,
                  organizationId: organizationId,
                ),
              )
              .toList()
            ..sort((a, b) {
              if (a.isLeader != b.isLeader) return a.isLeader ? -1 : 1;
              return a.displayName.compareTo(b.displayName);
            }),
        );
  }

  Future<void> updateGroupPositionRoles({
    required String organizationId,
    required String groupId,
    required List<GroupPositionRole> positionRoles,
  }) async {
    try {
      await _groupDoc(organizationId, groupId).update({
        'positionRoles': GroupPositionRoleCodec.toList(positionRoles),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e, 'Failed to update group roles');
    }
  }

  Future<void> addGroupMember({
    required String organizationId,
    required String groupId,
    required String userId,
    required String displayName,
    required String addedBy,
    GroupRole groupRole = GroupRole.member,
    String? positionRoleId,
  }) async {
    try {
      final groupRef = _groupDoc(organizationId, groupId);
      final memberRef = _membersRef(organizationId, groupId).doc(userId);

      await _firestore.runTransaction((tx) async {
        final groupSnap = await tx.get(groupRef);
        if (!groupSnap.exists) {
          throw const DatabaseException(message: 'Group not found');
        }

        final memberSnap = await tx.get(memberRef);
        if (memberSnap.exists) {
          throw const DatabaseException(
            message: 'User is already a member of this group',
          );
        }

        final groupData = groupSnap.data() ?? {};
        final groupName = groupData['name'] as String? ?? 'Group';

        final member = GroupMemberModel(
          userId: userId,
          organizationId: organizationId,
          groupId: groupId,
          displayName: displayName,
          groupRole: groupRole,
          positionRoleId: positionRoleId,
          joinedAt: DateTime.now(),
          addedBy: addedBy,
        );

        tx.set(memberRef, member.toCreateJson());
        tx.set(
          _userGroupMembershipDoc(organizationId, userId, groupId),
          _userGroupMembershipIndexJson(
            organizationId: organizationId,
            groupId: groupId,
            groupName: groupName,
            groupRole: groupRole,
            positionRoleId: positionRoleId,
          ),
          SetOptions(merge: true),
        );
        tx.update(groupRef, {
          'memberCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e, 'Failed to add group member');
    }
  }

  Future<void> removeGroupMember({
    required String organizationId,
    required String groupId,
    required String userId,
  }) async {
    try {
      final groupRef = _groupDoc(organizationId, groupId);
      final memberRef = _membersRef(organizationId, groupId).doc(userId);

      await _firestore.runTransaction((tx) async {
        final memberSnap = await tx.get(memberRef);
        if (!memberSnap.exists) return;

        tx.delete(memberRef);
        tx.delete(_userGroupMembershipDoc(organizationId, userId, groupId));
        tx.update(groupRef, {
          'memberCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e, 'Failed to remove group member');
    }
  }

  Future<void> updateMemberRole({
    required String organizationId,
    required String groupId,
    required String userId,
    required GroupRole groupRole,
  }) async {
    try {
      await _membersRef(organizationId, groupId).doc(userId).update({
        'groupRole': groupRole.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _userGroupMembershipDoc(organizationId, userId, groupId).set(
        {'groupRole': groupRole.value, 'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
      await _groupDoc(organizationId, groupId).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e, 'Failed to update member role');
    }
  }

  Future<void> updateMemberPosition({
    required String organizationId,
    required String groupId,
    required String userId,
    String? positionRoleId,
  }) async {
    try {
      final update = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (positionRoleId == null) {
        update['positionRoleId'] = FieldValue.delete();
      } else {
        update['positionRoleId'] = positionRoleId;
      }
      await _membersRef(organizationId, groupId).doc(userId).update(update);

      final indexUpdate = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (positionRoleId == null) {
        indexUpdate['positionRoleId'] = FieldValue.delete();
      } else {
        indexUpdate['positionRoleId'] = positionRoleId;
      }
      await _userGroupMembershipDoc(organizationId, userId, groupId)
          .set(indexUpdate, SetOptions(merge: true));

      await _groupDoc(organizationId, groupId).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e, 'Failed to update member position');
    }
  }

  /// Repairs per-user groupMemberships indexes from roster data (admin only).
  Future<int> backfillGroupMembershipIndexes({
    required String organizationId,
  }) async {
    try {
      final groupsSnap = await _groupsRef(organizationId).get();
      var synced = 0;
      WriteBatch batch = _firestore.batch();
      var batchCount = 0;

      for (final groupDoc in groupsSnap.docs) {
        final groupData = groupDoc.data();
        final groupName = groupData['name'] as String? ?? 'Group';
        final membersSnap =
            await _membersRef(organizationId, groupDoc.id).get();

        for (final memberDoc in membersSnap.docs) {
          final memberData = memberDoc.data();
          final userId = memberDoc.id;
          final groupRole = GroupRole.fromValue(
            memberData['groupRole'] as String? ?? GroupRole.member.value,
          );
          final positionRoleId = memberData['positionRoleId'] as String?;

          batch.set(
            _userGroupMembershipDoc(organizationId, userId, groupDoc.id),
            _userGroupMembershipIndexJson(
              organizationId: organizationId,
              groupId: groupDoc.id,
              groupName: groupName,
              groupRole: groupRole,
              positionRoleId: positionRoleId,
            ),
            SetOptions(merge: true),
          );
          synced++;
          batchCount++;

          if (batchCount >= 400) {
            await batch.commit();
            batch = _firestore.batch();
            batchCount = 0;
          }
        }
      }

      if (batchCount > 0) {
        await batch.commit();
      }
      return synced;
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e, 'Failed to backfill group memberships');
    }
  }

  AppException _mapFirebaseException(FirebaseException e, String fallback) {
    if (e.code == 'permission-denied') return const PermissionException();
    return DatabaseException(
      message: e.message ?? fallback,
      code: e.code,
    );
  }
}
