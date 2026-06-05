import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/organization/domain/entities/organization_config_entity.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';

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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Save failed: ${next.error}'),
            backgroundColor: theme.colorScheme.error,
          ));
        } else {
          setState(() => _draftGrades = null);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Grade levels updated')),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('School Grades'),
      ),
      body: orgConfig.isLoading && !orgConfig.hasValue
          ? const Center(child: CircularProgressIndicator())
          : orgConfig.hasError && !orgConfig.hasValue
              ? Center(child: Text('Failed to load settings: ${orgConfig.error}'))
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
                                'Define which grade levels your school uses. These appear '
                                'in Student Roster and Member Management filters.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Municipalities, barangays, and NGOs do not use grades.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Current grades',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              if (grades.isEmpty)
                                const Text('No grades configured yet.')
                              else
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: grades
                                      .map(
                                        (g) => InputChip(
                                          label: Text('Grade $g'),
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
                                decoration: const InputDecoration(
                                  labelText: 'Add grade level',
                                  hintText: 'e.g. 7',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (_) => _addGrade(grades),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton(
                                  onPressed: busy ? null : () => _addGrade(grades),
                                  child: const Text('Add grade'),
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
                                label: const Text(
                                  'Reset to high school default (7–12)',
                                ),
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
                                  label: Text(busy ? 'Saving…' : 'Save grades'),
                                ),
                              ),
                            ],
                          ),
                        ),
    );
  }

  void _addGrade(List<int> grades) {
    final value = int.tryParse(_addController.text.trim());
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid grade number')),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save grade levels?'),
        content: Text(
          'Students will be filterable and assignable by: '
          '${grades.map((g) => 'Grade $g').join(', ')}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(schoolGradesActionProvider.notifier).save(grades);
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
          'Grade levels are only used by school-type organizations. '
          'This setting is not available for your organization type.',
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'You do not have permission to manage organization settings.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
