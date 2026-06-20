import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/organization/domain/entities/roster_entry_entity.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/roster_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/features/organization/presentation/widgets/official_photo_section.dart';
import 'package:speakup_connect/shared/widgets/app_avatar.dart';

/// Sentinel for filtering roster rows without a grade.
const _noGradeFilter = -1;

/// Admin screen for viewing the student roster and assigning grades.
class RosterManagementScreen extends ConsumerStatefulWidget {
  const RosterManagementScreen({super.key});

  @override
  ConsumerState<RosterManagementScreen> createState() =>
      _RosterManagementScreenState();
}

class _RosterManagementScreenState
    extends ConsumerState<RosterManagementScreen> {
  final _searchController = TextEditingController();
  final _selectedIds = <String>{};
  String _query = '';
  int? _gradeFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _canManage {
    final profile = ref.read(userProfileProvider).value;
    return ref.read(hasPermissionProvider(AppPermission.manageClassRoster)) ||
        (profile?.isAdmin ?? false);
  }

  bool get _isOrgAdmin =>
      ref.read(userProfileProvider).value?.isAdmin ?? false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final rosterAsync = ref.watch(rosterEntriesProvider);
    final entries = ref.watch(rosterViewEntriesProvider);
    final filtered = _filterEntries(entries);
    final allSelected = filtered.isNotEmpty &&
        filtered.every((e) => _selectedIds.contains(e.studentId));
    final busy = ref.watch(rosterGradeActionProvider).isLoading;
    final supportsGrades = ref.watch(orgSupportsStudentGradesProvider);
    final gradeLevels = ref.watch(orgGradeLevelsProvider);

    ref.listen(rosterGradeActionProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading) {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              l10n.studentRosterAssignFailed('${next.error}'),
            ),
            backgroundColor: theme.colorScheme.error,
          ));
        } else if (next.hasValue && next.value != null) {
          setState(_selectedIds.clear);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.studentRosterUpdatedCount(next.value!),
              ),
            ),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.settingsStudentRoster),
        actions: [
          if (_isOrgAdmin)
            IconButton(
              tooltip: l10n.studentRosterAddStudent,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              onPressed: busy ? null : () => context.push(Routes.addStudent),
            ),
          if (_canManage && filtered.isNotEmpty)
            TextButton(
              onPressed: busy
                  ? null
                  : () => setState(() {
                        if (allSelected) {
                          _selectedIds.removeAll(
                            filtered.map((e) => e.studentId),
                          );
                        } else {
                          _selectedIds.addAll(
                            filtered.map((e) => e.studentId),
                          );
                        }
                      }),
              child: Text(
                allSelected ? l10n.commonClearAll : l10n.commonSelectAll,
              ),
            ),
        ],
      ),
      body: !supportsGrades
          ? const _NotSchoolPlaceholder()
          : !_canManage
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
                          hintText: l10n.studentRosterSearchHint,
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (v) =>
                            setState(() => _query = v.trim().toLowerCase()),
                      ),
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
                  ),
                ),
                if (_selectedIds.isNotEmpty)
                  Material(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.memberManagementSelectedCount(_selectedIds.length),
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            alignment: WrapAlignment.end,
                            children: [
                              FilledButton(
                                onPressed: busy
                                    ? null
                                    : () => _confirmAssignGrade(
                                          _selectedEntries(filtered),
                                        ),
                                child: Text(l10n.studentRosterAssignSelected),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(child: _buildList(rosterAsync, filtered, busy)),
              ],
            ),
      floatingActionButton: _isOrgAdmin
          ? FloatingActionButton.extended(
              onPressed: busy ? null : () => context.push(Routes.addStudent),
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: Text(l10n.studentRosterAddStudent),
            )
          : null,
    );
  }

  List<RosterEntryEntity> _filterEntries(List<RosterEntryEntity> entries) {
    return entries.where((e) {
      if (_gradeFilter == _noGradeFilter) {
        if (e.gradeLevel != null) return false;
      } else if (_gradeFilter != null && e.gradeLevel != _gradeFilter) {
        return false;
      }

      if (_query.isEmpty) return true;
      final haystack = [
        e.fullName,
        e.studentId,
        e.email ?? '',
      ].join(' ').toLowerCase();
      return haystack.contains(_query);
    }).toList();
  }

  Widget _buildList(
    AsyncValue<List<RosterEntryEntity>> rosterAsync,
    List<RosterEntryEntity> filtered,
    bool busy,
  ) {
    if (rosterAsync.isLoading && !rosterAsync.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }
    if (rosterAsync.hasError && !rosterAsync.hasValue) {
      return Center(
        child: Text(
          context.l10n.studentRosterLoadFailed('${rosterAsync.error}'),
        ),
      );
    }
    if (filtered.isEmpty) {
      final l10n = context.l10n;
      return Center(
        child: Text(
          _query.isEmpty && _gradeFilter == null
              ? l10n.studentRosterEmpty
              : l10n.studentRosterNoMatch,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (_, i) {
        final entry = filtered[i];
        return _RosterTile(
          entry: entry,
          selected: _selectedIds.contains(entry.studentId),
          busy: busy,
          onSelected: (selected) => setState(() {
            if (selected) {
              _selectedIds.add(entry.studentId);
            } else {
              _selectedIds.remove(entry.studentId);
            }
          }),
          onAssignGrade: () => _promptAssignGrade(entry, filtered),
          onPhotoTap: _canManage
              ? () => _showOfficialPhotoDialog(entry)
              : null,
        );
      },
    );
  }

  List<RosterEntryEntity> _selectedEntries(List<RosterEntryEntity> filtered) {
    return filtered
        .where((e) => _selectedIds.contains(e.studentId))
        .toList();
  }

  Future<void> _promptAssignGrade(
    RosterEntryEntity entry,
    List<RosterEntryEntity> filtered,
  ) async {
    final selected = _selectedEntries(filtered);
    if (selected.length <= 1) {
      await _confirmAssignGrade([entry]);
      return;
    }

    final l10n = context.l10n;
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.studentRosterAssignGradeTitle),
        content: Text(
          l10n.studentRosterAssignGradeWhichGroup(selected.length),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('one'),
            child: Text(
              entry.fullName.isNotEmpty
                  ? l10n.studentRosterOnlyNamed(entry.fullName)
                  : l10n.studentRosterOnlyThisStudent,
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop('selected'),
            child: Text(l10n.studentRosterAllSelected(selected.length)),
          ),
        ],
      ),
    );

    switch (action) {
      case 'selected':
        await _confirmAssignGrade(selected);
      case 'one':
        await _confirmAssignGrade([entry]);
      default:
        break;
    }
  }

  Future<void> _confirmAssignGrade(List<RosterEntryEntity> entries) async {
    if (entries.isEmpty) return;
    final l10n = context.l10n;

    final grade = await _showGradePickerDialog(
      title: entries.length == 1
          ? l10n.studentRosterAssignGradeToOne(entries.first.fullName)
          : l10n.studentRosterAssignGradeToMany(entries.length),
      previewNames: entries.map((e) => e.fullName).toList(),
      initialGrade: _initialGradeForEntries(entries),
    );
    if (grade == null) return;

    final confirmed = await _showConfirmDialog(
      title: l10n.studentRosterConfirmGradeTitle,
      message: entries.length == 1
          ? l10n.studentRosterConfirmGradeOne(entries.first.fullName, grade)
          : l10n.studentRosterConfirmGradeMany(entries.length, grade),
    );
    if (confirmed != true) return;

    await ref.read(rosterGradeActionProvider.notifier).assignGrades(
          gradesByStudentId: {
            for (final e in entries) e.studentId: grade,
          },
          entryDetails: {for (final e in entries) e.studentId: e},
        );
  }

  int? _initialGradeForEntries(List<RosterEntryEntity> entries) {
    if (entries.isEmpty) return null;
    if (entries.length == 1) return entries.first.gradeLevel;
    final assigned = entries.map((e) => e.gradeLevel).whereType<int>().toSet();
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
      ),
    );
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
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
                child: Text(l10n.commonConfirm),
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
    return '$shown\n${l10n.studentRosterPreviewAndMore(names.length - max)}';
  }

  Future<void> _showOfficialPhotoDialog(RosterEntryEntity entry) async {
    final l10n = context.l10n;
    final name =
        entry.fullName.isNotEmpty ? entry.fullName : entry.studentId;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.studentRosterOfficialPhotoTitle(name)),
        content: SingleChildScrollView(
          child: OfficialPhotoSection(
            displayName: name,
            officialPhotoUrl: entry.officialPhotoUrl,
            studentId: entry.studentId,
            userId: entry.registeredUserId,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonDone),
          ),
        ],
      ),
    );
  }
}

