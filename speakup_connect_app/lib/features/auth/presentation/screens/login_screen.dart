import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/errors/failure.dart';
import 'package:speakup_connect/core/extensions/context_extensions.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/translations/presentation/widgets/translation_anchor.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/app_text_field.dart';

/// Login / Sign Up screen.
///
/// Matches wireframe screen 2:
/// - Tab switcher: Login | Sign Up
/// - Email / School ID + Password fields
/// - "Forgot Password?" link
/// - Login / Sign Up button
/// - "Continue with Google" (placeholder for Sprint 3)
/// - Terms & Privacy Policy footer
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Login fields
  final _loginIdentifierController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _loginPasswordVisible = false;

  // Register fields
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  bool _registerPasswordVisible = false;
  bool _registerConfirmPasswordVisible = false;
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginIdentifierController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).signInWithIdentifier(
          identifier: _loginIdentifierController.text,
          password: _loginPasswordController.text,
        );
  }

  Future<void> _onRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      context.showSnackBar(context.l10n.authAcceptTermsSnackbar, isError: true);
      return;
    }
    await ref.read(authProvider.notifier).signUpWithEmail(
          email: _registerEmailController.text,
          password: _registerPasswordController.text,
          displayName: _registerNameController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final orgConfigAsync = ref.watch(organizationConfigProvider);
    final isLoading = authState.isLoading;

    // Show error from auth state
    ref.listen(authProvider, (_, next) {
      if (next is AsyncError) {
        final error = next.error;
        final message = error is Failure
            ? error.message
            : context.l10n.authSignInFailed;
        context.showSnackBar(message, isError: true);
      }
    });

    final theme = Theme.of(context);
    final l10n = context.l10n;
    final orgName =
        orgConfigAsync.value?.displayName ?? l10n.authOrgFallbackName;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(Routes.splash)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // --- Tab Bar ---
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: theme.colorScheme.primary,
                  ),
                  labelColor: theme.colorScheme.onPrimary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(
                      child: TranslationAnchor(
                        stringKey: 'commonLogin',
                        text: l10n.commonLogin,
                      ),
                    ),
                    Tab(
                      child: TranslationAnchor(
                        stringKey: 'commonSignUp',
                        text: l10n.commonSignUp,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- Tab Content ---
              SizedBox(
                height: 480,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _LoginForm(
                      formKey: _loginFormKey,
                      identifierController: _loginIdentifierController,
                      passwordController: _loginPasswordController,
                      passwordVisible: _loginPasswordVisible,
                      onTogglePassword: () => setState(
                          () => _loginPasswordVisible = !_loginPasswordVisible),
                      onLogin: _onLogin,
                      isLoading: isLoading,
                      orgName: orgName,
                    ),
                    _RegisterForm(
                      formKey: _registerFormKey,
                      nameController: _registerNameController,
                      emailController: _registerEmailController,
                      passwordController: _registerPasswordController,
                      confirmPasswordController: _registerConfirmPasswordController,
                      passwordVisible: _registerPasswordVisible,
                      onTogglePassword: () => setState(
                          () => _registerPasswordVisible = !_registerPasswordVisible),
                      confirmPasswordVisible: _registerConfirmPasswordVisible,
                      onToggleConfirmPassword: () => setState(() =>
                          _registerConfirmPasswordVisible =
                              !_registerConfirmPasswordVisible),
                      termsAccepted: _termsAccepted,
                      onTermsChanged: (v) =>
                          setState(() => _termsAccepted = v ?? false),
                      onRegister: _onRegister,
                      isLoading: isLoading,
                    ),
                  ],
                ),
              ),

              // --- Google Sign In (placeholder) ---
              Row(
                children: [
                  Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TranslationAnchor(
                      stringKey: 'commonOr',
                      text: l10n.commonOr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Google sign-in — Sprint 3
                  context.showSnackBar(l10n.authGoogleSignInSoon);
                },
                icon: const Icon(Icons.login),
                label: TranslationAnchor(
                  stringKey: 'authContinueWithGoogle',
                  text: l10n.authContinueWithGoogle,
                ),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
              ),

              const SizedBox(height: 24),

              // --- Terms ---
              TranslationAnchor(
                stringKey: 'authTermsFooter',
                text: l10n.authTermsFooter,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.identifierController,
    required this.passwordController,
    required this.passwordVisible,
    required this.onTogglePassword,
    required this.onLogin,
    required this.isLoading,
    required this.orgName,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController identifierController;
  final TextEditingController passwordController;
  final bool passwordVisible;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;
  final bool isLoading;
  final String orgName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          AppTextField(
            controller: identifierController,
            label: l10n.authEmailOrStudentId,
            hint: l10n.authEmailOrStudentIdHint,
            contentPadding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
            prefixIcon: Icons.person_outline_rounded,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            validator: (v) => l10n.validateLoginIdentifier(v),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: passwordController,
            label: l10n.commonPassword,
            hint: l10n.authPasswordHintLogin,
            contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: !passwordVisible,
            textInputAction: TextInputAction.done,
            validator: (v) => l10n.validateLoginPassword(v),
            suffixIcon: IconButton(
              icon: Icon(
                passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              ),
              onPressed: onTogglePassword,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Navigate to forgot password screen
              },
              child: TranslationAnchor(
                stringKey: 'authForgotPassword',
                text: l10n.authForgotPassword,
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppButton.primary(
            label: l10n.commonLogin,
            onPressed: onLogin,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.passwordVisible,
    required this.onTogglePassword,
    required this.confirmPasswordVisible,
    required this.onToggleConfirmPassword,
    required this.termsAccepted,
    required this.onTermsChanged,
    required this.onRegister,
    required this.isLoading,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool passwordVisible;
  final VoidCallback onTogglePassword;
  final bool confirmPasswordVisible;
  final VoidCallback onToggleConfirmPassword;
  final bool termsAccepted;
  final void Function(bool?) onTermsChanged;
  final VoidCallback onRegister;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: nameController,
            label: l10n.authFullName,
            hint: l10n.authFullNameHint,
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: (v) => l10n.validateRequired(v, fieldName: l10n.authFullName),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: emailController,
            label: l10n.commonEmail,
            hint: l10n.authEmailHint,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) => l10n.validateEmail(v),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: passwordController,
            label: l10n.commonPassword,
            hint: l10n.authPasswordHintRegister,
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: !passwordVisible,
            textInputAction: TextInputAction.next,
            validator: (v) => l10n.validatePassword(v),
            suffixIcon: IconButton(
              icon: Icon(
                passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              ),
              onPressed: onTogglePassword,
            ),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: confirmPasswordController,
            label: l10n.authConfirmPassword,
            hint: l10n.authConfirmPasswordHint,
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: !confirmPasswordVisible,
            textInputAction: TextInputAction.done,
            validator: (v) => l10n.validateConfirmPassword(v, passwordController.text),
            suffixIcon: IconButton(
              icon: Icon(
                confirmPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: onToggleConfirmPassword,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(value: termsAccepted, onChanged: onTermsChanged),
              Expanded(
                child: Text(l10n.authAcceptTermsCheckbox),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppButton.primary(
            label: l10n.commonSignUp,
            onPressed: onRegister,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
}
