import 'package:speakup_connect/features/reports/domain/entities/report_category_entity.dart';
import 'package:speakup_connect/features/reports/domain/entities/report_entity.dart';

/// Parameters for submitting a new report.
class SubmitReportParams {
  const SubmitReportParams({
    required this.organizationId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.isAnonymous,
    this.photoPaths = const [],
    this.submittedBy,
    this.submitterDisplayName,
  });

  final String organizationId;
  final String categoryId;
  final String title;
  final String description;
  final bool isAnonymous;
  final List<String> photoPaths;
  final String? submittedBy;
  final String? submitterDisplayName;
}

/// Abstract report repository interface.
abstract class ReportRepository {
  /// Submits a new report.
  /// Returns the created [ReportEntity] with generated ID and reference number.
  Future<ReportEntity> submitReport(SubmitReportParams params);

  /// Returns a real-time stream of reports submitted by [userId] in [organizationId].
  Stream<List<ReportEntity>> watchMyReports({
    required String organizationId,
    required String userId,
  });

  /// Returns a one-time fetch of a specific report by [reportId].
  Future<ReportEntity> getReportById({
    required String organizationId,
    required String reportId,
  });

  /// Returns all active categories for [organizationId].
  Future<List<ReportCategoryEntity>> getCategories(String organizationId);

  // --- Admin operations ---

  /// Returns a real-time stream of ALL reports for [organizationId] (admin only).
  Stream<List<ReportEntity>> watchAllReports({
    required String organizationId,
    ReportStatus? filterStatus,
    String? filterCategoryId,
  });

  /// Updates the status of a report. Creates a [StatusHistoryEntry].
  Future<void> updateReportStatus({
    required String organizationId,
    required String reportId,
    required ReportStatus newStatus,
    required String changedByUid,
    String? note,
  });

  /// Adds an admin note to a report.
  Future<void> addAdminNote({
    required String organizationId,
    required String reportId,
    required String authorId,
    required String authorName,
    required String content,
  });

  /// Assigns a report to an admin user.
  Future<void> assignReport({
    required String organizationId,
    required String reportId,
    required String adminUid,
  });
}
