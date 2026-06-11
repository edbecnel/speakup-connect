import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';
import 'package:speakup_connect/features/announcements/data/models/bulletin_model.dart';
import 'package:speakup_connect/features/announcements/domain/entities/bulletin_entity.dart';
import 'package:speakup_connect/features/announcements/domain/repositories/bulletin_repository.dart';
import 'package:speakup_connect/features/reminders/data/models/reminder_response_config_codec.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_config.dart';
import 'package:uuid/uuid.dart';

class BulletinRepositoryImpl implements BulletinRepository {
  BulletinRepositoryImpl(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> _bulletinsRef(String orgId) =>
      _firestore
          .collection(AppConstants.organizationsCollection)
          .doc(orgId)
          .collection(AppConstants.bulletinsCollection);

  @override
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
    DateTime? scheduledAt,
    DateTime? expiresAt,
    ReminderResponseConfig? responseConfig,
    String? imageUrl,
    String? bulletinId,
  }) async {
    try {
      final resolvedId = bulletinId ?? const Uuid().v4();
      final model = BulletinModel(
        bulletinId: resolvedId,
        organizationId: organizationId,
        title: title,
        body: body,
        status: status,
        authorId: authorId,
        authorName: authorName,
        sourceGroupId: sourceGroupId,
        sourceGroupName: sourceGroupName,
        isPinned: isPinned,
        scheduledAt: scheduledAt,
        expiresAt: expiresAt,
        responseConfig: responseConfig,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _bulletinsRef(organizationId).doc(resolvedId).set(
            model.toCreateJson(),
          );

      return model;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionException();
      throw DatabaseException(
        message: e.message ?? 'Failed to create announcement',
        code: e.code,
      );
    } catch (e) {
      throw DatabaseException(message: e.toString());
    }
  }

  @override
  Future<BulletinEntity> createGroupLeaderAnnouncement({
    required String organizationId,
    required String title,
    required String body,
    required String groupId,
    String? groupLabel,
    required String authorId,
    DateTime? scheduledAt,
    DateTime? expiresAt,
    ReminderResponseConfig? responseConfig,
  }) async {
    try {
      final callable = FirebaseFunctions.instance
          .httpsCallable('createGroupLeaderAnnouncement');
      final result = await callable.call<Map<String, dynamic>>({
        'orgId': organizationId,
        'title': title,
        'body': body,
        'groupId': groupId,
        if (groupLabel != null) 'groupLabel': groupLabel,
        if (scheduledAt != null) 'scheduledAt': scheduledAt.toIso8601String(),
        if (expiresAt != null) 'expiresAt': expiresAt.toIso8601String(),
        if (ReminderResponseConfigCodec.toMap(responseConfig) != null)
          'responseConfig': ReminderResponseConfigCodec.toMap(responseConfig),
      });

      final data = Map<String, dynamic>.from(result.data as Map);
      final bulletinId = data['bulletinId'] as String?;
      if (bulletinId == null || bulletinId.isEmpty) {
        throw const DatabaseException(
          message: 'Server did not return an announcement id',
        );
      }

      final status = BulletinStatus.fromValue(
        data['status'] as String? ?? BulletinStatus.pending.value,
      );

      // Prefer callable payload — avoids a race before Firestore read catches up.
      final created = await getBulletin(
        organizationId: organizationId,
        bulletinId: bulletinId,
      );
      if (created != null) return created;

      return BulletinModel(
        bulletinId: bulletinId,
        organizationId: organizationId,
        title: title,
        body: body,
        status: status,
        authorId: authorId,
        sourceGroupId: groupId,
        sourceGroupName: groupLabel,
        scheduledAt: scheduledAt,
        expiresAt: expiresAt,
        responseConfig: responseConfig,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionException();
      if (e.code == 'not-found') {
        throw const DatabaseException(
          message:
              'The announcement service is not deployed yet. '
              'Your administrator needs to deploy the latest cloud functions.',
          code: 'not-found',
        );
      }
      throw DatabaseException(
        message: e.message ?? 'Failed to post announcement',
        code: e.code,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException(message: e.toString());
    }
  }

  static String _imageContentType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  @override
  Future<String> uploadAnnouncementImage({
    required String organizationId,
    required String bulletinId,
    required String localPath,
  }) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) {
        throw const DatabaseException(
          message: 'Image file not found. Try selecting the photo again.',
        );
      }
      final ext = switch (_imageContentType(localPath)) {
        'image/png' => 'png',
        'image/webp' => 'webp',
        'image/gif' => 'gif',
        _ => 'jpg',
      };
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4().substring(0, 8)}.$ext';
      final storageRef = _storage
          .ref()
          .child(AppConstants.bulletinImageStoragePath(organizationId, bulletinId))
          .child(fileName);

      await storageRef.putFile(
        file,
        SettableMetadata(contentType: _imageContentType(localPath)),
      );
      return storageRef.getDownloadURL();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied' || e.code == 'unauthorized') {
        throw const PermissionException();
      }
      throw DatabaseException(
        message: e.message ?? 'Failed to upload image',
        code: e.code,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException(message: e.toString());
    }
  }

  @override
  Future<BulletinEntity> setAnnouncementImageUrl({
    required String organizationId,
    required String bulletinId,
    String? imageUrl,
  }) async {
    try {
      await _setAnnouncementImageUrlViaCallable(
        organizationId: organizationId,
        bulletinId: bulletinId,
        imageUrl: imageUrl,
      );
    } on DatabaseException catch (e) {
      if (e.code != 'not-found') rethrow;
      final docRef = _bulletinsRef(organizationId).doc(bulletinId);
      if (imageUrl == null || imageUrl.isEmpty) {
        await docRef.update({
          'imageUrl': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.update({
          'imageUrl': imageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    final updated = await getBulletin(
      organizationId: organizationId,
      bulletinId: bulletinId,
    );
    if (updated == null) {
      throw const DatabaseException(
        message: 'Announcement not found after image update',
      );
    }
    return updated;
  }

  Future<void> _setAnnouncementImageUrlViaCallable({
    required String organizationId,
    required String bulletinId,
    String? imageUrl,
  }) async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('setBulletinImageUrl');
      await callable.call<Map<String, dynamic>>({
        'orgId': organizationId,
        'bulletinId': bulletinId,
        if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
        if (imageUrl == null || imageUrl.isEmpty) 'clearImageUrl': true,
      });
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionException();
      throw DatabaseException(
        message: e.message ?? 'Failed to update announcement image',
        code: e.code,
      );
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionException();
      throw DatabaseException(
        message: e.message ?? 'Failed to update announcement image',
        code: e.code,
      );
    }
  }

  @override
  Stream<List<BulletinEntity>> watchPublishedBulletins(String organizationId) {
    return _bulletinsRef(organizationId)
        .where('status', isEqualTo: BulletinStatus.published.value)
        .snapshots()
        .map((snap) {
      final bulletins = snap.docs
          .map((d) => BulletinModel.fromFirestore(d.data(), d.id))
          .where((b) => !b.isExpired && !b.isScheduled)
          .toList()
        ..sort((a, b) {
          final pin = b.isPinned == a.isPinned
              ? 0
              : (b.isPinned ? 1 : -1);
          if (pin != 0) return pin;
          final aTime = a.publishedAt ?? a.scheduledAt ?? a.createdAt;
          final bTime = b.publishedAt ?? b.scheduledAt ?? b.createdAt;
          return bTime.compareTo(aTime);
        });
      return bulletins;
    });
  }

  @override
  Stream<List<BulletinEntity>> watchPendingBulletins(String organizationId) {
    return _bulletinsRef(organizationId)
        .where('status', isEqualTo: BulletinStatus.pending.value)
        .snapshots()
        .map((snap) {
      final bulletins = snap.docs
          .map((d) => BulletinModel.fromFirestore(d.data(), d.id))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return bulletins;
    });
  }

  @override
  Stream<List<BulletinEntity>> watchMyBulletins({
    required String organizationId,
    required String authorId,
  }) {
    return _bulletinsRef(organizationId)
        .where('authorId', isEqualTo: authorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => BulletinModel.fromFirestore(d.data(), d.id))
            .toList());
  }

  @override
  Future<BulletinEntity?> getBulletin({
    required String organizationId,
    required String bulletinId,
  }) async {
    try {
      final doc = await _bulletinsRef(organizationId).doc(bulletinId).get();
      if (!doc.exists || doc.data() == null) return null;
      return BulletinModel.fromFirestore(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionException();
      throw DatabaseException(
        message: e.message ?? 'Failed to load announcement',
        code: e.code,
      );
    }
  }

  @override
  Future<void> approveBulletin({
    required String organizationId,
    required String bulletinId,
    required String reviewerId,
    String? reviewerName,
  }) async {
    try {
      await _bulletinsRef(organizationId).doc(bulletinId).update({
        'status': BulletinStatus.published.value,
        'reviewedBy': reviewerId,
        if (reviewerName != null) 'reviewedByName': reviewerName,
        'reviewedAt': FieldValue.serverTimestamp(),
        'rejectionReason': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionException();
      throw DatabaseException(
        message: e.message ?? 'Failed to approve announcement',
        code: e.code,
      );
    }
  }

  @override
  Future<void> rejectBulletin({
    required String organizationId,
    required String bulletinId,
    required String reviewerId,
    String? reviewerName,
    required String reason,
  }) async {
    try {
      await _bulletinsRef(organizationId).doc(bulletinId).update({
        'status': BulletinStatus.rejected.value,
        'reviewedBy': reviewerId,
        if (reviewerName != null) 'reviewedByName': reviewerName,
        'reviewedAt': FieldValue.serverTimestamp(),
        'rejectionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionException();
      throw DatabaseException(
        message: e.message ?? 'Failed to reject announcement',
        code: e.code,
      );
    }
  }

  @override
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
  }) async {
    final responseMap = ReminderResponseConfigCodec.toMap(responseConfig);
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('updateBulletin');
      final result = await callable.call<Map<String, dynamic>>({
        'orgId': organizationId,
        'bulletinId': bulletinId,
        'title': title,
        'body': body,
        if (expiresAt != null) 'expiresAt': expiresAt.millisecondsSinceEpoch,
        if (clearExpiration) 'clearExpiresAt': true,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (clearImageUrl) 'clearImageUrl': true,
        if (responseMap != null) 'responseConfig': responseMap,
        if (clearResponseConfig) 'clearResponseConfig': true,
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      return (data['updatedNotifications'] as num?)?.toInt() ?? 0;
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'not-found') {
        return _updateBulletinFallback(
          organizationId: organizationId,
          bulletinId: bulletinId,
          title: title,
          body: body,
          expiresAt: expiresAt,
          clearExpiration: clearExpiration,
          imageUrl: imageUrl,
          clearImageUrl: clearImageUrl,
          responseConfig: responseConfig,
          clearResponseConfig: clearResponseConfig,
        );
      }
      if (e.code == 'permission-denied') throw const PermissionException();
      throw DatabaseException(
        message: e.message ?? 'Failed to update announcement',
        code: e.code,
      );
    }
  }

  /// Used when [updateBulletin] is not deployed — routes image changes through
  /// [setBulletinImageUrl] and other fields through the image callable or CF.
  Future<int> _updateBulletinFallback({
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
  }) async {
    if (imageUrl != null || clearImageUrl) {
      await _setAnnouncementImageUrlViaCallable(
        organizationId: organizationId,
        bulletinId: bulletinId,
        imageUrl: clearImageUrl ? null : imageUrl,
      );
      return 0;
    }

    throw const DatabaseException(
      message:
          'Could not update the announcement because the update service is '
          'not deployed. Deploy the latest cloud functions and try again.',
      code: 'not-found',
    );
  }

  @override
  Future<void> updateBulletinResponseConfig({
    required String organizationId,
    required String bulletinId,
    required ReminderResponseConfig responseConfig,
  }) async {
    final bulletin = await getBulletin(
      organizationId: organizationId,
      bulletinId: bulletinId,
    );
    if (bulletin == null) {
      throw const DatabaseException(message: 'Announcement not found');
    }

    await updateBulletin(
      organizationId: organizationId,
      bulletinId: bulletinId,
      title: bulletin.title,
      body: bulletin.body,
      expiresAt: bulletin.expiresAt,
      responseConfig: responseConfig.enabled ? responseConfig : null,
      clearResponseConfig: !responseConfig.enabled,
    );
  }

  @override
  Future<int> deleteBulletin({
    required String organizationId,
    required String bulletinId,
  }) async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('deleteBulletin');
      final result = await callable.call<Map<String, dynamic>>({
        'orgId': organizationId,
        'bulletinId': bulletinId,
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      return (data['deletedNotifications'] as num?)?.toInt() ?? 0;
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionException();
      throw DatabaseException(
        message: e.message ?? 'Failed to delete announcement',
        code: e.code,
      );
    }
  }
}
