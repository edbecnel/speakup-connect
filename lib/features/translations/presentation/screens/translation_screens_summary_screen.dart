import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/core/constants/translation_assignable_routes.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/translations/presentation/providers/translation_provider.dart';
import 'package:speakup_connect/features/translations/presentation/providers/translation_screens_provider.dart';
import 'package:speakup_connect/features/translations/presentation/utils/translation_route_utils.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';

class TranslationScreensSummaryScreen extends ConsumerStatefulWidget {
  const TranslationScreensSummaryScreen({super.key});

  @override
  ConsumerState<TranslationScreensSummaryScreen> createState() =>
      _TranslationScreensSummaryScreenState();
}

class _TranslationScreensSummaryScreenState
    extends ConsumerState<TranslationScreensSummaryScreen> {
  bool _badgesOnly = false;

  Map<String, int> _buildRouteCounts(List<Map<String, dynamic>> entries) {
    final routeCounts = <String, int>{};
    for (final e in entries) {
      final raw = (e['route'] as String?)?.trim();
      if (raw == null || raw.isEmpty) continue;
      final key = normalizeTranslationRoute(raw);
      routeCounts[key] = (routeCounts[key] ?? 0) + 1;
    }
    return routeCounts;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final workspaceAsync = ref.watch(translationWorkspaceProvider);
    final screensAsync = ref.watch(translationScreensProvider);

    return workspaceAsync.when(
      skipLoadingOnReload: true,
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.translationScreensSummaryTitle)),
        body: const AppLoadingIndicator(),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.translationScreensSummaryTitle)),
        body: AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(translationWorkspaceProvider),
        ),
      ),
      data: (workspaceState) => screensAsync.when(
        skipLoadingOnReload: true,
        loading: () => Scaffold(
          appBar: AppBar(title: Text(l10n.translationScreensSummaryTitle)),
          body: const AppLoadingIndicator(),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(title: Text(l10n.translationScreensSummaryTitle)),
          body: AppErrorWidget(
            message: e.toString(),
            onRetry: () => ref.invalidate(translationScreensProvider),
          ),
        ),
        data: (screensState) {
          final assignableRoutes = screensState.assignableRoutes.isNotEmpty
              ? screensState.assignableRoutes
              : kTranslationAssignableRoutes;
          final routeCounts = _buildRouteCounts(workspaceState.entries);

          final knownRoutes = assignableRoutes
              .map((r) => normalizeTranslationRoute(r.route))
              .toSet();
          final unknownRoutes = routeCounts.keys
              .where((k) => !knownRoutes.contains(k))
              .toList()
            ..sort();

          final items = assignableRoutes.where((r) {
            if (!_badgesOnly) return true;
            final screen = screensState.screenForRoute(r.route);
            return screen?.badgeEnabled == true;
          }).toList();

          items.sort((a, b) {
            final aName = (screensState.screenForRoute(a.route)?.name ?? '').trim();
            final bName = (screensState.screenForRoute(b.route)?.name ?? '').trim();

            final aHas = aName.isNotEmpty;
            final bHas = bName.isNotEmpty;
            if (aHas != bHas) return aHas ? -1 : 1;

            final byName =
                aName.toLowerCase().compareTo(bName.toLowerCase());
            if (byName != 0) return byName;

            final byLabel =
                a.label.toLowerCase().compareTo(b.label.toLowerCase());
            if (byLabel != 0) return byLabel;

            return a.route.compareTo(b.route);
          });

          final assignedCount = assignableRoutes
              .where((r) => screensState.screenForRoute(r.route) != null)
              .length;
          final badgesOnCount = assignableRoutes
              .where((r) =>
                  screensState.screenForRoute(r.route)?.badgeEnabled == true)
              .length;

          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.translationScreensSummaryTitle),
              actions: [
                IconButton(
                  tooltip: l10n.commonRefresh,
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref.invalidate(translationWorkspaceProvider);
                    ref.invalidate(translationScreensProvider);
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Chip(
                                label: Text(
                                  l10n.translationScreensSummaryTotalRoutes(
                                    assignableRoutes.length,
                                  ),
                                ),
                              ),
                              Chip(
                                label: Text(
                                  l10n.translationScreensSummaryAssigned(
                                    assignedCount,
                                  ),
                                ),
                              ),
                              Chip(
                                label: Text(
                                  l10n.translationScreensSummaryBadgesOn(
                                    badgesOnCount,
                                  ),
                                ),
                              ),
                              if (unknownRoutes.isNotEmpty)
                                Chip(
                                  label: Text(
                                    l10n.translationScreensSummaryUnknownRoutes(
                                      unknownRoutes.length,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile.adaptive(
                        value: _badgesOnly,
                        onChanged: (v) => setState(() => _badgesOnly = v),
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.translationScreensSummaryBadgesOnlyLabel),
                      ),
                      Text(
                        l10n.translationScreensSummaryCountsHint,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(translationWorkspaceProvider);
                      ref.invalidate(translationScreensProvider);
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        for (final route in items)
                          ...(() {
                            final assignedScreen =
                                screensState.screenForRoute(route.route);
                            return [
                              _RouteSummaryTile(
                                appLabel: route.label,
                                routePath: route.route,
                                screen: assignedScreen,
                                count: routeCounts[normalizeTranslationRoute(
                                      route.route,
                                    )] ??
                                    0,
                                onBadgeChanged: assignedScreen == null
                                    ? null
                                    : (enabled) => ref
                                        .read(
                                          translationScreensProvider.notifier,
                                        )
                                        .setBadgeEnabled(
                                          screenId: assignedScreen.screenId,
                                          enabled: enabled,
                                        ),
                              ),
                              const SizedBox(height: 8),
                            ];
                          })(),
                        if (unknownRoutes.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          ExpansionTile(
                            title: Text(
                              l10n.translationScreensSummaryUnknownSection,
                            ),
                            subtitle: Text(
                              l10n
                                  .translationScreensSummaryUnknownSectionSubtitle(
                                unknownRoutes.length,
                              ),
                            ),
                            childrenPadding:
                                const EdgeInsets.fromLTRB(0, 0, 0, 8),
                            children: [
                              for (final unknown in unknownRoutes) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  child: _RouteSummaryTile(
                                    appLabel: unknown,
                                    routePath: unknown,
                                    screen: null,
                                    count: routeCounts[unknown] ?? 0,
                                    onBadgeChanged: null,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RouteSummaryTile extends StatelessWidget {
  const _RouteSummaryTile({
    required this.appLabel,
    required this.routePath,
    required this.screen,
    required this.count,
    required this.onBadgeChanged,
  });

  final String appLabel;
  final String routePath;
  final TranslationScreenEntity? screen;
  final int count;
  final Future<void> Function(bool enabled)? onBadgeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final deviceWidth = MediaQuery.sizeOf(context).width;

    final screenName = (screen?.name.trim().isNotEmpty ?? false)
        ? screen!.name.trim()
        : l10n.translationScreensSummaryUnassigned;
    final badgesOn = screen?.badgeEnabled == true;
    final rightMaxWidth = switch (deviceWidth) {
      < 380 => 200.0,
      < 460 => 230.0,
      _ => 260.0,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    routePath,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: rightMaxWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: _CompactChip(
                      label: screenName,
                      icon: Icons.route_outlined,
                      maxLines: 2,
                      iconSize: 12,
                      textStyle: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        height: 1.1,
                      ),
                      expand: true,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<bool>(
                          segments: [
                            ButtonSegment<bool>(
                              value: false,
                              label: Text(
                                l10n.translationScreensSummaryBadgesOffChip,
                                textAlign: TextAlign.center,
                              ),
                              icon: const Icon(Icons.badge),
                            ),
                            ButtonSegment<bool>(
                              value: true,
                              label: Text(
                                l10n.translationScreensSummaryBadgesOnChip,
                                textAlign: TextAlign.center,
                              ),
                              icon: const Icon(Icons.badge_outlined),
                            ),
                          ],
                          selected: {badgesOn},
                          showSelectedIcon: false,
                          style: ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: WidgetStatePropertyAll(
                              theme.textTheme.labelSmall,
                            ),
                          ),
                          onSelectionChanged:
                              (screen == null || onBadgeChanged == null)
                                  ? null
                                  : (selection) =>
                                      onBadgeChanged?.call(selection.first),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _CompactChip(
                        label: l10n.translationScreensSummaryCountChip(count),
                        icon: Icons.translate_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactChip extends StatelessWidget {
  const _CompactChip({
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.iconSize = 14,
    this.textStyle,
    this.expand = false,
  });

  final String label;
  final IconData icon;
  final int maxLines;
  final double iconSize;
  final TextStyle? textStyle;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final Color bg = colors.surfaceContainerHighest;
    final Color fg = colors.onSurfaceVariant;
    final effectiveTextStyle =
        (textStyle ?? theme.textTheme.labelSmall)?.copyWith(color: fg);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: fg),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: effectiveTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}

