import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/features/notifications/domain/entities/app_notification_entity.dart';
import 'package:speakup_connect/features/notifications/presentation/providers/notification_provider.dart';
import 'package:speakup_connect/features/reminders/presentation/widgets/expiration_picker_section.dart'
    show formatDateTime;

/// Full-screen view of a single alert notification.
class NotificationDetailScreen extends ConsumerStatefulWidget {
  const NotificationDetailScreen({required this.notification, super.key});

  final AppNotificationEntity notification;

  @override
  ConsumerState<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState
    extends ConsumerState<NotificationDetailScreen> {
  @override
  void initState() {
    super.initState();
    final n = widget.notification;
    if (!n.read && !n.id.startsWith('broadcast-')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(notificationActionsProvider.notifier).markRead(n.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final n = widget.notification;
    final icon = switch (n.type) {
      'reminder' => Icons.campaign_outlined,
      'status_update' => Icons.assignment_turned_in_outlined,
      'group_membership' => Icons.groups_outlined,
      _ => Icons.notifications_outlined,
    };
    final typeLabel = switch (n.type) {
      'reminder' => 'Reminder',
      'status_update' => 'Status update',
      'group_membership' => 'Group update',
      _ => 'Alert',
    };

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        title: Text(typeLabel),
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
                      icon,
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
                          n.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatReceivedAt(n.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Message',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                n.body,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
              if (n.expiresAt != null) ...[
                const SizedBox(height: 24),
                Text(
                  'Expires',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatDateTime(n.expiresAt!),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _formatReceivedAt(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes} min ago';
  if (diff.inDays < 1) return '${diff.inHours} hr ago';
  if (diff.inDays < 7) return '${diff.inDays} d ago';
  return formatDateTime(dt);
}
