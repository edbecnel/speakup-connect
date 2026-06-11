import 'package:speakup_connect/features/organization/domain/entities/roster_entry_entity.dart';

/// Repository for org student/member roster operations.
abstract class RosterRepository {
  /// Streams all roster entries for the organization.
  Stream<List<RosterEntryEntity>> watchRoster({required String orgId});

  /// Sets the grade for one roster student and syncs enrolled profile if linked.
  Future<void> setStudentGrade({
    required String orgId,
    required String studentId,
    required int gradeLevel,
    RosterEntryEntity? entry,
  });

  /// Sets the grade for multiple roster students in one batch.
  ///
  /// [entryDetails] supplies name/registration metadata when upserting roster
  /// rows that only exist as user profiles today.
  Future<int> setStudentGrades({
    required String orgId,
    required Map<String, int> gradesByStudentId,
    Map<String, RosterEntryEntity> entryDetails = const {},
  });

  /// Admin-provisions a student account (roster + Auth + approved profile).
  Future<ProvisionedStudentResult> provisionStudent({
    required String orgId,
    required String studentId,
    required String fullName,
    required int gradeLevel,
    String? email,
  });

  /// Admin sets a new login password for a member.
  Future<void> resetOrgMemberPassword({
    required String orgId,
    required String userId,
    required String newPassword,
  });

  /// Admin updates member profile fields (name, student ID, email, grade).
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
  });
}

/// Result of [RosterRepository.provisionStudent].
class ProvisionedStudentResult {
  const ProvisionedStudentResult({
    required this.studentId,
    required this.userId,
  });

  final String studentId;
  final String userId;
}
