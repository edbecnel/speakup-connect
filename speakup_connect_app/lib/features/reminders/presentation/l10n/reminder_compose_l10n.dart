import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_config.dart';
import 'package:speakup_connect/l10n/app_localizations.dart';

String localizedReminderResponseTypeLabel(
  AppLocalizations l10n,
  ReminderResponseType type,
) {
  return switch (type) {
    ReminderResponseType.freeText => l10n.reminderComposeResponseFreeText,
    ReminderResponseType.checkbox => l10n.reminderComposeResponseCheckboxes,
    ReminderResponseType.multipleChoice => l10n.reminderComposeResponseChoices,
  };
}

String localizedReminderResponseTypeSummary(
  AppLocalizations l10n,
  ReminderResponseConfig config,
) {
  final base = localizedReminderResponseTypeLabel(l10n, config.type);
  if (config.type == ReminderResponseType.freeText || !config.allowAdditionalText) {
    return base.toLowerCase();
  }
  return '${base.toLowerCase()} ${l10n.reminderComposeResponseTypeExplanationSuffix}';
}
