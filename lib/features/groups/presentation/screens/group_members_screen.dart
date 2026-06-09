import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_entity.dart';
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
        actions: [
          if (canManage)
            IconButton(
              tooltip: 'Edit club positions',
              onPressed: () =>
                  context.push(Routes.editGroupPositionRolesPath(groupId)),
              icon: const Icon(Icons.badge_outlined),
            ),
        ],
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
      body: groupAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (group) => membersAsync.when(
          loading: () => const AppLoadingIndicator(),
          error: (e, _) => AppErrorWidget(message: e.toString()),
          data: (members) {
            if (members.isEmpty) {
              return _EmptyMembers(canManage: canManage);
            }

            final sorted = List<GroupMemberEntity>.from(members)
              ..sort((a, b) {
                if (group == null) {
                  return a.displayName.compareTo(b.displayName);
                }
                final orderA = group.positionSortOrder(a.positionRoleId);
                final orderB = group.positionSortOrder(b.positionRoleId);
                if (orderA != orderB) return orderA.compareTo(orderB);
                return a.displayName.compareTo(b.displayName);
              });

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (_, i) => _MemberTile(
                member: sorted[i],
                group: group,
                groupId: groupId,
                canManage: canManage,
                isBusy: actionState.isLoading,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyMembers extends StatelessWidget {
  const _EmptyMembers({required this.canManage});

  final bool canManage;

  @override
  Widget build(BuildContext context) {
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberTile extends ConsumerWidget {
  const _MemberTile({
    required this.member,
    required this.group,
    required this.groupId,
    required this.canManage,
    required this.isBusy,
  });

  final GroupMemberEntity member;
  final GroupEntity? group;
  final String groupId;
  final bool canManage;
  final bool isBusy;

  String _subtitle() {
    final parts = <String>[member.groupRole.label];
    final position = group?.positionLabel(member.positionRoleId);
    if (position != null) {
      parts.add(position);
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hasPositions = group?.hasPositionRoles ?? false;

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
        subtitle: Text(_subtitle()),
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
                  } else if (action.startsWith('position:')) {
                    final roleId = action.substring('position:'.length);
                    final positionId =
                        roleId == '__none__' ? null : roleId;
                    final ok = await notifier.updatePosition(
                      groupId: groupId,
                      userId: member.userId,
                      positionRoleId: positionId,
                    );
                    if (context.mounted && !ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not update position'),
                        ),
                      );
                    }
                  }
                },
                itemBuilder: (_) {
                  final items = <PopupMenuEntry<String>>[];
                  if (hasPositions) {
                    items.add(
                      const PopupMenuItem(
                        enabled: false,
                        child: Text('Assign position'),
                      ),
                    );
                    items.add(
                      PopupMenuItem(
                        value: 'position:__none__',
                        child: Text(
                          member.positionRoleId == null
                              ? 'No position ✓'
                              : 'No position',
                        ),
                      ),
                    );
                    for (final role in group!.positionRoles) {
                      final selected = member.positionRoleId == role.id;
                      items.add(
                        PopupMenuItem(
                          value: 'position:${role.id}',
                          child: Text(
                            selected ? '${role.label} ✓' : role.label,
                          ),
                        ),
                      );
                    }
                    items.add(const PopupMenuDivider());
                  }
                  if (!member.isLeader) {
                    items.add(
                      const PopupMenuItem(
                        value: 'leader',
                        child: Text('Make leader'),
                      ),
                    );
                  }
                  if (member.isLeader) {
                    items.add(
                      const PopupMenuItem(
                        value: 'member',
                        child: Text('Make member'),
                      ),
                    );
                  }
                  items.add(
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text('Remove from group'),
                    ),
                  );
                  return items;
                },
              )
            : null,
      ),
    );
  }
}
