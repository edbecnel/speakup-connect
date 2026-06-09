import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakup_connect/features/reminders/data/models/reminder_response_config_codec.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_entity.dart';

/// Firestore data model for a reminder document.
///
/// Document path: `organizations/{orgId}/reminders/{reminderId}`
class ReminderModel extends ReminderEntity {
  const ReminderModel({
    required super.reminderId,
    required super.organizationId,
    required super.title,
    required super.body,
    required super.audience,
    required super.status,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    super.createdByName,
    super.scheduledAt,
    super.expiresAt,
    super.publishedAt,
    super.reviewedBy,
    super.reviewedByName,
    super.reviewedAt,
    super.rejectionReason,
    super.responseConfig,
  });

  factory ReminderModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    DateTime? toDate(dynamic v) => v is Timestamp ? v.toDate() : null;

    return ReminderModel(
      reminderId: documentId,
      organizationId: data['organizationId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      audience: ReminderAudience(
        type: ReminderAudienceType.fromValue(
          data['audienceType'] as String? ?? 'all',
        ),
        targetId: data['audienceId'] as String?,
        targetLabel: data['audienceLabel'] as String?,
      ),
      status: ReminderStatus.fromValue(data['status'] as String? ?? 'draft'),
      createdBy: data['createdBy'] as String? ?? '',
      createdByName: data['createdByName'] as String?,
      scheduledAt: toDate(data['scheduledAt']),
      expiresAt: toDate(data['expiresAt']),
      publishedAt: toDate(data['publishedAt']),
      reviewedBy: data['reviewedBy'] as String?,
      reviewedByName: data['reviewedByName'] as String?,
      reviewedAt: toDate(data['reviewedAt']),
      rejectionReason: data['rejectionReason'] as String?,
      responseConfig:
          ReminderResponseConfigCodec.fromMap(data['responseConfig']),
      createdAt: toDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: toDate(data['updatedAt']) ?? DateTime.now(),
    );
  }

  /// Serializes the fields written when a reminder is first created.
  ///
  /// Server-managed timestamps use [FieldValue.serverTimestamp]. [scheduledAt]
  /// is written as a concrete [Timestamp] because it is a future point in time,
  /// not "now".
  Map<String, dynamic> toCreateJson() {
    return {
      'organizationId': organizationId,
      'title': title,
      'body': body,
      'audienceType': audience.type.value,
      if (audience.targetId != null) 'audienceId': audience.targetId,
      if (audience.targetLabel != null) 'audienceLabel': audience.targetLabel,
      'status': status.value,
      'createdBy': createdBy,
      if (createdByName != null) 'createdByName': createdByName,
      if (scheduledAt != null) 'scheduledAt': Timestamp.fromDate(scheduledAt!),
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
      if (publishedAt != null) 'publishedAt': Timestamp.fromDate(publishedAt!),
      if (ReminderResponseConfigCodec.toMap(responseConfig) != null)
        'responseConfig': ReminderResponseConfigCodec.toMap(responseConfig),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
