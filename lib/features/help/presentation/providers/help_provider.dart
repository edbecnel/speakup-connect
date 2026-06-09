import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/features/help/domain/help_article.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';

/// Organization whose bundled help assets should be loaded.
final activeHelpOrganizationIdProvider = Provider<String>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  if (profile != null && profile.organizationId.isNotEmpty) {
    return profile.organizationId;
  }
  return AppConfig.defaultOrganizationId;
});

/// Whether the signed-in user should see administration help content.
final canViewAdminHelpProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  if (profile?.isAdmin == true) return true;
  if (ref.watch(canAccessAdminReportsProvider)) return true;
  if (ref.watch(canManageGroupsProvider)) return true;
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
