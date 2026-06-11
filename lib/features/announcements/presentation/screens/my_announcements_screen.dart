import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/features/announcements/domain/entities/bulletin_entity.dart';
import 'package:speakup_connect/features/announcements/presentation/providers/announcement_provider.dart';
import 'package:speakup_connect/features/announcements/presentation/screens/announcement_responses_screen.dart';
import 'package:speakup_connect/features/announcements/presentation/widgets/edit_announcement_dialog.dart';
import 'package:speakup_connect/features/reminders/presentation/widgets/expiration_picker_section.dart';

class MyAnnouncementsScreen extends ConsumerWidget {
  const MyAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bulletinsAsync = ref.watch(myBulletinsProvider);

    ref.listen(updateAnnouncementProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading && context.mounted) {
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
                  ? 'Announcement updated — $updated alert(s) refreshed.'
                  : 'Announcement updated.',
            ),
            backgroundColor: Colors.green.shade700,
          ));
        }
      }
    });

    ref.listen(deleteAnnouncementProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading && context.mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        if (next.hasError) {
          messenger.showSnackBar(SnackBar(
            content: Text('Delete failed: ${next.error}'),
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

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('My Announcements'),
      ),
      body: bulletinsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (bulletins) {
          if (bulletins.isEmpty) {
            return const Center(
              child: Text('You have not posted any announcements yet.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bulletins.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _MyAnnouncementCard(bulletin: bulletins[i]),
          );
        },
      ),
    );
  }
}

class _MyAnnouncementCard extends ConsumerWidget {
  const _MyAnnouncementCard({required this.bulletin});

  final BulletinEntity bulletin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final canManageAsync =
        ref.watch(canManageAnnouncementProvider(bulletin.bulletinId));
    final canManage = canManageAsync.asData?.value ?? false;
    final busy = ref.watch(updateAnnouncementProvider).isLoading ||
        ref.watch(deleteAnnouncementProvider).isLoading;
    final isPublished = bulletin.isPublished;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: isPublished
            ? () => context.push(
                  Routes.announcementDetailPath(bulletin.bulletinId),
                )
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bulletin.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_statusLabel(bulletin)} · '
                '${DateFormat.yMMMd().format(bulletin.createdAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (bulletin.scheduledAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Scheduled ${formatDateTime(bulletin.scheduledAt!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              if (bulletin.acceptsResponses)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => AnnouncementResponsesScreen(
                            bulletinId: bulletin.bulletinId,
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
                      onPressed: busy ? null : () => _confirmDelete(context, ref),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Delete'),
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

  String _statusLabel(BulletinEntity bulletin) {
    return switch (bulletin.status) {
      BulletinStatus.pending => 'Pending approval',
      BulletinStatus.published =>
        bulletin.isScheduled ? 'Scheduled' : 'Published',
      BulletinStatus.rejected => 'Rejected',
    };
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final edited = await EditAnnouncementDialog.show(
      context,
      bulletin: bulletin,
    );
    if (edited == null || !context.mounted) return;

    final ok = await ref.read(updateAnnouncementProvider.notifier).update(
          bulletinId: bulletin.bulletinId,
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
      ref.invalidate(bulletinByIdProvider(bulletin.bulletinId));
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete announcement?'),
        content: Text(
          bulletin.isPublished
              ? 'This deletes the announcement and removes it from every '
                  'member\'s alerts feed. This cannot be undone.'
              : 'This permanently deletes the announcement. '
                  'This cannot be undone.',
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
          .read(deleteAnnouncementProvider.notifier)
          .delete(bulletin.bulletinId);
    }
  }
}
