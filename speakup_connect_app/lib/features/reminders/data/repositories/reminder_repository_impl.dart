import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';
import 'package:speakup_connect/features/reminders/data/models/reminder_response_config_codec.dart';
import 'package:speakup_connect/features/reminders/data/models/reminder_model.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_entity.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_config.dart';
import 'package:speakup_connect/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:uuid/uuid.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  ReminderRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _remindersRef(String orgId) =>
      _firestore
          .collection(AppConstants.organizationsCollection)
          .doc(orgId)
          .collection(AppConstants.remindersCollection);

  @override
  Future<ReminderEntity> createReminder({
    required String organizationId,
    required String title,
    required String body,
    required ReminderAudience audience,
    required ReminderStatus status,
    required String createdBy,
    String? createdByName,
    DateTime? scheduledAt,
    DateTime? expiresAt,
    ReminderResponseConfig? responseConfig,
  }) async {
    try {
      final reminderId = const Uuid().v4();
      final model = ReminderModel(
        reminderId: reminderId,
        organizationId: organizationId,
        title: title,
        body: body,
        audience: audience,
        status: status,
        createdBy: createdBy,
        createdByName: createdByName,
        scheduledAt: scheduledAt,
        expiresAt: expiresAt,
        responseConfig: responseConfig,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _remindersRef(organizationId).doc(reminderId).set(
            model.toCreateJson(),
          );

      return model;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionException();
      throw DatabaseException(
        message: e.message ?? 'Failed to create reminder',
        code: e.code,
      );
    } catch (e) {
      throw DatabaseException(message: e.toString());
    }
  }

  @override
  Future<ReminderEntity> createGroupLeaderReminder({
    required String organizationId,
    required String title,
    required String body,
    required String groupId,
    String? groupLabel,
    required String createdBy,
    DateTime? scheduledAt,
    DateTime? expiresAt,
    ReminderResponseConfig? responseConfig,
  }) async {
    try {
      final callable = FirebaseFunctions.instance
          .httpsCallable('createGroupLeaderReminder');
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
      final reminderId = data['reminderId'] as String?;
      if (reminderId == null || reminderId.isEmpty) {
        throw const DatabaseException(
          message: 'Server did not return a reminder id',
        );
      }

      final created = await getReminder(
        organizationId: organizationId,
        reminderId: reminderId,
      );
      if (created == null) {
        throw const DatabaseException(
          message: 'Reminder was created but could not be loaded',
        );
      }
      return created;
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionException();
      throw DatabaseException(
        message: e.message ?? 'Failed to create group alert',
        code: e.code,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException(message: e.toString());
    }
  }

  @override
  Stream<List<ReminderEntity>> watchPendingReminders(String organizationId) {
    // No orderBy — pending docs may lack a resolved `createdAt` while the
    // server timestamp is pending, and Firestore excludes those from ordered
    // queries. Sort client-side instead.
    return _remindersRef(organizationId)
        .where('status', isEqualTo: ReminderStatus.pending.value)
        .snapshots()
        .map((snap) {
      final reminders = snap.docs
          .map((d) => ReminderModel.fromFirestore(d.data(), d.id))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reminders;
    });
  }

  @override
  Stream<List<ReminderEntity>> watchMyReminders({
    required String organizationId,
    required String userId,
  }) {
    return _remindersRef(organizationId)
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ReminderModel.fromFirestore(d.data(), d.id))
            .toList());
  }

  @override
  Future<void> approveReminder({
    required String organizationId,
    required String reminderId,
    required String reviewerId,
    String? reviewerName,
  }) async {
    try {
      await _remindersRef(organizationId).doc(reminderId).update({
        'status': ReminderStatus.published.value,
        'reviewedBy': reviewerId,
        if (reviewerName != null) 'reviewedByName': reviewerName,
        'reviewedAt': FieldValue.serverTimestamp(),
        'rejectionReason': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionException();
      throw DatabaseException(
        message: e.message ?? 'Failed to approve reminder',
        code: e.code,
      );
    }
  }

  @override
  Future<void> rejectReminder({
    required String organizationId,
    required String reminderId,
    required String reviewerId,
    String? reviewerName,
    required String reason,
  }) async {
    try {
      await _remindersRef(organizationId).doc(reminderId).update({
        'status': ReminderStatus.rejected.value,
        'reviewedBy': reviewerId,
        if (reviewerName != null) 'reviewedByName': reviewerName,
        'reviewedAt': FieldValue.serverTimestamp(),
        'rejectionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionException();
      throw DatabaseException(
        message: e.message ?? 'Failed to reject reminder',
        code: e.code,
      );
    }
  }

  @override
  Future<ReminderEntity?> getReminder({
    required String organizationId,
    required String reminderId,
  }) async {
    try {
      final doc = await _remindersRef(organizationId).doc(reminderId).get();
      if (!doc.exists || doc.data() == null) return null;
      return ReminderModel.fromFirestore(doc.data()!, doc.id);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionException();
      throw DatabaseException(
        message: e.message ?? 'Failed to load reminder',
        code: e.code,
      );
    }
  }

  @override
  Future<int> updateReminder({
    required String organizationId,
    required String reminderId,
    required String title,
    required String body,
    DateTime? expiresAt,
    bool clearExpiration = false,
  }) async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('updateReminder');
      final payload = <String, dynamic>{
        'orgId': organizationId,
        'reminderId': reminderId,
        'title': title,
        'body': body,
      };
      if (clearExpiration) {
        payload['clearExpiresAt'] = true;
      } else if (expiresAt != null) {
        payload['expiresAt'] = expiresAt.millisecondsSinceEpoch;
      }
      final result = await callable.call<Map<String, dynamic>>(payload);
      return (result.data['updatedNotifications'] as num?)?.toInt() ?? 0;
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionException();
      throw DatabaseException(
        message: e.message ?? 'Failed to update reminder',
        code: e.code,
      );
    }
  }

  @override
  Future<int> recallReminder({
    required String organizationId,
    required String reminderId,
  }) async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('recallReminder');
      final result = await callable.call<Map<String, dynamic>>({
        'orgId': organizationId,
        'reminderId': reminderId,
      });
      return (result.data['deletedNotifications'] as num?)?.toInt() ?? 0;
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionException();
      throw DatabaseException(
        message: e.message ?? 'Failed to recall reminder',
        code: e.code,
      );
    }
  }
}
