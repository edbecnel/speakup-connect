import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/help/domain/help_article.dart';
import 'package:speakup_connect/features/help/presentation/providers/help_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';

/// Lists help guides available to the signed-in user.
class HelpHubScreen extends ConsumerWidget {
  const HelpHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final articles = ref.watch(visibleHelpArticlesProvider);
    final showAdmin = ref.watch(canViewAdminHelpProvider);
    final orgName =
        ref.watch(organizationConfigProvider).value?.displayName ??
            l10n.helpOrgFallback;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.settingsHelpCenter),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.helpHubHeadline,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.helpHubDescription(
              orgName,
              showAdmin ? l10n.helpHubAdminNote : '',
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          ...articles.map(
            (article) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(article.icon.data),
                title: Text(article.title(l10n)),
                subtitle: Text(article.subtitle(l10n)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(Routes.helpArticlePath(article.id)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
