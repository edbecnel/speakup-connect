import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/permission_l10n.dart';
import 'package:speakup_connect/features/roles/domain/entities/custom_capability_entity.dart';
import 'package:speakup_connect/features/roles/presentation/providers/roles_provider.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';
import 'package:speakup_connect/shared/widgets/app_text_field.dart';

/// Admin screen for managing capability definitions.
///
/// Two tabs:
///  - **Custom** — org-admin-defined aliases that map a human-readable name
///    to a built-in [AppPermission].
///  - **Built-ins** — read-only catalog of every [AppPermission] with its
///    group label and description.
class CapabilitiesScreen extends ConsumerWidget {
  const CapabilitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.capabilitiesTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.capabilitiesTabCustom),
              Tab(text: l10n.capabilitiesTabBuiltins),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _CustomCapabilitiesTab(),
            _BuiltInsTab(),
          ],
        ),
      ),
    );
  }
}

// ── Custom Capabilities Tab ───────────────────────────────────────────────────

class _CustomCapabilitiesTab extends ConsumerWidget {
  const _CustomCapabilitiesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capsAsync = ref.watch(customCapabilitiesProvider);

    return capsAsync.when(
      skipLoadingOnRefresh: false,
      loading: () => const AppLoadingIndicator(),
      error: (e, _) => AppErrorWidget(
        message: context.l10n.capabilitiesLoadFailed('$e'),
        onRetry: () => ref.invalidate(customCapabilitiesProvider),
      ),
      data: (caps) => _CustomCapsList(caps: caps),
    );
  }
}

class _CustomCapsList extends ConsumerWidget {
  const _CustomCapsList({required this.caps});

  final List<CustomCapabilityEntity> caps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Column(
      children: [
        Expanded(
          child: caps.isEmpty
              ? _EmptyCustomCapsPlaceholder(
                  onCreateTap: () => _showCreateSheet(context, ref),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: caps.length,
                  itemBuilder: (_, i) =>
                      _CustomCapTile(cap: caps[i], ref: ref),
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: AppButton.primary(
            label: l10n.capabilitiesCreateLabel,
            onPressed: () => _showCreateSheet(context, ref),
          ),
        ),
      ],
    );
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => UncontrolledProviderScope(
        container: ProviderScope.containerOf(context),
        child: const _CreateCapabilitySheet(),
      ),
    );
  }
}

// ── Custom Capability Tile ────────────────────────────────────────────────────

class _CustomCapTile extends ConsumerWidget {
  const _CustomCapTile({required this.cap, required this.ref});

  final CustomCapabilityEntity cap;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final resolvedPerm = AppPermission.fromKey(cap.resolvedAction);

    return ListTile(
      title: Text(cap.displayName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cap.description != null && cap.description!.isNotEmpty)
            Text(cap.description!),
          const SizedBox(height: 2),
          if (resolvedPerm != null)
            Wrap(
              spacing: 4,
              children: [
                _MiniChip(
                  label: localizedPermissionName(l10n, resolvedPerm),
                  icon: Icons.bolt_outlined,
                ),
                if (cap.tagScope != null)
                  _MiniChip(
                    label: '#${cap.tagScope}',
                    icon: Icons.label_outline,
                  ),
              ],
            ),
        ],
      ),
      isThreeLine: true,
      trailing: IconButton(
        icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
        tooltip: l10n.capabilitiesDeleteTooltip,
        onPressed: () => _confirmDelete(context, widgetRef),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.capabilitiesDeleteTitle),
        content: Text(
          context.l10n.capabilitiesDeleteBody(cap.displayName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.commonRemove),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(customCapabilityWriterProvider.notifier)
          .deleteCapability(cap.id);
      ref.invalidate(customCapabilitiesProvider);
    }
  }
}

// ── Create Capability Bottom Sheet ────────────────────────────────────────────

class _CreateCapabilitySheet extends ConsumerStatefulWidget {
  const _CreateCapabilitySheet();

  @override
  ConsumerState<_CreateCapabilitySheet> createState() =>
      _CreateCapabilitySheetState();
}

class _CreateCapabilitySheetState
    extends ConsumerState<_CreateCapabilitySheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  AppPermission? _selectedAction;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAction == null) return;

    await ref.read(customCapabilityWriterProvider.notifier).createCapability(
          displayName: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          resolvedAction: _selectedAction!.key,
          tagScope:
              _tagCtrl.text.trim().isEmpty ? null : _tagCtrl.text.trim(),
        );

    final state = ref.read(customCapabilityWriterProvider);
    if (state.hasError && mounted) {
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.commonErrorPrefix('${state.error}'))),
      );
    } else if (!state.hasError && mounted) {
      ref.invalidate(customCapabilitiesProvider);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final saving = ref.watch(customCapabilityWriterProvider).isLoading;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.capabilitiesNewCustomTitle,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _nameCtrl,
              label: l10n.capabilitiesNameLabel,
              hint: l10n.capabilitiesNameHint,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.capabilitiesNameRequired
                  : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _descCtrl,
              label: l10n.capabilitiesDescriptionLabel,
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<AppPermission>(
              value: _selectedAction,
              decoration: InputDecoration(
                labelText: l10n.capabilitiesBackedByLabel,
                border: const OutlineInputBorder(),
              ),
              items: AppPermission.values
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(localizedPermissionName(l10n, p)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedAction = v),
              validator: (v) =>
                  v == null ? l10n.capabilitiesSelectBacking : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _tagCtrl,
              label: l10n.capabilitiesRestrictTagLabel,
              hint: l10n.capabilitiesRestrictTagHint,
              helperText: l10n.capabilitiesRestrictTagHelper,
            ),
            const SizedBox(height: 20),
            AppButton.primary(
              label: saving
                  ? l10n.capabilitiesCreating
                  : l10n.capabilitiesCreateLabel,
              onPressed: saving ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Built-ins Tab ─────────────────────────────────────────────────────────────

class _BuiltInsTab extends StatelessWidget {
  const _BuiltInsTab();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    // Build group map.
    final Map<String, List<AppPermission>> grouped = {};
    for (final p in AppPermission.values) {
      grouped
          .putIfAbsent(localizedPermissionGroup(l10n, p), () => [])
          .add(p);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            l10n.capabilitiesBuiltinsIntro,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ...grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  entry.key,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ...entry.value.map(
                (p) => ListTile(
                  leading: const Icon(Icons.bolt_outlined, size: 20),
                  title: Text(localizedPermissionName(l10n, p)),
                  subtitle: Text(
                    p.key,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  dense: true,
                ),
              ),
              const Divider(height: 1),
            ],
          );
        }),
      ],
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 14),
      label: Text(label),
      labelStyle: theme.textTheme.labelSmall,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _EmptyCustomCapsPlaceholder extends StatelessWidget {
  const _EmptyCustomCapsPlaceholder({required this.onCreateTap});

  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_outlined,
              size: 56,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.capabilitiesNoCustomYet,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.capabilitiesNoCustomDescription,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
