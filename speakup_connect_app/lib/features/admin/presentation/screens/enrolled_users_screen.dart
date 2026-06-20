import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/admin/presentation/l10n/admin_ui_l10n.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/organization/domain/entities/enrolled_member.dart';
import 'package:speakup_connect/features/organization/domain/entities/user_profile_entity.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/admin/presentation/widgets/reset_member_password_dialog.dart';
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
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final profile = ref.watch(userProfileProvider).value;
    final currentUser = ref.watch(currentUserProvider);
    final canManage =
        ref.watch(hasPermissionProvider(AppPermission.blockUsers)) ||
            (profile?.isAdmin ?? false);
    final canEditProfiles = profile?.isAdmin ?? false;
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
            content: Text(l10n.commonActionFailed('${next.error}')),
            backgroundColor: theme.colorScheme.error,
          ));
        } else if (next.hasValue && next.value != null) {
          setState(_selectedIds.clear);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.memberManagementUpdatedCount(next.value!),
              ),
            ),
          );
        }
      }
    });

    ref.listen(userBlockActionProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading) {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.commonActionFailed('${next.error}')),
            backgroundColor: theme.colorScheme.error,
          ));
        } else if (next.hasValue) {
          setState(_selectedIds.clear);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.memberManagementUpdated)),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 20,
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.settingsMemberManagement),
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
              child: Text(
                allSelected ? l10n.commonClearAll : l10n.commonSelectAll,
              ),
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
                        decoration: InputDecoration(
                          hintText: l10n.memberManagementSearchHint,
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
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
                                label: Text(
                                  localizedMemberStatusFilter(l10n, f),
                                ),
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
                          decoration: InputDecoration(
                            labelText: l10n.commonGrade,
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: null,
                              child: Text(l10n.commonAllGrades),
                            ),
                            ...gradeLevels.map(
                              (g) => DropdownMenuItem(
                                value: g,
                                child: Text(l10n.schoolGradesGradeChip(g)),
                              ),
                            ),
                            DropdownMenuItem(
                              value: _noGradeFilter,
                              child: Text(l10n.commonNoGradeAssigned),
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
                    canEditProfiles,
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
    bool canEditProfiles,
  ) {
    if (membersAsync.isLoading && !membersAsync.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }
    if (membersAsync.hasError && !membersAsync.hasValue) {
      return Center(
        child: Text(
          context.l10n.memberManagementLoadFailed('${membersAsync.error}'),
        ),
      );
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
          onEdit: canEditProfiles
              ? () => context.push(Routes.editMemberPath(member.userId))
              : null,
          onResetPassword: canEditProfiles && selectable
              ? () => _confirmResetPassword(member)
              : null,
        );
      },
    );
  }

  Future<void> _confirmResetPassword(EnrolledMember member) async {
    await showResetMemberPasswordDialog(
      context: context,
      ref: ref,
      userId: member.userId,
      memberName: member.user.fullName,
      studentId: member.user.studentId,
    );
  }

  Future<void> _confirmBlock(EnrolledMember member) async {
    final l10n = context.l10n;
    final reason = await _showReasonDialog(
      title: l10n.memberManagementBlockDialogTitle(member.user.fullName),
      actionLabel: l10n.commonContinue,
      required: true,
      hint: l10n.memberManagementBlockReasonHint,
    );
    if (reason == null || reason.isEmpty) return;

    final confirmed = await _showConfirmDialog(
      title: l10n.memberManagementConfirmBlockTitle,
      message: l10n.memberManagementConfirmBlockMessage(member.user.fullName),
      actionLabel: l10n.memberManagementConfirmBlockAction,
      isDestructive: true,
    );
    if (confirmed != true) return;

    await ref.read(userBlockActionProvider.notifier).block(
          targetUserId: member.userId,
          reason: reason,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.memberManagementBlocked)),
      );
    }
  }

  Future<void> _confirmUnblock(EnrolledMember member) async {
    final l10n = context.l10n;
    final confirmed = await _showConfirmDialog(
      title: l10n.memberManagementUnblock,
      message: l10n.memberManagementUnblockMessage,
      actionLabel: l10n.memberManagementUnblock,
    );
    if (confirmed != true) return;
    await ref.read(userBlockActionProvider.notifier).unblock(
          targetUserId: member.userId,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.memberManagementUnblocked)),
      );
    }
  }

  Future<void> _confirmUnenroll(List<EnrolledMember> members) async {
    if (members.isEmpty) return;
    final l10n = context.l10n;
    final reason = await _showReasonDialog(
      title: members.length == 1
          ? l10n.memberManagementUnenrollTitleOne(members.first.user.fullName)
          : l10n.memberManagementUnenrollTitleMany(members.length),
      actionLabel: l10n.memberManagementUnenroll,
      required: true,
      hint: l10n.memberManagementUnenrollHint,
      previewNames: members.map((m) => m.user.fullName).toList(),
    );
    if (reason == null || reason.isEmpty) return;

    final confirmed = await _showConfirmDialog(
      title: l10n.memberManagementConfirmUnenrollTitle,
      message: members.length == 1
          ? l10n.memberManagementConfirmUnenrollMessageOne
          : l10n.memberManagementConfirmUnenrollMessageMany(members.length),
      actionLabel: l10n.memberManagementConfirmUnenrollAction,
      isDestructive: true,
    );
    if (confirmed != true) return;

    await ref.read(userManagementActionProvider.notifier).unenrollMany(
          targetUserIds: members.map((m) => m.userId).toList(),
          reason: reason,
        );
  }

  Future<void> _confirmBulkBlock(List<EnrolledMember> members) async {
    final l10n = context.l10n;
    final active = members.where((m) => !m.user.isBlocked).toList();
    if (active.isEmpty) return;

    final reason = await _showReasonDialog(
      title: l10n.memberManagementBulkBlockTitle(active.length),
      actionLabel: l10n.memberManagementBlock,
      required: true,
      hint: l10n.memberManagementBulkBlockHint,
      previewNames: active.map((m) => m.user.fullName).toList(),
    );
    if (reason == null || reason.isEmpty) return;

    final confirmed = await _showConfirmDialog(
      title: l10n.memberManagementConfirmBlockTitle,
      message: l10n.memberManagementBulkBlockConfirmMessage(active.length),
      actionLabel: l10n.memberManagementConfirmBlockAction,
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

    final l10n = context.l10n;
    final confirmed = await _showConfirmDialog(
      title: l10n.memberManagementBulkUnblockTitle(blocked.length),
      message: l10n.memberManagementBulkUnblockMessage,
      actionLabel: l10n.memberManagementConfirmUnblockAction,
    );
    if (confirmed != true) return;

    await ref.read(userManagementActionProvider.notifier).unblockMany(
          targetUserIds: blocked.map((m) => m.userId).toList(),
        );
  }

  Future<void> _confirmReEnroll(List<EnrolledMember> members) async {
    final unenrolled = members.where((m) => m.user.isUnenrolled).toList();
    if (unenrolled.isEmpty) return;

    final l10n = context.l10n;
    final confirmed = await _showConfirmDialog(
      title: unenrolled.length == 1
          ? l10n.memberManagementReenrollTitleOne(
              unenrolled.first.user.fullName,
            )
          : l10n.memberManagementReenrollTitleMany(unenrolled.length),
      message: unenrolled.length == 1
          ? l10n.memberManagementReenrollMessageOne
          : l10n.memberManagementReenrollMessageMany(unenrolled.length),
      actionLabel: l10n.memberManagementConfirmReenrollAction,
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
    final l10n = context.l10n;
    if (_query.isNotEmpty || _gradeFilter != null) {
      return l10n.memberManagementEmptyFiltered;
    }
    return switch (_statusFilter) {
      MemberStatusFilter.active => l10n.memberManagementEmptyActive,
      MemberStatusFilter.blocked => l10n.memberManagementEmptyBlocked,
      MemberStatusFilter.unenrolled => l10n.memberManagementEmptyUnenrolled,
      MemberStatusFilter.all => l10n.memberManagementEmptyFiltered,
    };
  }

  Future<void> _confirmAssignGrade(List<EnrolledMember> members) async {
    if (members.isEmpty) return;
    final l10n = context.l10n;

    final grade = await _showGradePickerDialog(
      title: members.length == 1
          ? l10n.memberManagementAssignGradeDialogTitle(
              members.first.user.fullName,
            )
          : l10n.memberManagementAssignGradeDialogTitle(
              '${members.length} members',
            ),
      previewNames: members.map((m) => m.user.fullName).toList(),
      initialGrade: _initialGradeForMembers(members),
    );
    if (grade == null) return;

    final confirmed = await _showConfirmDialog(
      title: l10n.memberManagementConfirmGradeTitle,
      message: members.length == 1
          ? l10n.memberManagementConfirmGradeOne(
              members.first.user.fullName,
              grade,
            )
          : l10n.memberManagementConfirmGradeMany(members.length, grade),
      actionLabel: l10n.commonConfirm,
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
    final l10n = context.l10n;
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
                  decoration: InputDecoration(
                    labelText: l10n.commonGradeLevel,
                    border: const OutlineInputBorder(),
                  ),
                  items: gradeLevels
                      .map(
                        (g) => DropdownMenuItem(
                          value: g,
                          child: Text(l10n.schoolGradesGradeChip(g)),
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
                  child: Text(l10n.commonCancel),
                ),
                FilledButton(
                  onPressed: selectedGrade == null
                      ? null
                      : () => Navigator.of(ctx).pop(selectedGrade),
                  child: Text(l10n.commonContinue),
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
    final l10n = context.l10n;
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
                  labelText: required
                      ? l10n.commonReasonOptional
                      : l10n.commonNoteOptional,
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
                child: Text(l10n.commonCancel),
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
    final l10n = context.l10n;
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
                child: Text(l10n.commonCancel),
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
    final l10n = context.l10n;
    const max = 5;
    if (names.length <= max) return names.join('\n');
    final shown = names.take(max).join('\n');
    return '$shown\n${l10n.memberManagementPreviewAndMore(names.length - max)}';
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
    final l10n = context.l10n;
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
          child: Text(l10n.memberManagementReenroll),
        ),
      if (statusFilter == MemberStatusFilter.blocked ||
          (statusFilter == MemberStatusFilter.all && blocked.isNotEmpty)) ...[
        TextButton(
          onPressed:
              busy || blocked.isEmpty ? null : () => onUnblock(blocked),
          child: Text(l10n.memberManagementUnblock),
        ),
        TextButton(
          onPressed:
              busy || blocked.isEmpty ? null : () => onUnenroll(blocked),
          child: Text(l10n.memberManagementUnenroll),
        ),
      ],
      if (supportsGrades &&
          (statusFilter == MemberStatusFilter.active ||
              (statusFilter == MemberStatusFilter.all &&
                  active.isNotEmpty))) ...[
        TextButton(
          onPressed:
              busy || active.isEmpty ? null : () => onAssignGrade(active),
          child: Text(l10n.memberManagementAssignGrade),
        ),
        TextButton(
          onPressed:
              busy || active.isEmpty ? null : () => onUnenroll(active),
          child: Text(l10n.memberManagementUnenroll),
        ),
        TextButton(
          onPressed: busy || active.isEmpty ? null : () => onBlock(active),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
          ),
          child: Text(l10n.memberManagementBlock),
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
              l10n.memberManagementSelectedCount(selected.length),
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
    this.onEdit,
    this.onResetPassword,
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
  final VoidCallback? onEdit;
  final VoidCallback? onResetPassword;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final user = member.user;
    final gradeLabel = member.gradeLevel != null
        ? l10n.schoolGradesGradeChip(member.gradeLevel!)
        : l10n.commonNoGradeAssigned;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: selectable && !busy && onEdit != null ? onEdit : null,
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
                  ? '$gradeLabel · ${localizedMemberManagementStatus(l10n, user)}'
                  : localizedMemberManagementStatus(l10n, user),
            ),
            if (user.email != null) Text(user.email!),
            if (user.studentId != null)
              Text('${l10n.commonIdLabel}: ${user.studentId}'),
            if (user.isBlocked && user.blockReason != null)
              Text(
                l10n.memberManagementBlockReasonLabel(user.blockReason!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            if (user.isUnenrolled && user.unenrollReason != null)
              Text(
                l10n.memberManagementUnenrollReasonLabel(user.unenrollReason!),
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
                    case 'edit':
                      onEdit?.call();
                    case 'resetPassword':
                      onResetPassword?.call();
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
                    return [
                      if (onEdit != null)
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(l10n.memberManagementEditProfile),
                        ),
                      if (onResetPassword != null)
                        PopupMenuItem(
                          value: 'resetPassword',
                          child: Text(l10n.memberManagementResetPassword),
                        ),
                      PopupMenuItem(
                        value: 'reEnroll',
                        child: Text(l10n.memberManagementReenroll),
                      ),
                    ];
                  }
                  return [
                    if (onEdit != null)
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(l10n.memberManagementEditProfile),
                      ),
                    if (onResetPassword != null)
                      PopupMenuItem(
                        value: 'resetPassword',
                        child: Text(l10n.memberManagementResetPassword),
                      ),
                    if (!user.isBlocked) ...[
                      if (onAssignGrade != null)
                        PopupMenuItem(
                          value: 'grade',
                          child: Text(l10n.memberManagementAssignGrade),
                        ),
                      PopupMenuItem(
                        value: 'unenroll',
                        child: Text(l10n.memberManagementUnenroll),
                      ),
                      PopupMenuItem(
                        value: 'block',
                        child: Text(l10n.memberManagementBlock),
                      ),
                    ] else ...[
                      PopupMenuItem(
                        value: 'unblock',
                        child: Text(l10n.memberManagementUnblock),
                      ),
                      PopupMenuItem(
                        value: 'unenroll',
                        child: Text(l10n.memberManagementUnenroll),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          context.l10n.memberManagementNoAccess,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
