import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/organization/presentation/providers/roster_provider.dart';
import 'package:speakup_connect/shared/widgets/app_text_field.dart';

/// Prompts an org admin to set a new login password for a member.
Future<bool> showResetMemberPasswordDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String userId,
  required String memberName,
  String? studentId,
}) async {
  final l10n = context.l10n;
  final newPassword = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _ResetMemberPasswordDialog(
      memberName: memberName,
      studentId: studentId,
    ),
  );

  if (newPassword == null || !context.mounted) return false;

  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final dialogL10n = ctx.l10n;
      return AlertDialog(
        title: Text(dialogL10n.memberManagementConfirmPasswordResetTitle),
        content: Text(
          dialogL10n.memberManagementConfirmPasswordResetMessage(memberName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(dialogL10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(dialogL10n.memberManagementResetPasswordAction),
          ),
        ],
      );
    },
  );

  if (confirmed != true || !context.mounted) return false;

  final ok = await ref.read(resetOrgMemberPasswordProvider.notifier).reset(
        userId: userId,
        newPassword: newPassword,
      );

  if (!context.mounted) return ok;

  if (ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.memberManagementPasswordResetSuccess(memberName))),
    );
  } else {
    final error = ref.read(resetOrgMemberPasswordProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error?.toString() ?? l10n.memberManagementPasswordResetFailed),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  return ok;
}

/// Eight-digit numeric password for admin-provisioned resets.
String generateRandomDigitPassword({int length = 8}) {
  final random = Random.secure();
  final buffer = StringBuffer();
  for (var i = 0; i < length; i++) {
    buffer.write(random.nextInt(10));
  }
  return buffer.toString();
}

class _ResetMemberPasswordDialog extends StatefulWidget {
  const _ResetMemberPasswordDialog({
    required this.memberName,
    this.studentId,
  });

  final String memberName;
  final String? studentId;

  @override
  State<_ResetMemberPasswordDialog> createState() =>
      _ResetMemberPasswordDialogState();
}

class _ResetMemberPasswordDialogState extends State<_ResetMemberPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _applyPassword(String value) {
    _passwordController.text = value;
    _confirmController.text = value;
    setState(() => _obscurePassword = false);
  }

  void _applyStudentIdPassword() {
    final id = widget.studentId?.trim();
    if (id == null || id.isEmpty) return;
    _applyPassword(id);
  }

  void _applyRandomPassword() {
    _applyPassword(generateRandomDigitPassword());
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final studentId = widget.studentId?.trim();
    final theme = Theme.of(context);

    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
        child: AlertDialog(
          scrollable: true,
          title: Text(l10n.memberManagementResetPasswordDialogTitle(widget.memberName)),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.memberManagementResetPasswordIntro,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (studentId != null && studentId.isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: _applyStudentIdPassword,
                        icon: const Icon(Icons.badge_outlined),
                        label: Text(l10n.memberManagementUseUsernamePassword),
                      ),
                    OutlinedButton.icon(
                      onPressed: _applyRandomPassword,
                      icon: const Icon(Icons.pin_outlined),
                      label: Text(l10n.memberManagementGenerate8DigitPassword),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _passwordController,
                  label: l10n.changePasswordNewLabel,
                  hint: l10n.memberManagementPasswordMinHint,
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: (v) => l10n.validateLoginPassword(v),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? l10n.commonShowPassword
                        : l10n.commonHidePassword,
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _confirmController,
                  label: l10n.memberManagementConfirmPasswordLabel,
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  validator: (v) => l10n.validateConfirmPassword(
                    v,
                    _passwordController.text,
                  ),
                  onFieldSubmitted: (_) => _submit(),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? l10n.commonShowPassword
                        : l10n.commonHidePassword,
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: _submit,
              child: Text(l10n.commonContinue),
            ),
          ],
        ),
      ),
    );
  }
}
