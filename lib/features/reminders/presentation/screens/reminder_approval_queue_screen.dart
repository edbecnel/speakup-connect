import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/announcements/domain/entities/bulletin_entity.dart';
import 'package:speakup_connect/features/announcements/presentation/providers/announcement_provider.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_entity.dart';
import 'package:speakup_connect/features/reminders/presentation/providers/reminder_provider.dart';

/// Admin Approval Queue — lists reminders awaiting review and lets approvers
/// approve or reject each one.
///
/// Gated on [canReviewPendingRemindersProvider] (org admins and approvers).
class ReminderApprovalQueueScreen extends ConsumerWidget {
  const ReminderApprovalQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final canApprove = ref.watch(canReviewPendingRemindersProvider);
    final pendingRemindersAsync = ref.watch(pendingRemindersProvider);
    final pendingBulletinsAsync = ref.watch(pendingBulletinsProvider);

    ref.listen(reminderReviewProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading && next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Action failed: ${next.error}'),
          backgroundColor: theme.colorScheme.error,
        ));
      }
    });

    ref.listen(bulletinReviewProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading && next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Action failed: ${next.error}'),
          backgroundColor: theme.colorScheme.error,
        ));
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Pending Approvals'),
      ),
      body: !canApprove
          ? const _NoAccessPlaceholder()
          : _PendingApprovalsBody(
              remindersAsync: pendingRemindersAsync,
              bulletinsAsync: pendingBulletinsAsync,
            ),
    );
  }
}

class _PendingApprovalsBody extends StatelessWidget {
  const _PendingApprovalsBody({
    required this.remindersAsync,
    required this.bulletinsAsync,
  });

  final AsyncValue<List<ReminderEntity>> remindersAsync;
  final AsyncValue<List<BulletinEntity>> bulletinsAsync;

  @override
  Widget build(BuildContext context) {
    if (remindersAsync.isLoading || bulletinsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (remindersAsync.hasError) {
      return Center(child: Text('Failed to load: ${remindersAsync.error}'));
    }
    if (bulletinsAsync.hasError) {
      return Center(child: Text('Failed to load: ${bulletinsAsync.error}'));
    }

    final reminders = remindersAsync.value ?? const [];
    final bulletins = bulletinsAsync.value ?? const [];
    if (reminders.isEmpty && bulletins.isEmpty) {
      return const _EmptyQueue();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (bulletins.isNotEmpty) ...[
          const _SectionLabel('Announcements'),
          ...bulletins.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PendingBulletinCard(bulletin: b),
            ),
          ),
        ],
        if (reminders.isNotEmpty) ...[
          if (bulletins.isNotEmpty) const SizedBox(height: 8),
          const _SectionLabel('Group alerts'),
          ...reminders.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PendingReminderCard(reminder: r),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _PendingBulletinCard extends ConsumerWidget {
  const _PendingBulletinCard({required this.bulletin});

  final BulletinEntity bulletin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reviewState = ref.watch(bulletinReviewProvider);
    final busy = reviewState.isLoading;

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
                    bulletin.title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Chip(
                  avatar: const Icon(Icons.campaign_outlined, size: 16),
                  label: const Text('School-wide'),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(bulletin.body, style: theme.textTheme.bodyMedium),
            if (bulletin.sourceGroupName?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                'From ${bulletin.sourceGroupName}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            if (bulletin.scheduledAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDateTime(bulletin.scheduledAt!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'By ${bulletin.authorName ?? 'Unknown'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: busy
                      ? null
                      : () => _confirmRejectBulletin(context, ref),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Reject'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
                FilledButton.icon(
                  onPressed: busy
                      ? null
                      : () => ref
                          .read(bulletinReviewProvider.notifier)
                          .approve(bulletin.bulletinId),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Approve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRejectBulletin(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final ctrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject announcement'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Reason (optional)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (reason == null) return;
    await ref.read(bulletinReviewProvider.notifier).reject(
          bulletin.bulletinId,
          reason.isEmpty ? 'No reason provided' : reason,
        );
  }
}

class _PendingReminderCard extends ConsumerWidget {
  const _PendingReminderCard({required this.reminder});

  final ReminderEntity reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reviewState = ref.watch(reminderReviewProvider);
    final busy = reviewState.isLoading;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    reminder.title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _AudienceChip(audience: reminder.audience),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(reminder.body, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'By ${reminder.createdByName ?? 'Unknown'}'
                    '${reminder.isScheduled ? ' · scheduled' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            if (reminder.scheduledAt != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.schedule,
                      size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(reminder.scheduledAt!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton.icon(
                  onPressed:
                      busy ? null : () => _confirmReject(context, ref),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Reject'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
                FilledButton.icon(
                  onPressed: busy
                      ? null
                      : () => ref
                          .read(reminderReviewProvider.notifier)
                          .approve(reminder.reminderId),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Approve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReject(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject reminder'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Reason (optional)',
            hintText: 'Let the author know why…',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (reason == null) return; // cancelled
    await ref.read(reminderReviewProvider.notifier).reject(
          reminder.reminderId,
          reason.isEmpty ? 'No reason provided' : reason,
        );
  }
}

class _AudienceChip extends StatelessWidget {
  const _AudienceChip({required this.audience});

  final ReminderAudience audience;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = switch (audience.type) {
      ReminderAudienceType.all => Icons.groups_outlined,
      ReminderAudienceType.group => Icons.diversity_3_outlined,
      ReminderAudienceType.role => Icons.badge_outlined,
    };
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(audience.displayLabel),
      labelStyle: theme.textTheme.labelSmall,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined,
              size: 56, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            'Nothing awaiting approval',
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
              'You don\'t have permission to approve content.',
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
