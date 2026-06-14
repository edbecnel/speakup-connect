import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/translations/presentation/providers/translation_mode_provider.dart';

Future<void> showTranslationEditSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String stringKey,
  required String arbText,
}) {
  final mode = ref.read(translationModeProvider);
  final source = mode.sourceForKey(stringKey, fallback: arbText);
  final targetFallback = mode.isPreviewingTarget
      ? arbText
      : mode.baselineTarget(stringKey);
  final baseline = mode.baselineTarget(stringKey, fallback: targetFallback);
  final existing = mode.sessionEdits[stringKey];
  final initialTarget = existing?.targetValue ?? baseline;
  final initialApprove = existing?.approve ?? false;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      return _TranslationEditSheetBody(
        stringKey: stringKey,
        sourceValue: source,
        initialTarget: initialTarget,
        initialApprove: initialApprove,
        originalTarget: baseline,
        onSave: (target, approve) {
          ref.read(translationModeProvider.notifier).queueEdit(
                stringKey: stringKey,
                sourceValue: source,
                originalTarget: baseline,
                targetValue: target,
                approve: approve,
              );
          Navigator.of(sheetContext).pop();
        },
      );
    },
  );
}

class _TranslationEditSheetBody extends StatefulWidget {
  const _TranslationEditSheetBody({
    required this.stringKey,
    required this.sourceValue,
    required this.initialTarget,
    required this.initialApprove,
    required this.originalTarget,
    required this.onSave,
  });

  final String stringKey;
  final String sourceValue;
  final String initialTarget;
  final bool initialApprove;
  final String originalTarget;
  final void Function(String target, bool approve) onSave;

  @override
  State<_TranslationEditSheetBody> createState() =>
      _TranslationEditSheetBodyState();
}

class _TranslationEditSheetBodyState extends State<_TranslationEditSheetBody> {
  late final TextEditingController _controller;
  late bool _approve;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTarget);
    _approve = widget.initialApprove;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.9;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.translationModeEditTitle,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                widget.stringKey,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                softWrap: true,
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.translationModeSourceLabel,
                  border: const OutlineInputBorder(),
                  filled: true,
                  alignLabelWithHint: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                ),
                child: Text(
                  widget.sourceValue,
                  softWrap: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                minLines: 2,
                maxLines: 6,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  labelText: l10n.translationTargetLabel,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l10n.translationApprove,
                  softWrap: true,
                ),
                value: _approve,
                onChanged: (v) => setState(() => _approve = v),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.commonCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () =>
                          widget.onSave(_controller.text, _approve),
                      child: Text(l10n.commonSave),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
