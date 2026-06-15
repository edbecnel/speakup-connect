import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/notifications/domain/entities/app_notification_entity.dart';
import 'package:speakup_connect/features/notifications/domain/entities/notification_attention.dart';
import 'package:speakup_connect/features/notifications/presentation/providers/notification_provider.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_entity.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_entity.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/features/reminders/presentation/providers/reminder_provider.dart';
import 'package:speakup_connect/features/reminders/presentation/providers/reminder_response_provider.dart';
import 'package:speakup_connect/features/reminders/presentation/screens/reminder_responses_screen.dart';
import 'package:speakup_connect/features/reminders/presentation/widgets/reminder_response_form.dart';
import 'package:speakup_connect/features/reminders/presentation/widgets/expiration_picker_section.dart'
    show formatDateTime;
import 'package:speakup_connect/l10n/app_localizations.dart';

/// Full-screen view of a broadcast reminder.
///
/// Opened from the Alerts feed or My Broadcasts. Loads the source reminder
/// document so expiration is always shown, even when the feed copy lacks it.
class BroadcastDetailScreen extends ConsumerStatefulWidget {
  const BroadcastDetailScreen({
    this.notification,
    this.reminder,
    super.key,
  }) : assert(notification != null || reminder != null);

  final AppNotificationEntity? notification;
  final ReminderEntity? reminder;

  @override
  ConsumerState<BroadcastDetailScreen> createState() =>
      _BroadcastDetailScreenState();
}

class _BroadcastDetailScreenState extends ConsumerState<BroadcastDetailScreen> {
  @override
  void initState() {
    super.initState();
    final n = widget.notification;
    if (n != null && !n.id.startsWith('broadcast-')) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeMarkRead(n));
    }
  }

  Future<void> _maybeMarkRead(AppNotificationEntity notification) async {
    final reminderId = _reminderId;
    if (reminderId == null) return;

    final reminder = await ref.read(reminderByIdProvider(reminderId).future);
    ReminderResponseEntity? myResponse;
    try {
      myResponse =
          await ref.read(myReminderResponseProvider(reminderId).future);
    } catch (_) {
      myResponse = null;
    }
    final attention = NotificationAttention.resolve(
      notification: notification,
      reminder: reminder,
      myResponse: myResponse,
    );

    // Mandatory-response alerts stay highlighted until answered.
    if (attention.responsePending) return;

    if (!mounted || notification.read) return;
    await ref
        .read(notificationActionsProvider.notifier)
        .markRead(notification.id);
  }

  String? get _reminderId =>
      widget.reminder?.reminderId ??
      reminderIdFromNotificationData(
        widget.notification?.data ?? const {},
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reminderId = _reminderId;
    if (reminderId == null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => Navigator.of(context).pop()),
          title: Text(l10n.reminderDetailTitle),
        ),
        body: Center(child: Text(l10n.reminderDetailNotFound)),
      );
    }

    if (widget.reminder != null) {
      return _buildScaffold(context, widget.reminder!, widget.notification);
    }

    final reminderAsync = ref.watch(reminderByIdProvider(reminderId));
    return reminderAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => Navigator.of(context).pop()),
          title: Text(l10n.reminderDetailTitle),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => Navigator.of(context).pop()),
          title: Text(l10n.reminderDetailTitle),
        ),
        body: Center(child: Text(l10n.reminderDetailLoadFailed('$e'))),
      ),
      data: (reminder) {
        if (reminder == null) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => Navigator.of(context).pop()),
              title: Text(l10n.reminderDetailTitle),
            ),
            body: Center(child: Text(l10n.reminderDetailNotFound)),
          );
        }
        return _buildScaffold(context, reminder, widget.notification);
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    ReminderEntity reminder,
    AppNotificationEntity? notification,
  ) {
    final l10n = context.l10n;
    final canRespond = reminder.isPublished &&
        !reminder.isExpired &&
        reminder.acceptsResponses;
    final myResponseAsync = canRespond
        ? ref.watch(myReminderResponseProvider(reminder.reminderId))
        : null;
    final canViewResponsesAsync = ref.watch(
      canViewReminderResponsesProvider(reminder.reminderId),
    );
    final canViewResponses = canViewResponsesAsync.asData?.value ?? false;

    final theme = Theme.of(context);
    final receivedAt = notification?.createdAt ??
        reminder.publishedAt ??
        reminder.createdAt;
    final expiresAt =
        reminder.expiresAt ?? notification?.expiresAt;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        title: Text(l10n.reminderDetailTitle),
        actions: [
          if (canViewResponses)
            IconButton(
              tooltip: l10n.announcementsViewResponses,
              icon: const Icon(Icons.poll_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ReminderResponsesScreen(
                      reminderId: reminder.reminderId,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.campaign_outlined,
                      size: 28,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatReceivedAt(l10n, receivedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailRow(
                label: l10n.reminderComposeAudienceLabel,
                value: reminder.audience.displayLabel,
                icon: Icons.groups_outlined,
              ),
              if (reminder.scheduledAt != null) ...[
                const SizedBox(height: 12),
                _DetailRow(
                  label: l10n.reminderDetailScheduledLabel,
                  value: formatDateTime(reminder.scheduledAt!),
                  icon: Icons.schedule,
                ),
              ],
              const SizedBox(height: 12),
              _DetailRow(
                label: l10n.reminderDetailExpiresLabel,
                value: expiresAt != null
                    ? formatDateTime(expiresAt)
                    : l10n.reminderDetailDoesNotExpire,
                icon: Icons.timer_outlined,
              ),
              const SizedBox(height: 28),
              Text(
                l10n.commonMessage,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reminder.body,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
              if (reminder.responseRequired &&
                  (myResponseAsync?.asData?.value == null) &&
                  myResponseAsync?.isLoading != true) ...[
                const SizedBox(height: 16),
                Material(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.reminderDetailResponseRequiredBanner,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (canRespond && reminder.responseConfig != null) ...[
                const SizedBox(height: 28),
                myResponseAsync == null
                    ? const SizedBox.shrink()
                    : myResponseAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) =>
                            Text(l10n.announcementsFailedToLoadResponse('$e')),
                        data: (existing) => ReminderResponseForm(
                          organizationId: AppConfig.defaultOrganizationId,
                          reminderId: reminder.reminderId,
                          config: reminder.responseConfig!,
                          existing: existing,
                        ),
                      ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatReceivedAt(AppLocalizations l10n, DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return l10n.reminderDetailJustNow;
  if (diff.inHours < 1) return l10n.reminderDetailMinutesAgo(diff.inMinutes);
  if (diff.inDays < 1) return l10n.reminderDetailHoursAgo(diff.inHours);
  if (diff.inDays < 7) return l10n.reminderDetailDaysAgo(diff.inDays);
  return formatDateTime(dt);
}
