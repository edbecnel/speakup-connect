import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/features/groups/domain/entities/my_group_membership.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';

/// Compact My Groups summary on the home dashboard — collapsed by default.
class MyGroupsHomeSection extends ConsumerStatefulWidget {
  const MyGroupsHomeSection({super.key});

  @override
  ConsumerState<MyGroupsHomeSection> createState() =>
      _MyGroupsHomeSectionState();
}

class _MyGroupsHomeSectionState extends ConsumerState<MyGroupsHomeSection> {
  static const _previewLimit = 3;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final membershipsAsync = ref.watch(myGroupMembershipsProvider);
    final theme = Theme.of(context);

    return membershipsAsync.when(
      loading: () => _CollapsibleSectionHeader(
        expanded: _expanded,
        onToggle: () => setState(() => _expanded = !_expanded),
        onSeeAll: () => context.push(Routes.myGroups),
        seeAllLabel: 'See all',
        subtitle: null,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: LinearProgressIndicator(),
        ),
      ),
      error: (e, _) => _CollapsibleSectionHeader(
        expanded: _expanded,
        onToggle: () => setState(() => _expanded = !_expanded),
        onSeeAll: () => context.push(Routes.myGroups),
        seeAllLabel: 'See all',
        subtitle: null,
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
        final seeAllLabel = memberships.isEmpty
            ? 'View'
            : hasMore
                ? 'See all (${memberships.length})'
                : 'See all';
        final subtitle = memberships.isEmpty
            ? 'No groups yet'
            : '${memberships.length} group${memberships.length == 1 ? '' : 's'}';

        return _CollapsibleSectionHeader(
          expanded: _expanded,
          onToggle: () => setState(() => _expanded = !_expanded),
          onSeeAll: () => context.push(Routes.myGroups),
          seeAllLabel: seeAllLabel,
          subtitle: subtitle,
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

class _CollapsibleSectionHeader extends StatelessWidget {
  const _CollapsibleSectionHeader({
    required this.expanded,
    required this.onToggle,
    required this.onSeeAll,
    required this.seeAllLabel,
    required this.child,
    this.subtitle,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onSeeAll;
  final String seeAllLabel;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    expanded
                        ? Icons.expand_more_rounded
                        : Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Groups & Clubs',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!expanded && subtitle != null)
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onSeeAll,
                    child: Text(seeAllLabel),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: child,
          crossFadeState:
              expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
          sizeCurve: Curves.easeInOut,
        ),
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
