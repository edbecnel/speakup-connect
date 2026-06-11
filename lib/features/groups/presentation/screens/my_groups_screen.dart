import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_membership_policy.dart';
import 'package:speakup_connect/features/groups/domain/entities/my_group_membership.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_membership_provider.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/features/groups/presentation/widgets/group_membership_policy_sheet.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';
import 'package:speakup_connect/shared/widgets/app_text_field.dart';

/// Groups and clubs the signed-in user belongs to, with leader/member actions.
class MyGroupsScreen extends ConsumerWidget {
  const MyGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipsAsync = ref.watch(myGroupMembershipsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('My Groups & Clubs'),
        actions: [
          TextButton(
            onPressed: () => context.push(Routes.browseGroups),
            child: const Text('Browse'),
          ),
        ],
      ),
      body: membershipsAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (memberships) {
          if (memberships.isEmpty) {
            return _EmptyMyGroups(
              onBrowse: () => context.push(Routes.browseGroups),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: memberships.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _MyGroupCard(entry: memberships[i]),
          );
        },
      ),
    );
  }
}

class _EmptyMyGroups extends StatelessWidget {
  const _EmptyMyGroups({required this.onBrowse});

  final VoidCallback onBrowse;

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
              Icons.groups_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No groups yet',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'When an administrator adds you to a club, it will appear here. '
              'You can also browse open groups and request to join.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            AppButton.primary(
              label: 'Browse Groups & Clubs',
              onPressed: onBrowse,
            ),
          ],
        ),
      ),
    );
  }
}

class _MyGroupCard extends ConsumerWidget {
  const _MyGroupCard({required this.entry});

  final MyGroupMembership entry;

  Future<void> _leaveVoluntarily(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave group?'),
        content: const Text(
          'You will stop receiving alerts for this group.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final ok = await ref
        .read(groupMembershipActionsProvider.notifier)
        .voluntaryLeave(groupId: entry.group.groupId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'You left the group' : 'Could not leave')),
      );
    }
  }

  Future<void> _requestLeave(BuildContext context, WidgetRef ref) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _LeaveRequestDialog(),
    );
    if (reason == null) return;
    if (reason.length < 20) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter at least 20 characters'),
          ),
        );
      }
      return;
    }

    final ok = await ref
        .read(groupMembershipActionsProvider.notifier)
        .submitLeaveRequest(
          groupId: entry.group.groupId,
          reason: reason,
        );
    if (context.mounted) {
      final error = ref.read(groupMembershipActionsProvider.notifier).lastErrorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Leave request submitted'
                : (error ?? 'Could not submit request'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final group = entry.group;
    final member = entry.membership;
    final rosterMember = ref
        .watch(myGroupMembershipInGroupProvider(group.groupId))
        .asData
        ?.value;
    final position = entry.positionLabel();
    final isBusy = ref.watch(groupMembershipActionsProvider).isLoading;
    final canManageRoster =
        ref.watch(canManageGroupRosterProvider(group.groupId));
    final canEditPolicies =
        ref.watch(canEditGroupMembershipPoliciesProvider(group.groupId));
    final leaveReq =
        ref.watch(myLeaveRequestForGroupProvider(group.groupId)).asData?.value;
    final leavePending = leaveReq?.status.isPending == true;
    final pendingCount =
        group.pendingJoinRequestCount + group.pendingLeaveRequestCount;

    final subtitleParts = <String>[
      (rosterMember ?? member).groupRole.label,
      if (position != null) position,
      if (group.memberCount > 0) '${group.memberCount} members',
      if (leavePending) 'Leave pending',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: canManageRoster
                      ? theme.colorScheme.secondaryContainer
                      : theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.groups_rounded,
                    color: canManageRoster
                        ? theme.colorScheme.onSecondaryContainer
                        : theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitleParts.join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canManageRoster && pendingCount > 0)
                  Badge(
                    label: Text('$pendingCount'),
                    child: const Icon(Icons.inbox_outlined),
                  ),
              ],
            ),
            if (group.description != null &&
                group.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                group.description!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppButton.secondary(
                  label: 'Manage Members',
                  icon: Icons.people_outline,
                  onPressed: () =>
                      context.push(Routes.groupMembersPath(group.groupId)),
                ),
                if (canManageRoster) ...[
                  AppButton.secondary(
                    label: 'Add Members',
                    icon: Icons.person_add_outlined,
                    onPressed: () => context
                        .push(Routes.addGroupMembersPath(group.groupId)),
                  ),
                  AppButton.secondary(
                    label: pendingCount > 0
                        ? 'Requests ($pendingCount)'
                        : 'Requests',
                    icon: Icons.inbox_outlined,
                    onPressed: () => context.push(
                      Routes.groupMembershipRequestsPath(group.groupId),
                    ),
                  ),
                  AppButton.primary(
                    label: 'Send Alert',
                    icon: Icons.campaign_outlined,
                    onPressed: () => context.push(
                      Routes.composeReminderForGroupPath(group.groupId),
                    ),
                  ),
                  if (canEditPolicies)
                    AppButton.secondary(
                      label: 'Settings',
                      icon: Icons.settings_outlined,
                      onPressed: () => showGroupMembershipPolicySheet(
                        context: context,
                        ref: ref,
                        group: group,
                      ),
                    ),
                ],
                if (!leavePending &&
                    group.memberLeavePolicy == MemberLeavePolicy.voluntary)
                  AppButton.secondary(
                    label: 'Leave group',
                    icon: Icons.logout,
                    isLoading: isBusy,
                    onPressed: isBusy
                        ? null
                        : () => _leaveVoluntarily(context, ref),
                  ),
                if (!leavePending &&
                    group.memberLeavePolicy == MemberLeavePolicy.requestRequired)
                  AppButton.secondary(
                    label: 'Request to leave',
                    icon: Icons.exit_to_app,
                    isLoading: isBusy,
                    onPressed:
                        isBusy ? null : () => _requestLeave(context, ref),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog that owns its [TextEditingController] so disposal happens after the
/// route is torn down (avoids `_dependents.isEmpty` assertion on pop).
class _LeaveRequestDialog extends StatefulWidget {
  const _LeaveRequestDialog();

  @override
  State<_LeaveRequestDialog> createState() => _LeaveRequestDialogState();
}

class _LeaveRequestDialogState extends State<_LeaveRequestDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Request to leave'),
      content: AppTextField(
        controller: _controller,
        label: 'Why do you want to leave?',
        hint: 'At least 20 characters',
        maxLines: 4,
        maxLength: 500,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
