import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/notifications/domain/entities/app_notification_entity.dart';
import 'package:speakup_connect/features/notifications/presentation/providers/notification_history_provider.dart';
import 'package:speakup_connect/features/notifications/presentation/providers/notification_provider.dart';
import 'package:speakup_connect/features/notifications/presentation/screens/notification_detail_screen.dart';
import 'package:speakup_connect/features/reminders/presentation/screens/broadcast_detail_screen.dart';
import 'package:speakup_connect/features/reminders/presentation/providers/reminder_provider.dart';
import 'package:speakup_connect/features/reminders/presentation/widgets/edit_reminder_dialog.dart';

/// Alerts — the in-app notification feed. Lists reminders and other
/// notifications delivered to the current user, with read/unread state.
class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadNotificationCountProvider);
    final canBroadcast =
        ref.watch(hasPermissionProvider(AppPermission.broadcastReminders));
    final canApprove =
        ref.watch(hasPermissionProvider(AppPermission.approveReminders));
    final canViewHistory = ref.watch(canViewNotificationHistoryProvider);
    final count = notificationsAsync.asData?.value.length ?? 0;

    ref.listen(updateReminderProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading && context.mounted) {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Update failed: ${next.error}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else if (next.hasValue) {
          final n = next.asData?.value ?? 0;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                n > 0
                    ? 'Broadcast updated — $n alert(s) refreshed.'
                    : 'Broadcast updated.',
              ),
            ),
          );
        }
      }
    });

    ref.listen(recallReminderProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading && context.mounted) {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Delete failed: ${next.error}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else if (next.hasValue) {
          final removed = next.asData?.value ?? 0;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                removed > 0
                    ? 'Broadcast deleted — $removed alert(s) removed.'
                    : 'Broadcast deleted.',
              ),
            ),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.home),
        ),
        title: const Text('Alerts'),
        actions: [
          if (canViewHistory)
            IconButton(
              tooltip: 'Notification history',
              icon: const Icon(Icons.history),
              onPressed: () => context.push(Routes.notificationHistory),
            ),
          if (canBroadcast)
            IconButton(
              tooltip: 'My broadcasts',
              icon: const Icon(Icons.outbox_outlined),
              onPressed: () => context.push(Routes.myBroadcasts),
            ),
          if (canApprove)
            IconButton(
              tooltip: 'Reminder approvals',
              icon: const Icon(Icons.fact_check_outlined),
              onPressed: () => context.push(Routes.reminderApprovals),
            ),
          if (count > 0)
            PopupMenuButton<String>(
              tooltip: 'More',
              onSelected: (value) {
                final actions = ref.read(notificationActionsProvider.notifier);
                if (value == 'read') {
                  actions.markAllRead();
                } else if (value == 'clear') {
                  _confirmClearAll(context, ref);
                }
              },
              itemBuilder: (_) => [
                if (unread > 0)
                  const PopupMenuItem(
                    value: 'read',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.done_all),
                        SizedBox(width: 12),
                        Text('Mark all read'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_sweep_outlined),
                      SizedBox(width: 12),
                      Text('Clear all'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: canBroadcast
          ? FloatingActionButton.extended(
              onPressed: () => context.push(Routes.composeReminder),
              icon: const Icon(Icons.campaign_outlined),
              label: const Text('Reminder'),
            )
          : null,
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load alerts: $e')),
        data: (items) {
          if (items.isEmpty) return const _EmptyFeed();
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => _NotificationRow(notification: items[i]),
          );
        },
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all alerts?'),
        content: const Text(
          'This permanently removes all alerts from your feed. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(notificationActionsProvider.notifier).clearAll();
    }
  }
}

class _NotificationRow extends ConsumerWidget {
  const _NotificationRow({required this.notification});

  final AppNotificationEntity notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminderId = notification.type == 'reminder'
        ? reminderIdFromNotificationData(notification.data)
        : null;
    final canManageAsync = reminderId != null
        ? ref.watch(canManageBroadcastProvider(reminderId))
        : const AsyncData(false);
    final canManage = canManageAsync.asData?.value ?? false;
    final isSynthetic = notification.id.startsWith('broadcast-');
    final busy = ref.watch(recallReminderProvider).isLoading ||
        ref.watch(updateReminderProvider).isLoading;

    final tile = _NotificationTile(
      notification: notification,
      canManage: canManage,
      busy: busy,
      onTap: () => _openNotificationDetail(context, notification),
      onEdit: reminderId != null && canManage
          ? () => _editBroadcast(context, ref, reminderId)
          : null,
      onDelete: () => _deleteNotification(
        context,
        ref,
        reminderId: reminderId,
        canManage: canManage,
      ),
    );

    if (canManage && reminderId != null) {
      return Dismissible(
        key: ValueKey(notification.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          color: Theme.of(context).colorScheme.errorContainer,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Icon(
            Icons.delete_outline_rounded,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
        onDismissed: (_) => _recallBroadcast(ref, reminderId),
        child: tile,
      );
    }

    if (!isSynthetic) {
      return Dismissible(
        key: ValueKey(notification.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          color: Theme.of(context).colorScheme.errorContainer,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Icon(
            Icons.delete_outline_rounded,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
        onDismissed: (_) {
          ref.read(notificationActionsProvider.notifier).delete(notification.id);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Alert dismissed')),
            );
        },
        child: tile,
      );
    }

    return tile;
  }

  void _openNotificationDetail(
    BuildContext context,
    AppNotificationEntity notification,
  ) {
    final Widget screen;
    if (notification.type == 'reminder' &&
        reminderIdFromNotificationData(notification.data) != null) {
      screen = BroadcastDetailScreen(notification: notification);
    } else {
      screen = NotificationDetailScreen(notification: notification);
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  Future<void> _editBroadcast(
    BuildContext context,
    WidgetRef ref,
    String reminderId,
  ) async {
    final reminder = await ref.read(reminderByIdProvider(reminderId).future);
    if (reminder == null || !context.mounted) return;

    final edited = await EditReminderDialog.show(
      context,
      initialTitle: reminder.title,
      initialBody: reminder.body,
      initialExpiresAt: reminder.expiresAt,
    );
    if (edited == null || !context.mounted) return;

    await ref.read(updateReminderProvider.notifier).update(
          reminderId: reminderId,
          title: edited.title,
          body: edited.body,
          expiresAt: edited.expiresAt,
          clearExpiration: edited.clearExpiration,
        );
  }

  Future<void> _deleteNotification(
    BuildContext context,
    WidgetRef ref, {
    required String? reminderId,
    required bool canManage,
  }) async {
    if (reminderId != null && canManage) {
      await _confirmRecallBroadcast(context, ref, reminderId);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete alert?'),
        content: const Text(
          'This removes the alert from your feed only.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(notificationActionsProvider.notifier)
          .delete(notification.id);
    }
  }

  Future<void> _confirmRecallBroadcast(
    BuildContext context,
    WidgetRef ref,
    String reminderId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete broadcast?'),
        content: const Text(
          'This deletes the broadcast and removes it from every '
          'recipient\'s alerts feed. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _recallBroadcast(ref, reminderId);
    }
  }

  Future<void> _recallBroadcast(
    WidgetRef ref,
    String reminderId,
  ) async {
    await ref.read(recallReminderProvider.notifier).recall(reminderId);
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({
    required this.notification,
    required this.canManage,
    required this.busy,
    required this.onTap,
    required this.onDelete,
    this.onEdit,
  });

  final AppNotificationEntity notification;
  final bool canManage;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isUnread = !notification.read;
    final icon = switch (notification.type) {
      'reminder' => Icons.campaign_outlined,
      'status_update' => Icons.assignment_turned_in_outlined,
      _ => Icons.notifications_outlined,
    };

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: isUnread
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          icon,
          color: isUnread
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(
        notification.title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.body),
          const SizedBox(height: 4),
          Text(
            _relativeTime(notification.createdAt),
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
      isThreeLine: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isUnread)
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          if (canManage)
            PopupMenuButton<String>(
              enabled: !busy,
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit?.call();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (_) => [
                if (onEdit != null)
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 12),
                        Text('Edit'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline),
                      SizedBox(width: 12),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none_rounded,
              size: 56, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            'No alerts yet',
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            'Reminders and updates will appear here.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

String _relativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  String two(int n) => n.toString().padLeft(2, '0');
  return '${dt.year}-${two(dt.month)}-${two(dt.day)}';
}
