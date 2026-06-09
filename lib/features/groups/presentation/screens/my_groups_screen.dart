import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/features/groups/domain/entities/my_group_membership.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';

/// Read-only list of groups and clubs the signed-in user belongs to.
class MyGroupsScreen extends ConsumerWidget {
  const MyGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipsAsync = ref.watch(myGroupMembershipsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('My Groups & Clubs'),
      ),
      body: membershipsAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (memberships) {
          if (memberships.isEmpty) {
            return _EmptyMyGroups();
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
              'When an administrator adds you to a club, program, or '
              'organization, it will appear here.',
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

class _MyGroupCard extends StatelessWidget {
  const _MyGroupCard({required this.entry});

  final MyGroupMembership entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final group = entry.group;
    final member = entry.membership;
    final position = entry.positionLabel();

    final subtitleParts = <String>[
      member.groupRole.label,
      if (position != null) position,
      if (group.memberCount > 0) '${group.memberCount} members',
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
                  backgroundColor: member.isLeader
                      ? theme.colorScheme.secondaryContainer
                      : theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.groups_rounded,
                    color: member.isLeader
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
                  label: 'View Members',
                  icon: Icons.people_outline,
                  onPressed: () =>
                      context.push(Routes.groupMembersPath(group.groupId)),
                ),
                if (member.isLeader) ...[
                  AppButton.secondary(
                    label: 'Manage Members',
                    icon: Icons.person_add_outlined,
                    onPressed: () => context
                        .push(Routes.addGroupMembersPath(group.groupId)),
                  ),
                  AppButton.primary(
                    label: 'Send Alert',
                    icon: Icons.campaign_outlined,
                    onPressed: () => context.push(
                      Routes.composeReminderForGroupPath(group.groupId),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
