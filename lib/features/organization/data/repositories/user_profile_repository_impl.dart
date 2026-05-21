import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';
import 'package:speakup_connect/features/organization/data/models/user_profile_model.dart';
import 'package:speakup_connect/features/organization/domain/entities/user_profile_entity.dart';
import 'package:speakup_connect/features/organization/domain/repositories/user_profile_repository.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  UserProfileRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _usersRef(String orgId) =>
      _firestore
          .collection(AppConstants.organizationsCollection)
          .doc(orgId)
          .collection(AppConstants.usersCollection);

  @override
  Future<UserProfileEntity?> getUserProfile({
    required String orgId,
    required String userId,
  }) async {
    try {
      final doc = await _usersRef(orgId).doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserProfileModel.fromFirestore(doc.data()!, userId);
    } on FirebaseException catch (e) {
      throw DatabaseException(
        message: e.message ?? 'Failed to fetch user profile',
        code: e.code,
      );
    }
  }

  @override
  Stream<UserProfileEntity?> watchUserProfile({
    required String orgId,
    required String userId,
  }) {
    return _usersRef(orgId).doc(userId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserProfileModel.fromFirestore(snap.data()!, userId);
    });
  }

  @override
  Future<UserProfileEntity> createUserProfile({
    required String orgId,
    required String userId,
    required String displayName,
    required String fullName,
    String? studentId,
    String? email,
  }) async {
    final model = UserProfileModel(
      userId: userId,
      organizationId: orgId,
      displayName: displayName,
      fullName: fullName,
      studentId: studentId,
      email: email,
      approvalStatus: ApprovalStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await _usersRef(orgId).doc(userId).set(model.toFirestore());
      return model;
    } on FirebaseException catch (e) {
      throw DatabaseException(
        message: e.message ?? 'Failed to create user profile',
        code: e.code,
      );
    }
  }

  @override
  Future<void> grantPermission({
    required String orgId,
    required String targetUserId,
    required String permission,
  }) async {
    try {
      await _usersRef(orgId).doc(targetUserId).update({
        'permissions': FieldValue.arrayUnion([permission]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw DatabaseException(
        message: e.message ?? 'Failed to grant permission',
        code: e.code,
      );
    }
  }

  @override
  Future<void> revokePermission({
    required String orgId,
    required String targetUserId,
    required String permission,
  }) async {
    try {
      await _usersRef(orgId).doc(targetUserId).update({
        'permissions': FieldValue.arrayRemove([permission]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw DatabaseException(
        message: e.message ?? 'Failed to revoke permission',
        code: e.code,
      );
    }
  }
}
