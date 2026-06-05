import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/organization/domain/entities/user_profile_entity.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';

/// Admin queue for reviewing join applications submitted after sign-up.
class MemberApprovalQueueScreen extends ConsumerWidget {
  const MemberApprovalQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(userProfileProvider).value;
    final canApprove =
        ref.watch(hasPermissionProvider(AppPermission.approveApplications));
    final canAct = canApprove || (profile?.isAdmin ?? false);
    final pendingAsync = ref.watch(pendingMemberApplicationsProvider);
    final applications = pendingAsync.value ?? const <UserProfileEntity>[];

    ref.listen(memberApplicationReviewProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading && next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Action failed: ${next.error}'),
          backgroundColor: theme.colorScheme.error,
        ));
      }
    });

    Widget body;
    if (pendingAsync.isLoading && !pendingAsync.hasValue) {
      body = const Center(child: CircularProgressIndicator());
    } else if (pendingAsync.hasError && !pendingAsync.hasValue) {
      body = Center(child: Text('Failed to load: ${pendingAsync.error}'));
    } else if (applications.isEmpty) {
      body = const _EmptyQueue();
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: applications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _PendingApplicationCard(
          profile: applications[i],
          canAct: canAct,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Join Applications'),
      ),
      body: body,
    );
  }
}

class _PendingApplicationCard extends ConsumerWidget {
  const _PendingApplicationCard({
    required this.profile,
    required this.canAct,
  });

  final UserProfileEntity profile;
  final bool canAct;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reviewState = ref.watch(memberApplicationReviewProvider);
    final busy = reviewState.isLoading;
    final appliedAt = DateFormat.yMMMd().add_jm().format(profile.createdAt);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(
              profile.fullName.isNotEmpty ? profile.fullName : 'Unknown',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (profile.displayName.isNotEmpty &&
                    profile.displayName != profile.fullName)
                  Text(profile.displayName),
                if (profile.email != null) Text(profile.email!),
                if (profile.studentId != null)
                  Text('Student ID: ${profile.studentId}'),
                Text('Applied $appliedAt'),
              ],
            ),
          ),
          if (canAct)
            OverflowBar(
              alignment: MainAxisAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: busy ? null : () => _confirmReject(context, ref),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  child: const Text('Reject'),
                ),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () => ref
                          .read(memberApplicationReviewProvider.notifier)
                          .approve(profile.userId),
                  child: const Text('Approve'),
                ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'View only — you do not have permission to approve applications.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmReject(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject application'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Reason (optional)',
            hintText: 'Let the applicant know why…',
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
    await ref.read(memberApplicationReviewProvider.notifier).reject(
          profile.userId,
          reason: reason.isEmpty ? null : reason,
        );
  }
}

class _EmptyQueue extends StatelessWidget {
  const _EmptyQueue();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.how_to_reg_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No pending applications',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'When someone signs up and completes the Join form, their request will appear here.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
