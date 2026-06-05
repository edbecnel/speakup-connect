import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';

/// Shown when an enrolled member's account has been blocked by an admin.
class BlockedAccountScreen extends ConsumerWidget {
  const BlockedAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(userProfileProvider).value;
    final reason = profile?.blockReason ?? 'Contact your administrator for help.';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.block,
                size: 72,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Account Restricted',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your access to this organization has been suspended.',
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
