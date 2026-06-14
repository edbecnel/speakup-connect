import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/core/l10n/locale_provider.dart';
import 'package:speakup_connect/core/router/app_navigator_key.dart';
import 'package:speakup_connect/features/translations/presentation/providers/translation_mode_provider.dart';

/// Wraps the app when translation mode is active — shows banner and handles exit.
///
/// Rendered from [MaterialApp.builder], which sits **above** the navigator
/// [Overlay]. Do not use [IconButton.tooltip] or other overlay-dependent
/// widgets here without [rootNavigatorKey].
class TranslationModeShell extends ConsumerWidget {
  const TranslationModeShell({required this.child, super.key});

  final Widget child;

  BuildContext? get _navigatorContext => rootNavigatorKey.currentContext;

  Future<void> _confirmExit(BuildContext context, WidgetRef ref) async {
    final mode = ref.read(translationModeProvider);
    if (!mode.hasUnsavedEdits) {
      await ref.read(translationModeProvider.notifier).exitMode();
      return;
    }

    final dialogContext = _navigatorContext ?? context;
    final l10n = dialogContext.l10n;
    final discard = await showDialog<bool>(
      context: dialogContext,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.translationModeExitConfirmTitle),
        content: Text(
          l10n.translationModeExitConfirmBody(mode.pendingCount),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.translationModeExitDiscard),
          ),
        ],
      ),
    );

    if (discard == true) {
      await ref.read(translationModeProvider.notifier).exitMode();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(translationModeProvider);
    if (!mode.isActive) return child;

    final l10n = context.l10n;
    final theme = Theme.of(context);
    final targetLabel =
        kLanguageNativeLabels[mode.targetLocale] ?? mode.targetLocale;
    final previewLabel =
        kLanguageNativeLabels[mode.previewLocale] ?? mode.previewLocale;

    return SizedBox.expand(
      child: Column(
        children: [
          Material(
            color: theme.colorScheme.primaryContainer,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.translate_rounded,
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.translationModeBanner(targetLabel),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                l10n.translationModeShowingPreview(previewLabel),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              if (mode.isLoadingEntries)
                                Text(
                                  l10n.translationModeLoadingEntries,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                )
                              else if (mode.pendingCount > 0)
                                Text(
                                  l10n.translationModeSessionEdited(
                                    mode.pendingCount,
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (mode.pendingCount > 0)
                          TextButton(
                            onPressed: () {
                              final nav = _navigatorContext;
                              if (nav != null) {
                                GoRouter.of(nav).push(
                                  Routes.translationSessionReview,
                                );
                              }
                            },
                            child: Text(l10n.translationModeReviewSession),
                          ),
                        IconButton(
                          onPressed: () => _confirmExit(context, ref),
                          icon: Icon(
                            Icons.close_rounded,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: [
                        ButtonSegment<String>(
                          value: 'en',
                          label: Text(
                            kLanguageNativeLabels['en'] ?? 'English',
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                        ButtonSegment<String>(
                          value: mode.targetLocale,
                          label: Text(
                            targetLabel,
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      ],
                      selected: {mode.previewLocale},
                      onSelectionChanged: (selected) {
                        ref
                            .read(translationModeProvider.notifier)
                            .setPreviewLocale(selected.first);
                      },
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
