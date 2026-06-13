import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/errors/failure.dart';
import 'package:speakup_connect/core/extensions/context_extensions.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/app_text_field.dart';

/// Self-service password change for signed-in members.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final current = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;

    if (newPassword == current) {
      context.showSnackBar(
        'New password must be different from your current password.',
        isError: true,
      );
      return;
    }

    await ref.read(authProvider.notifier).changePassword(
          currentPassword: current,
          newPassword: newPassword,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final theme = Theme.of(context);

    ref.listen(authProvider, (previous, next) {
      if (next is AsyncError) {
        final error = next.error;
        final message = error is Failure
            ? error.message
            : 'Could not change password. Please try again.';
        context.showSnackBar(message, isError: true);
        return;
      }

      if (previous?.isLoading == true && next is AsyncData) {
        context.showSnackBar('Password updated successfully.');
        if (context.mounted) {
          context.pop();
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(Routes.settings)),
        title: const Text('Change Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter your current password, then choose a new password.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  controller: _currentPasswordController,
                  label: 'Current password',
                  hint: 'Your current password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: !_currentPasswordVisible,
                  textInputAction: TextInputAction.next,
                  validator: (v) => context.l10n.validateLoginPassword(v),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _currentPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () => setState(
                      () => _currentPasswordVisible = !_currentPasswordVisible,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _newPasswordController,
                  label: 'New password',
                  hint: 'At least 8 characters',
                  prefixIcon: Icons.lock_reset_rounded,
                  obscureText: !_newPasswordVisible,
                  textInputAction: TextInputAction.next,
                  validator: (v) => context.l10n.validatePassword(v),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _newPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () => setState(
                      () => _newPasswordVisible = !_newPasswordVisible,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm new password',
                  hint: 'Re-enter your new password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: !_confirmPasswordVisible,
                  textInputAction: TextInputAction.done,
                  validator: (value) => context.l10n.validateConfirmPassword(
                    value,
                    _newPasswordController.text,
                  ),
                  onFieldSubmitted: (_) => _onSubmit(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () => setState(
                      () =>
                          _confirmPasswordVisible = !_confirmPasswordVisible,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                AppButton.primary(
                  label: 'Update Password',
                  onPressed: _onSubmit,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
