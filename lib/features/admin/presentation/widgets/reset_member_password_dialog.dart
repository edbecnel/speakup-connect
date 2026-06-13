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
    builder: (ctx) => AlertDialog(
      title: const Text('Confirm password reset'),
      content: Text(
        'Set a new sign-in password for $memberName? '
        'They will need it the next time they sign in.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Reset password'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return false;

  final ok = await ref.read(resetOrgMemberPasswordProvider.notifier).reset(
        userId: userId,
        newPassword: newPassword,
      );

  if (!context.mounted) return ok;

  if (ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password reset for $memberName')),
    );
  } else {
    final error = ref.read(resetOrgMemberPasswordProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error?.toString() ?? 'Could not reset password'),
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
          title: Text('Reset password for ${widget.memberName}'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Choose a new sign-in password. Use the shortcuts below '
                  'or enter one manually.',
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
                        label: const Text('Use username / student ID'),
                      ),
                    OutlinedButton.icon(
                      onPressed: _applyRandomPassword,
                      icon: const Icon(Icons.pin_outlined),
                      label: const Text('Generate 8-digit password'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _passwordController,
                  label: 'New password',
                  hint: 'At least 6 characters',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: (v) => context.l10n.validateLoginPassword(v),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Show password'
                        : 'Hide password',
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
                  label: 'Confirm password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  validator: (v) => context.l10n.validateConfirmPassword(
                    v,
                    _passwordController.text,
                  ),
                  onFieldSubmitted: (_) => _submit(),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Show password'
                        : 'Hide password',
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
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: _submit,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
