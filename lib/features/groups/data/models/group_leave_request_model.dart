import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_leave_request_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_membership_policy.dart';

class GroupLeaveRequestModel extends GroupLeaveRequestEntity {
  const GroupLeaveRequestModel({
    required super.userId,
    required super.organizationId,
    required super.groupId,
    required super.groupName,
    required super.displayName,
    required super.reason,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.studentId,
    super.reviewedBy,
    super.reviewedAt,
    super.rejectionReason,
  });

  factory GroupLeaveRequestModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    DateTime? toDate(dynamic v) => v is Timestamp ? v.toDate() : null;

    return GroupLeaveRequestModel(
      userId: documentId,
      organizationId: data['organizationId'] as String? ?? '',
      groupId: data['groupId'] as String? ?? '',
      groupName: data['groupName'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      studentId: data['studentId'] as String?,
      reason: data['reason'] as String? ?? '',
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
