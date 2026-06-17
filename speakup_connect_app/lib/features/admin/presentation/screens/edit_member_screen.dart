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

    final l10n = context.l10n;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.memberManagementUpdated)),
      );
      context.pop();
    } else {
      final error = ref.read(updateOrgMemberProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error?.toString() ?? l10n.memberManagementUpdateFailed),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profileAsync = ref.watch(userProfileByIdProvider(widget.userId));
    final isLoading = ref.watch(updateOrgMemberProvider).isLoading;
    final gradeLevels = ref.watch(orgGradeLevelsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.memberManagementEditMemberTitle),
      ),
      body: profileAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => Center(
          child: Text(l10n.memberManagementLoadMemberFailed(e.toString())),
        ),
        data: (profile) {
          if (profile == null) {
            return Center(child: Text(l10n.memberManagementMemberNotFound));
          }
          _initFromProfile(profile);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  l10n.memberManagementEditMemberIntro,
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
                    l10n.memberManagementStudentPersonalBadge,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.memberManagementStudentPersonalBadgeHint,
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
                  label: l10n.memberManagementFullNameLabel,
                  hint: l10n.memberManagementFullNameHint,
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (v) => l10n.validateRequired(
                    v,
                    fieldName: l10n.memberManagementFullNameLabel,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _studentIdController,
                  label: l10n.memberManagementStudentIdUsernameLabel,
                  hint: l10n.memberManagementStudentIdSignInHint,
                  prefixIcon: Icons.badge_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    return l10n.validateStudentId(v);
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _emailController,
                  label: l10n.memberManagementContactEmailOptionalLabel,
                  hint: l10n.memberManagementContactEmailHint,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) => l10n.validateOptionalEmail(v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  initialValue: _gradeLevel,
                  decoration: InputDecoration(
                    labelText: l10n.commonGrade,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(l10n.memberManagementNoGrade),
                    ),
                    ...gradeLevels.map(
                      (g) => DropdownMenuItem(
                        value: g,
                        child: Text(l10n.schoolGradesGradeChip(g)),
                      ),
                    ),
                  ],
                  onChanged:
                      isLoading ? null : (v) => setState(() => _gradeLevel = v),
                ),
                const SizedBox(height: 28),
                AppButton.primary(
                  label: isLoading
                      ? l10n.commonSaving
                      : l10n.memberManagementSaveChanges,
                  onPressed: isLoading ? null : _save,
                  isLoading: isLoading,
                ),
                if (!profile.isAdmin) ...[
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    l10n.memberManagementPasswordSection,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.memberManagementPasswordSectionHint,
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
                    label: Text(l10n.memberManagementResetPassword),
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
