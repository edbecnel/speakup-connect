import 'package:speakup_connect/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:speakup_connect/features/organization/domain/entities/enrolled_member.dart';
import 'package:speakup_connect/features/organization/domain/entities/user_profile_entity.dart';import 'package:speakup_connect/features/reports/domain/entities/report_entity.dart';
import 'package:speakup_connect/l10n/app_localizations.dart';

String localizedMemberStatusFilter(
  AppLocalizations l10n,
  MemberStatusFilter filter,
) {
  return switch (filter) {
    MemberStatusFilter.active => l10n.commonActive,
    MemberStatusFilter.blocked => l10n.commonBlocked,
    MemberStatusFilter.unenrolled => l10n.commonUnenrolled,
    MemberStatusFilter.all => l10n.commonAll,
  };
}

String localizedReportStatus(AppLocalizations l10n, ReportStatus status) {
  return switch (status) {
    ReportStatus.submitted => l10n.adminDashboardTabSubmitted,
    ReportStatus.underReview => l10n.adminDashboardTabUnderReview,
    ReportStatus.inProgress => l10n.adminDashboardTabInProgress,
    ReportStatus.resolved => l10n.adminDashboardTabResolved,
    ReportStatus.closed => l10n.adminDashboardTabClosed,
  };
}

String localizedReportPriority(AppLocalizations l10n, ReportPriority priority) {
  return switch (priority) {
    ReportPriority.low => l10n.adminDashboardReportPriorityLow,
    ReportPriority.medium => l10n.adminDashboardReportPriorityMedium,
    ReportPriority.high => l10n.adminDashboardReportPriorityHigh,
    ReportPriority.urgent => l10n.adminDashboardReportPriorityUrgent,
  };
}

String localizedAdminReportsTab(AppLocalizations l10n, AdminReportsTab tab) {
  return switch (tab) {
    AdminReportsTab.allActive => l10n.adminDashboardTabAll,
    AdminReportsTab.submitted => l10n.adminDashboardTabSubmitted,
    AdminReportsTab.underReview => l10n.adminDashboardTabUnderReview,
    AdminReportsTab.inProgress => l10n.adminDashboardTabInProgress,
    AdminReportsTab.resolved => l10n.adminDashboardTabResolved,
    AdminReportsTab.closed => l10n.adminDashboardTabClosed,
  };
}

String localizedAdminReportsStatLabel(AppLocalizations l10n, AdminReportsTab tab) {
  return switch (tab) {
    AdminReportsTab.allActive => l10n.adminDashboardStatTotal,
    AdminReportsTab.submitted => l10n.adminDashboardStatSubmitted,
    AdminReportsTab.underReview => l10n.adminDashboardStatUnderReview,
    AdminReportsTab.inProgress => l10n.adminDashboardStatInProgress,
    AdminReportsTab.resolved => l10n.adminDashboardStatResolved,
    AdminReportsTab.closed => l10n.adminDashboardStatClosed,
  };
}

String localizedMemberManagementStatus(
  AppLocalizations l10n,
  UserProfileEntity user,
) {
  if (user.isUnenrolled) return l10n.commonUnenrolled;
  if (user.isBlocked) return l10n.commonBlocked;
  if (user.isApproved) return l10n.commonActive;
  return user.approvalStatus.name;
}
