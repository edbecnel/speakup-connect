import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_entity.dart';
import 'package:speakup_connect/features/reminders/presentation/providers/reminder_provider.dart';

/// My Broadcasts — lists the reminders the current user has sent and lets them
/// recall (delete) any of them. Recalling a *published* reminder also removes
/// the copies already delivered to recipients' feeds (handled server-side).
///
/// Gated on [AppPermission.broadcastReminders].
class MyBroadcastsScreen extends ConsumerWidget {
  const MyBroadcastsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canBroadcast =
        ref.watch(hasPermissionProvider(AppPermission.broadcastReminders));
    final mineAsync = ref.watch(myRemindersProvider);

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
        title: const Text('My Broadcasts'),
      ),
      body: !canBroadcast
          ? const _NoAccessPlaceholder()
          : mineAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load: $e')),
              data: (reminders) {
                if (reminders.isEmpty) return const _EmptyState();
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
    final busy = ref.watch(recallReminderProvider).isLoading;
    final isPublished = reminder.status == ReminderStatus.published;
    // "Recall" implies pulling back something already delivered; otherwise it
    // is just a delete of a draft/pending/rejected item.
    final actionLabel = isPublished ? 'Recall' : 'Delete';

    return Card(
      margin: EdgeInsets.zero,
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
            Row(
              children: [
                Icon(Icons.groups_outlined,
                    size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  reminder.audience.displayLabel,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                if (reminder.scheduledAt != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.schedule,
                      size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _formatDateTime(reminder.scheduledAt!),
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed:
                    busy ? null : () => _confirm(context, ref, isPublished),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: Text(actionLabel),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
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
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.campaign_outlined,
              size: 56, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            'You haven\'t sent any broadcasts yet',
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
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
