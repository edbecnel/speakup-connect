import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_entity.dart';

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
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'groupId': groupId,
      'organizationId': organizationId,
      'name': name,
      if (description != null) 'description': description,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'isActive': isActive,
      'memberCount': memberCount,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
