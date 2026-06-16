import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
            .where(_isActiveNotification)
            .toList());
  }

  @override
  Stream<List<AppNotificationEntity>> watchAlertFeed({
    required String organizationId,
    required String userId,
  }) {
    final controller = StreamController<List<AppNotificationEntity>>();
    List<AppNotificationEntity> notifications = const [];
    List<AppNotificationEntity> broadcasts = const [];

    void emit() {
      if (controller.isClosed) return;
      controller.add(_mergeAlertFeed(notifications, broadcasts));
    }

    final notifSub = watchNotifications(
      organizationId: organizationId,
      userId: userId,
    ).listen(
      (items) {
        notifications = items;
        emit();
      },
      onError: controller.addError,
    );

    final broadcastSub = _watchOrgBroadcasts(organizationId).listen(
      (items) {
        broadcasts = items;
        emit();
      },
      onError: controller.addError,
    );

    controller.onCancel = () async {
      await notifSub.cancel();
      await broadcastSub.cancel();
    };

    return controller.stream;
  }

  Stream<List<AppNotificationEntity>> _watchOrgBroadcasts(String organizationId) {
    return _firestore
        .collection(AppConstants.organizationsCollection)
        .doc(organizationId)
        .collection(AppConstants.remindersCollection)
        .where('status', isEqualTo: 'published')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) {
          return snap.docs
              .where((doc) {
                final data = doc.data();
                final audience = data['audienceType'] as String? ?? 'all';
                final expiresAt = _toDate(data['expiresAt']);
                if (expiresAt != null && !expiresAt.isAfter(DateTime.now())) {
                  return false;
                }
                // Include all org-wide published broadcasts — covers missed
                // server-side delivery as well as late-approved members.
                return audience == 'all';
              })
              .map(_reminderDocToNotification)
              .toList();
        });
  }

  AppNotificationEntity _reminderDocToNotification(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    DateTime? toDate(dynamic v) => v is Timestamp ? v.toDate() : null;

    final responseConfig =
        data['responseConfig'] as Map<String, dynamic>? ?? const {};
    final responseRequired = responseConfig['enabled'] == true &&
        responseConfig['responseRequired'] == true;

    return AppNotificationModel(
      id: 'broadcast-${doc.id}',
      type: 'reminder',
      title: data['title'] as String? ?? 'New reminder',
      body: data['body'] as String? ?? '',
      read: false,
      expiresAt: toDate(data['expiresAt']),
      data: {
        'reminderId': doc.id,
        'audienceType': data['audienceType'] as String? ?? 'all',
        'synthetic': true,
        if (responseRequired) 'responseRequired': true,
      },
      createdAt: toDate(data['publishedAt']) ??
          toDate(data['deliveredAt']) ??
          toDate(data['createdAt']) ??
          DateTime.now(),
    );
  }

  DateTime? _toDate(dynamic v) => v is Timestamp ? v.toDate() : null;

  bool _isActiveNotification(AppNotificationEntity n) {
    final expiresAt = n.expiresAt;
    if (expiresAt == null) return true;
    return expiresAt.isAfter(DateTime.now());
  }

  List<AppNotificationEntity> _mergeAlertFeed(
    List<AppNotificationEntity> notifications,
    List<AppNotificationEntity> broadcasts,
  ) {
    final deliveredReminderIds = notifications
        .where((n) => n.type == 'reminder')
        .map((n) => n.data['reminderId'] as String?)
        .whereType<String>()
        .toSet();

    final merged = [
      ...notifications,
      ...broadcasts.where(
        (b) => !deliveredReminderIds.contains(b.data['reminderId']),
      ),
    ];
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged;
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
      final callable =
          FirebaseFunctions.instance.httpsCallable('dismissNotification');
      await callable.call<Map<String, dynamic>>({
        'orgId': organizationId,
        'notificationId': notificationId,
      });
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionException();
      if (e.code == 'failed-precondition') {
        throw DatabaseException(
          message: e.message ??
              'Submit your response before dismissing this alert.',
          code: e.code,
        );
      }
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
      final callable =
          FirebaseFunctions.instance.httpsCallable('clearNotificationFeed');
      await callable.call<Map<String, dynamic>>({
        'orgId': organizationId,
      });
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionException();
      throw DatabaseException(
        message: e.message ?? 'Failed to clear notifications',
        code: e.code,
      );
    }
  }

  @override
  Future<({int cleared, int skipped, int notFound})> clearSelected({
    required String organizationId,
    required String userId,
    required List<String> notificationIds,
  }) async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('dismissNotifications');
      final result = await callable.call<Map<String, dynamic>>({
        'orgId': organizationId,
        'notificationIds': notificationIds,
      });
      final data = result.data;
      return (
        cleared: (data['cleared'] as num?)?.toInt() ?? 0,
        skipped: (data['skipped'] as num?)?.toInt() ?? 0,
        notFound: (data['notFound'] as num?)?.toInt() ?? 0,
      );
    } on FirebaseFunctionsException catch (e) {
      // Dev/backwards-compat: if the bulk callable isn't deployed yet, fall back
      // to per-notification dismissal (slower, but avoids a hard failure).
      if (e.code == 'not-found') {
        return _clearSelectedFallback(
          organizationId: organizationId,
          notificationIds: notificationIds,
        );
      }
      if (e.code == 'permission-denied') throw const PermissionException();
      throw DatabaseException(
        message: e.message ?? 'Failed to clear selected notifications',
        code: e.code,
      );
    }
  }

  Future<({int cleared, int skipped, int notFound})> _clearSelectedFallback({
    required String organizationId,
    required List<String> notificationIds,
  }) async {
    final callable =
        FirebaseFunctions.instance.httpsCallable('dismissNotification');
    var cleared = 0;
    var skipped = 0;
    var notFound = 0;

    for (final id in notificationIds) {
      try {
        await callable.call<Map<String, dynamic>>({
          'orgId': organizationId,
          'notificationId': id,
        });
        cleared++;
      } on FirebaseFunctionsException catch (e) {
        if (e.code == 'permission-denied') throw const PermissionException();
        if (e.code == 'failed-precondition') {
          skipped++;
          continue;
        }
        if (e.code == 'not-found') {
          notFound++;
          continue;
        }
        throw DatabaseException(
          message: e.message ?? 'Failed to delete notification',
          code: e.code,
        );
      }
    }

    return (cleared: cleared, skipped: skipped, notFound: notFound);
  }
}
