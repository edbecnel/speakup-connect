import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_membership_provider.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';
import 'package:speakup_connect/shared/widgets/app_text_field.dart';

/// Discover org groups and request to join open clubs.
class BrowseGroupsScreen extends ConsumerStatefulWidget {
  const BrowseGroupsScreen({super.key});

  @override
  ConsumerState<BrowseGroupsScreen> createState() => _BrowseGroupsScreenState();
}

class _BrowseGroupsScreenState extends ConsumerState<BrowseGroupsScreen> {
  final _searchController = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _requestJoin(String groupId, String groupName) async {
    final message = await showDialog<String>(
      context: context,
      builder: (_) => _JoinRequestDialog(groupName: groupName),
    );
    if (message == null || !mounted) return;

    final ok = await ref
        .read(groupMembershipActionsProvider.notifier)
        .submitJoinRequest(
          groupId: groupId,
          message: message,
        );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Join request submitted')),
      );
    } else {
      final err = ref.read(groupMembershipActionsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not submit: $err')),
      );
    }
  }

  Future<void> _cancelJoinRequest(String groupId) async {
    final ok = await ref
        .read(groupMembershipActionsProvider.notifier)
        .withdrawJoinRequest(groupId: groupId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Request cancelled' : 'Could not cancel request'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entriesAsync = ref.watch(groupBrowseEntriesProvider);
    final isBusy = ref.watch(groupMembershipActionsProvider).isLoading;
    final query = _filter.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Groups & Clubs'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: AppTextField(
              controller: _searchController,
              label: 'Search',
              hint: 'Club or program name',
              prefixIcon: Icons.search,
              onChanged: (v) => setState(() => _filter = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: entriesAsync.when(
              loading: () => const AppLoadingIndicator(),
              error: (e, _) => AppErrorWidget(message: e.toString()),
              data: (entries) {
                final filtered = query.isEmpty
                    ? entries
                    : entries
                        .where((e) => e.group.name.toLowerCase().contains(query))
                        .toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No groups match your search.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final entry = filtered[i];
                    return _BrowseGroupCard(
                      entry: entry,
                      isBusy: isBusy,
                      onRequestJoin: () =>
                          _requestJoin(entry.group.groupId, entry.group.name),
                      onCancelRequest: () =>
                          _cancelJoinRequest(entry.group.groupId),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BrowseGroupCard extends StatelessWidget {
  const _BrowseGroupCard({
    required this.entry,
    required this.isBusy,
    required this.onRequestJoin,
    required this.onCancelRequest,
  });

  final GroupBrowseEntry entry;
  final bool isBusy;
  final VoidCallback onRequestJoin;
  final VoidCallback onCancelRequest;

  String _statusLabel() => switch (entry.status) {
        GroupBrowseStatus.member => 'Member',
        GroupBrowseStatus.joinPending => 'Pending',
        GroupBrowseStatus.canRequestJoin => 'Open to requests',
        GroupBrowseStatus.invitationOnly => 'Invitation only',
      };

  Color _chipColor(ThemeData theme) => switch (entry.status) {
        GroupBrowseStatus.member => theme.colorScheme.primaryContainer,
        GroupBrowseStatus.joinPending => theme.colorScheme.tertiaryContainer,
        GroupBrowseStatus.canRequestJoin => theme.colorScheme.secondaryContainer,
        GroupBrowseStatus.invitationOnly =>
          theme.colorScheme.surfaceContainerHighest,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final group = entry.group;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    _statusLabel(),
                    style: theme.textTheme.labelSmall,
                  ),
                  backgroundColor: _chipColor(theme),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if (group.description != null &&
                group.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(group.description!),
            ],
            if (group.allowJoinRequests &&
                group.joinRequestHint != null &&
                group.joinRequestHint!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                group.joinRequestHint!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (entry.status == GroupBrowseStatus.canRequestJoin)
              AppButton.primary(
                label: 'Request to Join',
                icon: Icons.person_add_alt_1_outlined,
                isLoading: isBusy,
                onPressed: isBusy ? null : onRequestJoin,
              )
            else if (entry.status == GroupBrowseStatus.joinPending)
              AppButton.secondary(
                label: 'Cancel Request',
                isLoading: isBusy,
                onPressed: isBusy ? null : onCancelRequest,
              )
            else if (entry.status == GroupBrowseStatus.invitationOnly)
              Text(
                'Membership by invitation only. Contact your adviser.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _JoinRequestDialog extends StatefulWidget {
  const _JoinRequestDialog({required this.groupName});

  final String groupName;

  @override
  State<_JoinRequestDialog> createState() => _JoinRequestDialogState();
}

class _JoinRequestDialogState extends State<_JoinRequestDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Request to join ${widget.groupName}'),
      content: AppTextField(
        controller: _controller,
        label: 'Message (optional)',
        hint: 'Tell the leader why you want to join',
        maxLength: 200,
        maxLines: 3,
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
