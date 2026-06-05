import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/notifications/domain/entities/app_notification_entity.dart';
import 'package:speakup_connect/features/notifications/presentation/providers/notification_provider.dart';

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
    final count = notificationsAsync.asData?.value.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.home),
        ),
        title: const Text('Alerts'),
        actions: [
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
            itemBuilder: (_, i) {
              final n = items[i];
              return Dismissible(
                key: ValueKey(n.id),
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
                  ref.read(notificationActionsProvider.notifier).delete(n.id);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('Alert dismissed')),
                    );
                },
                child: _NotificationTile(notification: n),
              );
            },
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

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final AppNotificationEntity notification;

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
      onTap: () {
        if (isUnread) {
          ref
              .read(notificationActionsProvider.notifier)
              .markRead(notification.id);
        }
      },
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
      trailing: isUnread
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            )
          : null,
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
