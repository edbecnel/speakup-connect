import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/organization/domain/entities/user_profile_entity.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';

/// Admin queue for reviewing join applications submitted after sign-up.
class MemberApprovalQueueScreen extends ConsumerWidget {
  const MemberApprovalQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
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
          content: Text(l10n.commonActionFailed(next.error.toString())),
          backgroundColor: theme.colorScheme.error,
        ));
      }
    });

    Widget body;
    if (pendingAsync.isLoading && !pendingAsync.hasValue) {
      body = const Center(child: CircularProgressIndicator());
    } else if (pendingAsync.hasError && !pendingAsync.hasValue) {
      body = Center(
        child: Text(l10n.commonFailedToLoad(pendingAsync.error.toString())),
      );
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
        title: Text(l10n.settingsJoinApplications),
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
    final l10n = context.l10n;
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
              profile.fullName.isNotEmpty
                  ? profile.fullName
                  : l10n.commonUnknown,
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
                  Text(l10n.memberManagementStudentIdWithValue(profile.studentId!)),
                Text(l10n.memberManagementAppliedAt(appliedAt)),
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
                  child: Text(l10n.commonReject),
                ),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () => ref
                          .read(memberApplicationReviewProvider.notifier)
                          .approve(profile.userId),
                  child: Text(l10n.commonApprove),
                ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                l10n.memberManagementViewOnlyNoPermission,
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
      builder: (ctx) {
        final dialogL10n = ctx.l10n;
        return AlertDialog(
          title: Text(dialogL10n.memberManagementRejectApplication),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: dialogL10n.commonReasonOptional,
              hintText: dialogL10n.memberManagementRejectApplicationHint,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(dialogL10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
              child: Text(dialogL10n.commonReject),
            ),
          ],
        );
      },
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
    final l10n = context.l10n;
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
              l10n.memberManagementNoPendingApplications,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.memberManagementNoPendingApplicationsHint,
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
