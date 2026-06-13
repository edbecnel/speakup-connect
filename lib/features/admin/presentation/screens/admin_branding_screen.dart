import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/core/theme/app_theme.dart';
import 'package:speakup_connect/features/admin/presentation/providers/admin_branding_provider.dart';
import 'package:speakup_connect/features/roles/presentation/l10n/roles_ui_l10n.dart';
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
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final savingState = ref.watch(adminBrandingProvider);
    final isSaving = savingState.isLoading;

    // Show a snackbar when save succeeds or fails.
    ref.listen(adminBrandingProvider, (prev, next) {
      if (!next.isLoading && prev?.isLoading == true) {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.orgSettingsSaveFailed('${next.error}')),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.orgSettingsBrandingUpdated),
              backgroundColor: Colors.green.shade700,
            ),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.orgSettingsTitle),
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
                title: l10n.orgSettingsOrgNameTitle,
                subtitle: l10n.orgSettingsOrgNameSubtitle,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: l10n.orgSettingsDisplayName,
                  hintText: l10n.orgSettingsDisplayNameHint,
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? context.l10n.orgSettingsRequired
                        : null,
              ),
              const SizedBox(height: 32),
              _SectionHeader(
                icon: Icons.palette_outlined,
                title: l10n.orgSettingsBrandColorsTitle,
                subtitle: l10n.orgSettingsBrandColorsSubtitle,
              ),
              const SizedBox(height: 16),
              _ColorField(
                controller: _primaryCtrl,
                label: l10n.orgSettingsPrimaryColor,
                hint: l10n.orgSettingsColorHint,
              ),
              const SizedBox(height: 16),
              _ColorField(
                controller: _secondaryCtrl,
                label: l10n.orgSettingsSecondaryColor,
                hint: l10n.orgSettingsSecondaryColorHint,
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
                  label: Text(isSaving ? l10n.orgSettingsSaving : l10n.orgSettingsSaveBranding),
                ),
              ),
              const SizedBox(height: 24),
              _InfoBox(message: l10n.orgSettingsBrandingInfo),
              const SizedBox(height: 32),
              _SetupCategoriesCard(),
              const SizedBox(height: 32),
              const _ReminderApprovalCard(),
              const SizedBox(height: 32),
              const _MemberProfilePhotosCard(),
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
      _showFieldError(context.l10n.orgSettingsPrimaryHexInvalid);
      return;
    }
    if (secondaryHex == null) {
      _showFieldError(context.l10n.orgSettingsSecondaryHexInvalid);
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
    final l10n = context.l10n;
    final surfaces = [
      if (lightIssue) l10n.orgSettingsContrastLightBackgrounds,
      if (darkIssue) l10n.orgSettingsContrastDarkBackgrounds,
    ];
    final surfaceLabel = surfaces.length == 1
        ? surfaces[0]
        : l10n.orgSettingsContrastLightAndDarkBackgrounds;

    final message = secondaryCanResolve
        ? l10n.orgSettingsContrastSecondaryFallback(
            primaryHex,
            secondaryHex,
            surfaceLabel,
          )
        : l10n.orgSettingsContrastNeither(
            primaryHex,
            secondaryHex,
            surfaceLabel,
          );

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.orgSettingsContrastWarning),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _performSave(primaryHex, secondaryHex);
            },
            child: Text(context.l10n.orgSettingsSaveAnyway),
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
            child: Text(context.l10n.orgSettingsAutoAdjustSave),
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
    final l10n = context.l10n;
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
    final l10n = context.l10n;
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
        if (v == null || v.trim().isEmpty) return l10n.orgSettingsRequired;
        final clean = v.replaceFirst('#', '').trim();
        if (clean.length != 6 || !RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(clean)) {
          return l10n.orgSettingsHexInvalid;
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
    final l10n = context.l10n;
    final primary = _fromHex(primaryHex);
    final secondary = _fromHex(secondaryHex);

    if (primary == null && secondary == null) return const SizedBox.shrink();

    return Row(
      children: [
        if (primary != null) ...[
          _Swatch(color: primary, label: l10n.orgSettingsPrimarySwatch),
          const SizedBox(width: 12),
        ],
        if (secondary != null)
          _Swatch(color: secondary, label: l10n.orgSettingsSecondarySwatch),
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
    final l10n = context.l10n;
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
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(reportCategoriesProvider);
    final seedState = ref.watch(seedCategoriesProvider);

    ref.listen(seedCategoriesProvider, (prev, next) {
      if (!next.isLoading && prev?.isLoading == true) {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              l10n.orgSettingsSeedCategoriesFailed('${next.error}'),
            ),
            backgroundColor: theme.colorScheme.error,
          ));
        } else {
          // Refresh category list after seeding.
          ref.invalidate(reportCategoriesProvider);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.orgSettingsSeedCategoriesSuccess),
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
          title: l10n.orgSettingsReportCategoriesTitle,
          subtitle: l10n.orgSettingsReportCategoriesSubtitle,
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
                    l10n.orgSettingsCategoriesConfigured(cats.length),
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
                  seedState.isLoading
                      ? l10n.orgSettingsAddingCategories
                      : l10n.orgSettingsAddDefaultCategories,
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
        title: Text(context.l10n.orgSettingsChangeOrgTypeTitle),
        content: Text(
          context.l10n.orgSettingsChangeOrgTypeConfirm(
            localizedOrganizationTypeName(context.l10n, currentType),
            localizedOrganizationTypeName(context.l10n, nextType),
            localizedOrganizationTypeDescription(context.l10n, nextType),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.l10n.commonConfirm),
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
            content: Text(
              context.l10n.orgSettingsOrgTypeSaved(
                localizedOrganizationTypeName(context.l10n, nextType),
              ),
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.orgSettingsOrgTypeFailed('$e'),
            ),
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
    final l10n = context.l10n;
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
          title: l10n.orgSettingsOrgTypeTitle,
          subtitle: l10n.orgSettingsOrgTypeSubtitle,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<OrganizationType>(
          initialValue: selectedType,
          decoration: InputDecoration(
            labelText: l10n.orgSettingsTypeLabel,
            border: const OutlineInputBorder(),
          ),
          items: OrganizationType.values
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(localizedOrganizationTypeName(l10n, type)),
                ),
              )
              .toList(),
          onChanged: _saving
              ? null
              : (value) => setState(() => _selectedType = value),
        ),
        const SizedBox(height: 8),
        Text(
          localizedOrganizationTypeDescription(l10n, selectedType),
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
                : Text(l10n.orgSettingsSaveType),
          ),
        ),
      ],
    );
  }
}

