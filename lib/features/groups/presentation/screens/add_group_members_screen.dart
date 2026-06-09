import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_member_entity.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/features/organization/domain/entities/user_profile_entity.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';
import 'package:speakup_connect/shared/widgets/app_text_field.dart';

/// Full-screen picker to add one or more org members to a group roster.
class AddGroupMembersScreen extends ConsumerStatefulWidget {
  const AddGroupMembersScreen({required this.groupId, super.key});

  final String groupId;

  @override
  ConsumerState<AddGroupMembersScreen> createState() =>
      _AddGroupMembersScreenState();
}

class _AddGroupMembersScreenState extends ConsumerState<AddGroupMembersScreen> {
  final _searchController = TextEditingController();
  final _selectedIds = <String>{};
  String _filter = '';
  GroupRole _role = GroupRole.member;
  String? _positionRoleId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usersAsync = ref.watch(approvedOrgUsersProvider);
    final membersAsync = ref.watch(groupMembersProvider(widget.groupId));
    final groupAsync = ref.watch(groupByIdProvider(widget.groupId));
    final isLoading = ref.watch(groupMemberActionsProvider).isLoading;
    final positionRoles = groupAsync.asData?.value?.positionRoles ?? const [];
    final hasPositions = positionRoles.isNotEmpty;

    final existingIds =
        membersAsync.asData?.value.map((m) => m.userId).toSet() ?? {};

    ref.listen(groupMemberActionsProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading && mounted) {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not add members: ${next.error}'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      }
    });

    final hasSelection = _selectedIds.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Add Members'),
        actions: [
          if (hasSelection)
            TextButton(
              onPressed: isLoading ? null : _addSelected,
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Add (${_selectedIds.length})'),
            ),
        ],
      ),
      body: usersAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (users) {
          final available =
              users.where((u) => !existingIds.contains(u.userId)).toList();
          final filtered = _filter.isEmpty
              ? available
              : available
                  .where(
                    (u) =>
                        u.displayName.toLowerCase().contains(_filter) ||
                        (u.studentId?.toLowerCase().contains(_filter) ??
                            false) ||
                        (u.email?.toLowerCase().contains(_filter) ?? false),
                  )
                  .toList();
          final allSelected = filtered.isNotEmpty &&
              filtered.every((u) => _selectedIds.contains(u.userId));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      controller: _searchController,
                      label: 'Search members',
                      hint: 'Name, email, or school ID',
                      prefixIcon: Icons.search,
                      onChanged: (v) =>
                          setState(() => _filter = v.toLowerCase()),
                    ),
                    if (filtered.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () => setState(() {
                                    if (allSelected) {
                                      _selectedIds.removeAll(
                                        filtered.map((u) => u.userId),
                                      );
                                    } else {
                                      _selectedIds.addAll(
                                        filtered.map((u) => u.userId),
                                      );
                                    }
                                  }),
                          child: Text(allSelected ? 'Clear all' : 'Select all'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            available.isEmpty
                                ? 'All approved members are already in this group.'
                                : 'No users match your search.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 4),
                        itemBuilder: (_, i) {
                          final user = filtered[i];
                          return _UserSelectTile(
                            user: user,
                            selected: _selectedIds.contains(user.userId),
                            enabled: !isLoading,
                            onChanged: (selected) {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                if (selected) {
                                  _selectedIds.add(user.userId);
                                } else {
                                  _selectedIds.remove(user.userId);
                                }
                              });
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Material(
          elevation: 8,
          color: theme.colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Role for selected members',
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                SegmentedButton<GroupRole>(
                  segments: GroupRole.values
                      .map(
                        (r) => ButtonSegment(
                          value: r,
                          label: Text(r.label),
                          icon: Icon(
                            r == GroupRole.leader
                                ? Icons.star_outline
                                : Icons.person_outline,
                          ),
                        ),
                      )
                      .toList(),
                  selected: {_role},
                  onSelectionChanged: isLoading
                      ? null
                      : (selected) {
                          setState(() => _role = selected.first);
                        },
                ),
                if (hasPositions) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    value: _positionRoleId,
                    decoration: const InputDecoration(
                      labelText: 'Club position (optional)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('No position'),
                      ),
                      ...positionRoles.map(
                        (r) => DropdownMenuItem<String?>(
                          value: r.id,
                          child: Text(r.label),
                        ),
                      ),
                    ],
                    onChanged: isLoading
                        ? null
                        : (v) => setState(() => _positionRoleId = v),
                  ),
                ],
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed:
                      hasSelection && !isLoading ? _addSelected : null,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.group_add_outlined),
                  label: Text(
                    hasSelection
                        ? 'Add ${_selectedIds.length} member'
                            '${_selectedIds.length == 1 ? '' : 's'}'
                        : 'Select members above',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addSelected() async {
    final usersAsync = ref.read(approvedOrgUsersProvider);
    final users = usersAsync.asData?.value;
    if (users == null || _selectedIds.isEmpty) return;

    final toAdd = users.where((u) => _selectedIds.contains(u.userId)).toList();
    final added = await ref
        .read(groupMemberActionsProvider.notifier)
        .addMembers(
          groupId: widget.groupId,
          users: toAdd,
          groupRole: _role,
          positionRoleId: _positionRoleId,
        );

    if (!mounted) return;

    if (added > 0) {
      final skipped = toAdd.length - added;
      final message = skipped > 0
          ? 'Added $added member(s); $skipped could not be added'
          : 'Added $added member${added == 1 ? '' : 's'}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      context.pop();
    }
  }
}

class _UserSelectTile extends StatelessWidget {
  const _UserSelectTile({
    required this.user,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  final UserProfileEntity user;
  final bool selected;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: CheckboxListTile(
        value: selected,
        enabled: enabled,
        onChanged: enabled ? (v) => onChanged(v ?? false) : null,
        secondary: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            user.displayName.isNotEmpty
                ? user.displayName[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(user.displayName),
        subtitle: Text(
          () {
            final parts = <String>[
              if (user.studentId != null && user.studentId!.isNotEmpty)
                'ID: ${user.studentId}',
              if (user.email != null && user.email!.isNotEmpty) user.email!,
            ];
            return parts.isEmpty ? user.fullName : parts.join(' · ');
          }(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
