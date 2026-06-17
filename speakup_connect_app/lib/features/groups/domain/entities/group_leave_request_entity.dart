import 'package:speakup_connect/features/groups/domain/entities/group_membership_policy.dart';

/// A member's request to leave a group (when policy requires approval).
class GroupLeaveRequestEntity {
  const GroupLeaveRequestEntity({
    required this.userId,
    required this.organizationId,
    required this.groupId,
    required this.groupName,
    required this.displayName,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.studentId,
    this.reviewedBy,
    this.reviewedAt,
    this.rejectionReason,
  });

  final String userId;
  final String organizationId;
  final String groupId;
  final String groupName;
  final String displayName;
  final String? studentId;
  final String reason;
  final GroupMembershipRequestStatus status;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;
}
