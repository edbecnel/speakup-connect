import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/features/roles/domain/entities/custom_capability_entity.dart';
import 'package:speakup_connect/features/roles/domain/entities/role_entity.dart';
import 'package:speakup_connect/features/roles/presentation/providers/roles_provider.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';
import 'package:speakup_connect/shared/widgets/app_text_field.dart';

/// Admin screen for creating or editing a role definition.
///
/// Pass [roleId] to edit an existing role, or omit it (null / "new") to
/// create a new role. The capability checklist is grouped by domain and
/// respects [AppPermission.groupLabel]. Custom capabilities created by the
/// org are listed in a dedicated section at the bottom.
class RoleEditorScreen extends ConsumerStatefulWidget {
  /// `null` or `"new"` means create mode. Any other value is an existing
  /// Firestore role document ID.
  final String? roleId;

  const RoleEditorScreen({super.key, this.roleId});

  bool get isNewRole => roleId == null || roleId == 'new';

  @override
  ConsumerState<RoleEditorScreen> createState() => _RoleEditorScreenState();
}

class _RoleEditorScreenState extends ConsumerState<RoleEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;

  /// Selected built-in permission keys.
  final Set<String> _selectedCaps = {};

  /// Selected custom capability IDs.
  final Set<String> _selectedCustomCaps = {};

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _descCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  /// Populate form fields once the existing role data loads.
  void _initFromRole(RoleEntity role) {
    if (_initialized) return;
    _initialized = true;
    _nameCtrl.text = role.displayName;
    _descCtrl.text = role.description ?? '';
    _selectedCaps
      ..clear()
      ..addAll(role.capabilities);
    _selectedCustomCaps
      ..clear()
      ..addAll(role.customCapabilities);
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final writer = ref.read(roleWriterProvider.notifier);

    if (widget.isNewRole) {
      await writer.createRole(
        displayName: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        capabilities: _selectedCaps.toList(),
        customCapabilities: _selectedCustomCaps.toList(),
      );
    } else {
      await writer.updateRole(
        roleId: widget.roleId!,
        displayName: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        capabilities: _selectedCaps.toList(),
        customCapabilities: _selectedCustomCaps.toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final writerState = ref.watch(roleWriterProvider);

    // Show result snackbar.
    ref.listen(roleWriterProvider, (prev, next) {
      if (!next.isLoading && prev?.isLoading == true) {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Save failed: ${next.error}'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Role saved')),
          );
          if (context.canPop()) context.pop();
        }
      }
    });

    final customCapsAsync = ref.watch(customCapabilitiesProvider);

    // In edit mode, load existing role data.
    if (!widget.isNewRole) {
      final roleAsync = ref.watch(roleByIdProvider(widget.roleId!));
      if (roleAsync.isLoading) return const _LoadingScaffold();
      if (roleAsync.hasError) {
        return _ErrorScaffold(message: roleAsync.error.toString());
      }
      final role = roleAsync.asData?.value;
      if (role != null) _initFromRole(role);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNewRole ? 'Create Role' : 'Edit Role'),
        actions: [
          if (!widget.isNewRole)
            TextButton.icon(
              onPressed: () => context.push(
                Routes.adminRoleAssignPath(widget.roleId!),
              ),
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Assign Users'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Basic details ─────────────────────────────────────────────
            _SectionTitle(title: 'Role Details'),
            const SizedBox(height: 12),
            AppTextField(
              controller: _nameCtrl,
              label: 'Role Name',
              hint: 'e.g. Guidance Counselor',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _descCtrl,
              label: 'Description',
              hint: 'Briefly describe who this role is for',
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // ── Built-in capabilities ─────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionTitle(title: 'Capabilities'),
                TextButton.icon(
                  onPressed: () => context.push(Routes.adminCapabilities),
                  icon: const Icon(Icons.tune_outlined, size: 16),
                  label: const Text('Manage Custom'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Select the built-in capabilities this role grants.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _CapabilityChecklist(
              selected: _selectedCaps,
              onChanged: (key, checked) => setState(() {
                if (checked) {
                  _selectedCaps.add(key);
                } else {
                  _selectedCaps.remove(key);
                }
              }),
            ),

            const SizedBox(height: 24),

            // ── Custom capabilities ───────────────────────────────────────
            _SectionTitle(title: 'Custom Capabilities'),
            const SizedBox(height: 4),
            Text(
              'Org-defined capability aliases built on top of built-ins.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            customCapsAsync.when(
              loading: () => const AppLoadingIndicator(),
              error: (e, _) => AppErrorWidget(message: e.toString()),
              data: (caps) {
                if (caps.isEmpty) {
                  return _NoCustomCapsHint(
                    onCreateTap: () =>
                        context.push(Routes.adminCapabilities),
                  );
                }
                return _CustomCapChecklist(
                  caps: caps,
                  selected: _selectedCustomCaps,
                  onChanged: (id, checked) => setState(() {
                    if (checked) {
                      _selectedCustomCaps.add(id);
                    } else {
                      _selectedCustomCaps.remove(id);
                    }
                  }),
                );
              },
            ),

            const SizedBox(height: 32),

            // ── Save button ───────────────────────────────────────────────
            AppButton.primary(
              label: writerState.isLoading ? 'Saving…' : 'Save Role',
              onPressed: writerState.isLoading ? null : _save,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Capability Checklist ──────────────────────────────────────────────────────

/// Shows all [AppPermission] values grouped by [AppPermission.groupLabel].
class _CapabilityChecklist extends StatelessWidget {
  const _CapabilityChecklist({
    required this.selected,
    required this.onChanged,
  });

  final Set<String> selected;
  final void Function(String key, bool checked) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Build group → [AppPermission] map while preserving insertion order.
    final Map<String, List<AppPermission>> grouped = {};
    for (final p in AppPermission.values) {
      grouped.putIfAbsent(p.groupLabel, () => []).add(p);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 2),
              child: Text(
                entry.key,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...entry.value.map((perm) {
              return CheckboxListTile(
                value: selected.contains(perm.key),
                onChanged: (v) => onChanged(perm.key, v ?? false),
                title: Text(
                  perm.displayName,
                  style: theme.textTheme.bodyMedium,
                ),
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              );
            }),
            const Divider(height: 1),
          ],
        );
      }).toList(),
    );
  }
}

// ── Custom Capability Checklist ───────────────────────────────────────────────

class _CustomCapChecklist extends StatelessWidget {
  const _CustomCapChecklist({
    required this.caps,
    required this.selected,
    required this.onChanged,
  });

  final List<CustomCapabilityEntity> caps;
  final Set<String> selected;
  final void Function(String id, bool checked) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: caps.map((cap) {
        final resolvedPerm = AppPermission.fromKey(cap.resolvedAction);
        return CheckboxListTile(
          value: selected.contains(cap.id),
          onChanged: (v) => onChanged(cap.id, v ?? false),
          title: Text(cap.displayName, style: theme.textTheme.bodyMedium),
          subtitle: resolvedPerm != null
              ? Text(
                  'Based on: ${resolvedPerm.displayName}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              : null,
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        );
      }).toList(),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleSmall
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _NoCustomCapsHint extends StatelessWidget {
  const _NoCustomCapsHint({required this.onCreateTap});
  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'No custom capabilities yet.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onCreateTap,
            child: const Text('Create a custom capability →'),
          ),
        ],
      ),
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: AppLoadingIndicator(),
      );
}

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(message: message),
      );
}
