import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/organization/domain/entities/enrolled_member.dart';
import 'package:speakup_connect/features/organization/domain/entities/user_profile_entity.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';

/// Grade filter sentinel for members without a resolved grade level.
const _noGradeFilter = -1;

/// Lists members with filters for active, blocked, and unenrolled status.
class EnrolledUsersScreen extends ConsumerStatefulWidget {
  const EnrolledUsersScreen({super.key});

  @override
  ConsumerState<EnrolledUsersScreen> createState() =>
      _EnrolledUsersScreenState();
}

class _EnrolledUsersScreenState extends ConsumerState<EnrolledUsersScreen> {
  final _searchController = TextEditingController();
  final _selectedIds = <String>{};
  String _query = '';
  int? _gradeFilter;
  MemberStatusFilter _statusFilter = MemberStatusFilter.active;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(userProfileProvider).value;
    final currentUser = ref.watch(currentUserProvider);
    final canManage =
        ref.watch(hasPermissionProvider(AppPermission.blockUsers)) ||
            (profile?.isAdmin ?? false);
    final membersAsync = ref.watch(managedUsersProvider);
    final members = ref.watch(managedMembersProvider);
    final filtered = _filterMembers(members);
    final selectable =
        filtered.where((m) => _isSelectable(m, currentUser?.uid)).toList();
    final allSelected = selectable.isNotEmpty &&
        selectable.every((m) => _selectedIds.contains(m.userId));
    final busy = ref.watch(userManagementActionProvider).isLoading ||
        ref.watch(userBlockActionProvider).isLoading;
    final supportsGrades = ref.watch(orgSupportsStudentGradesProvider);
    final gradeLevels = ref.watch(orgGradeLevelsProvider);

