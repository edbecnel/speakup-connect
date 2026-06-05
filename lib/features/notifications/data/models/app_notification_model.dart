import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakup_connect/features/notifications/domain/entities/app_notification_entity.dart';

/// Firestore data model for an in-app notification document.
class AppNotificationModel extends AppNotificationEntity {
  const AppNotificationModel({
    required super.id,
    required super.type,
    required super.title,
    required super.body,
    required super.createdAt,
    super.read,
    super.readAt,
    super.data,
  });

  factory AppNotificationModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    DateTime? toDate(dynamic v) => v is Timestamp ? v.toDate() : null;

    return AppNotificationModel(
      id: documentId,
      type: data['type'] as String? ?? 'general',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      read: data['read'] as bool? ?? false,
      readAt: toDate(data['readAt']),
      data: (data['data'] as Map<String, dynamic>?) ?? const {},
      createdAt: toDate(data['createdAt']) ?? DateTime.now(),
    );
  }
}
