import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/l10n/app_localizations.dart';

String localizedPermissionName(AppLocalizations l10n, AppPermission permission) {
  return switch (permission) {
    AppPermission.viewAllReports => l10n.permissionViewAllReports,
    AppPermission.viewGroupReports => l10n.permissionViewGroupReports,
    AppPermission.approveReport => l10n.permissionApproveReport,
    AppPermission.manageReports => l10n.permissionManageReports,
    AppPermission.postBulletinOrgWide => l10n.permissionPostBulletinOrgWide,
    AppPermission.postBulletinToGroup => l10n.permissionPostBulletinToGroup,
    AppPermission.broadcastReminders => l10n.permissionBroadcastReminders,
    AppPermission.approveReminders => l10n.permissionApproveReminders,
    AppPermission.manageGroupRoster => l10n.permissionManageGroupRoster,
    AppPermission.manageClassRoster => l10n.permissionManageClassRoster,
    AppPermission.approveApplications => l10n.permissionApproveApplications,
    AppPermission.blockUsers => l10n.permissionBlockUsers,
    AppPermission.manageOrganizationSettings =>
      l10n.permissionManageOrganizationSettings,
    AppPermission.manageRoles => l10n.permissionManageRoles,
    AppPermission.manageTranslations => l10n.permissionManageTranslations,
    AppPermission.viewAuditLogs => l10n.permissionViewAuditLogs,
  };
}

String localizedPermissionGroup(AppLocalizations l10n, AppPermission permission) {
  return switch (permission) {
    AppPermission.viewAllReports ||
    AppPermission.viewGroupReports ||
    AppPermission.approveReport ||
    AppPermission.manageReports =>
      l10n.permissionGroupReports,
    AppPermission.postBulletinOrgWide ||
    AppPermission.postBulletinToGroup =>
      l10n.permissionGroupBulletins,
    AppPermission.broadcastReminders ||
    AppPermission.approveReminders =>
      l10n.permissionGroupReminders,
    AppPermission.manageGroupRoster ||
    AppPermission.manageClassRoster ||
    AppPermission.approveApplications ||
    AppPermission.blockUsers =>
      l10n.permissionGroupRosterUsers,
    AppPermission.manageOrganizationSettings ||
    AppPermission.manageRoles ||
    AppPermission.manageTranslations ||
    AppPermission.viewAuditLogs =>
      l10n.permissionGroupAdministration,
  };
}