// ── Setup: reminder approval workflow toggle ────────────────────────────────

class _MemberProfilePhotosCard extends ConsumerStatefulWidget {
  const _MemberProfilePhotosCard();

  @override
  ConsumerState<_MemberProfilePhotosCard> createState() =>
      _MemberProfilePhotosCardState();
}

class _MemberProfilePhotosCardState
    extends ConsumerState<_MemberProfilePhotosCard> {
  bool _saving = false;
  bool? _localOverride;

  Future<void> _toggle(bool value) async {
    final l10n = context.l10n;
    setState(() {
      _saving = true;
      _localOverride = value;
    });
    try {
      await ref.read(organizationRepositoryProvider).updateMemberProfilePhotos(
            organizationId: AppConfig.defaultOrganizationId,
            allowMemberProfilePhotos: value,
          );
      final config = await ref
          .read(organizationConfigProvider.notifier)
          .refreshFromServer();
      if (config.allowMemberProfilePhotos != value) {
        throw StateError(context.l10n.orgSettingsProfilePhotoSaveFailed);
      }
      if (mounted) {
        setState(() => _localOverride = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? l10n.orgSettingsMemberPhotosEnabled
                  : l10n.orgSettingsMemberPhotosDisabled,
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _localOverride = null);
        final message = e is PermissionException
            ? l10n.orgSettingsPermissionDenied
            : context.l10n.orgSettingsOrgTypeFailed('$e');
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
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final orgAsync = ref.watch(organizationConfigProvider);
    final remoteValue =
        orgAsync.asData?.value.allowMemberProfilePhotos ?? false;

    ref.listen(organizationConfigProvider, (prev, next) {
      final nextValue = next.asData?.value.allowMemberProfilePhotos;
      if (!_saving &&
          mounted &&
          _localOverride != null &&
          nextValue == _localOverride) {
        setState(() => _localOverride = null);
      }
    });

    final allowed = _localOverride ?? remoteValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          icon: Icons.account_circle_outlined,
          title: l10n.orgSettingsMemberPhotosTitle,
          subtitle: l10n.orgSettingsMemberPhotosSubtitle,
        ),
        const SizedBox(height: 4),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.orgSettingsAllowPersonalPhotos),
          subtitle: Text(
            allowed
                ? l10n.orgSettingsMemberPhotosOn
                : l10n.orgSettingsMemberPhotosOff,
            style: theme.textTheme.bodySmall?.copyWith(
              color: allowed
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: allowed ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          value: allowed,
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
    final l10n = context.l10n;
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
        throw StateError(context.l10n.orgSettingsReminderApprovalSaveFailed);
      }
      if (mounted) {
        setState(() => _localOverride = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? l10n.orgSettingsReminderApprovalEnabled
                  : l10n.orgSettingsReminderApprovalDisabled,
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _localOverride = null);
        final message = e is PermissionException
            ? l10n.orgSettingsPermissionDenied
            : context.l10n.orgSettingsOrgTypeFailed('$e');
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
    final l10n = context.l10n;
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
          title: l10n.orgSettingsReminderApprovalTitle,
          subtitle: l10n.orgSettingsReminderApprovalSubtitle,
        ),
        const SizedBox(height: 4),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.orgSettingsRequireApproval),
          subtitle: Text(
            requireApproval
                ? l10n.orgSettingsReminderApprovalOn
                : l10n.orgSettingsReminderApprovalOff,
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

