import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';
import 'package:speakup_connect/features/organization/data/models/roster_entry_model.dart';
import 'package:speakup_connect/features/organization/domain/entities/roster_entry_entity.dart';
import 'package:speakup_connect/features/organization/domain/repositories/roster_repository.dart';

class RosterRepositoryImpl implements RosterRepository {
  RosterRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _rosterRef(String orgId) =>
      _firestore
          .collection(AppConstants.organizationsCollection)
          .doc(orgId)
          .collection(AppConstants.rosterCollection);

  CollectionReference<Map<String, dynamic>> _usersRef(String orgId) =>
      _firestore
          .collection(AppConstants.organizationsCollection)
          .doc(orgId)
          .collection(AppConstants.usersCollection);

  @override
  Stream<List<RosterEntryEntity>> watchRoster({required String orgId}) {
    return _rosterRef(orgId).snapshots().map((snap) {
      final entries = snap.docs
          .map((doc) => RosterEntryModel.fromFirestore(doc.data(), doc.id))
          .toList();
      entries.sort(
        (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
      );
      return entries;
    });
  }

  @override
  Future<void> setStudentGrade({
    required String orgId,
    required String studentId,
    required int gradeLevel,
    RosterEntryEntity? entry,
  }) async {
    await setStudentGrades(
      orgId: orgId,
      gradesByStudentId: {studentId: gradeLevel},
      entryDetails: entry == null ? const {} : {studentId: entry},
    );
  }

  @override
  Future<int> setStudentGrades({
    required String orgId,
    required Map<String, int> gradesByStudentId,
    Map<String, RosterEntryEntity> entryDetails = const {},
  }) async {
    if (gradesByStudentId.isEmpty) return 0;

    try {
      final batch = _firestore.batch();
      final now = FieldValue.serverTimestamp();
      final gradeLabelCache = <int, String>{};

      for (final entry in gradesByStudentId.entries) {
        final gradeLabel = gradeLabelCache.putIfAbsent(
          entry.value,
          () => formatGradeForRoster(entry.value),
        );
        final rosterRef = _rosterRef(orgId).doc(entry.key);
        final details = entryDetails[entry.key];
        final payload = <String, dynamic>{
          'grade': gradeLabel,
          'updatedAt': now,
        };
        if (details != null) {
          payload['fullName'] = details.fullName;
          if (details.email != null) payload['email'] = details.email;
          if (details.section != null) payload['section'] = details.section;
          if (details.registeredUserId != null) {
            payload['registeredUserId'] = details.registeredUserId;
            payload['isRegistered'] = true;
          }
        }
        batch.set(rosterRef, payload, SetOptions(merge: true));
      }

      await batch.commit();

      // Sync enrolled profiles for registered students.
      final rosterDocs = await Future.wait(
        gradesByStudentId.keys
            .map((id) => _rosterRef(orgId).doc(id).get())
            .toList(),
      );

      final profileBatch = _firestore.batch();
      var profileUpdates = 0;

      for (final doc in rosterDocs) {
        if (!doc.exists) continue;
        final userId = doc.data()?['registeredUserId'] as String?;
        if (userId == null) continue;
        final gradeLevel = gradesByStudentId[doc.id];
        if (gradeLevel == null) continue;
        profileBatch.update(_usersRef(orgId).doc(userId), {
          'gradeLevel': gradeLevel,
          'updatedAt': now,
        });
        profileUpdates++;
      }

      if (profileUpdates > 0) {
        await profileBatch.commit();
      }

      return gradesByStudentId.length;
    } on FirebaseException catch (e) {
      throw DatabaseException(
        message: e.message ?? 'Failed to update roster grades',
        code: e.code,
      );
    }
  }

  @override
  Future<ProvisionedStudentResult> provisionStudent({
    required String orgId,
    required String studentId,
    required String fullName,
    required int gradeLevel,
    String? email,
  }) async {
    try {
      final trimmedEmail = email?.trim();
      final callable =
          FirebaseFunctions.instance.httpsCallable('provisionStudent');
      final result = await callable.call<Map<String, dynamic>>({
        'orgId': orgId,
        'studentId': studentId.trim(),
        'fullName': fullName.trim(),
        'gradeLevel': gradeLevel,
        if (trimmedEmail != null && trimmedEmail.isNotEmpty)
          'email': trimmedEmail,
      });
      final data = result.data;
      return ProvisionedStudentResult(
        studentId: data['studentId'] as String? ?? studentId.trim(),
        userId: data['userId'] as String? ?? '',
      );
    } on FirebaseFunctionsException catch (e) {
      throw DatabaseException(
        message: e.message ?? 'Failed to add student',
        code: e.code,
      );
    }
  }

  @override
  Future<void> resetOrgMemberPassword({
    required String orgId,
    required String userId,
    required String newPassword,
  }) async {
    try {
      await FirebaseFunctions.instance
          .httpsCallable('resetOrgMemberPassword')
          .call<Map<String, dynamic>>({
        'orgId': orgId,
        'userId': userId,
        'newPassword': newPassword,
      });
    } on FirebaseFunctionsException catch (e) {
      throw DatabaseException(
        message: e.message ?? 'Failed to reset password',
        code: e.code,
      );
    }
  }

  @override
  Future<void> updateOrgMember({
    required String orgId,
    required String userId,
    required String fullName,
    String? studentId,
    String? email,
    int? gradeLevel,
    bool clearEmail = false,
    bool clearStudentId = false,
    bool clearGrade = false,
  }) async {
    try {
      final updates = <String, dynamic>{
        'fullName': fullName.trim(),
        if (clearStudentId) 'studentId': null,
        if (!clearStudentId && studentId != null) 'studentId': studentId.trim(),
        if (clearEmail) 'email': null,
        if (!clearEmail && email != null) 'email': email.trim(),
        if (clearGrade) 'gradeLevel': null,
        if (!clearGrade && gradeLevel != null) 'gradeLevel': gradeLevel,
      };

      await FirebaseFunctions.instance
          .httpsCallable('updateOrgMember')
          .call<Map<String, dynamic>>({
        'orgId': orgId,
        'userId': userId,
        'updates': updates,
      });
    } on FirebaseFunctionsException catch (e) {
      throw DatabaseException(
        message: e.message ?? 'Failed to update member',
        code: e.code,
      );
    }
  }
}
