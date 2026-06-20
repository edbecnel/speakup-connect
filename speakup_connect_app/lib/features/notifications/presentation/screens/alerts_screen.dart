import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/announcements/presentation/providers/announcement_provider.dart';
import 'package:speakup_connect/features/announcements/presentation/screens/announcement_detail_screen.dart';
import 'package:speakup_connect/features/announcements/presentation/widgets/edit_announcement_dialog.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/features/notifications/domain/entities/app_notification_entity.dart';
import 'package:speakup_connect/features/notifications/presentation/providers/alerts_selection_provider.dart';
import 'package:speakup_connect/features/notifications/presentation/providers/notification_history_provider.dart';
import 'package:speakup_connect/features/notifications/presentation/providers/notification_provider.dart';
import 'package:speakup_connect/features/notifications/presentation/screens/notification_detail_screen.dart';
import 'package:speakup_connect/features/reminders/presentation/providers/reminder_provider.dart';
import 'package:speakup_connect/features/reminders/presentation/screens/broadcast_detail_screen.dart';
import 'package:speakup_connect/features/reminders/presentation/widgets/edit_reminder_dialog.dart';
import 'package:speakup_connect/shared/widgets/notification_badge_icon.dart';

/// Alerts — the in-app notification feed. Lists reminders and other
/// notifications delivered to the current user, with read/unread state.
class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final notificationsAsync = ref.watch(notificationsProvider);
    final unread = ref.watch(unreadNotificationCountProvider);
    final canBroadcast = ref.watch(canComposeRemindersProvider);
    final canPostAnnouncements = ref.watch(canPostAnnouncementsProvider);
    final canViewOutbox = canBroadcast || canPostAnnouncements;
    final leaderOnly = ref.watch(isGroupLeaderOnlyComposerProvider);
    final canApprove = ref.watch(canReviewPendingRemindersProvider);
    final pendingApprovalCount = ref.watch(pendingReminderCountProvider);
    final canViewHistory = ref.watch(canViewNotificationHistoryProvider);
    final count = notificationsAsync.asData?.value.length ?? 0;
    final selection = ref.watch(alertsSelectionProvider);
    final isSelecting = selection.isSelecting;
    final selectedCount = selection.selectedIds.length;
    final actionsLoading = ref.watch(notificationActionsProvider).isLoading;

    ref.listen(updateReminderProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading && context.mounted) {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.commonUpdateFailed('${next.error}')),
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
              content: Text(l10n.commonDeleteFailed('${next.error}')),
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

    ref.listen(deleteAnnouncementProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        if (next.hasError) {
          messenger.showSnackBar(SnackBar(
            content: Text(l10n.commonDeleteFailed('${next.error}')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ));
        } else {
          final removed = next.asData?.value ?? 0;
          messenger.showSnackBar(SnackBar(
            content: Text(
              removed > 0
                  ? 'Announcement deleted — $removed alert(s) removed.'
                  : 'Announcement deleted.',
            ),
            backgroundColor: Colors.green.shade700,
          ));
        }
      }
    });

    ref.listen(updateAnnouncementProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        if (next.hasError) {
          messenger.showSnackBar(SnackBar(
            content: Text(l10n.commonUpdateFailed('${next.error}')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ));
        } else {
          final updated = next.asData?.value ?? 0;
          messenger.showSnackBar(SnackBar(
            content: Text(
              updated > 0
                  ? 'Announcement updated — $updated alert(s) refreshed.'
                  : 'Announcement updated.',
            ),
            backgroundColor: Colors.green.shade700,
          ));
        }
      }
    });

    return PopScope(
      canPop: !isSelecting,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (!isSelecting) return;
        ref.read(alertsSelectionProvider.notifier).exitSelection();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: isSelecting
              ? IconButton(
                  tooltip: l10n.commonCancel,
                  icon: const Icon(Icons.close),
                  onPressed: () =>
                      ref.read(alertsSelectionProvider.notifier).exitSelection(),
                )
              : BackButton(
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go(Routes.home),
                ),
          title: Text(
            isSelecting ? l10n.alertsSelectedCount(selectedCount) : l10n.alertsTitle,
          ),
          actions: [
            if (isSelecting) ...[
              IconButton(
                tooltip: l10n.alertsClearSelected,
                onPressed: selectedCount == 0 || actionsLoading
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        messenger.hideCurrentSnackBar();
                        try {
                          final result = await ref
                              .read(notificationActionsProvider.notifier)
                              .clearSelected(selection.selectedIds);
                          ref
                              .read(alertsSelectionProvider.notifier)
                              .exitSelection();
                          final message = result.skipped > 0
                              ? l10n.alertsClearedSelectedSnackbarWithSkipped(
                                  result.cleared,
                                  result.skipped,
                                )
                              : l10n.alertsClearedSelectedSnackbar(result.cleared);
                          messenger.showSnackBar(SnackBar(content: Text(message)));
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
                icon: const Icon(Icons.delete_sweep_outlined),
              ),
            ] else ...[
              if (canViewHistory)
                IconButton(
                  tooltip: l10n.notificationHistoryTitle,
                  icon: const Icon(Icons.history),
                  onPressed: () => context.push(Routes.notificationHistory),
                ),
              if (canViewOutbox)
                IconButton(
                  tooltip: l10n.settingsMyBroadcasts,
                  icon: const Icon(Icons.outbox_outlined),
                  onPressed: () => context.push(Routes.myBroadcasts),
                ),
              if (canApprove)
                IconButton(
                  tooltip: l10n.alertsReminderApprovalsTooltip,
                  onPressed: () => context.push(Routes.reminderApprovals),
                  icon: NotificationBadgeIcon(
                    icon: Icons.fact_check_outlined,
                    unreadCount: pendingApprovalCount,
                  ),
                ),
              if (count > 0)
                PopupMenuButton<String>(
                  tooltip: l10n.alertsMoreTooltip,
                  onSelected: (value) {
                    final actions =
                        ref.read(notificationActionsProvider.notifier);
                    if (value == 'read') {
                      actions.markAllRead();
                    } else if (value == 'clear') {
                      _confirmClearAll(context, ref);
                    } else if (value == 'select') {
                      ref.read(alertsSelectionProvider.notifier).enterSelection();
                    }
                  },
                  itemBuilder: (_) => [
                    if (unread > 0)
                      PopupMenuItem(
                        value: 'read',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.done_all),
                            const SizedBox(width: 12),
                            Text(l10n.alertsMarkAllRead),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'select',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.checklist_outlined),
                          const SizedBox(width: 12),
                          Text(l10n.alertsSelectAlerts),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'clear',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.delete_sweep_outlined),
                          const SizedBox(width: 12),
                          Text(l10n.commonClearAll),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
        floatingActionButton: isSelecting
            ? null
            : canBroadcast
                ? FloatingActionButton.extended(
                    onPressed: () => context.push(Routes.composeReminder),
                    icon: const Icon(Icons.campaign_outlined),
                    label: Text(leaderOnly ? 'Group Alert' : 'Reminder'),
                  )
                : null,
        body: notificationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(l10n.alertsFailedToLoad('$e'))),
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
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.alertsClearAllTitle),
        content: const Text(
          'This permanently removes all alerts from your feed. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonClearAll),
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
    final l10n = context.l10n;
    final selection = ref.watch(alertsSelectionProvider);
    final isSelecting = selection.isSelecting;
    final reminderId = notification.type == 'reminder'
        ? reminderIdFromNotificationData(notification.data)
        : null;
    final bulletinId = notification.type == 'bulletin'
        ? bulletinIdFromNotificationData(notification.data)
        : null;
    final canManageReminderAsync = reminderId != null
        ? ref.watch(canManageBroadcastProvider(reminderId))
        : const AsyncData(false);
    final canManageBulletinAsync = bulletinId != null
        ? ref.watch(canManageAnnouncementProvider(bulletinId))
        : const AsyncData(false);
    final canManage = (canManageReminderAsync.asData?.value ?? false) ||
        (canManageBulletinAsync.asData?.value ?? false);
    final isSynthetic = notification.id.startsWith('broadcast-');
    final busy = ref.watch(recallReminderProvider).isLoading ||
        ref.watch(updateReminderProvider).isLoading ||
        ref.watch(deleteAnnouncementProvider).isLoading ||
        ref.watch(updateAnnouncementProvider).isLoading;
    final attention = ref.watch(notificationAttentionProvider(notification));
    final isSelectable = !isSynthetic && attention.canDismiss;
    final isSelected = selection.selectedIds.contains(notification.id);

    void manageDelete() => _deleteNotification(
          context,
          ref,
          reminderId: reminderId,
          bulletinId: bulletinId,
          canManage: canManage,
          canDismiss: attention.canDismiss,
        );

    final tile = _NotificationTile(
      notification: notification,
      canManage: canManage,
      busy: busy,
      needsAttention: attention.needsAttention,
      responsePending: attention.responsePending,
      isSelecting: isSelecting,
      isSelected: isSelected,
      isSelectable: isSelectable,
      onToggleSelected: isSelecting && isSelectable
          ? () => ref
              .read(alertsSelectionProvider.notifier)
              .toggle(notification.id)
          : null,
      onTap: () {
        if (!isSelecting) {
          _openNotificationDetail(context, ref, notification);
          return;
        }
        if (isSelectable) {
          ref.read(alertsSelectionProvider.notifier).toggle(notification.id);
          return;
        }
        if (!attention.canDismiss) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.alertsSubmitBeforeDismiss)),
          );
        }
      },
      onEdit: reminderId != null && canManage
          ? () => _editBroadcast(context, ref, reminderId)
          : bulletinId != null && canManage
              ? () => _editAnnouncement(context, ref, bulletinId)
              : null,
      onDelete: manageDelete,
    );

    if (isSelecting) {
      return tile;
    }

    Future<void> clearFromMyFeed() async {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      if (isSynthetic) return;
      if (!attention.canDismiss) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.alertsSubmitBeforeDismiss)),
        );
        return;
      }
      try {
        final ok = await ref
            .read(notificationActionsProvider.notifier)
            .delete(notification.id);
        if (ok) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.alertsAlertDismissed)),
          );
        }
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    if (canManage && (reminderId != null || bulletinId != null)) {
      final theme = Theme.of(context);
      final endLabel = l10n.commonDelete;
      return Slidable(
        key: ValueKey(notification.id),
        startActionPane: isSynthetic
            ? null
            : ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => clearFromMyFeed(),
                    backgroundColor: theme.colorScheme.errorContainer,
                    foregroundColor: theme.colorScheme.onErrorContainer,
                    icon: Icons.delete_outline_rounded,
                    label: l10n.alertsSwipeClear,
                  ),
                ],
              ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => manageDelete(),
              backgroundColor: theme.colorScheme.errorContainer,
              foregroundColor: theme.colorScheme.onErrorContainer,
              icon: Icons.delete_outline_rounded,
              label: endLabel,
            ),
          ],
        ),
        child: tile,
      );
    }

    if (!isSynthetic) {
      final theme = Theme.of(context);
      return Slidable(
        key: ValueKey(notification.id),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) async {
                await clearFromMyFeed();
              },
              backgroundColor: theme.colorScheme.errorContainer,
              foregroundColor: theme.colorScheme.onErrorContainer,
              icon: Icons.delete_outline_rounded,
              label: l10n.alertsSwipeClear,
            ),
          ],
        ),
        child: tile,
      );
    }

    return tile;
  }

  void _openNotificationDetail(
    BuildContext context,
    WidgetRef ref,
    AppNotificationEntity notification,
  ) {
    if (notification.opensGroupMembershipRequests) {
      final groupId = notification.data['groupId'] as String?;
      if (groupId != null && groupId.isNotEmpty) {
        if (!notification.read && !notification.id.startsWith('broadcast-')) {
          ref.read(notificationActionsProvider.notifier).markRead(notification.id);
        }
        context.push(Routes.groupMembershipRequestsPath(groupId));
        return;
      }
    }

    final bulletinId = notification.type == 'bulletin'
        ? bulletinIdFromNotificationData(notification.data)
        : null;
    if (bulletinId != null && bulletinId.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AnnouncementDetailScreen(
            bulletinId: bulletinId,
            notification: notification,
          ),
        ),
      );
      return;
    }

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

  Future<void> _editAnnouncement(
    BuildContext context,
    WidgetRef ref,
    String bulletinId,
  ) async {
    final bulletin = await ref.read(bulletinByIdProvider(bulletinId).future);
    if (bulletin == null || !context.mounted) return;

    final edited = await EditAnnouncementDialog.show(
      context,
      bulletin: bulletin,
    );
    if (edited == null || !context.mounted) return;

    final ok = await ref.read(updateAnnouncementProvider.notifier).update(
          bulletinId: bulletinId,
          title: edited.title,
          body: edited.body,
          expiresAt: edited.expiresAt,
          clearExpiration: edited.clearExpiration,
          responseConfig: edited.responseConfig,
          newImageLocalPath: edited.newImageLocalPath,
          clearImage: edited.clearImage,
          clearResponseConfig: edited.clearResponseConfig,
        );
    if (ok && context.mounted) {
      ref.invalidate(bulletinByIdProvider(bulletinId));
    }
  }

  Future<void> _deleteNotification(
    BuildContext context,
    WidgetRef ref, {
    required String? reminderId,
    required String? bulletinId,
    required bool canManage,
    required bool canDismiss,
  }) async {
    if (reminderId != null && canManage) {
      await _confirmRecallBroadcast(context, ref, reminderId);
      return;
    }

    if (bulletinId != null && canManage) {
      await _confirmDeleteAnnouncement(context, ref, bulletinId);
      return;
    }

    if (!canDismiss) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.alertsSubmitBeforeDismiss),
        ),
      );
      return;
    }

    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.alertsDeleteAlertTitle),
        content: const Text(
          'This removes the alert from your feed only.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ref
            .read(notificationActionsProvider.notifier)
            .delete(notification.id);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  Future<void> _confirmRecallBroadcast(
    BuildContext context,
    WidgetRef ref,
    String reminderId,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.alertsDeleteBroadcastTitle),
        content: const Text(
          'This deletes the broadcast and removes it from every '
          'recipient\'s alerts feed. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonDelete),
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

  Future<void> _confirmDeleteAnnouncement(
    BuildContext context,
    WidgetRef ref,
    String bulletinId,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.alertsDeleteAnnouncementTitle),
        content: const Text(
          'This deletes the announcement and removes it from every '
          'member\'s alerts feed. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _deleteAnnouncement(ref, bulletinId);
    }
  }

  Future<void> _deleteAnnouncement(
    WidgetRef ref,
    String bulletinId,
  ) async {
    await ref.read(deleteAnnouncementProvider.notifier).delete(bulletinId);
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({
    required this.notification,
    required this.canManage,
    required this.busy,
    required this.needsAttention,
    required this.responsePending,
    required this.isSelecting,
    required this.isSelected,
    required this.isSelectable,
    required this.onTap,
    required this.onDelete,
    this.onToggleSelected,
    this.onEdit,
  });

  final AppNotificationEntity notification;
  final bool canManage;
  final bool busy;
  final bool needsAttention;
  final bool responsePending;
  final bool isSelecting;
  final bool isSelected;
  final bool isSelectable;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onToggleSelected;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isUnread = needsAttention;
    final icon = switch (notification.type) {
      'reminder' => Icons.campaign_outlined,
      'status_update' => Icons.assignment_turned_in_outlined,
      'group_membership' => Icons.groups_outlined,
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
          if (responsePending)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Response required',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.tertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      isThreeLine: true,
      trailing: isSelecting
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUnread)
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: responsePending
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                Checkbox(
                  value: isSelected,
                  onChanged: isSelectable ? (_) => onToggleSelected?.call() : null,
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUnread)
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: responsePending
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
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
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.edit_outlined),
                              const SizedBox(width: 12),
                              Text(l10n.commonEdit),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.delete_outline),
                            const SizedBox(width: 12),
                            Text(l10n.commonDelete),
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
