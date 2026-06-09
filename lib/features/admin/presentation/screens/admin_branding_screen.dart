import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';
import 'package:speakup_connect/core/theme/app_theme.dart';
import 'package:speakup_connect/features/admin/presentation/providers/admin_branding_provider.dart';
import 'package:speakup_connect/features/organization/domain/entities/organization_config_entity.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/reports/presentation/providers/report_provider.dart';

/// Admin screen for updating the organization's display name and brand colors.
///
/// Changes are written to Firestore (propagating to all connected clients in
/// real time) and the local SharedPreferences cache is refreshed automatically
/// via the [OrganizationConfig] stream listener — so the next app launch on
/// this device also loads the correct branding without a network call.
///
/// Access: restricted to users with the `admin` role (enforced by Firestore
/// security rules and the admin-only route guard in [AppRouter]).
class AdminBrandingScreen extends ConsumerStatefulWidget {
  const AdminBrandingScreen({super.key});

  @override
  ConsumerState<AdminBrandingScreen> createState() =>
      _AdminBrandingScreenState();
}

class _AdminBrandingScreenState extends ConsumerState<AdminBrandingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _primaryCtrl;
  late final TextEditingController _secondaryCtrl;

  @override
  void initState() {
    super.initState();
    final org = ref.read(organizationConfigProvider).asData?.value;
    _nameCtrl = TextEditingController(text: org?.displayName ?? '');
    _primaryCtrl = TextEditingController(
      text: org != null ? _colorToHex(org.themeColors.primary) : '',
    );
    _secondaryCtrl = TextEditingController(
      text: org != null ? _colorToHex(org.themeColors.secondary) : '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _primaryCtrl.dispose();
    _secondaryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final savingState = ref.watch(adminBrandingProvider);
    final isSaving = savingState.isLoading;

    // Show a snackbar when save succeeds or fails.
    ref.listen(adminBrandingProvider, (prev, next) {
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
            SnackBar(
              content: const Text('Branding updated successfully'),
              backgroundColor: Colors.green.shade700,
            ),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Organization Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _OrganizationTypeCard(),
              const SizedBox(height: 32),
              _SectionHeader(
                icon: Icons.business_outlined,
                title: 'Organization Name',
                subtitle:
                    'Displayed on the splash screen as "SpeakUp [Name]".',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'e.g. Riverside High',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              _SectionHeader(
                icon: Icons.palette_outlined,
                title: 'Brand Colors',
                subtitle:
                    'Enter 6-digit hex codes from the organization\'s brand guide '
                    '(e.g. #1A73E8). Changes apply to all connected devices in '
                    'real time and are cached locally for instant startup.',
              ),
              const SizedBox(height: 16),
              _ColorField(
                controller: _primaryCtrl,
                label: 'Primary Color',
                hint: 'e.g. #1A73E8',
              ),
              const SizedBox(height: 16),
              _ColorField(
                controller: _secondaryCtrl,
                label: 'Secondary Color',
                hint: 'e.g. #000000',
              ),
              const SizedBox(height: 16),
              _ColorPreviewRow(
                primaryHex: _primaryCtrl.text,
                secondaryHex: _secondaryCtrl.text,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: isSaving ? null : _save,
                  icon: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(isSaving ? 'Saving…' : 'Save Branding'),
                ),
              ),
              const SizedBox(height: 24),
              _InfoBox(
                message:
                    'After saving, the new colors will appear immediately on '
                    'all connected devices. On this device the branding is '
                    'also written to local storage, so it loads correctly on '
                    'the next app launch before Firestore responds.',
              ),
              const SizedBox(height: 32),
              _SetupCategoriesCard(),
              const SizedBox(height: 32),
              const _ReminderApprovalCard(),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final primaryHex = _normalizeHex(_primaryCtrl.text.trim());
    final secondaryHex = _normalizeHex(_secondaryCtrl.text.trim());

    if (primaryHex == null) {
      _showFieldError('Primary color must be a valid 6-digit hex (e.g. #1A73E8).');
      return;
    }
    if (secondaryHex == null) {
      _showFieldError('Secondary color must be a valid 6-digit hex (e.g. #000000).');
      return;
    }

    final primary = Color(int.parse('FF${primaryHex.substring(1)}', radix: 16));
    final secondary = Color(int.parse('FF${secondaryHex.substring(1)}', radix: 16));

    // Approximate M3 surface colors for each theme mode.
    const lightSurface = Color(0xFFFFFBFE);
    const darkSurface = Color(0xFF141218);

    // Warn whenever the primary itself fails — even if secondary can rescue it
    // at runtime, the admin should know their brand color isn't truly visible.
    final lightIssue = AppTheme.primaryNeedsContrastWarning(primary, lightSurface);
    final darkIssue = AppTheme.primaryNeedsContrastWarning(primary, darkSurface);

    if (lightIssue || darkIssue) {
      // Does secondary at least provide a fallback for the affected surface(s)?
      final secondaryCanResolve =
          (lightIssue && !AppTheme.primaryNeedsContrastWarning(secondary, lightSurface)) ||
          (darkIssue && !AppTheme.primaryNeedsContrastWarning(secondary, darkSurface));
      _showContrastWarningDialog(
        primaryHex: primaryHex,
        secondaryHex: secondaryHex,
        primary: primary,
        lightIssue: lightIssue,
        darkIssue: darkIssue,
        secondaryCanResolve: secondaryCanResolve,
      );
      return;
    }

    _performSave(primaryHex, secondaryHex);
  }

  void _performSave(String primaryHex, String secondaryHex) {
    ref.read(adminBrandingProvider.notifier).save(
          displayName: _nameCtrl.text.trim(),
          primaryHex: primaryHex,
          secondaryHex: secondaryHex,
        );
  }

  void _showContrastWarningDialog({
    required String primaryHex,
    required String secondaryHex,
    required Color primary,
    required bool lightIssue,
    required bool darkIssue,
    required bool secondaryCanResolve,
  }) {
    final surfaces = [
      if (lightIssue) 'light',
      if (darkIssue) 'dark',
    ];
    final surfaceLabel = surfaces.length == 1
        ? '${surfaces[0]} backgrounds'
        : 'light and dark backgrounds';

    final message = secondaryCanResolve
        ? 'Your primary color ($primaryHex) isn\'t visible enough on '
          '$surfaceLabel — it will blend into the background.\n\n'
          'Your secondary color ($secondaryHex) will be used as a fallback '
          'for buttons and icons, but you may want a more suitable primary.\n\n'
          'You can save anyway or let the app shift the primary to the '
          'nearest contrast-safe shade.'
        : 'Neither your primary ($primaryHex) nor secondary ($secondaryHex) '
          'color provides enough contrast against $surfaceLabel. '
          'Buttons, links, and icons may be hard to see.\n\n'
          'You can save anyway, or let the app shift the primary color to '
          'the nearest contrast-safe shade.';

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Contrast Warning'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _performSave(primaryHex, secondaryHex);
            },
            child: const Text('Save Anyway'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final adjustSurface = lightIssue
                  ? const Color(0xFFFFFBFE)
                  : const Color(0xFF141218);
              final adjusted =
                  AppTheme.autoAdjustForContrast(primary, adjustSurface);
              final r = (adjusted.r * 255).round().toRadixString(16).padLeft(2, '0');
              final g = (adjusted.g * 255).round().toRadixString(16).padLeft(2, '0');
              final b = (adjusted.b * 255).round().toRadixString(16).padLeft(2, '0');
              final adjustedHex = '#$r$g$b'.toUpperCase();
              setState(() => _primaryCtrl.text = adjustedHex);
              _performSave(adjustedHex, secondaryHex);
            },
            child: const Text('Auto-adjust & Save'),
          ),
        ],
      ),
    );
  }

  void _showFieldError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  /// Normalizes a user-typed hex string to `#RRGGBB` format, or returns null
  /// if the string is not a valid 6-digit hex.
  String? _normalizeHex(String input) {
    final clean = input.replaceFirst('#', '').trim().toUpperCase();
    if (clean.length != 6) return null;
    final validHex = RegExp(r'^[0-9A-F]{6}$');
    if (!validHex.hasMatch(clean)) return null;
    return '#$clean';
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(title, style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _ColorField extends StatefulWidget {
  const _ColorField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  @override
  State<_ColorField> createState() => _ColorFieldState();
}

class _ColorFieldState extends State<_ColorField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  Color? get _preview {
    final clean = widget.controller.text.replaceFirst('#', '').trim();
    if (clean.length != 6) return null;
    try {
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        border: const OutlineInputBorder(),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: preview ?? Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.black12),
            ),
          ),
        ),
      ),
      autocorrect: false,
      textCapitalization: TextCapitalization.characters,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Required';
        final clean = v.replaceFirst('#', '').trim();
        if (clean.length != 6 || !RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(clean)) {
          return 'Enter a valid 6-digit hex (e.g. #1A73E8)';
        }
        return null;
      },
    );
  }
}

