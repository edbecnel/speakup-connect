/// Upload and persist profile badge / official school photos.
abstract class ProfilePhotoRepository {
  /// Uploads a personal badge image and saves [avatarUrl] on the profile.
  Future<void> uploadMemberAvatar({
    required String orgId,
    required String userId,
    required String localPath,
  });

  /// Clears the signed-in member's personal badge.
  Future<void> clearMemberAvatar({
    required String orgId,
  });

  /// Uploads an official school photo for a student (roster + profile when linked).
  Future<void> uploadOfficialPhoto({
    required String orgId,
    required String localPath,
    String? studentId,
    String? userId,
  });

  /// Removes the official school photo from roster and linked profile.
  Future<void> clearOfficialPhoto({
    required String orgId,
    String? studentId,
    String? userId,
  });
}
