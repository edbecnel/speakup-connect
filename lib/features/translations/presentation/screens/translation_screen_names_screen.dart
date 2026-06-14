import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/translation_assignable_routes.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/translations/presentation/providers/translation_screens_provider.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';

/// CRUD for translation screen names and route assignment.
class TranslationScreenNamesScreen extends ConsumerStatefulWidget {
  const TranslationScreenNamesScreen({super.key});

  @override
  ConsumerState<TranslationScreenNamesScreen> createState() =>
      _TranslationScreenNamesScreenState();
}

class _TranslationScreenNamesScreenState
    extends ConsumerState<TranslationScreenNamesScreen> {
  final _newNameController = TextEditingController();
  final _nameControllers = <String, TextEditingController>{};

  @override
  void dispose() {
    _newNameController.dispose();
    for (final c in _nameControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String screenId, String name) {
    return _nameControllers.putIfAbsent(
      screenId,
      () => TextEditingController(text: name),
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final screensAsync = ref.watch(translationScreensProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.translationScreenNamesTitle),
      ),
      body: screensAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(translationScreensProvider),
        ),
        data: (state) {
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(translationScreensProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  l10n.translationScreenNamesIntro,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _newNameController,
                  decoration: InputDecoration(
                    labelText: l10n.translationScreenNamesNewLabel,
                    border: const OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _createScreen(),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: _createScreen,
                    child: Text(l10n.translationScreenNamesAdd),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.translationScreenNamesCatalog,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                if (state.screens.isEmpty)
                  Text(
                    l10n.translationScreenNamesEmpty,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  )
                else
                  ...state.screens.map(
                    (screen) => _ScreenNameCard(
                      screen: screen,
                      nameController: _controllerFor(screen.screenId, screen.name),
                      onSaveName: () => _run(() async {
                        final renamed = await ref
                            .read(translationScreensProvider.notifier)
                            .rename(
                              screenId: screen.screenId,
                              name: _controllerFor(screen.screenId, screen.name)
                                  .text
                                  .trim(),
                            );
                        if (!mounted) return;
                        final message = renamed > 0
                            ? l10n.translationScreenNamesRenamedCount(renamed)
                            : l10n.translationScreenNamesSaved;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      }),
                      onUnassign: screen.assignedRoute == null
                          ? null
                          : () => _run(
                                () => ref
                                    .read(translationScreensProvider.notifier)
                                    .unassignRoute(screen.screenId),
                              ),
                      onDelete: screen.assignedRoute == null
                          ? () => _confirmDelete(screen.screenId, screen.name)
                          : null,
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  l10n.translationScreenNamesRouteAssignment,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.translationScreenNamesRouteHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                ...state.assignableRoutes.map(
                  (route) => _RouteAssignmentTile(
                    route: route,
                    available: state.availableForRoute(route.route),
                    assigned: state.screenForRoute(route.route),
                    onChanged: (screenId) => _run(() async {
                      if (screenId == null) {
                        final current = state.screenForRoute(route.route);
                        if (current != null) {
                          await ref
                              .read(translationScreensProvider.notifier)
                              .unassignRoute(current.screenId);
                        }
                        return;
                      }
                      await ref
                          .read(translationScreensProvider.notifier)
                          .assignRoute(
                            screenId: screenId,
                            route: route.route,
                          );
                    }),
                    onBadgeChanged: state.screenForRoute(route.route) == null
                        ? null
                        : (enabled) => _run(
                              () => ref
                                  .read(translationScreensProvider.notifier)
                                  .setBadgeEnabled(
                                    screenId:
                                        state.screenForRoute(route.route)!.screenId,
                                    enabled: enabled,
                                  ),
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

  Future<void> _createScreen() async {
    final name = _newNameController.text.trim();
    if (name.isEmpty) return;
    await _run(() async {
      await ref.read(translationScreensProvider.notifier).create(name);
      _newNameController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.translationScreenNamesCreated)),
      );
    });
  }

  Future<void> _confirmDelete(String screenId, String name) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.translationScreenNamesDeleteTitle),
        content: Text(l10n.translationScreenNamesDeleteBody(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.translationScreenNamesDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(() async {
      await ref.read(translationScreensProvider.notifier).delete(screenId);
      _nameControllers.remove(screenId)?.dispose();
    });
  }
}

class _ScreenNameCard extends StatelessWidget {
  const _ScreenNameCard({
    required this.screen,
    required this.nameController,
    required this.onSaveName,
    this.onUnassign,
    this.onDelete,
  });

  final TranslationScreenEntity screen;
  final TextEditingController nameController;
  final VoidCallback onSaveName;
  final VoidCallback? onUnassign;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final routeLabel = screen.assignedRouteLabel ??
        translationRouteLabel(screen.assignedRoute) ??
        screen.assignedRoute;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.translationScreenNamesNameLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            if (routeLabel != null) ...[
              const SizedBox(height: 8),
              Text(
                l10n.translationScreenNamesAssignedRoute(routeLabel),
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.end,
              children: [
                if (onUnassign != null)
                  TextButton(
                    onPressed: onUnassign,
                    child: Text(l10n.translationScreenNamesUnassignRoute),
                  ),
                if (onDelete != null)
                  TextButton(
                    onPressed: onDelete,
                    child: Text(l10n.translationScreenNamesDelete),
                  ),
                FilledButton(
                  onPressed: onSaveName,
                  child: Text(l10n.commonSave),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteAssignmentTile extends StatelessWidget {
  const _RouteAssignmentTile({
    required this.route,
    required this.available,
    required this.assigned,
    required this.onChanged,
    this.onBadgeChanged,
  });

  final TranslationAssignableRoute route;
  final List<TranslationScreenEntity> available;
  final TranslationScreenEntity? assigned;
  final ValueChanged<String?> onChanged;
  final ValueChanged<bool>? onBadgeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(route.label, style: Theme.of(context).textTheme.titleSmall),
            Text(
              route.route,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              key: ValueKey('${route.route}-${assigned?.screenId}'),
              initialValue: assigned?.screenId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.translationScreenNamesRouteDropdown,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(l10n.translationScreenNamesUnassigned),
                ),
                ...available.map(
                  (s) => DropdownMenuItem<String?>(
                    value: s.screenId,
                    child: Text(s.name, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
              onChanged: onChanged,
            ),
            if (assigned != null && onBadgeChanged != null) ...[
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.translationScreenNamesBadgesLabel),
                subtitle: Text(l10n.translationScreenNamesBadgesHint),
                value: assigned!.badgeEnabled,
                onChanged: (value) {
                  if (value != null) onBadgeChanged!(value);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
