import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';
import 'package:speakup_connect/features/notifications/data/models/app_notification_model.dart';
import 'package:speakup_connect/features/notifications/domain/entities/app_notification_entity.dart';
import 'package:speakup_connect/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _ref(
    String orgId,
    String userId,
  ) =>
      _firestore
          .collection(AppConstants.organizationsCollection)
          .doc(orgId)
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.notificationsCollection);

  @override
  Stream<List<AppNotificationEntity>> watchNotifications({
    required String organizationId,
    required String userId,
  }) {
    return _ref(organizationId, userId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AppNotificationModel.fromFirestore(d.data(), d.id))
            .toList());
  }

  @override
  Future<void> markAsRead({
    required String organizationId,
    required String userId,
    required String notificationId,
  }) async {
    try {
      await _ref(organizationId, userId).doc(notificationId).update({
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw DatabaseException(
        message: e.message ?? 'Failed to mark notification read',
        code: e.code,
      );
    }
  }

  @override
  Future<void> markAllAsRead({
    required String organizationId,
    required String userId,
  }) async {
    try {
      final unread = await _ref(organizationId, userId)
          .where('read', isEqualTo: false)
          .get();
      if (unread.docs.isEmpty) return;
      final batch = _firestore.batch();
      for (final doc in unread.docs) {
        batch.update(doc.reference, {
          'read': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw DatabaseException(
        message: e.message ?? 'Failed to mark notifications read',
        code: e.code,
      );
    }
  }

  @override
  Future<void> deleteNotification({
    required String organizationId,
    required String userId,
    required String notificationId,
  }) async {
    try {
      await _ref(organizationId, userId).doc(notificationId).delete();
    } on FirebaseException catch (e) {
      throw DatabaseException(
        message: e.message ?? 'Failed to delete notification',
        code: e.code,
      );
    }
  }

  @override
  Future<void> clearAll({
    required String organizationId,
    required String userId,
  }) async {
    try {
      final all = await _ref(organizationId, userId).get();
      if (all.docs.isEmpty) return;
      final batch = _firestore.batch();
      for (final doc in all.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw DatabaseException(
        message: e.message ?? 'Failed to clear notifications',
        code: e.code,
      );
    }
  }
}
