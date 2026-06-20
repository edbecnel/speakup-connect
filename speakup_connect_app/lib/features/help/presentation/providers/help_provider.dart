import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/features/help/domain/help_article.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/features/translations/presentation/providers/translation_provider.dart';

/// Organization type whose bundled help assets should be loaded.
///
/// When unavailable, resolver falls back to `_default` assets only.
final activeHelpOrganizationTypeProvider = Provider<String?>((ref) {
  final orgConfig = ref.watch(organizationConfigProvider).value;
  final type = orgConfig?.type.value.trim().toLowerCase();
  if (type == null || type.isEmpty) {
    return null;
  }

  // Help bundles are currently maintained for school organizations only.
  // Unknown/unsupported org types should fall back to `_default`.
  if (type == 'school') {
    return type;
  }
  return null;
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
