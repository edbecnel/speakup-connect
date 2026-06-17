import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_member_entity.dart';

/// Firestore data model for a group membership document.
///
/// Document path: `organizations/{orgId}/groups/{groupId}/members/{userId}`
class GroupMemberModel extends GroupMemberEntity {
  const GroupMemberModel({
    required super.userId,
    required super.organizationId,
    required super.groupId,
    required super.displayName,
    required super.groupRole,
    required super.joinedAt,
    required super.addedBy,
    super.positionRoleId,
  });

  factory GroupMemberModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId, {
    required String groupId,
    required String organizationId,
  }) {
    DateTime? toDate(dynamic v) => v is Timestamp ? v.toDate() : null;

    return GroupMemberModel(
      userId: data['userId'] as String? ?? documentId,
      organizationId: data['organizationId'] as String? ?? organizationId,
      groupId: data['groupId'] as String? ?? groupId,
      displayName: data['displayName'] as String? ?? '',
      groupRole: GroupRole.fromValue(data['groupRole'] as String? ?? 'member'),
      joinedAt: toDate(data['joinedAt']) ?? DateTime.now(),
      addedBy: data['addedBy'] as String? ?? '',
      positionRoleId: data['positionRoleId'] as String?,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'userId': userId,
      'organizationId': organizationId,
      'groupId': groupId,
      'displayName': displayName,
      'groupRole': groupRole.value,
      if (positionRoleId != null) 'positionRoleId': positionRoleId,
      'joinedAt': FieldValue.serverTimestamp(),
      'addedBy': addedBy,
    };
  }
}
