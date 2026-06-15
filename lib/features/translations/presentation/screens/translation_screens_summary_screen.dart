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

    final workspaceError = workspaceAsync.error;
    if (workspaceError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.translationScreensSummaryTitle)),
        body: AppErrorWidget(
          message: workspaceError.toString(),
          onRetry: () => ref.invalidate(translationWorkspaceProvider),
        ),
      );
    }

    final screensError = screensAsync.error;
    if (screensError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.translationScreensSummaryTitle)),
        body: AppErrorWidget(
          message: screensError.toString(),
          onRetry: () => ref.invalidate(translationScreensProvider),
        ),
      );
    }

    final workspaceState = workspaceAsync.asData?.value;
    final screensState = screensAsync.asData?.value;
    if (workspaceState == null || screensState == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.translationScreensSummaryTitle)),
        body: const AppLoadingIndicator(),
      );
    }

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
    }).toList(growable: false);

    final assignedCount = assignableRoutes
        .where((r) => screensState.screenForRoute(r.route) != null)
        .length;
    final badgesOnCount = assignableRoutes
        .where((r) => screensState.screenForRoute(r.route)?.badgeEnabled == true)
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
                            l10n.translationScreensSummaryAssigned(assignedCount),
                          ),
                        ),
                        Chip(
                          label: Text(
                            l10n.translationScreensSummaryBadgesOn(badgesOnCount),
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
                  for (final route in items) ...[
                    _RouteSummaryTile(
                      appLabel: route.label,
                      routePath: route.route,
                      screen: screensState.screenForRoute(route.route),
                      count: routeCounts[
                              normalizeTranslationRoute(route.route)] ??
                          0,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (unknownRoutes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    ExpansionTile(
                      title: Text(l10n.translationScreensSummaryUnknownSection),
                      subtitle: Text(
                        l10n.translationScreensSummaryUnknownSectionSubtitle(
                          unknownRoutes.length,
                        ),
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
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
  }
}

class _RouteSummaryTile extends StatelessWidget {
  const _RouteSummaryTile({
    required this.appLabel,
    required this.routePath,
    required this.screen,
    required this.count,
  });

  final String appLabel;
  final String routePath;
  final TranslationScreenEntity? screen;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final screenName = (screen?.name.trim().isNotEmpty ?? false)
        ? screen!.name.trim()
        : l10n.translationScreensSummaryUnassigned;
    final badgesOn = screen?.badgeEnabled == true;

    final badgeLabel = badgesOn
        ? l10n.translationScreensSummaryBadgesOnChip
        : l10n.translationScreensSummaryBadgesOffChip;

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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 190),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _CompactChip(
                    label: screenName,
                    icon: Icons.route_outlined,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.end,
                    children: [
                      _CompactChip(
                        label: badgeLabel,
                        icon: badgesOn ? Icons.badge_outlined : Icons.badge,
                        tone: badgesOn ? _ChipTone.success : _ChipTone.neutral,
                      ),
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

enum _ChipTone { neutral, success }

class _CompactChip extends StatelessWidget {
  const _CompactChip({
    required this.label,
    required this.icon,
    this.tone = _ChipTone.neutral,
  });

  final String label;
  final IconData icon;
  final _ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final Color bg = switch (tone) {
      _ChipTone.neutral => colors.surfaceContainerHighest,
      _ChipTone.success => colors.primaryContainer,
    };
    final Color fg = switch (tone) {
      _ChipTone.neutral => colors.onSurfaceVariant,
      _ChipTone.success => colors.onPrimaryContainer,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

