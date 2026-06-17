import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/core/l10n/locale_provider.dart';
import 'package:speakup_connect/features/help/data/help_asset_resolver.dart';
import 'package:speakup_connect/features/help/domain/help_article.dart';
import 'package:speakup_connect/features/help/presentation/providers/help_provider.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';

/// Renders a single org-specific markdown help article.
class HelpArticleScreen extends ConsumerWidget {
  const HelpArticleScreen({required this.articleId, super.key});

  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final article = HelpArticles.byId(articleId);
    final canViewAdmin = ref.watch(canViewAdminHelpProvider);
    final organizationId = ref.watch(activeHelpOrganizationIdProvider);
    final languageCode = helpLanguageCodeForLocale(ref.watch(appLocaleProvider));

    if (article == null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: Text(l10n.helpTitle),
        ),
        body: AppErrorWidget(message: l10n.helpGuideNotFound),
      );
    }

    if (article.audience == HelpAudience.admin && !canViewAdmin) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: Text(article.title(l10n)),
        ),
        body: AppErrorWidget(message: l10n.helpAdminAccessDenied),
      );
    }

    final theme = Theme.of(context);
    final contentFuture = HelpAssetResolver.loadMarkdown(
      organizationId: organizationId,
      articleId: article.id,
      languageCode: languageCode,
    );

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(article.title(l10n)),
      ),
      body: FutureBuilder<String>(
        future: contentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const AppLoadingIndicator();
          }
          if (snapshot.hasError) {
            return AppErrorWidget(
              message: l10n.helpLoadFailedDetail('${snapshot.error}'),
            );
          }

          return Markdown(
            data: snapshot.data ?? '',
            selectable: true,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
              h1: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              h2: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              h3: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              p: theme.textTheme.bodyMedium,
              listBullet: theme.textTheme.bodyMedium,
              blockquoteDecoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              blockquotePadding: const EdgeInsets.all(12),
              horizontalRuleDecoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.dividerColor),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
