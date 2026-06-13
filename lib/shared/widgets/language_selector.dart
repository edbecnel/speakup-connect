import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/core/l10n/locale_provider.dart';

/// Dropdown for switching app language. Option labels use [kLanguageNativeLabels]
/// so users can find their language before the rest of the UI is translated.
class LanguageSelectorDropdown extends ConsumerWidget {
  const LanguageSelectorDropdown({
    super.key,
    this.compact = false,
    this.showLeadingIcon = true,
  });

  /// When true, sizes for a dense app-bar action; when false, expands in a row.
  final bool compact;

  /// Globe icon before the dropdown (recommended on Home for discoverability).
  final bool showLeadingIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCode = ref.watch(appLocaleProvider).languageCode;
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final dropdown = DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: currentCode,
        isExpanded: !compact,
        isDense: compact,
        icon: Icon(
          Icons.arrow_drop_down_rounded,
          color: compact ? theme.colorScheme.onSurface : null,
        ),
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: compact ? FontWeight.w600 : FontWeight.w500,
        ),
        items: supportedAppLanguageCodes
            .map(
              (code) => DropdownMenuItem<String>(
                value: code,
                child: Text(kLanguageNativeLabels[code] ?? code),
              ),
            )
            .toList(),
        onChanged: (code) async {
          if (code == null) return;
          try {
            await ref.read(appLocaleProvider.notifier).setLanguageCode(code);
          } catch (_) {
            await ref.read(appLocaleProvider.notifier).resetToEnglish();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.settingsLanguageRevertToEnglish),
                ),
              );
            }
          }
        },
      ),
    );

    if (!showLeadingIcon) {
      return Semantics(
        label: l10n.settingsLanguage,
        child: dropdown,
      );
    }

    return Semantics(
      label: l10n.settingsLanguage,
      child: Row(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Icon(
            Icons.language_rounded,
            size: compact ? 22 : 24,
            color: compact
                ? theme.colorScheme.onSurface
                : theme.colorScheme.primary,
          ),
          SizedBox(width: compact ? 4 : 10),
          if (compact) dropdown else Expanded(child: dropdown),
        ],
      ),
    );
  }
}

/// Bottom-sheet language picker (Settings and other full-screen flows).
void showLanguagePickerSheet(BuildContext context, WidgetRef ref) {
  final current = ref.read(appLocaleProvider).languageCode;

  showModalBottomSheet<void>(
    context: context,
    builder: (_) => SafeArea(
      child: RadioGroup<String>(
        groupValue: current,
        onChanged: (code) async {
          if (code == null) return;
          final l10n = context.l10n;
          try {
            await ref.read(appLocaleProvider.notifier).setLanguageCode(code);
          } catch (_) {
            await ref.read(appLocaleProvider.notifier).resetToEnglish();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.settingsLanguageRevertToEnglish),
                ),
              );
            }
          }
          if (context.mounted) Navigator.pop(context);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: supportedAppLanguageCodes
              .map(
                (code) => RadioListTile<String>(
                  value: code,
                  title: Text(kLanguageNativeLabels[code] ?? code),
                ),
              )
              .toList(),
        ),
      ),
    ),
  );
}
