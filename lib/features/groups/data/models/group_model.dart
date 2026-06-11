import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakup_connect/features/groups/data/models/group_position_role_codec.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_membership_policy.dart';

/// Firestore data model for a group document.
///
/// Document path: `organizations/{orgId}/groups/{groupId}`
class GroupModel extends GroupEntity {
  const GroupModel({
    required super.groupId,
    required super.organizationId,
    required super.name,
    required super.isActive,
    required super.memberCount,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    super.description,
    super.avatarUrl,
    super.positionRoles = const [],
    super.allowJoinRequests = false,
    super.joinRequestHint,
    super.memberLeavePolicy = MemberLeavePolicy.requestRequired,
    super.pendingJoinRequestCount = 0,
    super.pendingLeaveRequestCount = 0,
  });

  factory GroupModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    DateTime? toDate(dynamic v) => v is Timestamp ? v.toDate() : null;

    return GroupModel(
      groupId: documentId,
      organizationId: data['organizationId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      memberCount: (data['memberCount'] as num?)?.toInt() ?? 0,
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: toDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: toDate(data['updatedAt']) ?? DateTime.now(),
      positionRoles:
          GroupPositionRoleCodec.fromList(data['positionRoles']),
      allowJoinRequests: data['allowJoinRequests'] as bool? ?? false,
      joinRequestHint: data['joinRequestHint'] as String?,
      memberLeavePolicy: MemberLeavePolicy.fromValue(
        data['memberLeavePolicy'] as String?,
      ),
      pendingJoinRequestCount:
          (data['pendingJoinRequestCount'] as num?)?.toInt() ?? 0,
      pendingLeaveRequestCount:
          (data['pendingLeaveRequestCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toCreateJson({
    bool allowJoinRequests = false,
    String? joinRequestHint,
    MemberLeavePolicy memberLeavePolicy = MemberLeavePolicy.requestRequired,
  }) {
    return {
      'groupId': groupId,
      'organizationId': organizationId,
      'name': name,
      if (description != null) 'description': description,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (positionRoles.isNotEmpty)
        'positionRoles': GroupPositionRoleCodec.toList(positionRoles),
      'isActive': isActive,
      'allowJoinRequests': allowJoinRequests,
      if (joinRequestHint != null && joinRequestHint.trim().isNotEmpty)
        'joinRequestHint': joinRequestHint.trim(),
      'memberLeavePolicy': memberLeavePolicy.value,
      'memberCount': memberCount,
      'pendingJoinRequestCount': 0,
      'pendingLeaveRequestCount': 0,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toMembershipPolicyJson() {
    return {
      'allowJoinRequests': allowJoinRequests,
      'memberLeavePolicy': memberLeavePolicy.value,
      'updatedAt': FieldValue.serverTimestamp(),
      if (joinRequestHint != null && joinRequestHint!.trim().isNotEmpty)
        'joinRequestHint': joinRequestHint!.trim()
      else
        'joinRequestHint': FieldValue.delete(),
    };
  }
}