class _RosterTile extends StatelessWidget {
  const _RosterTile({
    required this.entry,
    required this.selected,
    required this.busy,
    required this.onSelected,
    required this.onAssignGrade,
    this.onPhotoTap,
  });

  final RosterEntryEntity entry;
  final bool selected;
  final bool busy;
  final ValueChanged<bool> onSelected;
  final VoidCallback onAssignGrade;
  final VoidCallback? onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final gradeLabel = entry.gradeLevel != null
        ? l10n.schoolGradesGradeChip(entry.gradeLevel!)
        : l10n.commonNoGradeAssigned;
    final statusLabel =
        entry.isRegistered ? l10n.commonRegistered : l10n.commonNotRegistered;

    final displayName =
        entry.fullName.isNotEmpty ? entry.fullName : entry.studentId;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: selected,
              onChanged: busy ? null : (v) => onSelected(v ?? false),
            ),
            InkWell(
              onTap: busy ? null : onPhotoTap,
              customBorder: const CircleBorder(),
              child: AppAvatar(
                displayName: displayName,
                officialPhotoUrl: entry.officialPhotoUrl,
                radius: 20,
              ),
            ),
          ],
        ),
        title: Text(
          entry.fullName.isNotEmpty ? entry.fullName : entry.studentId,
          style:
              theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.studentRosterGradeStatusLine(gradeLabel, statusLabel)),
            Text('${l10n.commonIdLabel}: ${entry.studentId}'),
            if (entry.section != null)
              Text(l10n.studentRosterSectionLabel(entry.section!)),
          ],
        ),
        isThreeLine: entry.section != null,
        trailing: IconButton(
          tooltip: l10n.studentRosterAssignGradeTitle,
          onPressed: busy ? null : onAssignGrade,
          icon: const Icon(Icons.school_outlined),
        ),
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
          context.l10n.studentRosterNoPermission,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _NotSchoolPlaceholder extends StatelessWidget {
  const _NotSchoolPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          context.l10n.studentRosterNotSchool,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
