import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';
import 'package:speakup_connect/features/groups/data/models/group_join_request_model.dart';
import 'package:speakup_connect/features/groups/data/models/group_leave_request_model.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_join_request_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_leave_request_entity.dart';

/// Callable-backed membership request mutations and Firestore reads.
class GroupMembershipRemoteDataSource {
  GroupMembershipRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _joinRequestsRef(
    String orgId,
    String groupId,
  ) =>
      _firestore
          .collection(AppConstants.organizationsCollection)
          .doc(orgId)
          .collection(AppConstants.groupsCollection)
          .doc(groupId)
          .collection(AppConstants.groupJoinRequestsCollection);

  CollectionReference<Map<String, dynamic>> _leaveRequestsRef(
    String orgId,
    String groupId,
  ) =>
      _firestore
          .collection(AppConstants.organizationsCollection)
          .doc(orgId)
          .collection(AppConstants.groupsCollection)
          .doc(groupId)
          .collection(AppConstants.groupLeaveRequestsCollection);

  Future<void> _call(String name, Map<String, dynamic> data) async {
    try {
      await FirebaseFunctions.instance
          .httpsCallable(name)
          .call<Map<String, dynamic>>(data);
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'permission-denied') {
        throw const PermissionException();
      }
      throw DatabaseException(
        message: e.message ?? 'Membership request failed',
        code: e.code,
      );
    }
  }

  Stream<List<GroupJoinRequestEntity>> watchPendingJoinRequests({
    required String organizationId,
    required String groupId,
  }) {
    return _joinRequestsRef(organizationId, groupId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) => GroupJoinRequestModel.fromFirestore(d.data(), d.id),
              )
              .toList(),
        );
  }

  Stream<List<GroupLeaveRequestEntity>> watchPendingLeaveRequests({
    required String organizationId,
    required String groupId,
  }) {
    return _leaveRequestsRef(organizationId, groupId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) => GroupLeaveRequestModel.fromFirestore(d.data(), d.id),
              )
              .toList(),
        );
  }

  Stream<GroupJoinRequestEntity?> watchMyJoinRequest({
    required String organizationId,
    required String groupId,
    required String userId,
  }) {
    return _joinRequestsRef(organizationId, groupId)
        .doc(userId)
        .snapshots()
        .map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return GroupJoinRequestModel.fromFirestore(snap.data()!, snap.id);
    });
  }

  Stream<GroupLeaveRequestEntity?> watchMyLeaveRequest({
    required String organizationId,
    required String groupId,
    required String userId,
  }) {
    return _leaveRequestsRef(organizationId, groupId)
        .doc(userId)
        .snapshots()
        .map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return GroupLeaveRequestModel.fromFirestore(snap.data()!, snap.id);
    });
  }

  Future<void> submitJoinRequest({
    required String organizationId,
    required String groupId,
    String? message,
  }) =>
      _call('submitGroupJoinRequest', {
        'orgId': organizationId,
        'groupId': groupId,
        if (message != null && message.trim().isNotEmpty)
          'message': message.trim(),
      });

  Future<void> withdrawJoinRequest({
    required String organizationId,
    required String groupId,
  }) =>
      _call('withdrawGroupJoinRequest', {
        'orgId': organizationId,
        'groupId': groupId,
      });

  Future<void> reviewJoinRequest({
    required String organizationId,
    required String groupId,
    required String userId,
    required bool approve,
    String? rejectionReason,
  }) =>
      _call('reviewGroupJoinRequest', {
        'orgId': organizationId,
        'groupId': groupId,
        'userId': userId,
        'action': approve ? 'approve' : 'reject',
        if (!approve && rejectionReason != null)
          'rejectionReason': rejectionReason.trim(),
      });

  Future<void> voluntaryLeave({
    required String organizationId,
    required String groupId,
  }) =>
      _call('voluntaryLeaveGroup', {
        'orgId': organizationId,
        'groupId': groupId,
      });

  Future<void> submitLeaveRequest({
    required String organizationId,
    required String groupId,
    required String reason,
  }) =>
      _call('submitGroupLeaveRequest', {
        'orgId': organizationId,
        'groupId': groupId,
        'reason': reason.trim(),
      });

  Future<void> withdrawLeaveRequest({
    required String organizationId,
    required String groupId,
  }) =>
      _call('withdrawGroupLeaveRequest', {
        'orgId': organizationId,
        'groupId': groupId,
      });

  Future<void> reviewLeaveRequest({
    required String organizationId,
    required String groupId,
    required String userId,
    required bool approve,
    String? rejectionReason,
  }) =>
      _call('reviewGroupLeaveRequest', {
        'orgId': organizationId,
        'groupId': groupId,
        'userId': userId,
        'action': approve ? 'approve' : 'reject',
        if (!approve && rejectionReason != null)
          'rejectionReason': rejectionReason.trim(),
      });

  Future<void> removeMemberWithNotification({
    required String organizationId,
    required String groupId,
    required String userId,
  }) =>
      _call('removeGroupMemberWithNotification', {
        'orgId': organizationId,
        'groupId': groupId,
        'userId': userId,
      });
}
