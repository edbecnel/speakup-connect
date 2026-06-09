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
  });

  final String groupId;
  final String organizationId;
  final String name;
  final String? description;
  final String? avatarUrl;
  final bool isActive;

  /// Denormalized count of documents in the `members` subcollection.
  final int memberCount;

  /// UID of the admin who created the group.
  final String createdBy;

  final DateTime createdAt;
  final DateTime updatedAt;
}
