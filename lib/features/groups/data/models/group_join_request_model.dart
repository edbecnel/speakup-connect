import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_join_request_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_membership_policy.dart';

class GroupJoinRequestModel extends GroupJoinRequestEntity {
  const GroupJoinRequestModel({
    required super.userId,
    required super.organizationId,
    required super.groupId,
    required super.groupName,
    required super.displayName,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.studentId,
    super.message,
    super.reviewedBy,
    super.reviewedAt,
    super.rejectionReason,
  });

  factory GroupJoinRequestModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    DateTime? toDate(dynamic v) => v is Timestamp ? v.toDate() : null;

    return GroupJoinRequestModel(
      userId: documentId,
      organizationId: data['organizationId'] as String? ?? '',
      groupId: data['groupId'] as String? ?? '',
      groupName: data['groupName'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      studentId: data['studentId'] as String?,
      message: data['message'] as String?,
      status: GroupMembershipRequestStatus.fromValue(
        data['status'] as String?,
      ),
      reviewedBy: data['reviewedBy'] as String?,
      reviewedAt: toDate(data['reviewedAt']),
      rejectionReason: data['rejectionReason'] as String?,
      createdAt: toDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: toDate(data['updatedAt']) ?? DateTime.now(),
    );
  }
}
