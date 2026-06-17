import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/extensions/context_extensions.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/organization/domain/entities/user_profile_entity.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';

/// Shown after a join application has been submitted, and while [approvalStatus]
/// is still [ApprovalStatus.pending] or [ApprovalStatus.rejected].
///
/// Automatically navigates to the home dashboard when the profile becomes
/// [ApprovalStatus.approved].
class PendingApprovalScreen extends ConsumerWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    // Navigate to home when admin approves.
    ref.listen<AsyncValue<UserProfileEntity?>>(userProfileProvider, (_, next) {
      final profile = next.asData?.value;
      if (profile != null && profile.isApproved) {
        context.go(Routes.home);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text(err.toString())),
          data: (profile) => _Body(profile: profile, ref: ref),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.profile, required this.ref});

  final UserProfileEntity? profile;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isRejected = profile?.isRejected ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),

          // --- Status Icon ---
          Icon(
            isRejected
                ? Icons.cancel_outlined
                : Icons.hourglass_empty_rounded,
            size: 80,
            color: isRejected
                ? context.colorScheme.error
                : context.colorScheme.primary,
          ),
          const SizedBox(height: 24),

          // --- Title ---
          Text(
            isRejected
                ? l10n.authPendingRejectedTitle
                : l10n.authPendingSubmittedTitle,
            style: context.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // --- Message ---
          Text(
            isRejected
                ? l10n.authPendingRejectedMessage
                : l10n.authPendingReviewMessage,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          if (profile != null) ...[
            const SizedBox(height: 32),
            _ProfileSummaryCard(profile: profile!),
          ],

          const Spacer(),

          // --- Actions ---
          if (isRejected)
            AppButton.secondary(
              label: l10n.authEditApplication,
              icon: Icons.edit_outlined,
              onPressed: () => context.go(Routes.applyToJoin),
            ),
          const SizedBox(height: 12),
          AppButton.text(
            label: l10n.settingsSignOut,
            icon: Icons.logout,
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.profile});

  final UserProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.authSubmittedDetails,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _Row(label: l10n.authFullName, value: profile.fullName),
            if (profile.studentId != null)
              _Row(label: l10n.authStudentId, value: profile.studentId!),
            if (profile.email != null)
              _Row(label: l10n.commonEmail, value: profile.email!),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: context.textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
