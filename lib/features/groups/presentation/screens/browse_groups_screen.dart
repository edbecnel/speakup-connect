import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
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

  Future<void> _requestJoin(GroupBrowseEntry entry) async {
    if (entry.status != GroupBrowseStatus.canRequestJoin) return;

    final groupId = entry.group.groupId;
    final groupName = entry.group.name;
    final message = await showDialog<String>(
      context: context,
      builder: (_) => _JoinRequestDialog(groupName: groupName),
    );
    if (message == null || !mounted) return;

    final l10n = context.l10n;
    final ok = await ref
        .read(groupMembershipActionsProvider.notifier)
        .submitJoinRequest(
          groupId: groupId,
          message: message,
        );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.groupsJoinRequestSubmitted)),
      );
    } else {
      final err = ref.read(groupMembershipActionsProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.groupsCouldNotSubmitJoin('$err'))),
      );
    }
  }

  Future<void> _cancelJoinRequest(String groupId) async {
    final l10n = context.l10n;
    final ok = await ref
        .read(groupMembershipActionsProvider.notifier)
        .withdrawJoinRequest(groupId: groupId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? l10n.groupsRequestCancelled : l10n.groupsCouldNotCancelRequest,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final entriesAsync = ref.watch(groupBrowseEntriesProvider);
    final isBusy = ref.watch(groupMembershipActionsProvider).isLoading;
    final query = _filter.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsBrowseGroups),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: AppTextField(
              controller: _searchController,
              label: l10n.commonSearch,
              hint: l10n.groupsSearchClubHint,
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
                      l10n.groupsNoSearchResults,
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
                          _requestJoin(entry),
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

  String _statusLabel(BuildContext context) {
    final l10n = context.l10n;
    return switch (entry.status) {
      GroupBrowseStatus.member => l10n.groupsStatusMember,
      GroupBrowseStatus.joinPending => l10n.groupsStatusPending,
      GroupBrowseStatus.canRequestJoin => l10n.groupsStatusOpenToRequests,
      GroupBrowseStatus.invitationOnly => l10n.groupsStatusInvitationOnly,
    };
  }

  Color _chipColor(ThemeData theme) => switch (entry.status) {
        GroupBrowseStatus.member => theme.colorScheme.primaryContainer,
        GroupBrowseStatus.joinPending => theme.colorScheme.tertiaryContainer,
        GroupBrowseStatus.canRequestJoin => theme.colorScheme.secondaryContainer,
        GroupBrowseStatus.invitationOnly =>
          theme.colorScheme.surfaceContainerHighest,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                    _statusLabel(context),
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
                label: l10n.groupsRequestToJoin,
                icon: Icons.person_add_alt_1_outlined,
                isLoading: isBusy,
                onPressed: isBusy ? null : onRequestJoin,
              )
            else if (entry.status == GroupBrowseStatus.joinPending)
              AppButton.secondary(
                label: l10n.groupsCancelRequest,
                isLoading: isBusy,
                onPressed: isBusy ? null : onCancelRequest,
              )
            else if (entry.status == GroupBrowseStatus.invitationOnly)
              Text(
                l10n.groupsInvitationOnlyMessage,
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
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.groupsJoinRequestTitle(widget.groupName)),
      content: AppTextField(
        controller: _controller,
        label: l10n.groupsJoinMessageLabel,
        hint: l10n.groupsJoinMessageHint,
        maxLength: 200,
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(l10n.commonSubmit),
        ),
      ],
    );
  }
}
