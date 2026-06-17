import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';
import 'package:speakup_connect/features/announcements/domain/repositories/bulletin_response_repository.dart';
import 'package:speakup_connect/features/reminders/data/models/reminder_response_model.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_entity.dart';

class BulletinResponseRepositoryImpl implements BulletinResponseRepository {
  BulletinResponseRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _responsesRef(
    String orgId,
    String bulletinId,
  ) =>
      _firestore
          .collection(AppConstants.organizationsCollection)
          .doc(orgId)
          .collection(AppConstants.bulletinsCollection)
          .doc(bulletinId)
          .collection(AppConstants.reminderResponsesCollection);

  @override
  Future<void> submitResponse({
    required String organizationId,
    required String bulletinId,
    String? text,
    List<String>? selectedOptionIds,
    String? selectedOptionId,
  }) async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('submitBulletinResponse');
      await callable.call<Map<String, dynamic>>({
        'orgId': organizationId,
        'bulletinId': bulletinId,
        if (text != null) 'text': text,
        if (selectedOptionIds != null) 'selectedOptionIds': selectedOptionIds,
        if (selectedOptionId != null) 'selectedOptionId': selectedOptionId,
      });
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionException();
      if (e.code == 'not-found') {
        throw const DatabaseException(
          message:
              'The response service is not deployed yet. '
              'Ask your administrator to deploy the latest cloud functions.',
          code: 'not-found',
        );
      }
      throw DatabaseException(
        message: e.message ?? 'Failed to submit response',
        code: e.code,
      );
    }
  }

  ReminderResponseEntity _fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    final model = ReminderResponseModel.fromFirestore(data, documentId);
    return ReminderResponseEntity(
      userId: model.userId,
      organizationId: model.organizationId,
      reminderId: data['bulletinId'] as String? ?? model.reminderId,
      userDisplayName: model.userDisplayName,
      responseType: model.responseType,
      text: model.text,
      selectedOptionIds: model.selectedOptionIds,
      selectedOptionId: model.selectedOptionId,
      submittedAt: model.submittedAt,
    );
  }

  @override
  Stream<ReminderResponseEntity?> watchMyResponse({
    required String organizationId,
    required String bulletinId,
    required String userId,
  }) {
    return _responsesRef(organizationId, bulletinId)
        .doc(userId)
        .snapshots()
        .map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return _fromFirestore(snap.data()!, snap.id);
    });
  }

  @override
  Stream<List<ReminderResponseEntity>> watchResponses({
    required String organizationId,
    required String bulletinId,
  }) {
    return _responsesRef(organizationId, bulletinId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => _fromFirestore(d.data(), d.id))
              .toList(),
        );
  }
}
