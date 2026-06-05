import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakup_connect/features/organization/domain/entities/roster_entry_entity.dart';

class RosterEntryModel extends RosterEntryEntity {
  const RosterEntryModel({
    required super.studentId,
    required super.fullName,
    super.email,
    super.grade,
    super.section,
    super.isRegistered,
    super.registeredUserId,
    super.importedAt,
  });

  factory RosterEntryModel.fromFirestore(
    Map<String, dynamic> data,
    String studentId,
  ) {
    return RosterEntryModel(
      studentId: studentId,
      fullName: data['fullName'] as String? ?? '',
      email: data['email'] as String?,
      grade: data['grade'] as String?,
      section: data['section'] as String?,
      isRegistered: data['isRegistered'] as bool? ?? false,
      registeredUserId: data['registeredUserId'] as String?,
      importedAt: (data['importedAt'] as Timestamp?)?.toDate(),
    );
  }
}
