import 'package:speakup_connect/features/organization/domain/entities/enrolled_member.dart';
import 'package:speakup_connect/features/organization/domain/entities/user_profile_entity.dart';

/// A student/member row from the org roster used for signup verification.
class RosterEntryEntity {
  const RosterEntryEntity({
    required this.studentId,
    required this.fullName,
    this.email,
    this.grade,
    this.section,
    this.isRegistered = false,
    this.registeredUserId,
    this.importedAt,
  });

  final String studentId;
  final String fullName;
  final String? email;
  final String? grade;
  final String? section;
  final bool isRegistered;
  final String? registeredUserId;
  final DateTime? importedAt;

  int? get gradeLevel => parseGradeLevel(grade);

  /// Builds a roster row from a user profile when no roster document exists yet.
  factory RosterEntryEntity.fromProfile(UserProfileEntity profile) {
    final studentId = profile.studentId;
    assert(studentId != null && studentId.isNotEmpty);
    return RosterEntryEntity(
      studentId: studentId!,
      fullName: profile.fullName.isNotEmpty
          ? profile.fullName
          : profile.displayName,
      email: profile.email,
      grade: profile.gradeLevel != null
          ? formatGradeForRoster(profile.gradeLevel!)
          : null,
      isRegistered: profile.isApproved,
      registeredUserId: profile.userId,
    );
  }

  /// Merges an imported roster row with a linked user profile.
  RosterEntryEntity mergedWith(UserProfileEntity profile) {
    return RosterEntryEntity(
      studentId: studentId,
      fullName: fullName.isNotEmpty ? fullName : profile.fullName,
      email: email ?? profile.email,
      grade: grade ??
          (profile.gradeLevel != null
              ? formatGradeForRoster(profile.gradeLevel!)
              : null),
      section: section,
      isRegistered: isRegistered || profile.isApproved,
      registeredUserId: registeredUserId ?? profile.userId,
      importedAt: importedAt,
    );
  }
}

/// Formats a numeric grade for storage in roster documents.
String formatGradeForRoster(int gradeLevel) => 'Grade $gradeLevel';
