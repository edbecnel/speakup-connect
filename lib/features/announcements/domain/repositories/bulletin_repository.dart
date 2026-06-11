import 'package:speakup_connect/features/announcements/domain/entities/bulletin_entity.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_config.dart';

abstract class BulletinRepository {
  Future<BulletinEntity> createBulletin({
    required String organizationId,
    required String title,
    required String body,
    required BulletinStatus status,
    required String authorId,
    String? authorName,
    String? sourceGroupId,
    String? sourceGroupName,
    bool isPinned = false,
    DateTime? expiresAt,
    ReminderResponseConfig? responseConfig,
    String? imageUrl,
    String? bulletinId,
  });

  Future<BulletinEntity> createGroupLeaderAnnouncement({
    required String organizationId,
    required String title,
    required String body,
    required String groupId,
    String? groupLabel,
    required String authorId,
    DateTime? expiresAt,
    ReminderResponseConfig? responseConfig,
  });

  /// Uploads a local image file and returns its download URL.
  Future<String> uploadAnnouncementImage({
    required String organizationId,
    required String bulletinId,
    required String localPath,
  });

  /// Sets or clears the announcement image URL on the bulletin document.
  Future<BulletinEntity> setAnnouncementImageUrl({
    required String organizationId,
    required String bulletinId,
    String? imageUrl,
  });

  Stream<List<BulletinEntity>> watchPublishedBulletins(String organizationId);

  Stream<List<BulletinEntity>> watchPendingBulletins(String organizationId);

  Stream<List<BulletinEntity>> watchMyBulletins({
    required String organizationId,
    required String authorId,
  });

  Future<BulletinEntity?> getBulletin({
    required String organizationId,
    required String bulletinId,
  });

  Future<void> approveBulletin({
    required String organizationId,
    required String bulletinId,
    required String reviewerId,
    String? reviewerName,
  });

  Future<void> rejectBulletin({
    required String organizationId,
    required String bulletinId,
    required String reviewerId,
    String? reviewerName,
    required String reason,
  });

  /// Updates title/body/expiration and propagates to delivered feed copies.
  Future<int> updateBulletin({
    required String organizationId,
    required String bulletinId,
    required String title,
    required String body,
    DateTime? expiresAt,
    bool clearExpiration = false,
    String? imageUrl,
    bool clearImageUrl = false,
    ReminderResponseConfig? responseConfig,
    bool clearResponseConfig = false,
  });

  /// Updates optional response settings on the bulletin document.
  Future<void> updateBulletinResponseConfig({
    required String organizationId,
    required String bulletinId,
    required ReminderResponseConfig responseConfig,
  });

  /// Deletes the bulletin and removes all delivered feed copies.
  Future<int> deleteBulletin({
    required String organizationId,
    required String bulletinId,
  });
}
