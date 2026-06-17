import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/translations/domain/translation_session_edit.dart';
import 'package:speakup_connect/features/translations/presentation/providers/translation_mode_provider.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';

/// Review and commit all in-context translation edits from the current session.
class TranslationSessionReviewScreen extends ConsumerStatefulWidget {
  const TranslationSessionReviewScreen({super.key});

  @override
  ConsumerState<TranslationSessionReviewScreen> createState() =>
      _TranslationSessionReviewScreenState();
}

class _TranslationSessionReviewScreenState
    extends ConsumerState<TranslationSessionReviewScreen> {
  var _saving = false;

  Future<void> _saveAll() async {
    setState(() => _saving = true);
    try {
      final count =
          await ref.read(translationModeProvider.notifier).commitSession();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.translationModeReviewSaveAllSuccess(count)),
        ),
      );
      if (count > 0) context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mode = ref.watch(translationModeProvider);
    final edits = mode.sessionEdits.values.toList()
      ..sort((a, b) => a.stringKey.compareTo(b.stringKey));

    if (!mode.isActive) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
          title: Text(l10n.translationModeReviewTitle),
        ),
        body: AppErrorWidget(
          message: l10n.translationModeReviewInactive,
          onRetry: () => context.pop(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.translationModeReviewTitle),
      ),
      body: edits.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.translationModeReviewEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: edits.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) => _SessionEditCard(
                edit: edits[index],
                onChanged: (updated) => ref
                    .read(translationModeProvider.notifier)
                    .updateSessionEdit(updated.stringKey, updated),
                onRemove: () => ref
                    .read(translationModeProvider.notifier)
                    .removeSessionEdit(edits[index].stringKey),
              ),
            ),
      bottomNavigationBar: edits.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AppButton.primary(
                  label: l10n.translationModeReviewSaveAll(edits.length),
                  isLoading: _saving,
                  onPressed: _saving ? null : _saveAll,
                ),
              ),
            ),
    );
  }
}

class _SessionEditCard extends StatefulWidget {
  const _SessionEditCard({
    required this.edit,
    required this.onChanged,
    required this.onRemove,
  });

  final TranslationSessionEdit edit;
  final ValueChanged<TranslationSessionEdit> onChanged;
  final VoidCallback onRemove;

  @override
  State<_SessionEditCard> createState() => _SessionEditCardState();
}

class _SessionEditCardState extends State<_SessionEditCard> {
  late final TextEditingController _controller;
  late bool _approve;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.edit.targetValue);
    _approve = widget.edit.approve;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      widget.edit.copyWith(
        targetValue: _controller.text.trim(),
        approve: _approve,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.edit.stringKey,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    softWrap: true,
                  ),
                ),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.edit.sourceValue,
              style: theme.textTheme.bodySmall,
              softWrap: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              minLines: 2,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                labelText: l10n.translationTargetLabel,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              onChanged: (_) => _emit(),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.translationApprove,
                softWrap: true,
              ),
              value: _approve,
              onChanged: (v) {
                setState(() => _approve = v);
                _emit();
              },
            ),
          ],
        ),
      ),
    );
  }
}
