import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/features/organization/data/repositories/roster_repository_impl.dart';
import 'package:speakup_connect/features/organization/domain/entities/roster_entry_entity.dart';
import 'package:speakup_connect/features/organization/domain/repositories/roster_repository.dart';

final rosterRepositoryProvider = Provider<RosterRepository>((ref) {
  return RosterRepositoryImpl(FirebaseFirestore.instance);
});

/// Streams imported roster documents from Firestore.
final rosterEntriesProvider = StreamProvider<List<RosterEntryEntity>>((ref) {
  final orgId = AppConfig.defaultOrganizationId;
  return ref.watch(rosterRepositoryProvider).watchRoster(orgId: orgId);
});

class RosterGradeActionNotifier extends Notifier<AsyncValue<int?>> {
  @override
  AsyncValue<int?> build() => const AsyncValue.data(null);

  Future<int> assignGrades({
    required Map<String, int> gradesByStudentId,
    Map<String, RosterEntryEntity> entryDetails = const {},
  }) async {
    if (gradesByStudentId.isEmpty) return 0;
    state = const AsyncValue.loading();
    try {
      final count = await ref.read(rosterRepositoryProvider).setStudentGrades(
            orgId: AppConfig.defaultOrganizationId,
            gradesByStudentId: gradesByStudentId,
            entryDetails: entryDetails,
          );
      state = AsyncValue.data(count);
      return count;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<int> assignGrade({
    required String studentId,
    required int gradeLevel,
    RosterEntryEntity? entry,
  }) {
    return assignGrades(
      gradesByStudentId: {studentId: gradeLevel},
      entryDetails: entry == null ? const {} : {studentId: entry},
    );
  }
}

final rosterGradeActionProvider =
    NotifierProvider<RosterGradeActionNotifier, AsyncValue<int?>>(
  RosterGradeActionNotifier.new,
);
