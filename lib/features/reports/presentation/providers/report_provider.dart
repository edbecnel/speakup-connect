import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/reports/data/repositories/report_repository_impl.dart';
import 'package:speakup_connect/features/reports/domain/entities/report_category_entity.dart';
import 'package:speakup_connect/features/reports/domain/entities/report_entity.dart';
import 'package:speakup_connect/features/reports/domain/repositories/report_repository.dart';

part 'report_provider.g.dart';

// --- Infrastructure ---

@riverpod
ReportRepository reportRepository(Ref ref) {
  return ReportRepositoryImpl(
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
  );
}

// --- Categories ---

@riverpod
Future<List<ReportCategoryEntity>> reportCategories(Ref ref) async {
  const orgId = AppConfig.defaultOrganizationId;
  return ref.watch(reportRepositoryProvider).getCategories(orgId);
}

// --- My Reports Stream ---

@riverpod
Stream<List<ReportEntity>> myReports(Ref ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null || user.isAnonymous) return const Stream.empty();

  return ref.watch(reportRepositoryProvider).watchMyReports(
        organizationId: AppConfig.defaultOrganizationId,
        userId: user.uid,
      );
}

// --- Status Filter for My Reports Tabs ---

@riverpod
class MyReportsStatusFilter extends _$MyReportsStatusFilter {
  @override
  ReportStatus? build() => null; // null = All

  void setFilter(ReportStatus? status) => state = status;
}

// --- Submit Report State ---

/// Holds the multi-step report form state across all 3 wizard steps.
@riverpod
class SubmitReportFormNotifier extends _$SubmitReportFormNotifier {
  @override
  SubmitReportFormState build() => const SubmitReportFormState();

  void updateCategory(String categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updateIsAnonymous(bool isAnonymous) {
    state = state.copyWith(isAnonymous: isAnonymous);
  }

  void addPhoto(String path) {
    if (state.photoPaths.length >= 3) return;
    state = state.copyWith(photoPaths: [...state.photoPaths, path]);
  }

  void removePhoto(int index) {
    final updated = [...state.photoPaths]..removeAt(index);
    state = state.copyWith(photoPaths: updated);
  }

  void reset() {
    state = const SubmitReportFormState();
  }
}

class SubmitReportFormState {
  const SubmitReportFormState({
    this.categoryId,
    this.title = '',
    this.description = '',
    this.isAnonymous = false,
    this.photoPaths = const [],
  });

  final String? categoryId;
  final String title;
  final String description;
  final bool isAnonymous;
  final List<String> photoPaths;

  bool get isStep1Valid =>
      categoryId != null && title.trim().length >= 5 && description.trim().length >= 10;

  SubmitReportFormState copyWith({
    String? categoryId,
    String? title,
    String? description,
    bool? isAnonymous,
    List<String>? photoPaths,
  }) {
    return SubmitReportFormState(
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      photoPaths: photoPaths ?? this.photoPaths,
    );
  }
}

// --- Report Submission ---

@riverpod
class SubmitReportNotifier extends _$SubmitReportNotifier {
  @override
  AsyncValue<ReportEntity?> build() => const AsyncData(null);

  Future<ReportEntity?> submit() async {
    final formState = ref.read(submitReportFormProvider);
    final user = ref.read(currentUserProvider);
    const orgId = AppConfig.defaultOrganizationId;

    if (!formState.isStep1Valid) return null;

    state = const AsyncLoading();
    try {
      final params = SubmitReportParams(
        organizationId: orgId,
        categoryId: formState.categoryId!,
        title: formState.title,
        description: formState.description,
        isAnonymous: formState.isAnonymous,
        photoPaths: formState.photoPaths,
        submittedBy: formState.isAnonymous ? null : user?.uid,
        submitterDisplayName: formState.isAnonymous ? null : user?.displayName,
      );

      final report = await ref.read(reportRepositoryProvider).submitReport(params);
      state = AsyncData(report);

      // Reset form after successful submission
      ref.read(submitReportFormProvider.notifier).reset();

      return report;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}
