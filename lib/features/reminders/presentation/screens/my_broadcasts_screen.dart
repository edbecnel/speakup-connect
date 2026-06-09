import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_entity.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/reminders/presentation/providers/reminder_provider.dart';
import 'package:speakup_connect/features/notifications/presentation/providers/notification_history_provider.dart';
import 'package:speakup_connect/features/reminders/presentation/screens/broadcast_detail_screen.dart';
import 'package:speakup_connect/features/reminders/presentation/screens/reminder_responses_screen.dart';
import 'package:speakup_connect/features/reminders/presentation/widgets/edit_reminder_dialog.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';

/// My Broadcasts — lists the reminders the current user has sent and lets them
/// recall (delete) any of them. Recalling a *published* reminder also removes
/// the copies already delivered to recipients' feeds (handled server-side).
///
/// Gated on [canComposeRemindersProvider] (org broadcasters and group leaders).
class MyBroadcastsScreen extends ConsumerWidget {
  const MyBroadcastsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canAccess = ref.watch(canComposeRemindersProvider);
    final leaderOnly = ref.watch(isGroupLeaderOnlyComposerProvider);
    final canViewHistory = ref.watch(canViewNotificationHistoryProvider);
    final mineAsync = ref.watch(myRemindersProvider);

    ref.listen(updateReminderProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        if (next.hasError) {
          messenger.showSnackBar(SnackBar(
            content: Text('Update failed: ${next.error}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ));
        } else {
          final updated = next.asData?.value ?? 0;
          messenger.showSnackBar(SnackBar(
            content: Text(
              updated > 0
                  ? 'Broadcast updated — $updated alert(s) refreshed.'
                  : 'Broadcast updated.',
            ),
            backgroundColor: Colors.green.shade700,
          ));
        }
      }
    });

    ref.listen(recallReminderProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        if (next.hasError) {
          messenger.showSnackBar(SnackBar(
            content: Text('Recall failed: ${next.error}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ));
        } else {
          final removed = next.asData?.value ?? 0;
          messenger.showSnackBar(SnackBar(
            content: Text(
              removed > 0
                  ? 'Reminder recalled — $removed delivered alert(s) removed.'
                  : 'Reminder deleted.',
            ),
            backgroundColor: Colors.green.shade700,
          ));
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.alerts),
        ),
        title: Text(leaderOnly ? 'Sent Group Alerts' : 'My Broadcasts'),
        actions: [
          if (canViewHistory)
            IconButton(
              tooltip: 'Notification history',
              icon: const Icon(Icons.history),
              onPressed: () => context.push(Routes.notificationHistory),
            ),
        ],
      ),
      body: !canAccess
          ? const _NoAccessPlaceholder()
          : mineAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load: $e')),
              data: (reminders) {
                if (reminders.isEmpty) {
                  return _EmptyState(leaderOnly: leaderOnly);
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: reminders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) =>
                      _BroadcastCard(reminder: reminders[i]),
                );
              },
            ),
    );
  }
}

class _BroadcastCard extends ConsumerWidget {
  const _BroadcastCard({required this.reminder});

  final ReminderEntity reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final busy = ref.watch(recallReminderProvider).isLoading ||
        ref.watch(updateReminderProvider).isLoading;
    final user = ref.watch(currentUserProvider);
    final profile = ref.watch(userProfileProvider).value;
    final canManage =
        reminder.createdBy == user?.uid || (profile?.isAdmin ?? false);
    final isPublished = reminder.status == ReminderStatus.published;
    final actionLabel = isPublished ? 'Delete' : 'Delete';

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BroadcastDetailScreen(reminder: reminder),
            ),
          );
        },
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    reminder.title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                _StatusChip(status: reminder.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(reminder.body, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _MetaItem(
                  icon: Icons.groups_outlined,
                  label: reminder.audience.displayLabel,
                ),
                if (reminder.scheduledAt != null)
                  _MetaItem(
                    icon: Icons.schedule,
                    label: _formatDateTime(reminder.scheduledAt!),
                  ),
                if (reminder.expiresAt != null)
                  _MetaItem(
                    icon: Icons.timer_outlined,
                    label: 'Expires ${_formatDateTime(reminder.expiresAt!)}',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (reminder.acceptsResponses)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ReminderResponsesScreen(
                          reminderId: reminder.reminderId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.poll_outlined, size: 18),
                  label: const Text('View responses'),
                ),
              ),
            if (canManage)
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: busy ? null : () => _edit(context, ref),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    onPressed:
                        busy ? null : () => _confirm(context, ref, isPublished),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: Text(actionLabel),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
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

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final edited = await EditReminderDialog.show(
      context,
      initialTitle: reminder.title,
      initialBody: reminder.body,
      initialExpiresAt: reminder.expiresAt,
    );
    if (edited == null || !context.mounted) return;

    await ref.read(updateReminderProvider.notifier).update(
          reminderId: reminder.reminderId,
          title: edited.title,
          body: edited.body,
          expiresAt: edited.expiresAt,
          clearExpiration: edited.clearExpiration,
        );
  }

  Future<void> _confirm(
    BuildContext context,
    WidgetRef ref,
    bool isPublished,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isPublished ? 'Recall this broadcast?' : 'Delete broadcast?'),
        content: Text(
          isPublished
              ? 'This deletes the reminder and removes it from every '
                  'recipient\'s alerts feed. This cannot be undone.'
              : 'This permanently deletes the reminder. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isPublished ? 'Recall' : 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(recallReminderProvider.notifier)
          .recall(reminder.reminderId);
    }
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final maxWidth = MediaQuery.sizeOf(context).width - 64;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              style: style,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ReminderStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color bg, Color fg) = switch (status) {
      ReminderStatus.published => (scheme.primaryContainer, scheme.onPrimaryContainer),
      ReminderStatus.pending => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      ReminderStatus.rejected => (scheme.errorContainer, scheme.onErrorContainer),
      ReminderStatus.draft => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.leaderOnly});

  final bool leaderOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.campaign_outlined,
                size: 56, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              leaderOnly
                  ? 'No group alerts sent yet'
                  : 'You haven\'t sent any broadcasts yet',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (leaderOnly) ...[
              const SizedBox(height: 8),
              Text(
                'Send an alert from My Groups & Clubs, then return here '
                'to view member responses.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NoAccessPlaceholder extends StatelessWidget {
  const _NoAccessPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline,
                size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'You don\'t have permission to broadcast reminders.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final ampm = dt.hour < 12 ? 'AM' : 'PM';
  return '${dt.year}-${two(dt.month)}-${two(dt.day)} · $h:${two(dt.minute)} $ampm';
}
