import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/features/translations/presentation/providers/translation_mode_provider.dart';
import 'package:speakup_connect/features/translations/presentation/providers/translation_screens_provider.dart';
import 'package:speakup_connect/features/translations/presentation/utils/translation_route_utils.dart';
import 'package:speakup_connect/features/translations/presentation/widgets/translation_edit_sheet.dart';

/// Marks a localized string for in-context translation when [translationModeProvider]
/// is active. Shows a tappable badge and applies session preview overrides.
class TranslationAnchor extends ConsumerWidget {
  const TranslationAnchor({
    required this.stringKey,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    super.key,
  });

  final String stringKey;
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(translationModeProvider);
    final displayText = mode.displayText(stringKey, text);

    final textWidget = Text(
      displayText,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
      softWrap: true,
    );

    if (!mode.isActive) return textWidget;

    final badgeRoutes = ref.watch(translationBadgeEnabledRoutesProvider);
    final route = currentTranslationRoute(GoRouter.of(context));
    if (!isTranslationBadgeRouteEnabled(badgeRoutes, route)) {
      return textWidget;
    }

    final hasEdit = mode.sessionEdits.containsKey(stringKey);

    void openEditor() {
      ref.read(translationModeProvider.notifier).captureRouteForKey(
            stringKey: stringKey,
            route: route,
          );
      final targetFallback = mode.isPreviewingTarget
          ? text
          : mode.baselineTarget(stringKey);
      showTranslationEditSheet(
        context: context,
        ref: ref,
        stringKey: stringKey,
        arbText: mode.isPreviewingTarget
            ? text
            : mode.baselineTarget(stringKey, fallback: targetFallback),
      );
    }

    // Wrap flows to the next line instead of overflowing in tight slots
    // (app bar titles, tabs, list tiles, grid labels).
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 2,
      children: [
        _TranslationBadge(
          hasEdit: hasEdit,
          onTap: openEditor,
        ),
        textWidget,
      ],
    );
  }
}

class _TranslationBadge extends StatelessWidget {
  const _TranslationBadge({
    required this.hasEdit,
    required this.onTap,
  });

  final bool hasEdit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = hasEdit
        ? theme.colorScheme.tertiary
        : theme.colorScheme.primary;

    return Material(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            Icons.translate_rounded,
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }
}