class _ColorPreviewRow extends StatelessWidget {
  const _ColorPreviewRow({
    required this.primaryHex,
    required this.secondaryHex,
  });

  final String primaryHex;
  final String secondaryHex;

  @override
  Widget build(BuildContext context) {
    final primary = _fromHex(primaryHex);
    final secondary = _fromHex(secondaryHex);

    if (primary == null && secondary == null) return const SizedBox.shrink();

    return Row(
      children: [
        if (primary != null) ...[
          _Swatch(color: primary, label: 'Primary'),
          const SizedBox(width: 12),
        ],
        if (secondary != null) _Swatch(color: secondary, label: 'Secondary'),
      ],
    );
  }

  Color? _fromHex(String hex) {
    final clean = hex.replaceFirst('#', '').trim();
    if (clean.length != 6) return null;
    try {
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return null;
    }
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline,
              size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Setup: seed default categories ──────────────────────────────────────────

class _SetupCategoriesCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(reportCategoriesProvider);
    final seedState = ref.watch(seedCategoriesProvider);

    ref.listen(seedCategoriesProvider, (prev, next) {
      if (!next.isLoading && prev?.isLoading == true) {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Seed failed: ${next.error}'),
            backgroundColor: theme.colorScheme.error,
          ));
        } else {
          // Refresh category list after seeding.
          ref.invalidate(reportCategoriesProvider);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Default categories added successfully'),
            backgroundColor: Colors.green,
          ));
        }
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          icon: Icons.category_outlined,
          title: 'Report Categories',
          subtitle:
              'Categories are required for users to submit concerns. '
              'Tap the button below to populate the default set.',
        ),
        const SizedBox(height: 12),
        categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
          data: (cats) {
            if (cats.isNotEmpty) {
              return Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${cats.length} categories configured',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.green.shade700),
                  ),
                ],
              );
            }
            return SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: seedState.isLoading
                    ? null
                    : () => ref.read(seedCategoriesProvider.notifier).seed(),
                icon: seedState.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_circle_outline),
                label: Text(
                  seedState.isLoading ? 'Adding…' : 'Add Default Categories',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── Organization type ───────────────────────────────────────────────────────

class _OrganizationTypeCard extends ConsumerStatefulWidget {
  const _OrganizationTypeCard();

  @override
  ConsumerState<_OrganizationTypeCard> createState() =>
      _OrganizationTypeCardState();
}

class _OrganizationTypeCardState extends ConsumerState<_OrganizationTypeCard> {
  OrganizationType? _selectedType;
  bool _saving = false;

  Future<void> _saveType(OrganizationType currentType) async {
    final nextType = _selectedType;
    if (nextType == null || nextType == currentType) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change organization type?'),
        content: Text(
          'Change from ${currentType.adminDisplayName} to '
          '${nextType.adminDisplayName}?\n\n'
          '${nextType.adminDescription}\n\n'
          'This affects which admin features are available (such as student '
          'grades and roster for schools).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _saving = true);
    try {
      await ref.read(organizationRepositoryProvider).updateOrganizationType(
            organizationId: AppConfig.defaultOrganizationId,
            type: nextType,
          );
      if (mounted) {
        setState(() => _selectedType = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Organization type set to ${nextType.adminDisplayName}'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orgAsync = ref.watch(organizationConfigProvider);
    final currentType =
        orgAsync.asData?.value.type ?? OrganizationType.other;
    final selectedType = _selectedType ?? currentType;
    final hasChanges = selectedType != currentType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          icon: Icons.apartment_outlined,
          title: 'Organization Type',
          subtitle:
              'Determines which features are available. Schools can use '
              'student grades and roster; municipalities and NGOs use '
              'member management without grades.',
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<OrganizationType>(
          initialValue: selectedType,
          decoration: const InputDecoration(
            labelText: 'Type',
            border: OutlineInputBorder(),
          ),
          items: OrganizationType.values
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.adminDisplayName),
                ),
              )
              .toList(),
          onChanged: _saving
              ? null
              : (value) => setState(() => _selectedType = value),
        ),
        const SizedBox(height: 8),
        Text(
          selectedType.adminDescription,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: _saving || !hasChanges
                ? null
                : () => _saveType(currentType),
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save type'),
          ),
        ),
      ],
    );
  }
}

