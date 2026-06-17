import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/notifications/domain/entities/notification_history_entity.dart';
import 'package:speakup_connect/features/notifications/presentation/providers/notification_history_provider.dart';

/// Read-only archive of expired, recalled, and dismissed notifications.
class NotificationHistoryScreen extends ConsumerWidget {
  const NotificationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final historyAsync = ref.watch(notificationHistoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.alerts),
        ),
        title: Text(l10n.notificationHistoryTitle),
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(l10n.notificationHistoryFailedToLoad('$e'))),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No archived notifications yet.',
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
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) => _HistoryTile(entry: items[index]),
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});

  final NotificationHistoryEntity entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = StringBuffer(entry.removalReasonLabel);
    if (entry.audienceLabel != null && entry.audienceLabel!.isNotEmpty) {
      subtitle.write(' · ${entry.audienceLabel}');
    }
    if (entry.feedCopiesAffected != null && entry.feedCopiesAffected! > 0) {
      subtitle.write(' · ${entry.feedCopiesAffected} feed copies');
    }

    return ListTile(
      title: Text(entry.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatWhen(entry.removedAt)} — $subtitle',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      isThreeLine: true,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          _iconForReason(entry.removalReason),
          size: 20,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  IconData _iconForReason(String reason) => switch (reason) {
        'expired' => Icons.timer_off_outlined,
        'recalled' => Icons.delete_outline,
        'user_dismissed' => Icons.close,
        'cleared_all' => Icons.clear_all,
        _ => Icons.history,
      };
}

String _formatWhen(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final ampm = dt.hour < 12 ? 'AM' : 'PM';
  return '${dt.year}-${two(dt.month)}-${two(dt.day)} · $h:${two(dt.minute)} $ampm';
}
