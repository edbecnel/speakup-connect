import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_entity.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';

/// Admin list of org groups and clubs with search.
class GroupsListScreen extends ConsumerWidget {
  const GroupsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final groupsAsync = ref.watch(orgGroupsProvider);
    final query = ref.watch(groupsSearchQueryProvider).trim().toLowerCase();
    final canManage = ref.watch(canManageGroupsProvider);
    final canSeedDemoGroups =
        ref.watch(userProfileProvider).value?.isAdmin == true ||
            ref.watch(
              hasPermissionProvider(AppPermission.manageOrganizationSettings),
            );
    final seedState = ref.watch(seedDemoGroupsProvider);
    final backfillState = ref.watch(backfillGroupMembershipIndexesProvider);
    final theme = Theme.of(context);

    ref.listen(seedDemoGroupsProvider, (prev, next) {
      if (!next.isLoading && prev?.isLoading == true) {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.groupsSeedFailed('${next.error}')),
            backgroundColor: theme.colorScheme.error,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.groupsSeedSuccess),
            backgroundColor: Colors.green,
          ));
        }
      }
    });

    ref.listen(backfillGroupMembershipIndexesProvider, (prev, next) {
      if (!next.isLoading && prev?.isLoading == true) {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.groupsSyncFailed('${next.error}')),
            backgroundColor: theme.colorScheme.error,
          ));
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsAdminGroups),
        actions: [
          if (canSeedDemoGroups)
            PopupMenuButton<String>(
              tooltip: l10n.groupsMoreActions,
              onSelected: (value) async {
                if (value == 'seed' && !seedState.isLoading) {
                  ref.read(seedDemoGroupsProvider.notifier).seed();
                } else if (value == 'backfill' && !backfillState.isLoading) {
                  try {
                    final count = await ref
                        .read(backfillGroupMembershipIndexesProvider.notifier)
                        .run();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(l10n.groupsSyncSuccess(count)),
                        backgroundColor: Colors.green,
                      ));
                    }
                  } catch (_) {}
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'seed',
                  enabled: !seedState.isLoading && !backfillState.isLoading,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: seedState.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_fix_high_outlined),
                    title: Text(
                      seedState.isLoading
                          ? l10n.groupsSeeding
                          : l10n.groupsSeedDemoGroups,
                    ),
                    subtitle: Text(l10n.groupsSeedDemoSubtitle),
                  ),
                ),
                PopupMenuItem(
                  value: 'backfill',
                  enabled: !seedState.isLoading && !backfillState.isLoading,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: backfillState.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync_outlined),
                    title: Text(
                      backfillState.isLoading
                          ? l10n.groupsSyncing
                          : l10n.groupsSyncIndexes,
                    ),
                    subtitle: Text(l10n.groupsSyncIndexesSubtitle),
                  ),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => context.push(Routes.createGroup),
              icon: const Icon(Icons.add),
              label: Text(l10n.groupsNewGroup),
              shape: const StadiumBorder(),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.groupsSearchGroupsHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            ref.read(groupsSearchQueryProvider.notifier).clear(),
                      )
                    : null,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: ref.read(groupsSearchQueryProvider.notifier).setQuery,
            ),
          ),
          Expanded(
            child: groupsAsync.when(
              loading: () => const AppLoadingIndicator(),
              error: (e, _) => AppErrorWidget(message: e.toString()),
              data: (groups) {
                final filtered = query.isEmpty
                    ? groups
                    : groups
                        .where(
                          (g) =>
                              g.name.toLowerCase().contains(query) ||
                              (g.description?.toLowerCase().contains(query) ??
                                  false),
                        )
                        .toList();

                if (filtered.isEmpty) {
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
                            groups.isEmpty
                                ? l10n.homeGroupsNone
                                : l10n.groupsNoSearchMatch,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            groups.isEmpty && canManage
                                ? l10n.groupsEmptySeedHint
                                : l10n.groupsTryDifferentSearch,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (groups.isEmpty && canSeedDemoGroups) ...[
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: seedState.isLoading
                                    ? null
                                    : () => ref
                                        .read(seedDemoGroupsProvider.notifier)
                                        .seed(),
                                icon: seedState.isLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.auto_fix_high_outlined),
                                label: Text(
                                  seedState.isLoading
                                      ? l10n.groupsSeeding
                                      : l10n.groupsSeedDemoGroups,
                                ),
                              ),
                            ),
                          ],
                          if (groups.isEmpty && canManage) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    context.push(Routes.createGroup),
                                icon: const Icon(Icons.add),
                                label: Text(l10n.groupsCreateGroup),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _GroupCard(group: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends ConsumerWidget {
  const _GroupCard({required this.group});

  final GroupEntity group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final canEdit = ref.watch(canEditGroupSettingsProvider(group.groupId));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Routes.groupMembersPath(group.groupId)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.groups_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 14),
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
                    if (group.description != null &&
                        group.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          group.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      [
                        l10n.groupsMemberCount(group.memberCount),
                        if (group.allowJoinRequests) l10n.groupsOpenToJoin,
                        if (group.pendingJoinRequestCount +
                                group.pendingLeaveRequestCount >
                            0)
                          '${group.pendingJoinRequestCount + group.pendingLeaveRequestCount} ${l10n.groupsPending}',
                      ].join(' · '),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (canEdit)
                IconButton(
                  tooltip: l10n.groupsEditGroupTooltip,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    context.push(Routes.editGroupPath(group.groupId));
                  },
                ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
