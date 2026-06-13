import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/extensions/context_extensions.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/app_text_field.dart';

/// Apply-to-join screen shown after a new user signs up for an organisation
/// that has [signupRequiresApproval] enabled.
///
/// The user enters their full name and school/org-issued student ID.
/// Submitting creates a pending profile in Firestore, which an admin must
/// approve before the user can access the app.
class ApplyToJoinScreen extends ConsumerStatefulWidget {
  const ApplyToJoinScreen({super.key});

  @override
  ConsumerState<ApplyToJoinScreen> createState() => _ApplyToJoinScreenState();
}

class _ApplyToJoinScreenState extends ConsumerState<ApplyToJoinScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  final _studentIdController = TextEditingController();
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate with the name provided during sign-up.
    final user = ref.read(currentUserProvider);
    _fullNameController = TextEditingController(
      text: user?.displayName ?? '',
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms to continue.'),
        ),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    await ref.read(joinApplicationProvider.notifier).submitApplication(
          orgId: AppConfig.defaultOrganizationId,
          userId: user.uid,
          displayName: user.displayName ?? _fullNameController.text.trim(),
          fullName: _fullNameController.text.trim(),
          studentId: _studentIdController.text.trim().isEmpty
              ? null
              : _studentIdController.text.trim(),
          email: user.email,
        );
  }

  @override
  Widget build(BuildContext context) {
    final orgConfig = ref.watch(organizationConfigProvider);
    final orgName = orgConfig.asData?.value?.displayName ?? AppConfig.appName;

    final submissionState = ref.watch(joinApplicationProvider);

    // Navigate to pending screen once submission succeeds.
    ref.listen<AsyncValue<void>>(joinApplicationProvider, (_, next) {
      next.whenOrNull(
        data: (_) => context.go(Routes.pendingApproval),
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err.toString()),
              backgroundColor: context.colorScheme.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Join $orgName'),
        centerTitle: true,
        // User just signed up — sign out is available via the trailing action.
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Header ---
              Icon(
                Icons.how_to_reg_outlined,
                size: 64,
                color: context.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Request to Join',
                style: context.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your details will be reviewed by an admin before you can access $orgName.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // --- Form ---
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      controller: _fullNameController,
                      label: 'Full Name',
                      hint: 'e.g. Juan Dela Cruz',
                      prefixIcon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      validator: (v) => context.l10n.validateRequired(
                        v,
                        fieldName: 'Full name',
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _studentIdController,
                      label: 'Student / Member ID',
                      hint: 'Your school-issued ID number',
                      prefixIcon: Icons.badge_outlined,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      // Student ID is optional (some orgs may not require it).
                    ),
                    const SizedBox(height: 24),

                    // --- Terms checkbox ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _termsAccepted,
                          onChanged: (v) =>
                              setState(() => _termsAccepted = v ?? false),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(
                              () => _termsAccepted = !_termsAccepted,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                'I confirm that the information I provided is accurate.',
                                style: context.textTheme.bodySmall,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // --- Submit ---
                    AppButton.primary(
                      label: 'Submit Application',
                      isLoading: submissionState.isLoading,
                      onPressed: submissionState.isLoading ? null : _submit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
