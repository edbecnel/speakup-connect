import 'package:flutter/material.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/l10n/app_localizations.dart';

/// How the user specifies when a broadcast should expire.
enum ExpirationMode { off, dateTime, duration }

/// User-facing expiration settings before persisting as [expiresAt].
class ExpirationPickerValue {
  const ExpirationPickerValue({
    this.mode = ExpirationMode.off,
    this.expiresAt,
    this.durationHours = 24,
    this.durationMinutes = 0,
  });

  final ExpirationMode mode;
  final DateTime? expiresAt;
  final int durationHours;
  final int durationMinutes;

  bool get isEnabled => mode != ExpirationMode.off;

  /// Base time for duration math: scheduled send time, or now if sending immediately.
  static DateTime expirationBase({DateTime? scheduledAt}) {
    final now = DateTime.now();
    if (scheduledAt != null && scheduledAt.isAfter(now)) return scheduledAt;
    return now;
  }

  DateTime? resolve({DateTime? scheduledAt}) {
    if (mode == ExpirationMode.off) return null;
    if (mode == ExpirationMode.dateTime) return expiresAt;
    if (durationHours == 0 && durationMinutes == 0) return null;
    return expirationBase(scheduledAt: scheduledAt).add(
      Duration(hours: durationHours, minutes: durationMinutes),
    );
  }

  bool isValid({DateTime? scheduledAt}) {
    final resolved = resolve(scheduledAt: scheduledAt);
    if (resolved == null) {
      return mode == ExpirationMode.off;
    }
    final now = DateTime.now();
    if (!resolved.isAfter(now)) return false;
    if (scheduledAt != null && !resolved.isAfter(scheduledAt)) return false;
    return true;
  }

  String summary(AppLocalizations l10n, {DateTime? scheduledAt}) {
    if (mode == ExpirationMode.off) {
      return l10n.reminderComposeExpirationOff;
    }
    final resolved = resolve(scheduledAt: scheduledAt);
    if (resolved == null) return l10n.reminderComposeSetExpirationBelow;
    if (mode == ExpirationMode.duration) {
      final baseLabel = scheduledAt != null &&
              scheduledAt.isAfter(DateTime.now())
          ? l10n.reminderComposeExpirationBaseScheduled
          : l10n.reminderComposeExpirationBaseSend;
      return l10n.reminderComposeExpirationDurationSummary(
        _formatDuration(l10n, durationHours, durationMinutes),
        baseLabel,
        formatDateTime(resolved),
      );
    }
    return l10n.reminderComposeExpirationAt(formatDateTime(resolved));
  }

  ExpirationPickerValue copyWith({
    ExpirationMode? mode,
    DateTime? expiresAt,
    int? durationHours,
    int? durationMinutes,
    bool clearExpiresAt = false,
  }) {
    return ExpirationPickerValue(
      mode: mode ?? this.mode,
      expiresAt: clearExpiresAt ? null : (expiresAt ?? this.expiresAt),
      durationHours: durationHours ?? this.durationHours,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }

  /// Builds an initial value from a stored absolute expiration time.
  factory ExpirationPickerValue.fromExpiresAt(DateTime? expiresAt) {
    if (expiresAt == null) return const ExpirationPickerValue();
    return ExpirationPickerValue(
      mode: ExpirationMode.dateTime,
      expiresAt: expiresAt,
    );
  }
}

/// Expiration controls: optional date/time pick or hours + minutes duration.
class ExpirationPickerSection extends StatelessWidget {
  const ExpirationPickerSection({
    required this.value,
    required this.onChanged,
    this.scheduledAt,
    super.key,
  });

  final ExpirationPickerValue value;
  final ValueChanged<ExpirationPickerValue> onChanged;
  final DateTime? scheduledAt;

