import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/announcements/domain/entities/bulletin_entity.dart';
import 'package:speakup_connect/features/announcements/presentation/providers/announcement_provider.dart';
import 'package:speakup_connect/features/announcements/presentation/providers/bulletin_response_provider.dart';
import 'package:speakup_connect/features/announcements/presentation/screens/announcement_responses_screen.dart';
import 'package:speakup_connect/features/announcements/presentation/widgets/edit_announcement_dialog.dart';
import 'package:speakup_connect/features/notifications/domain/entities/app_notification_entity.dart';
import 'package:speakup_connect/features/notifications/domain/entities/notification_attention.dart';
import 'package:speakup_connect/features/notifications/presentation/providers/notification_provider.dart';
import 'package:speakup_connect/features/reminders/presentation/widgets/reminder_response_form.dart';
import 'package:speakup_connect/shared/widgets/photo_viewer.dart';

class AnnouncementDetailScreen extends ConsumerStatefulWidget {
  const AnnouncementDetailScreen({
    required this.bulletinId,
    this.notification,
    super.key,
  });

  final String bulletinId;
  final AppNotificationEntity? notification;

  @override
  ConsumerState<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState
    extends ConsumerState<AnnouncementDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeMarkRead());
  }

  Future<void> _maybeMarkRead() async {
    final notification = widget.notification;
    if (notification == null) {
      await ref
          .read(announcementReadProvider.notifier)
          .markBulletinNotificationRead(widget.bulletinId);
      return;
    }

    final bulletin =
        await ref.read(bulletinByIdProvider(widget.bulletinId).future);
    final myResponse =
        await ref.read(myBulletinResponseProvider(widget.bulletinId).future);
    final attention = NotificationAttention.resolve(
      notification: notification,
      bulletin: bulletin,
      myBulletinResponse: myResponse,
    );

    if (attention.responsePending) return;
    if (!mounted || notification.read) return;

    await ref
        .read(notificationActionsProvider.notifier)
        .markRead(notification.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final bulletinAsync = ref.watch(bulletinByIdProvider(widget.bulletinId));
    final canManageAsync =
        ref.watch(canManageAnnouncementProvider(widget.bulletinId));
    final canManage = canManageAsync.asData?.value ?? false;
    final busy = ref.watch(updateAnnouncementProvider).isLoading ||
        ref.watch(deleteAnnouncementProvider).isLoading;

    ref.listen(updateAnnouncementProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading && mounted) {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.commonUpdateFailed('${next.error}')),
            backgroundColor: theme.colorScheme.error,
          ));
        } else {
          final updated = next.asData?.value ?? 0;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
      if (prev?.isLoading == true && !next.isLoading && mounted) {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.commonDeleteFailed('${next.error}')),
            backgroundColor: theme.colorScheme.error,
          ));
        } else {
          final removed = next.asData?.value ?? 0;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              removed > 0
                  ? 'Announcement deleted — $removed alert(s) removed.'
                  : 'Announcement deleted.',
            ),
            backgroundColor: Colors.green.shade700,
          ));
          if (context.canPop()) context.pop();
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.announcementsDetailTitle),
        actions: [
          if (canManage) ...[
            IconButton(
              tooltip: l10n.commonEdit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: busy
                  ? null
                  : () => bulletinAsync.whenData(
                        (bulletin) {
                          if (bulletin != null) {
                            _editAnnouncement(context, bulletin);
                          }
                        },
                      ),
            ),
            IconButton(
              tooltip: l10n.commonDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: busy ? null : () => _confirmDelete(context),
            ),
          ],
        ],
      ),
      body: bulletinAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.commonFailedToLoad('$e'))),
        data: (bulletin) {
          if (bulletin == null) {
            return Center(child: Text(l10n.announcementsNotFound));
          }
          return _AnnouncementBody(
            bulletin: bulletin,
            onEdit: canManage
                ? () => _editAnnouncement(context, bulletin)
                : null,
          );
        },
      ),
    );
  }

  Future<void> _editAnnouncement(
    BuildContext context,
    BulletinEntity bulletin,
  ) async {
    BulletinEntity initialBulletin = bulletin;
    try {
      initialBulletin = await ref
              .read(bulletinByIdProvider(widget.bulletinId).future) ??
          bulletin;
    } catch (_) {
      initialBulletin = bulletin;
    }

    final edited = await EditAnnouncementDialog.show(
      context,
      bulletin: initialBulletin,
    );
    if (edited == null || !context.mounted) return;

    final ok = await ref.read(updateAnnouncementProvider.notifier).update(
          bulletinId: widget.bulletinId,
          title: edited.title,
          body: edited.body,
          expiresAt: edited.expiresAt,
          clearExpiration: edited.clearExpiration,
          responseConfig: edited.responseConfig,
          newImageLocalPath: edited.newImageLocalPath,
          clearImage: edited.clearImage,
          clearResponseConfig: edited.clearResponseConfig,
        );
    if (ok && mounted) {
      ref.invalidate(bulletinByIdProvider(widget.bulletinId));
      ref.invalidate(myBulletinsProvider);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.announcementsDeleteTitle),
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
      await ref
          .read(deleteAnnouncementProvider.notifier)
          .delete(widget.bulletinId);
    }
  }
}

class _AnnouncementBody extends ConsumerWidget {
  const _AnnouncementBody({
    required this.bulletin,
    this.onEdit,
  });

  final BulletinEntity bulletin;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final date = bulletin.publishedAt ?? bulletin.createdAt;
    final dateLabel = DateFormat.yMMMMd().add_jm().format(date);
    final canRespond = bulletin.isPublished &&
        !bulletin.isExpired &&
        bulletin.acceptsResponses;
    final myResponseAsync = canRespond
        ? ref.watch(myBulletinResponseProvider(bulletin.bulletinId))
        : null;
    final canViewResponsesAsync =
        ref.watch(canViewBulletinResponsesProvider(bulletin.bulletinId));
    final canViewResponses = canViewResponsesAsync.asData?.value ?? false;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (canViewResponses)
            Align(
              alignment: Alignment.centerRight,
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
                label: Text(l10n.announcementsViewResponses),
              ),
            ),
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
          if (bulletin.imageUrl?.isNotEmpty == true) ...[
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => showPhotoViewer(
                context,
                urls: [bulletin.imageUrl!],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  bulletin.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    alignment: Alignment.center,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (onEdit != null && bulletin.imageUrl?.isNotEmpty != true) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
              label: Text(l10n.announcementsAddImage),
            ),
          ],
          if (bulletin.expiresAt != null) ...[
            const SizedBox(height: 24),
            Text(
              'Expires ${DateFormat.yMMMd().format(bulletin.expiresAt!)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (canRespond && bulletin.responseRequired) ...[
            const SizedBox(height: 20),
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
                        'Response required — submit your answer to dismiss '
                        'this alert.',
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
          if (canRespond && bulletin.responseConfig != null) ...[
            const SizedBox(height: 28),
            myResponseAsync == null
                ? const SizedBox.shrink()
                : myResponseAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text(l10n.announcementsFailedToLoadResponse('$e')),
                    data: (existing) => ReminderResponseForm(
                      organizationId: AppConfig.defaultOrganizationId,
                      bulletinId: bulletin.bulletinId,
                      config: bulletin.responseConfig!,
                      existing: existing,
                    ),
                  ),
          ],
        ],
      ),
    );
  }
}
