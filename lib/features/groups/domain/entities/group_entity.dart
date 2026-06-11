import 'package:speakup_connect/features/groups/domain/entities/group_membership_policy.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_position_role.dart';

/// Domain entity for an extracurricular group or club.
///
/// Stored in Firestore at:
///   `organizations/{orgId}/groups/{groupId}`
class GroupEntity {
  const GroupEntity({
    required this.groupId,
    required this.organizationId,
    required this.name,
    required this.isActive,
    required this.memberCount,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.avatarUrl,
    this.positionRoles = const [],
    this.allowJoinRequests = false,
    this.joinRequestHint,
    this.memberLeavePolicy = MemberLeavePolicy.requestRequired,
    this.pendingJoinRequestCount = 0,
    this.pendingLeaveRequestCount = 0,
  });

  final String groupId;
  final String organizationId;
  final String name;
  final String? description;
  final String? avatarUrl;
  final bool isActive;

  /// Optional club offices (President, Secretary, etc.) defined by the admin.
  final List<GroupPositionRole> positionRoles;

  /// When true, approved members may request to join this group.
  final bool allowJoinRequests;

  /// Optional helper text when [allowJoinRequests] is enabled.
  final String? joinRequestHint;

  /// Whether members may leave on their own or must request approval.
  final MemberLeavePolicy memberLeavePolicy;

  /// Denormalized pending join requests (for leader/admin badges).
  final int pendingJoinRequestCount;

  /// Denormalized pending leave requests (for leader/admin badges).
  final int pendingLeaveRequestCount;

  /// Denormalized count of documents in the `members` subcollection.
  final int memberCount;

  /// UID of the admin who created the group.
  final String createdBy;

  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasPositionRoles => positionRoles.isNotEmpty;

  String? positionLabel(String? positionRoleId) {
    if (positionRoleId == null) return null;
    for (final role in positionRoles) {
      if (role.id == positionRoleId) return role.label;
    }
    return null;
  }

  int positionSortOrder(String? positionRoleId) {
    if (positionRoleId == null) return 9999;
    for (final role in positionRoles) {
      if (role.id == positionRoleId) return role.sortOrder;
    }
    return 9998;
  }
}
