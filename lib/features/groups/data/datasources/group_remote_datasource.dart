import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';
import 'package:speakup_connect/features/groups/data/models/group_member_model.dart';
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
      await _groupDoc(organizationId, groupId).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e, 'Failed to update member position');
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
