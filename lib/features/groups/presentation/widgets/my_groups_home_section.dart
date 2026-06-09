import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/features/groups/domain/entities/my_group_membership.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';

/// Compact My Groups summary on the home dashboard.
class MyGroupsHomeSection extends ConsumerWidget {
  const MyGroupsHomeSection({super.key});

  static const _previewLimit = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipsAsync = ref.watch(myGroupMembershipsProvider);
    final theme = Theme.of(context);

    return membershipsAsync.when(
      loading: () => _SectionHeader(
        onSeeAll: () => context.push(Routes.myGroups),
        seeAllLabel: 'See all',
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: LinearProgressIndicator(),
        ),
      ),
      error: (e, _) => _SectionHeader(
        onSeeAll: () => context.push(Routes.myGroups),
        seeAllLabel: 'See all',
        child: Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Text(
            'Could not load your groups. Tap See all to retry.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
      ),
      data: (memberships) {
        final preview = memberships.take(_previewLimit).toList();
        final hasMore = memberships.length > _previewLimit;

        return _SectionHeader(
          onSeeAll: () => context.push(Routes.myGroups),
          seeAllLabel: memberships.isEmpty
              ? 'View'
              : hasMore
                  ? 'See all (${memberships.length})'
                  : 'See all',
          child: memberships.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    'You are not in any groups yet. Tap View for details.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : Column(
                  children: [
                    const SizedBox(height: 8),
                    ...preview.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _PreviewTile(entry: entry),
                        )),
                  ],
                ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.onSeeAll,
    required this.seeAllLabel,
    required this.child,
  });

  final VoidCallback onSeeAll;
  final String seeAllLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'My Groups & Clubs',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: onSeeAll,
              child: Text(seeAllLabel),
            ),
          ],
        ),
        child,
      ],
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({required this.entry});

  final MyGroupMembership entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final position = entry.positionLabel();
    final subtitle = [
      if (position != null) position,
      entry.membership.groupRole.label,
    ].join(' · ');

    return Card(
      child: ListTile(
        leading: Icon(
          Icons.groups_outlined,
          color: theme.colorScheme.primary,
        ),
        title: Text(entry.group.name),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        dense: true,
        onTap: () => context.push(Routes.myGroups),
      ),
    );
  }
}
