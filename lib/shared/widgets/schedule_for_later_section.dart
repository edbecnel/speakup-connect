import 'package:flutter/material.dart';
import 'package:speakup_connect/features/reminders/presentation/widgets/expiration_picker_section.dart';

/// Toggle and date/time picker for scheduling a broadcast for later.
class ScheduleForLaterSection extends StatelessWidget {
  const ScheduleForLaterSection({
    required this.scheduledAt,
    required this.onChanged,
    super.key,
  });

  final DateTime? scheduledAt;
  final ValueChanged<DateTime?> onChanged;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: scheduledAt ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        scheduledAt ?? now.add(const Duration(hours: 1)),
      ),
    );
    if (time == null) return;
    final when =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    onChanged(when);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheduled = scheduledAt != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Schedule for later'),
          subtitle: Text(
            scheduled
                ? formatDateTime(scheduledAt!)
                : 'Off — send immediately',
          ),
          value: scheduled,
          onChanged: (on) {
            if (on) {
              _pick(context);
            } else {
              onChanged(null);
            }
          },
        ),
        if (scheduled)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _pick(context),
              icon: const Icon(Icons.edit_calendar_outlined, size: 18),
              label: Text(
                'Change time',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ),
      ],
    );
  }
}
