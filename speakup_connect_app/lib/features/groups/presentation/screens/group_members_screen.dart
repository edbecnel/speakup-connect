import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_member_entity.dart';
import 'package:speakup_connect/features/groups/presentation/l10n/group_ui_l10n.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';

/// Roster management for a single group — view, add, remove, assign leader.
class GroupMembersScreen extends ConsumerWidget {
  const GroupMembersScreen({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final groupAsync = ref.watch(groupByIdProvider(groupId));
    final membersAsync = ref.watch(groupMembersProvider(groupId));
    final canManageRoster = ref.watch(canManageGroupRosterProvider(groupId));
    final canEditSettings = ref.watch(canEditGroupSettingsProvider(groupId));
    final actionState = ref.watch(groupMemberActionsProvider);
    final group = groupAsync.asData?.value;
    final pendingCount = group == null
        ? 0
        : group.pendingJoinRequestCount + group.pendingLeaveRequestCount;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: groupAsync.when(
          data: (g) => Text(g?.name ?? l10n.groupsGroupMembersTitle),
          loading: () => Text(l10n.groupsGroupMembersTitle),
          error: (_, __) => Text(l10n.groupsGroupMembersTitle),
        ),
        actions: [
          if (canManageRoster)
            IconButton(
              tooltip: pendingCount > 0
                  ? l10n.groupsMembershipRequestsCount(pendingCount)
                  : l10n.groupsMembershipRequests,
              onPressed: () => context.push(
                Routes.groupMembershipRequestsPath(groupId),
              ),
              icon: pendingCount > 0
                  ? Badge(
                      label: Text(pendingCount.toString()),
                      child: const Icon(Icons.inbox_outlined),
                    )
                  : const Icon(Icons.inbox_outlined),
            ),
          if (canEditSettings)
            TextButton.icon(
              onPressed: () => context.push(Routes.editGroupPath(groupId)),
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.groupsEditGroup),
            ),
        ],
      ),
      floatingActionButton: canManageRoster
          ? FloatingActionButton.extended(
              onPressed: actionState.isLoading
                  ? null
                  : () => context.push(Routes.addGroupMembersPath(groupId)),
              icon: const Icon(Icons.person_add_outlined),
              label: Text(l10n.groupsAddMembers),
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (canEditSettings)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () =>
                              context.push(Routes.editGroupPath(groupId)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.groupsEditGroup,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        l10n.groupsEditGroupMembersHint,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Expanded(child: _EmptyMembers(canManage: canManageRoster)),
                ],
              );
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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (canEditSettings)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () =>
                            context.push(Routes.editGroupPath(groupId)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.groupsEditGroup,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l10n.groupsEditGroupMembersHint,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                    itemCount: sorted.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (_, i) => _MemberTile(
                      member: sorted[i],
                      group: group,
                      groupId: groupId,
                      canManage: canManageRoster,
                      isBusy: actionState.isLoading,
                    ),
                  ),
                ),
              ],
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
    final l10n = context.l10n;

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
              l10n.groupsNoMembersYet,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              canManage
                  ? l10n.groupsNoMembersManageHint
                  : l10n.groupsNoMembersViewHint,
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

  String _subtitle(BuildContext context) {
    final parts = <String>[context.localizedGroupRole(member.groupRole)];
    final position = group?.positionLabel(member.positionRoleId);
    if (position != null) {
      parts.add(position);
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
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
        subtitle: Text(_subtitle(context)),
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
                        title: Text(l10n.groupsRemoveMemberTitle),
                        content: Text(
                          l10n.groupsRemoveMemberMessage(member.displayName),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(l10n.commonCancel),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(l10n.commonRemove),
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
                          SnackBar(
                            content: Text(l10n.groupsCouldNotRemoveMember),
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
                        SnackBar(
                          content: Text(l10n.groupsCouldNotUpdatePosition),
                        ),
                      );
                    }
                  }
                },
                itemBuilder: (ctx) {
                  final items = <PopupMenuEntry<String>>[];
                  if (hasPositions) {
                    items.add(
                      PopupMenuItem(
                        enabled: false,
                        child: Text(l10n.groupsAssignPosition),
                      ),
                    );
                    items.add(
                      PopupMenuItem(
                        value: 'position:__none__',
                        child: Text(
                          member.positionRoleId == null
                              ? l10n.groupsNoPositionSelected
                              : l10n.groupsNoPosition,
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
                      PopupMenuItem(
                        value: 'leader',
                        child: Text(l10n.groupsMakeLeader),
                      ),
                    );
                  }
                  if (member.isLeader) {
                    items.add(
                      PopupMenuItem(
                        value: 'member',
                        child: Text(l10n.groupsMakeMember),
                      ),
                    );
                  }
                  items.add(
                    PopupMenuItem(
                      value: 'remove',
                      child: Text(l10n.groupsRemoveFromGroup),
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
