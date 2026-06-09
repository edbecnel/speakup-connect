import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/features/help/domain/help_article.dart';
import 'package:speakup_connect/features/help/presentation/providers/help_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';

/// Lists help guides available to the signed-in user.
class HelpHubScreen extends ConsumerWidget {
  const HelpHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(visibleHelpArticlesProvider);
    final showAdmin = ref.watch(canViewAdminHelpProvider);
    final orgName =
        ref.watch(organizationConfigProvider).value?.displayName ??
            'your organization';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Help Center'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Guides for using SpeakUp Connect',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Guides for $orgName. '
            '${showAdmin ? 'Includes administration topics for your role. ' : ''}'
            'Content is specific to how this organization is set up.',
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
                title: Text(article.title),
                subtitle: Text(article.subtitle),
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
