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
}