// ── Setup: reminder approval workflow toggle ────────────────────────────────

class _ReminderApprovalCard extends ConsumerStatefulWidget {
  const _ReminderApprovalCard();

  @override
  ConsumerState<_ReminderApprovalCard> createState() =>
      _ReminderApprovalCardState();
}

class _ReminderApprovalCardState extends ConsumerState<_ReminderApprovalCard> {
  bool _saving = false;
  bool? _localOverride;

  Future<void> _toggle(bool value) async {
    setState(() {
      _saving = true;
      _localOverride = value;
    });
    try {
      await ref.read(organizationRepositoryProvider).updateReminderApproval(
            organizationId: AppConfig.defaultOrganizationId,
            requireApproval: value,
          );
      final config = await ref
          .read(organizationConfigProvider.notifier)
          .refreshFromServer();
      if (config.requireReminderApproval != value) {
        throw StateError('Reminder approval setting did not save.');
      }
      if (mounted) {
        setState(() => _localOverride = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? 'Reminders now require approval before publishing'
                  : 'Reminders now publish directly',
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _localOverride = null);
        final message = e is PermissionException
            ? 'You do not have permission to change this setting.'
            : 'Update failed: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orgAsync = ref.watch(organizationConfigProvider);
    final remoteValue =
        orgAsync.asData?.value.requireReminderApproval ?? false;

    ref.listen(organizationConfigProvider, (prev, next) {
      final nextValue = next.asData?.value.requireReminderApproval;
      if (!_saving &&
          mounted &&
          _localOverride != null &&
          nextValue == _localOverride) {
        setState(() => _localOverride = null);
      }
    });

    final requireApproval = _localOverride ?? remoteValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          icon: Icons.fact_check_outlined,
          title: 'Reminder Approval',
          subtitle:
              'When enabled, members who can broadcast reminders but cannot '
              'approve them must submit reminders for review before they are '
              'published.',
        ),
        const SizedBox(height: 4),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Require approval before publishing'),
          subtitle: Text(
            requireApproval
                ? 'Currently ON — reminders from non-approvers are held for review'
                : 'Currently OFF — reminders publish immediately',
            style: theme.textTheme.bodySmall?.copyWith(
              color: requireApproval
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight:
                  requireApproval ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          value: requireApproval,
          onChanged: _saving ? null : _toggle,
          secondary: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
        ),
      ],
    );
  }
}

