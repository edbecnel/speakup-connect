import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';
import 'package:speakup_connect/features/reminders/data/models/reminder_response_model.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_entity.dart';
import 'package:speakup_connect/features/reminders/domain/repositories/reminder_response_repository.dart';

class ReminderResponseRepositoryImpl implements ReminderResponseRepository {
  ReminderResponseRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _responsesRef(
    String orgId,
    String reminderId,
  ) =>
      _firestore
          .collection(AppConstants.organizationsCollection)
          .doc(orgId)
          .collection(AppConstants.remindersCollection)
          .doc(reminderId)
          .collection(AppConstants.reminderResponsesCollection);

  @override
  Future<void> submitResponse({
    required String organizationId,
    required String reminderId,
    String? text,
    List<String>? selectedOptionIds,
    String? selectedOptionId,
  }) async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('submitReminderResponse');
      await callable.call<Map<String, dynamic>>({
        'orgId': organizationId,
        'reminderId': reminderId,
        if (text != null) 'text': text,
        if (selectedOptionIds != null) 'selectedOptionIds': selectedOptionIds,
        if (selectedOptionId != null) 'selectedOptionId': selectedOptionId,
      });
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') throw const PermissionException();
      throw DatabaseException(
        message: e.message ?? 'Failed to submit response',
        code: e.code,
      );
    }
  }

  @override
  Stream<ReminderResponseEntity?> watchMyResponse({
    required String organizationId,
    required String reminderId,
    required String userId,
  }) {
    return _responsesRef(organizationId, reminderId)
        .doc(userId)
        .snapshots()
        .map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return ReminderResponseModel.fromFirestore(snap.data()!, snap.id);
    });
  }

  @override
  Stream<List<ReminderResponseEntity>> watchResponses({
    required String organizationId,
    required String reminderId,
  }) {
    return _responsesRef(organizationId, reminderId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ReminderResponseModel.fromFirestore(d.data(), d.id))
              .toList(),
        );
  }
}
