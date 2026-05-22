import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/features/admin/presentation/providers/admin_branding_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';

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
        title: const Text('Branding Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

    ref.read(adminBrandingProvider.notifier).save(
          displayName: _nameCtrl.text.trim(),
          primaryHex: primaryHex,
          secondaryHex: secondaryHex,
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
