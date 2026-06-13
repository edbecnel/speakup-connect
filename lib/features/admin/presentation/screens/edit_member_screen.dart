import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/organization/domain/entities/user_profile_entity.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/roster_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/features/admin/presentation/widgets/reset_member_password_dialog.dart';
import 'package:speakup_connect/features/organization/presentation/widgets/official_photo_section.dart';
import 'package:speakup_connect/shared/widgets/app_avatar.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';
import 'package:speakup_connect/shared/widgets/app_text_field.dart';

/// Admin screen to edit a member's profile (name, student ID, email, grade).
class EditMemberScreen extends ConsumerStatefulWidget {
  const EditMemberScreen({required this.userId, super.key});

  final String userId;

  @override
  ConsumerState<EditMemberScreen> createState() => _EditMemberScreenState();
}

class _EditMemberScreenState extends ConsumerState<EditMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  int? _gradeLevel;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _initFromProfile(UserProfileEntity profile) {
    if (_initialized) return;
    _nameController.text = profile.fullName;
    _studentIdController.text = profile.studentId ?? '';
    _emailController.text = profile.email ?? '';
    _gradeLevel = profile.gradeLevel;
    _initialized = true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final studentIdText = _studentIdController.text.trim();
    final emailText = _emailController.text.trim();

    final ok = await ref.read(updateOrgMemberProvider.notifier).update(
          userId: widget.userId,
          fullName: _nameController.text,
          studentId: studentIdText.isEmpty ? null : studentIdText,
          email: emailText.isEmpty ? null : emailText,
          gradeLevel: _gradeLevel,
          clearStudentId: studentIdText.isEmpty,
          clearEmail: emailText.isEmpty,
          clearGrade: _gradeLevel == null,
        );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member updated')),
      );
      context.pop();
    } else {
      final error = ref.read(updateOrgMemberProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error?.toString() ?? 'Could not update member'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileByIdProvider(widget.userId));
    final isLoading = ref.watch(updateOrgMemberProvider).isLoading;
    final gradeLevels = ref.watch(orgGradeLevelsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Member'),
      ),
      body: profileAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => Center(child: Text('Could not load member: $e')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Member not found'));
          }
          _initFromProfile(profile);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Update login username (student ID), contact email, grade, '
                  'and display name. Changing a student ID also updates their '
                  'sign-in username.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                OfficialPhotoSection(
                  displayName: profile.fullName,
                  officialPhotoUrl: profile.officialPhotoUrl,
                  studentId: profile.studentId,
                  userId: profile.userId,
                ),
                if (profile.avatarUrl != null &&
                    profile.avatarUrl!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Student personal badge',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Optional photo the student chose in Settings. This does '
                    'not replace the official school photo above.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: AppAvatar(
                      displayName: profile.fullName,
                      avatarUrl: profile.avatarUrl,
                      radius: 40,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _nameController,
                  label: 'Full name',
                  hint: 'Legal / roster name',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (v) => context.l10n.validateRequired(
                    v,
                    fieldName: 'Full name',
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _studentIdController,
                  label: 'Student ID (username)',
                  hint: 'School-issued ID for sign-in',
                  prefixIcon: Icons.badge_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    return context.l10n.validateStudentId(v);
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _emailController,
                  label: 'Contact email (optional)',
                  hint: 'For notifications; can also sign in if set',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) => context.l10n.validateOptionalEmail(v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  initialValue: _gradeLevel,
                  decoration: const InputDecoration(
                    labelText: 'Grade',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('No grade'),
                    ),
                    ...gradeLevels.map(
                      (g) => DropdownMenuItem(
                        value: g,
                        child: Text('Grade $g'),
                      ),
                    ),
                  ],
                  onChanged:
                      isLoading ? null : (v) => setState(() => _gradeLevel = v),
                ),
                const SizedBox(height: 28),
                AppButton.primary(
                  label: isLoading ? 'Saving…' : 'Save changes',
                  onPressed: isLoading ? null : _save,
                  isLoading: isLoading,
                ),
                if (!profile.isAdmin) ...[
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Password',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set a new sign-in password for this member. Their current '
                    'session stays active until they sign out.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => showResetMemberPasswordDialog(
                              context: context,
                              ref: ref,
                              userId: widget.userId,
                              memberName: profile.fullName,
                              studentId: profile.studentId,
                            ),
                    icon: const Icon(Icons.lock_reset),
                    label: const Text('Reset password…'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
