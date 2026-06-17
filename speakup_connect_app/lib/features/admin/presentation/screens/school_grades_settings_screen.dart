import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/organization/domain/entities/organization_config_entity.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/l10n/app_localizations.dart';

/// Lets school admins define which grade levels their students belong to.
class SchoolGradesSettingsScreen extends ConsumerStatefulWidget {
  const SchoolGradesSettingsScreen({super.key});

  @override
  ConsumerState<SchoolGradesSettingsScreen> createState() =>
      _SchoolGradesSettingsScreenState();
}

class _SchoolGradesSettingsScreenState
    extends ConsumerState<SchoolGradesSettingsScreen> {
  final _addController = TextEditingController();
  List<int>? _draftGrades;
  List<int>? _lastSavedGrades;

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  List<int> _gradesFrom(List<int> configured) {
    return _draftGrades ?? List<int>.from(configured);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final orgConfig = ref.watch(organizationConfigProvider);
    final configuredGrades = ref.watch(orgGradeLevelsProvider);
    final grades = _gradesFrom(configuredGrades);
    final supportsGrades = ref.watch(orgSupportsStudentGradesProvider);
    final profile = ref.watch(userProfileProvider).value;
    final canManage =
        ref.watch(hasPermissionProvider(AppPermission.manageOrganizationSettings)) ||
            (profile?.isAdmin ?? false);
    final busy = ref.watch(schoolGradesActionProvider).isLoading;

    ref.listen(schoolGradesActionProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading) {
        if (next.hasError) {
          _lastSavedGrades = null;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              l10n.schoolGradesSaveFailed(
                _localizedSaveError(l10n, next.error),
              ),
            ),
            backgroundColor: theme.colorScheme.error,
          ));
        } else {
          setState(() {
            if (_lastSavedGrades != null) {
              _draftGrades = List<int>.from(_lastSavedGrades!);
            }
            _lastSavedGrades = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.schoolGradesSaveSuccess)),
          );
        }
      }
    });

    ref.listen(orgGradeLevelsProvider, (prev, next) {
      if (_draftGrades != null && _gradeListsEqual(_draftGrades!, next)) {
        setState(() => _draftGrades = null);
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.settingsSchoolGrades),
      ),
      body: orgConfig.isLoading && !orgConfig.hasValue
          ? const Center(child: CircularProgressIndicator())
          : orgConfig.hasError && !orgConfig.hasValue
              ? Center(
                  child: Text(
                    l10n.schoolGradesLoadFailed('${orgConfig.error}'),
                  ),
                )
              : !supportsGrades
                  ? const _NotSchoolPlaceholder()
                  : !canManage
                      ? const _NoAccessPlaceholder()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.schoolGradesIntro,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.schoolGradesIntroWhereUsed(
                                  l10n.settingsStudentRoster,
                                  l10n.settingsMemberManagement,
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.schoolGradesNonSchoolNote,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                l10n.schoolGradesCurrent,
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              if (grades.isEmpty)
                                Text(l10n.schoolGradesEmpty)
                              else
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: grades
                                      .map(
                                        (g) => InputChip(
                                          label: Text(l10n.schoolGradesGradeChip(g)),
                                          onDeleted: busy
                                              ? null
                                              : () => setState(() {
                                                    final next =
                                                        List<int>.from(grades)
                                                          ..remove(g);
                                                    _draftGrades = next;
                                                  }),
                                        ),
                                      )
                                      .toList(),
                                ),
                              const SizedBox(height: 24),
                              TextField(
                                controller: _addController,
                                enabled: !busy,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  labelText: l10n.schoolGradesAddLabel,
                                  hintText: l10n.schoolGradesAddHint,
                                  border: const OutlineInputBorder(),
                                ),
                                onSubmitted: (_) => _addGrade(grades),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton(
                                  onPressed: busy ? null : () => _addGrade(grades),
                                  child: Text(l10n.schoolGradesAddButton),
                                ),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: busy
                                    ? null
                                    : () => setState(
                                          () => _draftGrades = List<int>.from(
                                            kDefaultSchoolGradeLevels,
                                          ),
                                        ),
                                icon: const Icon(Icons.restore_outlined),
                                label: Text(l10n.schoolGradesResetDefault),
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                height: 52,
                                child: FilledButton.icon(
                                  onPressed:
                                      busy || grades.isEmpty ? null : () => _save(grades),
                                  icon: busy
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.save_outlined),
                                  label: Text(
                                    busy ? l10n.schoolGradesSaving : l10n.schoolGradesSave,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
    );
  }

  void _addGrade(List<int> grades) {
    final l10n = context.l10n;
    final value = int.tryParse(_addController.text.trim());
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.schoolGradesInvalidNumber)),
      );
      return;
    }
    setState(() {
      final next = List<int>.from(grades);
      if (!next.contains(value)) {
        next.add(value);
        next.sort();
      }
      _draftGrades = next;
      _addController.clear();
    });
  }

  Future<void> _save(List<int> grades) async {
    final l10n = context.l10n;
    final gradeList =
        grades.map((g) => l10n.schoolGradesGradeChip(g)).join(', ');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.schoolGradesSaveDialogTitle),
        content: Text('${l10n.schoolGradesSaveDialogBody} $gradeList.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    _lastSavedGrades = List<int>.from(grades);
    await ref.read(schoolGradesActionProvider.notifier).save(grades);
  }

  static bool _gradeListsEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static String _localizedSaveError(
    AppLocalizations l10n,
    Object? error,
  ) {
    final message = error?.toString() ?? '';
    if (message.contains('not saved correctly')) {
      return l10n.schoolGradesSaveVerifyFailed;
    }
    if (message.contains('At least one grade level')) {
      return l10n.schoolGradesAtLeastOneRequired;
    }
    return message;
  }
}

class _NotSchoolPlaceholder extends StatelessWidget {
  const _NotSchoolPlaceholder();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          l10n.schoolGradesNotSchool,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _NoAccessPlaceholder extends StatelessWidget {
  const _NoAccessPlaceholder();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          l10n.schoolGradesNoPermission,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
