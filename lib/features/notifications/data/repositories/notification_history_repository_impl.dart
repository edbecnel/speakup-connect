import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/features/notifications/data/models/notification_history_model.dart';
import 'package:speakup_connect/features/notifications/domain/entities/notification_history_entity.dart';
import 'package:speakup_connect/features/notifications/domain/repositories/notification_history_repository.dart';

class NotificationHistoryRepositoryImpl implements NotificationHistoryRepository {
  NotificationHistoryRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _ref(String orgId) => _firestore
      .collection(AppConstants.organizationsCollection)
      .doc(orgId)
      .collection(AppConstants.notificationHistoryCollection);

  @override
  Stream<List<NotificationHistoryEntity>> watchOrgHistory(
    String organizationId,
  ) {
    return _ref(organizationId)
        .orderBy('removedAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) => NotificationHistoryModel.fromFirestore(d.data(), d.id),
              )
              .toList(),
        );
  }

  @override
  Stream<List<NotificationHistoryEntity>> watchAuthorHistory({
    required String organizationId,
    required String userId,
  }) {
    return _ref(organizationId)
        .where('createdBy', isEqualTo: userId)
        .orderBy('removedAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) => NotificationHistoryModel.fromFirestore(d.data(), d.id),
              )
              .toList(),
        );
  }
}
