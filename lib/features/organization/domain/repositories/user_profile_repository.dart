import 'package:speakup_connect/features/organization/domain/entities/user_profile_entity.dart';

/// Repository interface for user profile operations.
///
/// Implementations write to / read from:
///   `organizations/{organizationId}/users/{userId}`
abstract class UserProfileRepository {
  /// Returns the user's profile for the given org, or null if it doesn't exist.
  Future<UserProfileEntity?> getUserProfile({
    required String orgId,
    required String userId,
  });

  /// Emits the latest profile whenever it changes in Firestore.
  /// Emits null when no document exists.
  Stream<UserProfileEntity?> watchUserProfile({
    required String orgId,
    required String userId,
  });

  /// Creates a new pending user profile (apply-to-join submission).
  Future<UserProfileEntity> createUserProfile({
    required String orgId,
    required String userId,
    required String displayName,
    required String fullName,
    String? studentId,
    String? email,
  });

  /// Grants [permission] to [targetUserId] in [orgId].
  ///
  /// Uses Firestore `arrayUnion` so concurrent writes are safe.
  /// Only a `super_admin` caller should invoke this; enforcement is
  /// also applied in Firestore Security Rules.
  Future<void> grantPermission({
    required String orgId,
    required String targetUserId,
    required String permission,
  });

  /// Revokes [permission] from [targetUserId] in [orgId].
  ///
  /// Uses Firestore `arrayRemove`. Safe to call when permission is not present.
  Future<void> revokePermission({
    required String orgId,
    required String targetUserId,
    required String permission,
  });

  /// Streams join applications awaiting admin review.
  Stream<List<UserProfileEntity>> watchPendingApplications({
    required String orgId,
  });

  /// Approves or rejects a join application.
  Future<void> updateApprovalStatus({
    required String orgId,
    required String targetUserId,
    required ApprovalStatus status,
    String? reviewedBy,
    String? rejectionReason,
  });
}
