import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/permission_l10n.dart';
import 'package:speakup_connect/features/roles/domain/entities/custom_capability_entity.dart';
import 'package:speakup_connect/features/roles/domain/entities/role_entity.dart';
import 'package:speakup_connect/features/reports/domain/entities/report_category_entity.dart';
import 'package:speakup_connect/features/reports/presentation/providers/report_provider.dart';
import 'package:speakup_connect/features/roles/presentation/providers/roles_provider.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';
import 'package:speakup_connect/shared/widgets/app_text_field.dart';
import 'package:speakup_connect/shared/widgets/secondary_app_bar.dart';

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

  /// Allowed report category IDs for report-related capabilities.
  final Set<String> _selectedCategories = {};

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
    _selectedCategories
      ..clear()
      ..addAll(role.allowedCategoryIds ?? const []);
  }

  bool get _hasReportCapability => _selectedCaps.any(
        (key) => AppPermission.fromKey(key)?.isReportRelated ?? false,
      );

  bool get _isOrgAdminRole => widget.roleId == 'org-admin';

  List<String>? get _allowedCategoryIdsPayload {
    if (_isOrgAdminRole) return null;
    return _selectedCategories.toList();
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_hasReportCapability &&
        !_isOrgAdminRole &&
        _selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.roleEditorReportCategoriesRequired),
        ),
      );
      return;
    }

    final writer = ref.read(roleWriterProvider.notifier);

    if (widget.isNewRole) {
      await writer.createRole(
        displayName: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        capabilities: _selectedCaps.toList(),
        customCapabilities: _selectedCustomCaps.toList(),
        allowedCategoryIds: _allowedCategoryIdsPayload,
      );
    } else {
      await writer.updateRole(
        roleId: widget.roleId!,
        displayName: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        capabilities: _selectedCaps.toList(),
        customCapabilities: _selectedCustomCaps.toList(),
        allowedCategoryIds: _isOrgAdminRole ? null : _allowedCategoryIdsPayload,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final writerState = ref.watch(roleWriterProvider);

    // Show result snackbar.
    ref.listen(roleWriterProvider, (prev, next) {
      if (!next.isLoading && prev?.isLoading == true) {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.roleEditorSaveFailed('${next.error}')),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.roleEditorSaved)),
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
      appBar: SecondaryAppBar(
        title: widget.isNewRole
            ? l10n.roleEditorCreateTitle
            : l10n.roleEditorEditTitle,
        actions: [
          if (!widget.isNewRole)
            AppButton.text(
              label: l10n.roleEditorAssignUsers,
              icon: Icons.person_add_outlined,
              minimumWidth: 0,
              onPressed: () => context.push(
                Routes.adminRoleAssignPath(widget.roleId!),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Basic details ─────────────────────────────────────────────
            _SectionTitle(title: l10n.roleEditorRoleDetails),
            const SizedBox(height: 12),
            AppTextField(
              controller: _nameCtrl,
              label: l10n.roleEditorRoleName,
              hint: l10n.roleEditorNameHint,
              validator: (v) =>
                  (v == null || v.trim().isEmpty)
                      ? l10n.commonNameRequired
                      : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _descCtrl,
              label: l10n.roleEditorDescription,
              hint: l10n.roleEditorDescriptionHint,
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // ── Built-in capabilities ─────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionTitle(title: l10n.roleEditorCapabilities),
                TextButton.icon(
                  onPressed: () => context.push(Routes.adminCapabilities),
                  icon: const Icon(Icons.tune_outlined, size: 16),
                  label: Text(l10n.roleEditorManageCustom),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.roleEditorCapabilitiesHint,
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

            if (_hasReportCapability && !_isOrgAdminRole) ...[
              const SizedBox(height: 24),
              _SectionTitle(title: l10n.roleEditorReportCategories),
              const SizedBox(height: 4),
              Text(
                l10n.roleEditorReportCategoriesHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              ref.watch(reportCategoriesProvider).when(
                    loading: () => const AppLoadingIndicator(),
                    error: (e, _) => AppErrorWidget(message: '$e'),
                    data: (categories) => _CategoryChipSelector(
                      categories: categories,
                      selected: _selectedCategories,
                      onChanged: (categoryId, checked) => setState(() {
                        if (checked) {
                          _selectedCategories.add(categoryId);
                        } else {
                          _selectedCategories.remove(categoryId);
                        }
                      }),
                    ),
                  ),
            ],

            const SizedBox(height: 24),

            // ── Custom capabilities ───────────────────────────────────────
            _SectionTitle(title: l10n.roleEditorCustomCapabilities),
            const SizedBox(height: 4),
            Text(
              l10n.roleEditorCustomCapabilitiesHint,
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
              label: writerState.isLoading
                  ? l10n.roleEditorSaving
                  : l10n.roleEditorSaveRole,
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
    final l10n = context.l10n;
    final theme = Theme.of(context);

    // Build group → [AppPermission] map while preserving insertion order.
    final Map<String, List<AppPermission>> grouped = {};
    for (final p in AppPermission.values) {
      grouped
          .putIfAbsent(localizedPermissionGroup(l10n, p), () => [])
          .add(p);
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
                  localizedPermissionName(l10n, perm),
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

// ── Category Chip Selector ────────────────────────────────────────────────────

class _CategoryChipSelector extends StatelessWidget {
  const _CategoryChipSelector({
    required this.categories,
    required this.selected,
    required this.onChanged,
  });

  final List<ReportCategoryEntity> categories;
  final Set<String> selected;
  final void Function(String categoryId, bool checked) onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: categories.map((cat) {
        return FilterChip(
          label: Text(cat.label),
          selected: selected.contains(cat.categoryId),
          onSelected: (v) => onChanged(cat.categoryId, v),
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
    final l10n = context.l10n;
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
                  l10n.roleEditorBasedOn(
                    localizedPermissionName(l10n, resolvedPerm),
                  ),
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
    final l10n = context.l10n;
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
            l10n.roleEditorNoCustomCaps,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onCreateTap,
            child: Text(l10n.roleEditorCreateCustomCap),
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
