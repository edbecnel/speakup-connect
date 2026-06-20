import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/features/help/domain/help_article.dart';
import 'package:speakup_connect/features/organization/domain/entities/organization_config_entity.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/features/translations/presentation/providers/translation_provider.dart';
import 'package:speakup_connect/flavor_config.dart';

/// Organization type whose bundled help assets should be loaded.
///
/// When unavailable, resolver falls back to `_default` assets only.
final activeHelpOrganizationTypeProvider = FutureProvider<String?>((ref) async {
  final profile = ref.watch(userProfileProvider).value;
  final profileOrgId = profile?.organizationId.trim();
  final orgId = (profileOrgId != null && profileOrgId.isNotEmpty)
      ? profileOrgId
      : AppConfig.defaultOrganizationId;

  String? flavorFallback() {
    final bakedType = FlavorConfig.instance.orgDefaults?.type;
    return bakedType == OrganizationType.school ? 'school' : null;
  }

  if (orgId.isEmpty) {
    return flavorFallback() ?? 'school';
  }

  // Current supported production scenario is school tenants.
  // If org type is missing/other, prefer school bundle then resolver fallback.
  String preferSchoolFallback(OrganizationType? type) {
    if (type == OrganizationType.school) return 'school';
    final flavor = flavorFallback();
    return flavor ?? 'school';
  }

  final repo = ref.read(organizationRepositoryProvider);
  try {
    final config = await repo.getOrganizationConfig(orgId);
    return preferSchoolFallback(config.type);
  } catch (_) {
    return preferSchoolFallback(null);
  }
});

/// Whether the signed-in user should see administration help content.
final canViewAdminHelpProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  if (profile?.isAdmin == true) return true;
  if (ref.watch(canAccessAdminReportsProvider)) return true;
  if (ref.watch(canManageGroupsProvider)) return true;
  if (ref.watch(canManageTranslationsProvider)) return true;
  return false;
});

/// Help articles visible to the current user.
final visibleHelpArticlesProvider = Provider<List<HelpArticle>>((ref) {
  final showAdmin = ref.watch(canViewAdminHelpProvider);
  return HelpArticles.all
      .where(
        (a) =>
            a.audience == HelpAudience.member ||
            (a.audience == HelpAudience.admin && showAdmin),
      )
      .toList();
});
