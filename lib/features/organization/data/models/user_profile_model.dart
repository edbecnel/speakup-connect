import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakup_connect/features/organization/domain/entities/user_profile_entity.dart';

/// Firestore data model for a user profile document.
///
/// Document path: `organizations/{organizationId}/users/{userId}`
class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.userId,
    required super.organizationId,
    required super.displayName,
    required super.fullName,
    super.studentId,
    super.email,
    super.role,
    super.approvalStatus,
    super.applicationSubmitted,
    super.isActive,
    super.permissions,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserProfileModel.fromFirestore(
    Map<String, dynamic> data,
    String userId,
  ) {
    return UserProfileModel(
      userId: userId,
      organizationId: data['organizationId'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      fullName: data['fullName'] as String? ??
          data['displayName'] as String? ??
          '',
      studentId: data['studentId'] as String?,
      email: data['email'] as String?,
      role: data['role'] as String? ?? 'user',
      approvalStatus: _parseApprovalStatus(
        data['approvalStatus'] as String?,
      ),
      applicationSubmitted: data['applicationSubmitted'] as bool? ??
          data.containsKey('approvalStatus') ||
              ((data['fullName'] as String?)?.isNotEmpty ?? false),
      isActive: data['isActive'] as bool? ?? true,
      permissions: Set<String>.from(
        (data['permissions'] as List<dynamic>?) ?? [],
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Returns a map suitable for writing to Firestore on initial creation.
  /// Server timestamps are used for [createdAt] and [updatedAt].
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'organizationId': organizationId,
      'displayName': displayName,
      'fullName': fullName,
      'studentId': studentId,
      'email': email,
      'role': role,
      'approvalStatus': approvalStatus.name,
      'applicationSubmitted': applicationSubmitted,
      'isActive': isActive,
      'permissions': permissions.toList(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static ApprovalStatus _parseApprovalStatus(String? status) {
    switch (status) {
      case 'approved':
        return ApprovalStatus.approved;
      case 'rejected':
        return ApprovalStatus.rejected;
      default:
        return ApprovalStatus.pending;
    }
  }
}
