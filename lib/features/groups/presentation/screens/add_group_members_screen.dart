import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_member_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_position_role.dart';
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
  final _searchFocus = FocusNode();
  final _selectedIds = <String>{};
  String _filter = '';
  GroupRole _role = GroupRole.member;
  String? _positionRoleId;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _selectUser(UserProfileEntity user) {
    FocusScope.of(context).unfocus();
    setState(() {
      _searchController.text = user.displayName;
      _filter = user.displayName.toLowerCase();
      _selectedIds.add(user.userId);
    });
  }

  void _toggleUser(UserProfileEntity user, bool selected) {
    FocusScope.of(context).unfocus();
    setState(() {
      if (selected) {
        _selectedIds.add(user.userId);
        _searchController.text = user.displayName;
        _filter = user.displayName.toLowerCase();
      } else {
        _selectedIds.remove(user.userId);
      }
    });
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Scrollable so search + assign panel don't overflow when the
              // keyboard is open on smaller phones.
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        label: 'Search members',
                        hint: 'Name, email, or school ID',
                        prefixIcon: Icons.search,
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: isLoading
                                    ? null
                                    : () => setState(() {
                                          _searchController.clear();
                                          _filter = '';
                                        }),
                              )
                            : null,
                        onChanged: (v) =>
                            setState(() => _filter = v.toLowerCase()),
                      ),
                      const SizedBox(height: 12),
                      _AssignPanel(
                        role: _role,
                        positionRoleId: _positionRoleId,
                        positionRoles: positionRoles,
                        hasPositions: hasPositions,
                        isLoading: isLoading,
                        hasSelection: hasSelection,
                        selectedCount: _selectedIds.length,
                        onRoleChanged: (r) => setState(() => _role = r),
                        onPositionChanged: (v) =>
                            setState(() => _positionRoleId = v),
                        onAssign: _addSelected,
                      ),
                      if (filtered.isNotEmpty)
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
                            child:
                                Text(allSelected ? 'Clear all' : 'Select all'),
                          ),
                        ),
                    ],
                  ),
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
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 4),
                        itemBuilder: (_, i) {
                          final user = filtered[i];
                          final selected =
                              _selectedIds.contains(user.userId);
                          return _UserSelectTile(
                            user: user,
                            selected: selected,
                            enabled: !isLoading,
                            onTap: () => _selectUser(user),
                            onChanged: (v) => _toggleUser(user, v),
                          );
                        },
                      ),
              ),
            ],
          );
        },
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
          ? 'Assigned $added member(s); $skipped could not be added'
          : 'Assigned $added member${added == 1 ? '' : 's'}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      context.pop();
    }
  }
}

/// Role, optional position, and primary assign action — kept above the list so
/// it stays visible when the keyboard is open.
class _AssignPanel extends StatelessWidget {
  const _AssignPanel({
    required this.role,
    required this.positionRoleId,
    required this.positionRoles,
    required this.hasPositions,
    required this.isLoading,
    required this.hasSelection,
    required this.selectedCount,
    required this.onRoleChanged,
    required this.onPositionChanged,
    required this.onAssign,
  });

  final GroupRole role;
  final String? positionRoleId;
  final List<GroupPositionRole> positionRoles;
  final bool hasPositions;
  final bool isLoading;
  final bool hasSelection;
  final int selectedCount;
  final ValueChanged<GroupRole> onRoleChanged;
  final ValueChanged<String?> onPositionChanged;
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              hasSelection
                  ? '$selectedCount selected — choose role and assign'
                  : 'Search and tap a member below',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<GroupRole>(
              isExpanded: true,
              value: role,
              decoration: const InputDecoration(
                labelText: 'Group role',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: GroupRole.values
                  .map(
                    (r) => DropdownMenuItem(
                      value: r,
                      child: Text(r.label, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              selectedItemBuilder: (context) => GroupRole.values
                  .map(
                    (r) => Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        r.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: isLoading ? null : (v) => onRoleChanged(v ?? role),
            ),
            if (hasPositions) ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<String?>(
                isExpanded: true,
                value: positionRoleId,
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
                      child: Text(r.label, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                selectedItemBuilder: (context) => [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('No position', overflow: TextOverflow.ellipsis),
                  ),
                  ...positionRoles.map(
                    (r) => Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        r.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: isLoading ? null : onPositionChanged,
              ),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: hasSelection && !isLoading ? onAssign : null,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.person_add_alt_1_outlined),
              label: Text(
                hasSelection
                    ? selectedCount == 1
                        ? 'Assign member'
                        : 'Assign $selectedCount members'
                    : 'Assign',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserSelectTile extends StatelessWidget {
  const _UserSelectTile({
    required this.user,
    required this.selected,
    required this.enabled,
    required this.onTap,
    required this.onChanged,
  });

  final UserProfileEntity user;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: selected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
          : null,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Checkbox(
                value: selected,
                onChanged: enabled ? (v) => onChanged(v ?? false) : null,
              ),
              CircleAvatar(
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    Text(
                      () {
                        final parts = <String>[
                          if (user.studentId != null &&
                              user.studentId!.isNotEmpty)
                            'ID: ${user.studentId}',
                          if (user.email != null && user.email!.isNotEmpty)
                            user.email!,
                        ];
                        return parts.isEmpty ? user.fullName : parts.join(' · ');
                      }(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
