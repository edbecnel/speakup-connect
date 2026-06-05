import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';

/// Shown when a former member has been unenrolled (e.g. after graduation).
class UnenrolledAccountScreen extends ConsumerWidget {
  const UnenrolledAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(userProfileProvider).value;
    final reason =
        profile?.unenrollReason ?? 'Contact your administrator if you need access.';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.school_outlined,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'No Longer Enrolled',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your membership in this organization has ended.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reason',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(reason, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              AppButton.text(
                label: 'Sign Out',
                icon: Icons.logout,
                onPressed: () async {
                  await ref.read(authProvider.notifier).signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