  Future<void> _pickDateTime(BuildContext context) async {
    final base = ExpirationPickerValue.expirationBase(scheduledAt: scheduledAt);
    final min = base.add(const Duration(minutes: 5));
    final date = await showDatePicker(
      context: context,
      initialDate: value.expiresAt ?? min.add(const Duration(hours: 24)),
      firstDate: min,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        value.expiresAt ?? min.add(const Duration(hours: 24)),
      ),
    );
    if (time == null) return;
    final when =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    onChanged(
      value.copyWith(
        mode: ExpirationMode.dateTime,
        expiresAt: when,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final enabled = value.isEnabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.reminderComposeSetExpiration),
          subtitle: Text(value.summary(l10n, scheduledAt: scheduledAt)),
          value: enabled,
          onChanged: (on) {
            if (on) {
              onChanged(
                const ExpirationPickerValue(
                  mode: ExpirationMode.duration,
                  durationHours: 24,
                ),
              );
            } else {
              onChanged(const ExpirationPickerValue());
            }
          },
        ),
        if (enabled) ...[
          const SizedBox(height: 4),
          SegmentedButton<ExpirationMode>(
            segments: [
              ButtonSegment(
                value: ExpirationMode.dateTime,
                label: Text(l10n.reminderComposeExpirationDateTime),
                icon: const Icon(Icons.event_outlined, size: 18),
              ),
              ButtonSegment(
                value: ExpirationMode.duration,
                label: Text(l10n.reminderComposeExpirationDuration),
                icon: const Icon(Icons.timelapse_outlined, size: 18),
              ),
            ],
            selected: {value.mode},
            onSelectionChanged: (selection) {
              final mode = selection.first;
              if (mode == ExpirationMode.dateTime && value.expiresAt == null) {
                final base =
                    ExpirationPickerValue.expirationBase(scheduledAt: scheduledAt);
                onChanged(
                  value.copyWith(
                    mode: mode,
                    expiresAt: base.add(const Duration(hours: 24)),
                  ),
                );
              } else {
                onChanged(value.copyWith(mode: mode));
              }
            },
          ),
          const SizedBox(height: 12),
          if (value.mode == ExpirationMode.dateTime)
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => _pickDateTime(context),
                icon: const Icon(Icons.edit_calendar_outlined, size: 18),
                label: Text(
                  value.expiresAt != null
                      ? formatDateTime(value.expiresAt!)
                      : l10n.reminderComposePickDateTime,
                ),
              ),
            )
          else
            _DurationPickers(
              l10n: l10n,
              hours: value.durationHours,
              minutes: value.durationMinutes,
              onChanged: (hours, minutes) => onChanged(
                value.copyWith(
                  durationHours: hours,
                  durationMinutes: minutes,
                ),
              ),
            ),
          if (!value.isValid(scheduledAt: scheduledAt))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.reminderComposeExpirationAfterSend,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class _DurationPickers extends StatelessWidget {
  const _DurationPickers({
    required this.l10n,
    required this.hours,
    required this.minutes,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final int hours;
  final int minutes;
  final void Function(int hours, int minutes) onChanged;

  static final _hourOptions = List.generate(169, (i) => i);
  static final _minuteOptions = List.generate(60, (i) => i);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reminderComposeExpireAfter,
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.reminderComposeHours,
                  border: const OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: hours,
                    items: _hourOptions
                        .map(
                          (h) => DropdownMenuItem(
                            value: h,
                            child: Text('$h'),
                          ),
                        )
                        .toList(),
                    onChanged: (h) {
                      if (h != null) onChanged(h, minutes);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.reminderComposeMinutes,
                  border: const OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: minutes,
                    items: _minuteOptions
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(m.toString().padLeft(2, '0')),
                          ),
                        )
                        .toList(),
                    onChanged: (m) {
                      if (m != null) onChanged(hours, m);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String _formatDuration(AppLocalizations l10n, int hours, int minutes) {
  final parts = <String>[];
  if (hours > 0) parts.add(l10n.reminderComposeDurationHours(hours));
  if (minutes > 0) parts.add(l10n.reminderComposeDurationMinutes(minutes));
  return parts.isEmpty ? l10n.reminderComposeDurationZeroMin : parts.join(' ');
}

String formatDateTime(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final ampm = dt.hour < 12 ? 'AM' : 'PM';
  return '${dt.year}-${two(dt.month)}-${two(dt.day)} · $h:${two(dt.minute)} $ampm';
}