    ref.listen(userManagementActionProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading) {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Action failed: ${next.error}'),
            backgroundColor: theme.colorScheme.error,
          ));
        } else if (next.hasValue && next.value != null) {
          setState(_selectedIds.clear);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Updated ${next.value} member(s)')),
          );
        }
      }
    });

    ref.listen(userBlockActionProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading) {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Action failed: ${next.error}'),
            backgroundColor: theme.colorScheme.error,
          ));
        } else if (next.hasValue) {
          setState(_selectedIds.clear);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Member updated')),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Member Management'),
        actions: [
          if (canManage && selectable.isNotEmpty)
            TextButton(
              onPressed: busy
                  ? null
                  : () => setState(() {
                        if (allSelected) {
                          _selectedIds.removeAll(
                            selectable.map((m) => m.userId),
                          );
                        } else {
                          _selectedIds.addAll(
                            selectable.map((m) => m.userId),
                          );
                        }
                      }),
              child: Text(allSelected ? 'Clear all' : 'Select all'),
            ),
        ],
      ),
      body: !canManage
          ? const _NoAccessPlaceholder()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search by name or email…',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (v) =>
                            setState(() => _query = v.trim().toLowerCase()),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<MemberStatusFilter>(
                        segments: MemberStatusFilter.values
                            .map(
                              (f) => ButtonSegment(
                                value: f,
                                label: Text(f.label),
                              ),
                            )
                            .toList(),
                        selected: {_statusFilter},
                        onSelectionChanged: busy
                            ? null
                            : (selection) => setState(() {
                                  _statusFilter = selection.first;
                                  _selectedIds.clear();
                                }),
                      ),
                      if (supportsGrades) ...[
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int?>(
                          initialValue: _gradeFilter,
                          decoration: const InputDecoration(
                            labelText: 'Grade',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All grades'),
                            ),
                            ...gradeLevels.map(
                              (g) => DropdownMenuItem(
                                value: g,
                                child: Text('Grade $g'),
                              ),
                            ),
                            const DropdownMenuItem(
                              value: _noGradeFilter,
                              child: Text('No grade assigned'),
                            ),
                          ],
                          onChanged: busy
                              ? null
                              : (value) => setState(() {
                                    _gradeFilter = value;
                                    _selectedIds.clear();
                                  }),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_selectedIds.isNotEmpty)
                  _BulkActionBar(
                    selected: filtered
                        .where((m) => _selectedIds.contains(m.userId))
                        .toList(),
                    statusFilter: _statusFilter,
                    supportsGrades: supportsGrades,
                    busy: busy,
                    onAssignGrade: _confirmAssignGrade,
                    onBlock: _confirmBulkBlock,
                    onUnenroll: _confirmBulkUnenroll,
                    onUnblock: _confirmBulkUnblock,
                    onReEnroll: _confirmBulkReEnroll,
                  ),
                Expanded(
                  child: _buildBody(
                    membersAsync,
                    filtered,
                    currentUser?.uid,
                    busy,
                    supportsGrades,
                  ),
                ),
              ],
            ),
    );
  }

  List<EnrolledMember> _filterMembers(List<EnrolledMember> members) {
    return members.where((m) {
      if (!_statusFilter.matches(m.user)) return false;

      if (_gradeFilter == _noGradeFilter) {
        if (m.gradeLevel != null) return false;
      } else if (_gradeFilter != null && m.gradeLevel != _gradeFilter) {
        return false;
      }

      if (_query.isEmpty) return true;
      final haystack = [
        m.user.fullName,
        m.user.displayName,
        m.user.email ?? '',
        m.user.studentId ?? '',
      ].join(' ').toLowerCase();
      return haystack.contains(_query);
    }).toList();
  }

  bool _isSelectable(EnrolledMember member, String? currentUid) {
    return member.userId != currentUid && !member.user.isAdmin;
  }

  Widget _buildBody(
    AsyncValue<List<UserProfileEntity>> membersAsync,
    List<EnrolledMember> filtered,
    String? currentUid,
    bool busy,
    bool supportsGrades,
  ) {
    if (membersAsync.isLoading && !membersAsync.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }
    if (membersAsync.hasError && !membersAsync.hasValue) {
      return Center(child: Text('Failed to load: ${membersAsync.error}'));
    }
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          _emptyStateMessage(),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (_, i) {
        final member = filtered[i];
        final selectable = _isSelectable(member, currentUid);
        return _MemberTile(
          member: member,
          selected: _selectedIds.contains(member.userId),
          selectable: selectable,
          busy: busy,
          onSelected: selectable
              ? (selected) => setState(() {
                    if (selected) {
                      _selectedIds.add(member.userId);
                    } else {
                      _selectedIds.remove(member.userId);
                    }
                  })
              : null,
          onBlock: () => _confirmBlock(member),
          onUnblock: () => _confirmUnblock(member),
          onUnenroll: () => _confirmUnenroll([member]),
          onAssignGrade: supportsGrades
              ? () => _confirmAssignGrade([member])
              : null,
          onReEnroll: () => _confirmReEnroll([member]),
        );
      },
    );
  }

  Future<void> _confirmBlock(EnrolledMember member) async {
    final reason = await _showReasonDialog(
      title: 'Block ${member.user.fullName}?',
      actionLabel: 'Continue',
      required: true,
      hint: 'Why is this account being blocked?',
    );
    if (reason == null || reason.isEmpty) return;

    final confirmed = await _showConfirmDialog(
      title: 'Confirm block',
      message: '${member.user.fullName} will lose access immediately.',
      actionLabel: 'Confirm block',
      isDestructive: true,
    );
    if (confirmed != true) return;

    await ref.read(userBlockActionProvider.notifier).block(
          targetUserId: member.userId,
          reason: reason,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member blocked')),
      );
    }
  }

  Future<void> _confirmUnblock(EnrolledMember member) async {
    final confirmed = await _showConfirmDialog(
      title: 'Unblock ${member.user.fullName}?',
      message: 'This member will regain access to the organization.',
      actionLabel: 'Unblock',
    );
    if (confirmed != true) return;
    await ref.read(userBlockActionProvider.notifier).unblock(
          targetUserId: member.userId,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member unblocked')),
      );
    }
  }

  Future<void> _confirmUnenroll(List<EnrolledMember> members) async {
    if (members.isEmpty) return;
    final reason = await _showReasonDialog(
      title: members.length == 1
          ? 'Unenroll ${members.first.user.fullName}?'
          : 'Unenroll ${members.length} members?',
      actionLabel: 'Unenroll',
      required: true,
      hint: 'e.g. Graduated, transferred, left the school',
      previewNames: members.map((m) => m.user.fullName).toList(),
    );
    if (reason == null || reason.isEmpty) return;

    final confirmed = await _showConfirmDialog(
      title: 'Confirm unenrollment',
      message: members.length == 1
          ? 'This member will lose access immediately.'
          : '${members.length} members will lose access immediately.',
      actionLabel: 'Confirm unenroll',
      isDestructive: true,
    );
    if (confirmed != true) return;

    await ref.read(userManagementActionProvider.notifier).unenrollMany(
          targetUserIds: members.map((m) => m.userId).toList(),
          reason: reason,
        );
  }

  Future<void> _confirmBulkBlock(List<EnrolledMember> members) async {
    final active = members.where((m) => !m.user.isBlocked).toList();
    if (active.isEmpty) return;

    final reason = await _showReasonDialog(
      title: 'Block ${active.length} members?',
      actionLabel: 'Block',
      required: true,
      hint: 'Why are these accounts being blocked?',
      previewNames: active.map((m) => m.user.fullName).toList(),
    );
    if (reason == null || reason.isEmpty) return;

    final confirmed = await _showConfirmDialog(
      title: 'Confirm block',
      message: '${active.length} member(s) will lose access immediately.',
      actionLabel: 'Confirm block',
      isDestructive: true,
    );
    if (confirmed != true) return;

    await ref.read(userManagementActionProvider.notifier).blockMany(
          targetUserIds: active.map((m) => m.userId).toList(),
          reason: reason,
        );
  }

  Future<void> _confirmBulkUnenroll(List<EnrolledMember> members) async {
    await _confirmUnenroll(members);
  }

  Future<void> _confirmBulkUnblock(List<EnrolledMember> members) async {
    final blocked =
        members.where((m) => m.user.isApproved && m.user.isBlocked).toList();
    if (blocked.isEmpty) return;

    final confirmed = await _showConfirmDialog(
      title: 'Unblock ${blocked.length} members?',
      message: 'These members will regain access to the organization.',
      actionLabel: 'Confirm unblock',
    );
    if (confirmed != true) return;

    await ref.read(userManagementActionProvider.notifier).unblockMany(
          targetUserIds: blocked.map((m) => m.userId).toList(),
        );
  }

  Future<void> _confirmReEnroll(List<EnrolledMember> members) async {
    final unenrolled = members.where((m) => m.user.isUnenrolled).toList();
    if (unenrolled.isEmpty) return;

    final confirmed = await _showConfirmDialog(
      title: unenrolled.length == 1
          ? 'Re-enroll ${unenrolled.first.user.fullName}?'
          : 'Re-enroll ${unenrolled.length} members?',
      message: unenrolled.length == 1
          ? 'This member will regain full access to the organization.'
          : '${unenrolled.length} members will regain full access.',
      actionLabel: 'Confirm re-enroll',
    );
    if (confirmed != true) return;

    await ref.read(userManagementActionProvider.notifier).reEnrollMany(
          targetUserIds: unenrolled.map((m) => m.userId).toList(),
        );
  }

  Future<void> _confirmBulkReEnroll(List<EnrolledMember> members) async {
    await _confirmReEnroll(members);
  }

  String _emptyStateMessage() {
    if (_query.isNotEmpty || _gradeFilter != null) {
      return 'No members match your filters.';
    }
    return switch (_statusFilter) {
      MemberStatusFilter.active => 'No active members found.',
      MemberStatusFilter.blocked => 'No blocked members found.',
      MemberStatusFilter.unenrolled => 'No unenrolled members found.',
      MemberStatusFilter.all => 'No members found.',
    };
  }

  Future<void> _confirmAssignGrade(List<EnrolledMember> members) async {
    if (members.isEmpty) return;

    final grade = await _showGradePickerDialog(
      title: members.length == 1
          ? 'Assign grade to ${members.first.user.fullName}'
          : 'Assign grade to ${members.length} members',
      previewNames: members.map((m) => m.user.fullName).toList(),
      initialGrade: _initialGradeForMembers(members),
    );
    if (grade == null) return;

    final confirmed = await _showConfirmDialog(
      title: 'Confirm grade assignment',
      message: members.length == 1
          ? 'Set ${members.first.user.fullName} to Grade $grade?'
          : 'Set ${members.length} members to Grade $grade?',
      actionLabel: 'Confirm',
    );
    if (confirmed != true) return;

    await ref.read(userManagementActionProvider.notifier).assignGradesToMembers(
          members: members,
          gradeLevel: grade,
        );
  }

  int? _initialGradeForMembers(List<EnrolledMember> members) {
    if (members.isEmpty) return null;
    if (members.length == 1) return members.first.gradeLevel;
    final assigned = members.map((m) => m.gradeLevel).whereType<int>().toSet();
    return assigned.length == 1 ? assigned.first : null;
  }

  Widget _scrollableDialogContent(BuildContext ctx, Widget child) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(ctx).height * 0.55,
      ),
      child: SingleChildScrollView(child: child),
    );
  }

  Future<int?> _showGradePickerDialog({
    required String title,
    List<String> previewNames = const [],
    int? initialGrade,
  }) {
    final gradeLevels = ref.read(orgGradeLevelsProvider);
    int? selectedGrade = initialGrade != null && gradeLevels.contains(initialGrade)
        ? initialGrade
        : (gradeLevels.isNotEmpty ? gradeLevels.first : null);

    return showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(title),
          content: _scrollableDialogContent(
            ctx,
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (previewNames.isNotEmpty) ...[
                  Text(_previewLabel(previewNames)),
                  const SizedBox(height: 12),
                ],
                DropdownButtonFormField<int>(
                  initialValue: selectedGrade,
                  decoration: const InputDecoration(
                    labelText: 'Grade level',
                    border: OutlineInputBorder(),
                  ),
                  items: gradeLevels
                      .map(
                        (g) => DropdownMenuItem(
                          value: g,
                          child: Text('Grade $g'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedGrade = v),
                ),
              ],
            ),
          ),
          actions: [
            OverflowBar(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: selectedGrade == null
                      ? null
                      : () => Navigator.of(ctx).pop(selectedGrade),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _showReasonDialog({
    required String title,
    required String actionLabel,
    required bool required,
    required String hint,
    List<String> previewNames = const [],
  }) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: _scrollableDialogContent(
          ctx,
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (previewNames.isNotEmpty) ...[
                Text(_previewLabel(previewNames)),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: ctrl,
                autofocus: true,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: required ? 'Reason (required)' : 'Note (optional)',
                  hintText: hint,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          OverflowBar(
            spacing: 8,
            children: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final text = ctrl.text.trim();
                  if (required && text.isEmpty) return;
                  Navigator.of(ctx).pop(text);
                },
                child: Text(actionLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String actionLabel,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: _scrollableDialogContent(ctx, Text(message)),
        actions: [
          OverflowBar(
            spacing: 8,
            children: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: isDestructive
                    ? FilledButton.styleFrom(
                        backgroundColor: Theme.of(ctx).colorScheme.error,
                        foregroundColor: Theme.of(ctx).colorScheme.onError,
                      )
                    : null,
                child: Text(actionLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _previewLabel(List<String> names) {
    const max = 5;
    if (names.length <= max) return names.join('\n');
    final shown = names.take(max).join('\n');
    return '$shown\n…and ${names.length - max} more';
  }
}

class _BulkActionBar extends StatelessWidget {
  const _BulkActionBar({
    required this.selected,
    required this.statusFilter,
    required this.supportsGrades,
    required this.busy,
    required this.onAssignGrade,
    required this.onBlock,
    required this.onUnenroll,
    required this.onUnblock,
    required this.onReEnroll,
  });

  final List<EnrolledMember> selected;
  final MemberStatusFilter statusFilter;
  final bool supportsGrades;
  final bool busy;
  final Future<void> Function(List<EnrolledMember>) onAssignGrade;
  final Future<void> Function(List<EnrolledMember>) onBlock;
  final Future<void> Function(List<EnrolledMember>) onUnenroll;
  final Future<void> Function(List<EnrolledMember>) onUnblock;
  final Future<void> Function(List<EnrolledMember>) onReEnroll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = selected
        .where((m) => m.user.isApproved && !m.user.isBlocked)
        .toList();
    final blocked =
        selected.where((m) => m.user.isApproved && m.user.isBlocked).toList();
    final unenrolled = selected.where((m) => m.user.isUnenrolled).toList();

    final actions = <Widget>[
      if (statusFilter == MemberStatusFilter.unenrolled ||
          (statusFilter == MemberStatusFilter.all && unenrolled.isNotEmpty))
        TextButton(
          onPressed: busy || unenrolled.isEmpty
              ? null
              : () => onReEnroll(unenrolled),
          child: const Text('Re-enroll'),
        ),
      if (statusFilter == MemberStatusFilter.blocked ||
          (statusFilter == MemberStatusFilter.all && blocked.isNotEmpty)) ...[
        TextButton(
          onPressed:
              busy || blocked.isEmpty ? null : () => onUnblock(blocked),
          child: const Text('Unblock'),
        ),
        TextButton(
          onPressed:
              busy || blocked.isEmpty ? null : () => onUnenroll(blocked),
          child: const Text('Unenroll'),
        ),
      ],
      if (supportsGrades &&
          (statusFilter == MemberStatusFilter.active ||
              (statusFilter == MemberStatusFilter.all &&
                  active.isNotEmpty))) ...[
        TextButton(
          onPressed:
              busy || active.isEmpty ? null : () => onAssignGrade(active),
          child: const Text('Assign grade'),
        ),
        TextButton(
          onPressed:
              busy || active.isEmpty ? null : () => onUnenroll(active),
          child: const Text('Unenroll'),
        ),
        TextButton(
          onPressed: busy || active.isEmpty ? null : () => onBlock(active),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
          ),
          child: const Text('Block'),
        ),
      ],
    ];

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${selected.length} selected',
              style: theme.textTheme.titleSmall,
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.end,
                children: actions,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.selected,
    required this.selectable,
    required this.busy,
    required this.onSelected,
    required this.onBlock,
    required this.onUnblock,
    required this.onUnenroll,
    this.onAssignGrade,
    required this.onReEnroll,
  });

  final EnrolledMember member;
  final bool selected;
  final bool selectable;
  final bool busy;
  final ValueChanged<bool>? onSelected;
  final VoidCallback onBlock;
  final VoidCallback onUnblock;
  final VoidCallback onUnenroll;
  final VoidCallback? onAssignGrade;
  final VoidCallback onReEnroll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = member.user;
    final gradeLabel = member.gradeLevel != null
        ? 'Grade ${member.gradeLevel}'
        : 'No grade';

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: selectable
            ? Checkbox(
                value: selected,
                onChanged: busy ? null : (v) => onSelected?.call(v ?? false),
              )
            : CircleAvatar(
                child: Text(
                  user.fullName.isNotEmpty
                      ? user.fullName[0].toUpperCase()
                      : '?',
                ),
              ),
        title: Text(
          user.fullName.isNotEmpty ? user.fullName : user.displayName,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              onAssignGrade != null
                  ? '$gradeLabel · ${user.managementStatusLabel}'
                  : user.managementStatusLabel,
            ),
            if (user.email != null) Text(user.email!),
            if (user.studentId != null) Text('ID: ${user.studentId}'),
            if (user.isBlocked && user.blockReason != null)
              Text(
                'Block reason: ${user.blockReason}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            if (user.isUnenrolled && user.unenrollReason != null)
              Text(
                'Unenrolled: ${user.unenrollReason}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: selectable
            ? PopupMenuButton<String>(
                enabled: !busy,
                onSelected: (action) {
                  switch (action) {
                    case 'grade':
                      onAssignGrade?.call();
                    case 'unenroll':
                      onUnenroll();
                    case 'block':
                      onBlock();
                    case 'unblock':
                      onUnblock();
                    case 'reEnroll':
                      onReEnroll();
                  }
                },
                itemBuilder: (ctx) {
                  if (user.isUnenrolled) {
                    return const [
                      PopupMenuItem(
                        value: 'reEnroll',
                        child: Text('Re-enroll…'),
                      ),
                    ];
                  }
                  return [
                    if (!user.isBlocked) ...[
                      if (onAssignGrade != null)
                        const PopupMenuItem(
                          value: 'grade',
                          child: Text('Assign grade…'),
                        ),
                      const PopupMenuItem(
                        value: 'unenroll',
                        child: Text('Unenroll…'),
                      ),
                      const PopupMenuItem(
                        value: 'block',
                        child: Text('Block…'),
                      ),
                    ] else ...[
                      const PopupMenuItem(
                        value: 'unblock',
                        child: Text('Unblock…'),
                      ),
                      const PopupMenuItem(
                        value: 'unenroll',
                        child: Text('Unenroll…'),
                      ),
                    ],
                  ];
                },
              )
            : null,
      ),
    );
  }
}

class _NoAccessPlaceholder extends StatelessWidget {
  const _NoAccessPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'You do not have permission to manage enrolled members.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
