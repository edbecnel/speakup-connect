import 'package:flutter/material.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_config.dart';
import 'package:uuid/uuid.dart';

/// Admin UI for optionally configuring recipient responses on a broadcast.
class ResponseConfigSection extends StatelessWidget {
  const ResponseConfigSection({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final ReminderResponseConfig value;
  final ValueChanged<ReminderResponseConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Request a response'),
          subtitle: Text(
            value.enabled
                ? 'Recipients can respond via ${value.typeLabel.toLowerCase()}'
                : 'Off — no response requested',
          ),
          value: value.enabled,
          onChanged: (on) {
            if (on) {
              onChanged(
                ReminderResponseConfig(
                  enabled: true,
                  type: value.type,
                  maxTextLength: value.maxTextLength,
                  options: value.options.isNotEmpty
                      ? value.options
                      : value.type == ReminderResponseType.freeText
                          ? const []
                          : value.type == ReminderResponseType.checkbox
                              ? _defaultCheckboxOptions()
                              : _defaultChoiceOptions(),
                ),
              );
            } else {
              onChanged(const ReminderResponseConfig());
            }
          },
        ),
        if (value.enabled) ...[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Response required'),
            subtitle: const Text(
              'Recipients must respond before they can dismiss the alert',
            ),
            value: value.responseRequired,
            onChanged: (on) =>
                onChanged(value.copyWith(responseRequired: on)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Allow changing responses'),
            subtitle: Text(
              value.allowResponseUpdates
                  ? 'Recipients can update their answer after submitting'
                  : 'Locked after submit — use for votes and one-time polls',
            ),
            value: value.allowResponseUpdates,
            onChanged: (on) =>
                onChanged(value.copyWith(allowResponseUpdates: on)),
          ),
          const SizedBox(height: 4),
          SegmentedButton<ReminderResponseType>(
            segments: const [
              ButtonSegment(
                value: ReminderResponseType.freeText,
                label: Text('Free text'),
                icon: Icon(Icons.notes_outlined, size: 18),
              ),
              ButtonSegment(
                value: ReminderResponseType.checkbox,
                label: Text('Checkboxes'),
                icon: Icon(Icons.check_box_outlined, size: 18),
              ),
              ButtonSegment(
                value: ReminderResponseType.multipleChoice,
                label: Text('Choices'),
                icon: Icon(Icons.radio_button_checked_outlined, size: 18),
              ),
            ],
            selected: {value.type},
            onSelectionChanged: (selection) {
              final type = selection.first;
              onChanged(
                value.copyWith(
                  type: type,
                  allowAdditionalText: type == ReminderResponseType.freeText
                      ? false
                      : value.allowAdditionalText,
                  options: type == ReminderResponseType.freeText
                      ? const []
                      : type == ReminderResponseType.checkbox
                          ? (value.options.isNotEmpty
                              ? value.options
                              : _defaultCheckboxOptions())
                          : (value.options.length >= 2
                              ? value.options
                              : _defaultChoiceOptions()),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          if (value.type == ReminderResponseType.freeText)
            _FreeTextLimitPicker(
              maxLength: value.maxTextLength,
              onChanged: (n) => onChanged(value.copyWith(maxTextLength: n)),
            )
          else ...[
            _OptionsEditor(
              key: ValueKey('${value.type}-${value.options.length}'),
              type: value.type,
              options: value.options,
              onChanged: (options) => onChanged(value.copyWith(options: options)),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Allow explanation text'),
              subtitle: const Text(
                'Optional text box for comments (e.g. why they cannot attend)',
              ),
              value: value.allowAdditionalText,
              onChanged: (on) =>
                  onChanged(value.copyWith(allowAdditionalText: on)),
            ),
            if (value.allowAdditionalText)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: _FreeTextLimitPicker(
                  maxLength: value.maxTextLength,
                  onChanged: (n) => onChanged(value.copyWith(maxTextLength: n)),
                ),
              ),
          ],
          if (!value.isValid)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                value.type == ReminderResponseType.freeText
                    ? 'Set a character limit between '
                        '${AppReminderResponseLimits.minMaxTextLength} and '
                        '${AppReminderResponseLimits.maxMaxTextLength}.'
                    : value.type == ReminderResponseType.checkbox
                        ? 'Add at least one checkbox option with a label.'
                        : 'Add at least 2 answer choices with labels.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ],
    );
  }

  List<ReminderResponseOption> _defaultCheckboxOptions() => [
        ReminderResponseOption(id: const Uuid().v4(), label: ''),
      ];

  List<ReminderResponseOption> _defaultChoiceOptions() => [
        ReminderResponseOption(id: const Uuid().v4(), label: ''),
        ReminderResponseOption(id: const Uuid().v4(), label: ''),
      ];
}

class _FreeTextLimitPicker extends StatelessWidget {
  const _FreeTextLimitPicker({
    required this.maxLength,
    required this.onChanged,
  });

  final int maxLength;
  final ValueChanged<int> onChanged;

  static const _limits = [50, 100, 200, 300, 500, 750, 1000];

  @override
  Widget build(BuildContext context) {
    final value = _limits.contains(maxLength) ? maxLength : 500;
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Character limit',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: value,
          items: _limits
              .map((n) => DropdownMenuItem(value: n, child: Text('$n characters')))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _OptionsEditor extends StatefulWidget {
  const _OptionsEditor({
    required this.type,
    required this.options,
    required this.onChanged,
    super.key,
  });

  final ReminderResponseType type;
  final List<ReminderResponseOption> options;
  final ValueChanged<List<ReminderResponseOption>> onChanged;

  @override
  State<_OptionsEditor> createState() => _OptionsEditorState();
}

class _OptionsEditorState extends State<_OptionsEditor> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.options
        .map((o) => TextEditingController(text: o.label))
        .toList();
  }

  @override
  void didUpdateWidget(covariant _OptionsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options.length != widget.options.length ||
        oldWidget.options.map((o) => o.id).join() !=
            widget.options.map((o) => o.id).join()) {
      for (final c in _controllers) {
        c.dispose();
      }
      _controllers = widget.options
          .map((o) => TextEditingController(text: o.label))
          .toList();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _emit() {
    final updated = <ReminderResponseOption>[];
    for (var i = 0; i < widget.options.length; i++) {
      updated.add(widget.options[i].copyWith(label: _controllers[i].text));
    }
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = widget.type == ReminderResponseType.checkbox
        ? 'Checkbox options'
        : 'Answer choices';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        ...widget.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final minOptions =
              widget.type == ReminderResponseType.checkbox ? 1 : 2;
          final canRemove = widget.options.length > minOptions;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Icon(
                    widget.type == ReminderResponseType.checkbox
                        ? Icons.check_box_outlined
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controllers[index],
                    decoration: InputDecoration(
                      labelText: 'Option ${index + 1}',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => _emit(),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: canRemove
                      ? IconButton(
                          tooltip: 'Remove option',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          onPressed: () {
                            widget.onChanged(
                              widget.options
                                  .where((o) => o.id != option.id)
                                  .toList(),
                            );
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                        )
                      : null,
                ),
              ],
            ),
          );
        }),
        if (widget.options.length < AppReminderResponseLimits.maxOptions)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                widget.onChanged([
                  ...widget.options,
                  ReminderResponseOption(id: const Uuid().v4(), label: ''),
                ]);
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add option'),
            ),
          ),
      ],
    );
  }
}
