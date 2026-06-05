import 'package:speakup_connect/features/organization/domain/entities/user_profile_entity.dart';

/// An enrolled member with a resolved grade level for management screens.
class EnrolledMember {
  const EnrolledMember({
    required this.user,
    required this.gradeLevel,
  });

  final UserProfileEntity user;
  final int? gradeLevel;

  String get userId => user.userId;
}

/// Parses a grade level from roster/profile text (e.g. "Grade 10", "10-Rizal").
int? parseGradeLevel(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final match = RegExp(r'\d{1,2}').firstMatch(raw);
  if (match == null) return null;
  return int.tryParse(match.group(0)!);
}

/// Filters members by enrollment/block status on the management screen.
enum MemberStatusFilter {
  active,
  blocked,
  unenrolled,
  all,
}

extension MemberStatusFilterX on MemberStatusFilter {
  String get label => switch (this) {
        MemberStatusFilter.active => 'Active',
        MemberStatusFilter.blocked => 'Blocked',
        MemberStatusFilter.unenrolled => 'Unenrolled',
        MemberStatusFilter.all => 'All',
      };

  bool matches(UserProfileEntity user) => switch (this) {
        MemberStatusFilter.active => user.isApproved && !user.isBlocked,
        MemberStatusFilter.blocked => user.isApproved && user.isBlocked,
        MemberStatusFilter.unenrolled => user.isUnenrolled,
        MemberStatusFilter.all => user.isApproved || user.isUnenrolled,
      };
}

extension ManagedMemberStatusX on UserProfileEntity {
  String get managementStatusLabel {
    if (isUnenrolled) return 'Unenrolled';
    if (isBlocked) return 'Blocked';
    if (isApproved) return 'Active';
    return approvalStatus.name;
  }
}
