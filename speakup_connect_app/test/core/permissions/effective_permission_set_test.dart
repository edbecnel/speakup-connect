import 'package:flutter_test/flutter_test.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/entities/effective_permission_set.dart';
import 'package:speakup_connect/core/permissions/org_scope_type.dart';

EffectivePermissionSet _set({
  required List<AppPermission> permissions,
  Set<String>? allowedCategoryIds,
}) {
  return EffectivePermissionSet(
    grants: permissions
        .map(
          (p) => PermissionGrant(
            permission: p,
            scopeType: OrgScopeType.org,
          ),
        )
        .toList(),
    allowedCategoryIds: allowedCategoryIds,
  );
}

void main() {
  group('EffectivePermissionSet report category RBAC', () {
    test('unrestricted user can act on any category', () {
      final perms = _set(
        permissions: [AppPermission.approveReport],
        allowedCategoryIds: null,
      );

      expect(perms.canAccessReportCategory('guidance'), isTrue);
      expect(perms.can(AppPermission.approveReport, categoryId: 'bullying'), isTrue);
    });

    test('scoped role can approve only allowed category', () {
      final perms = _set(
        permissions: [AppPermission.approveReport],
        allowedCategoryIds: {'guidance'},
      );

      expect(perms.can(AppPermission.approveReport, categoryId: 'guidance'), isTrue);
      expect(perms.can(AppPermission.approveReport, categoryId: 'bullying'), isFalse);
    });

    test('discipline role cannot act on guidance report', () {
      final perms = _set(
        permissions: [AppPermission.manageReports],
        allowedCategoryIds: {'bullying'},
      );

      expect(perms.can(AppPermission.manageReports, categoryId: 'guidance'), isFalse);
    });

    test('union of categories from multiple grants at set level', () {
      final perms = EffectivePermissionSet(
        grants: [
          PermissionGrant(
            permission: AppPermission.viewGroupReports,
            scopeType: OrgScopeType.org,
          ),
        ],
        allowedCategoryIds: {'guidance', 'bullying'},
      );

      expect(perms.canViewReport('guidance'), isTrue);
      expect(perms.canViewReport('bullying'), isTrue);
      expect(perms.canViewReport('academic'), isFalse);
    });

    test('report caps with empty allowed categories deny all report actions', () {
      final perms = _set(
        permissions: [AppPermission.viewGroupReports, AppPermission.approveReport],
        allowedCategoryIds: {},
      );

      expect(perms.canAccessAdminReports, isFalse);
      expect(perms.canViewReport('guidance'), isFalse);
    });

    test('non-report permission unaffected by category list', () {
      final perms = _set(
        permissions: [AppPermission.broadcastReminders],
        allowedCategoryIds: {},
      );

      expect(perms.has(AppPermission.broadcastReminders), isTrue);
      expect(perms.can(AppPermission.broadcastReminders), isTrue);
    });
  });
}
