import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';
import 'package:speakup_connect/features/announcements/data/models/bulletin_model.dart';
import 'package:speakup_connect/features/announcements/domain/entities/bulletin_entity.dart';
import 'package:speakup_connect/features/announcements/domain/repositories/bulletin_repository.dart';
import 'package:uuid/uuid.dart';

class BulletinRepositoryImpl implements BulletinRepository {
  BulletinRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

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
    DateTime? expiresAt,
  }) async {
    try {
      final bulletinId = const Uuid().v4();
      final model = BulletinModel(
        bulletinId: bulletinId,
        organizationId: organizationId,
        title: title,
        body: body,
        status: status,
        authorId: authorId,
        authorName: authorName,
        sourceGroupId: sourceGroupId,
        sourceGroupName: sourceGroupName,
        isPinned: isPinned,
        expiresAt: expiresAt,
        publishedAt:
            status == BulletinStatus.published ? DateTime.now() : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _bulletinsRef(organizationId).doc(bulletinId).set(
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
    DateTime? expiresAt,
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
        if (expiresAt != null) 'expiresAt': expiresAt.toIso8601String(),
      });

      final data = Map<String, dynamic>.from(result.data as Map);
      final bulletinId = data['bulletinId'] as String?;
      if (bulletinId == null || bulletinId.isEmpty) {
        throw const DatabaseException(
          message: 'Server did not return an announcement id',
        );
      }

      final created = await getBulletin(
        organizationId: organizationId,
        bulletinId: bulletinId,
      );
      if (created == null) {
        throw const DatabaseException(
          message: 'Announcement was created but could not be loaded',
        );
      }
      return created;
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionException();
      throw DatabaseException(
        message: e.message ?? 'Failed to post announcement',
        code: e.code,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException(message: e.toString());
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
          .where((b) => !b.isExpired)
          .toList()
        ..sort((a, b) {
          final pin = b.isPinned == a.isPinned
              ? 0
              : (b.isPinned ? 1 : -1);
          if (pin != 0) return pin;
          final aTime = a.publishedAt ?? a.createdAt;
          final bTime = b.publishedAt ?? b.createdAt;
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
        'publishedAt': FieldValue.serverTimestamp(),
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
}
