import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Capabilities'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Custom'),
              Tab(text: 'Built-ins'),
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
      loading: () => const AppLoadingIndicator(),
      error: (e, _) => AppErrorWidget(message: e.toString()),
      data: (caps) => _CustomCapsList(caps: caps),
    );
  }
}

class _CustomCapsList extends ConsumerWidget {
  const _CustomCapsList({required this.caps});

  final List<CustomCapabilityEntity> caps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            label: 'Create Custom Capability',
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
                  label: resolvedPerm.displayName,
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
        tooltip: 'Delete',
        onPressed: () => _confirmDelete(context, widgetRef),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Capability?'),
        content: Text(
          '"${cap.displayName}" will be removed. Roles using it will '
          'lose this capability assignment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(customCapabilityWriterProvider.notifier)
          .deleteCapability(cap.id);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${state.error}')),
      );
    } else if (!state.hasError && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
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
              'New Custom Capability',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _nameCtrl,
              label: 'Capability Name',
              hint: 'e.g. Review Guidance Referral',
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Name is required'
                  : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _descCtrl,
              label: 'Description (optional)',
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<AppPermission>(
              value: _selectedAction,
              decoration: const InputDecoration(
                labelText: 'Backed by (built-in action)',
                border: OutlineInputBorder(),
              ),
              items: AppPermission.values
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(p.displayName),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedAction = v),
              validator: (v) =>
                  v == null ? 'Select a backing action' : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _tagCtrl,
              label: 'Restrict to tag (optional)',
              hint: 'e.g. guidance',
              helperText:
                  'Leave empty to apply to all content with this action.',
            ),
            const SizedBox(height: 20),
            AppButton.primary(
              label: saving ? 'Creating…' : 'Create Capability',
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
    final theme = Theme.of(context);

    // Build group map.
    final Map<String, List<AppPermission>> grouped = {};
    for (final p in AppPermission.values) {
      grouped.putIfAbsent(p.groupLabel, () => []).add(p);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'These are the built-in capabilities available across '
            'all SpeakUp Connect organisations. They cannot be modified '
            'or removed — only custom capability aliases can be created '
            'on top of them.',
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
                  title: Text(p.displayName),
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
              'No custom capabilities yet',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a capability alias to give school-specific names '
              'to built-in actions.',
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
