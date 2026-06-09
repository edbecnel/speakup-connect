import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakup_connect/features/notifications/domain/entities/notification_history_entity.dart';

class NotificationHistoryModel extends NotificationHistoryEntity {
  const NotificationHistoryModel({
    required super.historyId,
    required super.organizationId,
    required super.sourceType,
    required super.sourceId,
    required super.title,
    required super.body,
    required super.type,
    required super.removalReason,
    required super.removedAt,
    super.reminderId,
    super.userId,
    super.audienceType,
    super.audienceLabel,
    super.createdBy,
    super.createdByName,
    super.publishedAt,
    super.expiresAt,
    super.removedBy,
    super.feedCopiesAffected,
  });

  factory NotificationHistoryModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    DateTime? toDate(dynamic v) => v is Timestamp ? v.toDate() : null;

    return NotificationHistoryModel(
      historyId: documentId,
      organizationId: data['organizationId'] as String? ?? '',
      sourceType: data['sourceType'] as String? ?? 'reminder',
      sourceId: data['sourceId'] as String? ?? documentId,
      reminderId: data['reminderId'] as String?,
      userId: data['userId'] as String?,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      type: data['type'] as String? ?? 'reminder',
      audienceType: data['audienceType'] as String?,
      audienceLabel: data['audienceLabel'] as String?,
      createdBy: data['createdBy'] as String?,
      createdByName: data['createdByName'] as String?,
      publishedAt: toDate(data['publishedAt']),
      expiresAt: toDate(data['expiresAt']),
      removedAt: toDate(data['removedAt']) ?? DateTime.now(),
      removalReason: data['removalReason'] as String? ?? 'unknown',
      removedBy: data['removedBy'] as String?,
      feedCopiesAffected: (data['feedCopiesAffected'] as num?)?.toInt(),
    );
  }
}
