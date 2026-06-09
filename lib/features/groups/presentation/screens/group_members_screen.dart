import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_member_entity.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';

/// Roster management for a single group — view, add, remove, assign leader.
class GroupMembersScreen extends ConsumerWidget {
  const GroupMembersScreen({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupByIdProvider(groupId));
    final membersAsync = ref.watch(groupMembersProvider(groupId));
    final canManage = ref.watch(canManageGroupsProvider);
    final actionState = ref.watch(groupMemberActionsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: groupAsync.when(
          data: (g) => Text(g?.name ?? 'Group Members'),
          loading: () => const Text('Group Members'),
          error: (_, __) => const Text('Group Members'),
        ),
      ),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: actionState.isLoading
                  ? null
                  : () => context.push(Routes.addGroupMembersPath(groupId)),
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Add Members'),
              shape: const StadiumBorder(),
            )
          : null,
      body: membersAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (members) {
          if (members.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No members yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      canManage
                          ? 'Add students or staff to this group.'
                          : 'Members will appear here once added.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            itemCount: members.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (_, i) => _MemberTile(
              member: members[i],
              groupId: groupId,
              canManage: canManage,
              isBusy: actionState.isLoading,
            ),
          );
        },
      ),
    );
  }
}

class _MemberTile extends ConsumerWidget {
  const _MemberTile({
    required this.member,
    required this.groupId,
    required this.canManage,
    required this.isBusy,
  });

  final GroupMemberEntity member;
  final String groupId;
  final bool canManage;
  final bool isBusy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: member.isLeader
              ? theme.colorScheme.secondaryContainer
              : theme.colorScheme.primaryContainer,
          child: Text(
            member.displayName.isNotEmpty
                ? member.displayName[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: member.isLeader
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(member.displayName),
        subtitle: Text(member.groupRole.label),
        trailing: canManage
            ? PopupMenuButton<String>(
                enabled: !isBusy,
                onSelected: (action) async {
                  final notifier =
                      ref.read(groupMemberActionsProvider.notifier);
                  if (action == 'leader') {
                    await notifier.updateRole(
                      groupId: groupId,
                      userId: member.userId,
                      groupRole: GroupRole.leader,
                    );
                  } else if (action == 'member') {
                    await notifier.updateRole(
                      groupId: groupId,
                      userId: member.userId,
                      groupRole: GroupRole.member,
                    );
                  } else if (action == 'remove') {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Remove member?'),
                        content: Text(
                          'Remove ${member.displayName} from this group?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Remove'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      final ok = await notifier.removeMember(
                        groupId: groupId,
                        userId: member.userId,
                      );
                      if (context.mounted && !ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not remove member'),
                          ),
                        );
                      }
                    }
                  }
                },
                itemBuilder: (_) => [
                  if (!member.isLeader)
                    const PopupMenuItem(
                      value: 'leader',
                      child: Text('Make leader'),
                    ),
                  if (member.isLeader)
                    const PopupMenuItem(
                      value: 'member',
                      child: Text('Make member'),
                    ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Text('Remove from group'),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
