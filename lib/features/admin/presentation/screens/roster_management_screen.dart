import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/organization/domain/entities/roster_entry_entity.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/roster_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';

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
            content: Text('Failed to assign grades: ${next.error}'),
            backgroundColor: theme.colorScheme.error,
          ));
        } else if (next.hasValue && next.value != null) {
          setState(_selectedIds.clear);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Updated ${next.value} student(s)')),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Student Roster'),
        actions: [
          if (_isOrgAdmin)
            IconButton(
              tooltip: 'Add student',
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
              child: Text(allSelected ? 'Clear all' : 'Select all'),
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
                        decoration: const InputDecoration(
                          hintText: 'Search by name or student ID…',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (v) =>
                            setState(() => _query = v.trim().toLowerCase()),
                      ),
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
                            '${_selectedIds.length} selected',
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
                                child: const Text('Assign grade to selected'),
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
              label: const Text('Add Student'),
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
      return Center(child: Text('Failed to load: ${rosterAsync.error}'));
    }
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          _query.isEmpty && _gradeFilter == null
              ? 'No students yet. Tap Add Student to provision an account.'
              : 'No students match your filters.',
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

    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign grade'),
        content: Text(
          '${selected.length} students are selected. Assign a grade to '
          'which group?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('one'),
            child: Text(
              entry.fullName.isNotEmpty
                  ? 'Only ${entry.fullName}'
                  : 'Only this student',
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop('selected'),
            child: Text('All ${selected.length} selected'),
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

    final grade = await _showGradePickerDialog(
      title: entries.length == 1
          ? 'Assign grade to ${entries.first.fullName}'
          : 'Assign grade to ${entries.length} students',
      previewNames: entries.map((e) => e.fullName).toList(),
      initialGrade: _initialGradeForEntries(entries),
    );
    if (grade == null) return;

    final confirmed = await _showConfirmDialog(
      title: 'Confirm grade assignment',
      message: entries.length == 1
          ? 'Set ${entries.first.fullName} to Grade $grade?'
          : 'Set ${entries.length} students to Grade $grade?',
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
      ),
    );
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
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
                child: const Text('Confirm'),
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

class _RosterTile extends StatelessWidget {
  const _RosterTile({
    required this.entry,
    required this.selected,
    required this.busy,
    required this.onSelected,
    required this.onAssignGrade,
  });

  final RosterEntryEntity entry;
  final bool selected;
  final bool busy;
  final ValueChanged<bool> onSelected;
  final VoidCallback onAssignGrade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradeLabel =
        entry.gradeLevel != null ? 'Grade ${entry.gradeLevel}' : 'No grade';
    final statusLabel = entry.isRegistered ? 'Registered' : 'Not registered';

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Checkbox(
          value: selected,
          onChanged: busy ? null : (v) => onSelected(v ?? false),
        ),
        title: Text(
          entry.fullName.isNotEmpty ? entry.fullName : entry.studentId,
          style:
              theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$gradeLabel · $statusLabel'),
            Text('ID: ${entry.studentId}'),
            if (entry.section != null) Text('Section: ${entry.section}'),
          ],
        ),
        isThreeLine: entry.section != null,
        trailing: IconButton(
          tooltip: 'Assign grade',
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'You do not have permission to manage the student roster.',
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'Student roster and grades are only available for school-type '
          'organizations.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
