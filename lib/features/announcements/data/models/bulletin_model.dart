import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakup_connect/features/announcements/domain/entities/bulletin_entity.dart';
import 'package:speakup_connect/features/reminders/data/models/reminder_response_config_codec.dart';

class BulletinModel extends BulletinEntity {
  const BulletinModel({
    required super.bulletinId,
    required super.organizationId,
    required super.title,
    required super.body,
    required super.status,
    required super.authorId,
    required super.createdAt,
    required super.updatedAt,
    super.authorName,
    super.sourceGroupId,
    super.sourceGroupName,
    super.isPinned,
    super.expiresAt,
    super.publishedAt,
    super.reviewedBy,
    super.reviewedByName,
    super.reviewedAt,
    super.rejectionReason,
    super.responseConfig,
    super.imageUrl,
  });

  factory BulletinModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    DateTime? toDate(dynamic v) => v is Timestamp ? v.toDate() : null;

    return BulletinModel(
      bulletinId: documentId,
      organizationId: data['organizationId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      status: BulletinStatus.fromValue(data['status'] as String? ?? 'pending'),
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String?,
      sourceGroupId: data['sourceGroupId'] as String?,
      sourceGroupName: data['sourceGroupName'] as String?,
      isPinned: data['isPinned'] as bool? ?? false,
      expiresAt: toDate(data['expiresAt']),
      publishedAt: toDate(data['publishedAt']),
      reviewedBy: data['reviewedBy'] as String?,
      reviewedByName: data['reviewedByName'] as String?,
      reviewedAt: toDate(data['reviewedAt']),
      rejectionReason: data['rejectionReason'] as String?,
      responseConfig:
          ReminderResponseConfigCodec.fromMap(data['responseConfig']),
      imageUrl: data['imageUrl'] as String?,
      createdAt: toDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: toDate(data['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'organizationId': organizationId,
      'title': title,
      'body': body,
      'status': status.value,
      'authorId': authorId,
      if (authorName != null) 'authorName': authorName,
      if (sourceGroupId != null) 'sourceGroupId': sourceGroupId,
      if (sourceGroupName != null) 'sourceGroupName': sourceGroupName,
      'isPinned': isPinned,
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
      if (publishedAt != null) 'publishedAt': Timestamp.fromDate(publishedAt!),
      if (ReminderResponseConfigCodec.toMap(responseConfig) != null)
        'responseConfig': ReminderResponseConfigCodec.toMap(responseConfig),
      if (imageUrl != null) 'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
