import 'package:speakup_connect/core/permissions/org_scope_type.dart';
import 'package:speakup_connect/features/organization/domain/entities/organization_config_entity.dart';
import 'package:speakup_connect/features/roles/domain/entities/role_assignment_entity.dart';
import 'package:speakup_connect/l10n/app_localizations.dart';

String localizedOrganizationTypeName(
  AppLocalizations l10n,
  OrganizationType type,
) {
  return switch (type) {
    OrganizationType.school => l10n.orgTypeAdminSchool,
    OrganizationType.university => l10n.orgTypeAdminUniversity,
    OrganizationType.lgu => l10n.orgTypeAdminLgu,
    OrganizationType.ngo => l10n.orgTypeAdminNgo,
    OrganizationType.church => l10n.orgTypeAdminChurch,
    OrganizationType.corporation => l10n.orgTypeAdminCorporation,
    OrganizationType.other => l10n.orgTypeAdminOther,
  };
}

String localizedOrganizationTypeDescription(
  AppLocalizations l10n,
  OrganizationType type,
) {
  return switch (type) {
    OrganizationType.school => l10n.orgTypeAdminSchoolDesc,
    OrganizationType.university => l10n.orgTypeAdminUniversityDesc,
    OrganizationType.lgu => l10n.orgTypeAdminLguDesc,
    OrganizationType.ngo => l10n.orgTypeAdminNgoDesc,
    OrganizationType.church => l10n.orgTypeAdminChurchDesc,
    OrganizationType.corporation => l10n.orgTypeAdminCorporationDesc,
    OrganizationType.other => l10n.orgTypeAdminOtherDesc,
  };
}

String localizedOrgScopeDropdownLabel(AppLocalizations l10n, OrgScopeType type) {
  return switch (type) {
    OrgScopeType.org => l10n.assignRoleScopeOptionOrg,
    OrgScopeType.tag => l10n.assignRoleScopeOptionTag,
    OrgScopeType.classUnit => l10n.assignRoleScopeOptionClass,
    OrgScopeType.group => l10n.assignRoleScopeOptionGroup,
    OrgScopeType.department => l10n.assignRoleScopeOptionDepartment,
    OrgScopeType.barangay => l10n.assignRoleScopeOptionBarangay,
  };
}

String localizedOrgScopeIdFieldLabel(AppLocalizations l10n, OrgScopeType type) {
  return switch (type) {
    OrgScopeType.tag => l10n.assignRoleScopeFieldTag,
    OrgScopeType.classUnit => l10n.assignRoleScopeFieldClassId,
    OrgScopeType.group => l10n.assignRoleScopeFieldGroupId,
    OrgScopeType.department => l10n.assignRoleScopeFieldDepartmentId,
    OrgScopeType.barangay => l10n.assignRoleScopeFieldBarangayId,
    OrgScopeType.org => '',
  };
}

String localizedOrgScopeIdHint(AppLocalizations l10n, OrgScopeType type) {
  return switch (type) {
    OrgScopeType.tag => l10n.assignRoleScopeHintTag,
    OrgScopeType.classUnit => l10n.assignRoleScopeHintClass,
    OrgScopeType.group => l10n.assignRoleScopeHintGroup,
    OrgScopeType.department => l10n.assignRoleScopeHintDepartment,
    OrgScopeType.barangay => l10n.assignRoleScopeHintBarangay,
    OrgScopeType.org => '',
  };
}

String localizedOrgScopeAssignmentLabel(
  AppLocalizations l10n,
  OrgScopeType type, {
  String? scopeId,
}) {
  if (type == OrgScopeType.org) return l10n.assignRoleScopeChipOrg;
  final id = scopeId ?? '';
  return switch (type) {
    OrgScopeType.tag => l10n.assignRoleScopeValueTag(id),
    OrgScopeType.classUnit => l10n.assignRoleScopeValueClass(id),
    OrgScopeType.group => l10n.assignRoleScopeValueGroup(id),
    OrgScopeType.department => l10n.assignRoleScopeValueDepartment(id),
    OrgScopeType.barangay => l10n.assignRoleScopeValueBarangay(id),
    OrgScopeType.org => l10n.assignRoleScopeChipOrg,
  };
}

String localizedOrgScopeAssignmentLabelFromEntity(
  AppLocalizations l10n,
  RoleAssignmentEntity assignment,
) {
  return localizedOrgScopeAssignmentLabel(
    l10n,
    assignment.scopeType,
    scopeId: assignment.scopeId,
  );
}
