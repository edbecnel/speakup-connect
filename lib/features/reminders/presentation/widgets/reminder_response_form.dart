import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_config.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_entity.dart';
import 'package:speakup_connect/features/reminders/presentation/providers/reminder_response_provider.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';

/// Recipient form for submitting a response to a broadcast reminder.
class ReminderResponseForm extends ConsumerStatefulWidget {
  const ReminderResponseForm({
    required this.organizationId,
    required this.reminderId,
    required this.config,
    this.existing,
    super.key,
  });

  final String organizationId;
  final String reminderId;
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
      ReminderResponseType.checkbox => _checkedIds.isNotEmpty,
      ReminderResponseType.multipleChoice => _selectedChoiceId != null,
    };
  }

  Future<void> _submit() async {
    final notifier = ref.read(submitReminderResponseProvider.notifier);
    final ok = await notifier.submit(
      organizationId: widget.organizationId,
      reminderId: widget.reminderId,
      text: widget.config.type == ReminderResponseType.freeText
          ? _textController.text.trim()
          : null,
      selectedOptionIds: widget.config.type == ReminderResponseType.checkbox
          ? _checkedIds.toList()
          : null,
      selectedOptionId: widget.config.type == ReminderResponseType.multipleChoice
          ? _selectedChoiceId
          : null,
    );
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Response submitted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final submitState = ref.watch(submitReminderResponseProvider);
    final hasExisting = widget.existing != null;

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
