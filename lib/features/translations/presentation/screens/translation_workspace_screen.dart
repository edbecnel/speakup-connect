import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/constants/translation_assignable_routes.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/core/l10n/locale_provider.dart';
import 'package:speakup_connect/features/translations/presentation/providers/translation_mode_provider.dart';
import 'package:speakup_connect/features/translations/presentation/providers/translation_provider.dart';
import 'package:speakup_connect/features/translations/presentation/providers/translation_screens_provider.dart';
import 'package:speakup_connect/features/translations/presentation/utils/translation_screen_display_utils.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';

/// In-app Translation Helper for org admins and translation moderators.
class TranslationWorkspaceScreen extends ConsumerStatefulWidget {
  const TranslationWorkspaceScreen({super.key});

  @override
  ConsumerState<TranslationWorkspaceScreen> createState() =>
      _TranslationWorkspaceScreenState();
}

class _TranslationWorkspaceScreenState
    extends ConsumerState<TranslationWorkspaceScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _displayTarget(Map<String, dynamic> entry) {
    final target = entry['targetValue'] as String?;
    if (target != null && target.isNotEmpty) return target;
    final draft = entry['aiDraft'] as String?;
    if (draft != null && draft.isNotEmpty) return draft;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final workspaceAsync = ref.watch(translationWorkspaceProvider);
    final screensAsync = ref.watch(translationScreensProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.settingsTranslations),
        actions: [
          IconButton(
            tooltip: l10n.translationScreenNamesManage,
            icon: const Icon(Icons.view_list_outlined),
            onPressed: () => context.push(Routes.translationScreenNames),
          ),
        ],
      ),
      body: workspaceAsync.when(
        skipLoadingOnReload: true,
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(translationWorkspaceProvider),
        ),
        data: (state) {
          final localeValue = state.allowedLocales.contains(state.locale)
              ? state.locale
              : state.allowedLocales.first;
          final screensState = screensAsync.asData?.value;
          final assignableRoutes =
              screensState?.assignableRoutes ?? kTranslationAssignableRoutes;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      key: ValueKey(localeValue),
                      initialValue: localeValue,
                      decoration: InputDecoration(
                        labelText: l10n.settingsLanguage,
                        border: const OutlineInputBorder(),
                      ),
                      items: state.allowedLocales
                          .map(
                            (code) => DropdownMenuItem(
                              value: code,
                              child: Text(
                                kLanguageNativeLabels[code] ?? code,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          ref
                              .read(translationWorkspaceProvider.notifier)
                              .setLocale(v);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: l10n.translationSearchHint,
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () => ref
                              .read(translationWorkspaceProvider.notifier)
                              .setSearch(_searchController.text.trim()),
                        ),
                      ),
                      onSubmitted: (v) => ref
                          .read(translationWorkspaceProvider.notifier)
                          .setSearch(v.trim()),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        AppButton.primary(
                          label: l10n.translationModeStart,
                          minimumWidth: 0,
                          onPressed: () async {
                            try {
                              await ref
                                  .read(translationModeProvider.notifier)
                                  .enterMode(localeValue);
                              if (!context.mounted) return;
                              context.go(Routes.home);
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                ),
                              );
                            }
                          },
                        ),
                        if (state.canExportArb)
                          AppButton.secondary(
                            label: l10n.translationExportArb,
                            minimumWidth: 0,
                            onPressed: () async {
                              final result = await ref
                                  .read(translationWorkspaceProvider.notifier)
                                  .exportArb();
                              final arb = result['arb'] as Map<String, dynamic>?;
                              if (arb == null || !context.mounted) return;
                              await Clipboard.setData(
                                ClipboardData(
                                  text: const JsonEncoder.withIndent('  ')
                                      .convert(arb),
                                ),
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.translationExportCopied),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.translationModeStartSubtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.translationEntryCount(state.entries.length),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: state.entries.isEmpty
                    ? AppEmptyState(
                        icon: Icons.translate_outlined,
                        message: l10n.translationNoEntries,
                      )
                    : RefreshIndicator(
                            onRefresh: () => ref
                                .read(translationWorkspaceProvider.notifier)
                                .setLocale(state.locale),
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: state.entries.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final entry = state.entries[index];
                                final stringKey =
                                    entry['stringKey'] as String? ?? '';
                                return _TranslationEntryCard(
                                  entry: entry,
                                  initialTarget: _displayTarget(entry),
                                  screensState: screensState,
                                  assignableRoutes: assignableRoutes,
                                  onRouteChanged: (value) => ref
                                      .read(translationWorkspaceProvider
                                          .notifier)
                                      .saveRoute(
                                        stringKey: stringKey,
                                        route: value,
                                      ),
                                  onSave: (value, approve) => ref
                                      .read(translationWorkspaceProvider
                                          .notifier)
                                      .save(
                                        stringKey: stringKey,
                                        targetValue: value,
                                        approve: approve,
                                      ),
                                  onDraft: () => ref
                                      .read(translationWorkspaceProvider
                                          .notifier)
                                      .draft(stringKey),
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TranslationEntryCard extends StatefulWidget {
  const _TranslationEntryCard({
    required this.entry,
    required this.initialTarget,
    required this.onSave,
    required this.onDraft,
    required this.onRouteChanged,
    required this.screensState,
    required this.assignableRoutes,
  });

  final Map<String, dynamic> entry;
  final String initialTarget;
  final TranslationScreensState? screensState;
  final List<TranslationAssignableRoute> assignableRoutes;
  final Future<void> Function(String value, bool approve) onSave;
  final Future<void> Function() onDraft;
  final Future<void> Function(String? route) onRouteChanged;

  @override
  State<_TranslationEntryCard> createState() => _TranslationEntryCardState();
}

class _TranslationEntryCardState extends State<_TranslationEntryCard> {
  late final TextEditingController _controller;
  late String? _selectedRoute;
  var _busy = false;

  String? _normalizeRoute(String? raw) {
    final v = raw?.trim();
    return (v != null && v.isNotEmpty) ? v : null;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTarget);
    _selectedRoute = _normalizeRoute(widget.entry['route'] as String?);
  }

  @override
  void didUpdateWidget(covariant _TranslationEntryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final raw = _normalizeRoute(widget.entry['route'] as String?);
    final oldRaw = _normalizeRoute(oldWidget.entry['route'] as String?);
    if (raw != oldRaw && raw != _selectedRoute) {
      setState(() => _selectedRoute = raw);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final key = widget.entry['stringKey'] as String? ?? '';
    final source = widget.entry['sourceValue'] as String? ?? '';
    final status = widget.entry['status'] as String? ?? 'missing';
    final englishDisplay = source.trim().isEmpty ? '—' : source;
    final assignableRoutes = widget.assignableRoutes;
    final routeFromEntry = _normalizeRoute(widget.entry['route'] as String?);
    final currentRoute = _normalizeRoute(_selectedRoute) ?? routeFromEntry;

    final knownRouteSet = assignableRoutes.map((r) => r.route).toSet();
    final effectiveRoutes = <TranslationAssignableRoute>[
      if (currentRoute != null && !knownRouteSet.contains(currentRoute))
        TranslationAssignableRoute(route: currentRoute, label: currentRoute),
      ...assignableRoutes,
    ];

    final routeDropdownKey = ValueKey(
      Object.hash(Object.hashAll(effectiveRoutes.map((e) => e.route)), currentRoute),
    );

    final screenLabel = translationScreenDisplayLabel(
      route: currentRoute,
      screensState: widget.screensState,
      unassignedLabel: l10n.adminReportDetailUnassigned,
    );

    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              key,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              softWrap: true,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: routeDropdownKey,
              initialValue: currentRoute,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.translationStringScreenLabel,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    l10n.adminReportDetailUnassigned,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ...effectiveRoutes.map(
                  (item) {
                    final display = translationScreenDisplayLabel(
                      route: item.route,
                      screensState: widget.screensState,
                      unassignedLabel: l10n.adminReportDetailUnassigned,
                    );
                    return DropdownMenuItem<String?>(
                      value: item.route,
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          display,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ],
              onChanged: _busy
                  ? null
                  : (value) => _run(() async {
                        setState(() => _selectedRoute = value);
                        await widget.onRouteChanged(value);
                      }),
            ),
            const SizedBox(height: 6),
            Text(
              screenLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.settingsLanguageEnglish,
                border: const OutlineInputBorder(),
                filled: true,
                alignLabelWithHint: true,
                fillColor: theme.colorScheme.surface,
              ),
              child: Text(
                englishDisplay,
                style: theme.textTheme.bodyMedium,
                softWrap: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              minLines: 2,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: l10n.translationTargetLabel,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            Chip(label: Text(status)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.end,
              children: [
                TextButton(
                  onPressed: _busy ? null : () => _run(widget.onDraft),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(l10n.translationAiDraft),
                ),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => _run(
                            () => widget.onSave(_controller.text.trim(), false),
                          ),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(l10n.commonSave),
                ),
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => _run(
                            () => widget.onSave(_controller.text.trim(), true),
                          ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(l10n.translationApprove),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
