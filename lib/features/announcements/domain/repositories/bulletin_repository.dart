import 'package:speakup_connect/features/announcements/domain/entities/bulletin_entity.dart';

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
  });

  Future<BulletinEntity> createGroupLeaderAnnouncement({
    required String organizationId,
    required String title,
    required String body,
    required String groupId,
    String? groupLabel,
    required String authorId,
    DateTime? expiresAt,
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
}
