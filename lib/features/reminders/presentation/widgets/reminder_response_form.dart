import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/features/announcements/presentation/providers/bulletin_response_provider.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_config.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_entity.dart';
import 'package:speakup_connect/features/reminders/presentation/providers/reminder_response_provider.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';

/// Recipient form for submitting a response to a broadcast or announcement.
class ReminderResponseForm extends ConsumerStatefulWidget {
  const ReminderResponseForm({
    required this.organizationId,
    required this.config,
    this.reminderId,
    this.bulletinId,
    this.existing,
    super.key,
  }) : assert(reminderId != null || bulletinId != null);

  final String organizationId;
  final String? reminderId;
  final String? bulletinId;
  final ReminderResponseConfig config;
  final ReminderResponseEntity? existing;

  @override
  ConsumerState<ReminderResponseForm> createState() =>
      _ReminderResponseFormState();
}

class _ReminderResponseFormState extends ConsumerState<ReminderResponseForm> {
  final _textController = TextEditingController();
  final Set<String> _checkedIds = {};
  String? _selectedChoiceId;

  @override
  void initState() {
    super.initState();
    _loadExisting(widget.existing);
  }

  @override
  void didUpdateWidget(covariant ReminderResponseForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.existing?.submittedAt != widget.existing?.submittedAt) {
      _loadExisting(widget.existing);
    }
  }

  void _loadExisting(ReminderResponseEntity? existing) {
    if (existing == null) return;
    _textController.text = existing.text ?? '';
    _checkedIds
      ..clear()
      ..addAll(existing.selectedOptionIds);
    _selectedChoiceId = existing.selectedOptionId;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    return switch (widget.config.type) {
      ReminderResponseType.freeText => _textController.text.trim().isNotEmpty,
      // Unchecked boxes are a valid answer (e.g. "none of the above").
      ReminderResponseType.checkbox => true,
      ReminderResponseType.multipleChoice => _selectedChoiceId != null,
    };
  }

  String? get _submittedText {
    final trimmed = _textController.text.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  }

  Future<void> _submit() async {
    final includeText = widget.config.type == ReminderResponseType.freeText ||
        widget.config.allowAdditionalText;
    final text = includeText ? _submittedText : null;
    final selectedOptionIds =
        widget.config.type == ReminderResponseType.checkbox
            ? _checkedIds.toList()
            : null;
    final selectedOptionId =
        widget.config.type == ReminderResponseType.multipleChoice
            ? _selectedChoiceId
            : null;

    final bool ok;
    if (widget.bulletinId != null) {
      ok = await ref.read(submitBulletinResponseProvider.notifier).submit(
            organizationId: widget.organizationId,
            bulletinId: widget.bulletinId!,
            text: text,
            selectedOptionIds: selectedOptionIds,
            selectedOptionId: selectedOptionId,
          );
    } else {
      ok = await ref.read(submitReminderResponseProvider.notifier).submit(
            organizationId: widget.organizationId,
            reminderId: widget.reminderId!,
            text: text,
            selectedOptionIds: selectedOptionIds,
            selectedOptionId: selectedOptionId,
          );
    }

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Response submitted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final submitState = widget.bulletinId != null
        ? ref.watch(submitBulletinResponseProvider)
        : ref.watch(submitReminderResponseProvider);
    final hasExisting = widget.existing != null;
    final isLocked =
        hasExisting && !widget.config.allowResponseUpdates;

    if (isLocked && widget.existing != null) {
      return _LockedResponseView(
        config: widget.config,
        existing: widget.existing!,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your response',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        if (hasExisting)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'You already responded. Update your answer below if needed.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        switch (widget.config.type) {
          ReminderResponseType.freeText => TextField(
              controller: _textController,
              maxLines: 4,
              maxLength: widget.config.maxTextLength,
              decoration: InputDecoration(
                hintText: 'Type your response…',
                border: const OutlineInputBorder(),
                counterText:
                    'Max ${widget.config.maxTextLength} characters',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ReminderResponseType.checkbox => Column(
              children: widget.config.validOptions.map((option) {
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(option.label),
                  value: _checkedIds.contains(option.id),
                  onChanged: (on) {
                    setState(() {
                      if (on == true) {
                        _checkedIds.add(option.id);
                      } else {
                        _checkedIds.remove(option.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ReminderResponseType.multipleChoice => Column(
              children: widget.config.validOptions.map((option) {
                return RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(option.label),
                  value: option.id,
                  groupValue: _selectedChoiceId,
                  onChanged: (id) => setState(() => _selectedChoiceId = id),
                );
              }).toList(),
            ),
        },
        if (widget.config.allowAdditionalText &&
            widget.config.type != ReminderResponseType.freeText) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            maxLines: 3,
            maxLength: widget.config.maxTextLength,
            decoration: InputDecoration(
              labelText: 'Additional comments (optional)',
              hintText: 'Add an explanation if needed…',
              border: const OutlineInputBorder(),
              counterText: 'Max ${widget.config.maxTextLength} characters',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
        const SizedBox(height: 12),
        AppButton.primary(
          label: hasExisting ? 'Update response' : 'Submit response',
          isLoading: submitState.isLoading,
          onPressed: _canSubmit && !submitState.isLoading ? _submit : null,
        ),
        if (submitState.hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Failed: ${submitState.error}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

class _LockedResponseView extends StatelessWidget {
  const _LockedResponseView({
    required this.config,
    required this.existing,
  });

  final ReminderResponseConfig config;
  final ReminderResponseEntity existing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final answer = existing.displayValue(config);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your response',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        answer.isNotEmpty ? answer : 'Submitted',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your answer is locked and cannot be changed.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
