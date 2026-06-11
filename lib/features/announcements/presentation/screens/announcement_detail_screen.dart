import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:speakup_connect/features/announcements/presentation/providers/announcement_provider.dart';

class AnnouncementDetailScreen extends ConsumerWidget {
  const AnnouncementDetailScreen({required this.bulletinId, super.key});

  final String bulletinId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bulletinAsync = ref.watch(bulletinByIdProvider(bulletinId));

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Announcement'),
      ),
      body: bulletinAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (bulletin) {
          if (bulletin == null) {
            return const Center(child: Text('Announcement not found.'));
          }

          final date = bulletin.publishedAt ?? bulletin.createdAt;
          final dateLabel = DateFormat.yMMMMd().add_jm().format(date);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bulletin.isPinned)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.push_pin_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Pinned',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  bulletin.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (bulletin.sourceGroupName?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Posted on behalf of ${bulletin.sourceGroupName}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                Text(
                  '${bulletin.authorName ?? 'Member'} · $dateLabel',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Divider(height: 32),
                Text(
                  bulletin.body,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
                if (bulletin.expiresAt != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Expires ${DateFormat.yMMMd().format(bulletin.expiresAt!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
