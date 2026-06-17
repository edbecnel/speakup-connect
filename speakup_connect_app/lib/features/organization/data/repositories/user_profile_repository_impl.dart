import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakup_connect/core/auth/student_auth_credentials.dart';
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
      applicationSubmitted: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      // Merge so re-submissions after rejection update fields in place.
      await _usersRef(orgId).doc(userId).set(
            model.toFirestore(),
            SetOptions(merge: true),
          );
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

  @override
  Stream<List<UserProfileEntity>> watchPendingApplications({
    required String orgId,
  }) {
    // Stream the whole collection and filter client-side so legacy profiles
    // missing indexed fields still appear in the admin queue.
    return _usersRef(orgId).snapshots().map((snap) {
      final profiles = snap.docs
          .map((d) => UserProfileModel.fromFirestore(d.data(), d.id))
          .where((p) => p.isAwaitingJoinApproval)
          .toList();
      profiles.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return profiles;
    });
  }

  @override
  Future<void> updateApprovalStatus({
    required String orgId,
    required String targetUserId,
    required ApprovalStatus status,
    String? reviewedBy,
    String? rejectionReason,
  }) async {
    final update = <String, dynamic>{
      'approvalStatus': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (reviewedBy != null) {
      update['reviewedBy'] = reviewedBy;
      update['reviewedAt'] = FieldValue.serverTimestamp();
    }
    if (status == ApprovalStatus.rejected && rejectionReason != null) {
      update['rejectionReason'] = rejectionReason;
    } else if (status == ApprovalStatus.approved) {
      update['rejectionReason'] = FieldValue.delete();
    }

    try {
      await _usersRef(orgId).doc(targetUserId).update(update);

      if (status == ApprovalStatus.approved) {
        final doc = await _usersRef(orgId).doc(targetUserId).get();
        final data = doc.data();
        if (data != null) {
          final profile = UserProfileModel.fromFirestore(data, targetUserId);
          final studentId = profile.studentId;
          if (studentId != null && studentId.isNotEmpty) {
            await _rosterRef(orgId).doc(studentId).set(
              {
                'fullName': profile.fullName,
                if (profile.email != null) 'email': profile.email,
                'isRegistered': true,
                'registeredUserId': targetUserId,
                'importedAt': FieldValue.serverTimestamp(),
                'importSource': 'approval',
                'updatedAt': FieldValue.serverTimestamp(),
              },
              SetOptions(merge: true),
            );
          }
        }
      }
    } on FirebaseException catch (e) {
      throw DatabaseException(
        message: e.message ?? 'Failed to update approval status',
        code: e.code,
      );
    }
  }

  CollectionReference<Map<String, dynamic>> _rosterRef(String orgId) =>
      _firestore
          .collection(AppConstants.organizationsCollection)
          .doc(orgId)
          .collection(AppConstants.rosterCollection);

  @override
  Stream<List<UserProfileEntity>> watchEnrolledUsers({
    required String orgId,
  }) {
    return _usersRef(orgId)
        .where('approvalStatus', isEqualTo: ApprovalStatus.approved.name)
        .orderBy('displayName')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => UserProfileModel.fromFirestore(d.data(), d.id))
            .where((p) => p.isEnrolled)
            .toList());
  }

  @override
  Stream<List<UserProfileEntity>> watchManagedMembers({
    required String orgId,
  }) {
    return _usersRef(orgId)
        .where(
          'approvalStatus',
          whereIn: [
            ApprovalStatus.approved.name,
            ApprovalStatus.unenrolled.name,
          ],
        )
        .snapshots()
        .map((snap) {
      final members = snap.docs
          .map((d) => UserProfileModel.fromFirestore(d.data(), d.id))
          .where((p) => p.isApproved || p.isUnenrolled)
          .toList();
      members.sort(
        (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
      );
      return members;
    });
  }

  @override
  Future<void> setUserBlockStatus({
    required String orgId,
    required String targetUserId,
    required bool isActive,
    required String actorId,
    String? reason,
  }) async {
    final update = <String, dynamic>{
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (isActive) {
      update['blockReason'] = FieldValue.delete();
      update['blockedAt'] = FieldValue.delete();
      update['blockedBy'] = FieldValue.delete();
    } else {
      update['blockReason'] = reason ?? 'No reason provided';
      update['blockedAt'] = FieldValue.serverTimestamp();
      update['blockedBy'] = actorId;
    }

    try {
      await _usersRef(orgId).doc(targetUserId).update(update);
    } on FirebaseException catch (e) {
      throw DatabaseException(
        message: e.message ?? 'Failed to update user block status',
        code: e.code,
      );
    }
  }

  @override
  Future<int> unenrollUsers({
    required String orgId,
    required List<String> targetUserIds,
    required String actorId,
    required String reason,
  }) async {
    if (targetUserIds.isEmpty) return 0;

    try {
      final batch = _firestore.batch();
      final now = FieldValue.serverTimestamp();

      for (final userId in targetUserIds) {
        batch.update(_usersRef(orgId).doc(userId), {
          'approvalStatus': ApprovalStatus.unenrolled.name,
          'unenrollReason': reason,
          'unenrolledAt': now,
          'unenrolledBy': actorId,
          'updatedAt': now,
        });
      }

      await batch.commit();
      return targetUserIds.length;
    } on FirebaseException catch (e) {
      throw DatabaseException(
        message: e.message ?? 'Failed to unenroll users',
        code: e.code,
      );
    }
  }

  @override
  Future<int> reEnrollUsers({
    required String orgId,
    required List<String> targetUserIds,
    required String actorId,
  }) async {
    if (targetUserIds.isEmpty) return 0;

    try {
      final batch = _firestore.batch();
      final now = FieldValue.serverTimestamp();

      for (final userId in targetUserIds) {
        batch.update(_usersRef(orgId).doc(userId), {
          'approvalStatus': ApprovalStatus.approved.name,
          'isActive': true,
          'unenrollReason': FieldValue.delete(),
          'unenrolledAt': FieldValue.delete(),
          'unenrolledBy': FieldValue.delete(),
          'updatedAt': now,
        });
      }

      await batch.commit();
      return targetUserIds.length;
    } on FirebaseException catch (e) {
      throw DatabaseException(
        message: e.message ?? 'Failed to re-enroll users',
        code: e.code,
      );
    }
  }

  @override
  Future<void> setMemberGradeLevel({
    required String orgId,
    required String targetUserId,
    required int gradeLevel,
  }) async {
    try {
      await _usersRef(orgId).doc(targetUserId).update({
        'gradeLevel': gradeLevel,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw DatabaseException(
        message: e.message ?? 'Failed to update member grade',
        code: e.code,
      );
    }
  }

  @override
  Future<void> updateContactEmail({
    required String orgId,
    required String userId,
    String? email,
  }) async {
    final trimmed = email?.trim();
    final update = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (trimmed == null || trimmed.isEmpty) {
      update['email'] = FieldValue.delete();
    } else {
      update['email'] = normalizeContactEmail(trimmed);
    }

    try {
      await _usersRef(orgId).doc(userId).update(update);

      final profileDoc = await _usersRef(orgId).doc(userId).get();
      final studentId = profileDoc.data()?['studentId'] as String?;
      if (studentId != null && studentId.isNotEmpty) {
        final rosterUpdate = <String, dynamic>{
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (trimmed == null || trimmed.isEmpty) {
          rosterUpdate['email'] = FieldValue.delete();
        } else {
          rosterUpdate['email'] = normalizeContactEmail(trimmed);
        }
        await _rosterRef(orgId).doc(studentId).set(
              rosterUpdate,
              SetOptions(merge: true),
            );
      }
    } on FirebaseException catch (e) {
      throw DatabaseException(
        message: e.message ?? 'Failed to update email',
        code: e.code,
      );
    }
  }
}
