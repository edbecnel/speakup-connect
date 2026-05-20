import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';

/// Splash / Welcome screen — the first screen the user sees.
///
/// Displays the organization's branding:
/// - Logo (from org config, or a default placeholder)
/// - App title: "SpeakUp {orgDisplayName}" (e.g., "SpeakUp MONHS")
/// - Tagline (from org config)
/// - "Get Started" button
///
/// Automatically redirects authenticated users to the Home screen.
/// The go_router redirect guard handles this, but we also check here
/// to show appropriate UI while auth state loads.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgConfigAsync = ref.watch(organizationConfigProvider);
    final authState = ref.watch(authStateChangesProvider);

    // If auth state is still loading, show full-screen loader
    if (authState.isLoading) {
      return const Scaffold(
        body: AppLoadingIndicator(),
      );
    }

    // If auth state is loaded and user is signed in, go_router handles redirect.
    // We just show the splash in case the redirect hasn't fired yet.

    return Scaffold(
      body: SafeArea(
        child: orgConfigAsync.when(
          loading: () => const AppLoadingIndicator(),
          error: (_, __) => const _SplashContent(
            orgName: 'Connect',
            tagline: 'Your voice. Our action.',
          ),
          data: (config) => _SplashContent(
            orgName: config.displayName,
            tagline: config.effectiveTagline,
            logoUrl: config.logoUrl,
          ),
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent({
    required this.orgName,
    required this.tagline,
    this.logoUrl,
  });

  final String orgName;
  final String tagline;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),

          // --- Logo ---
          _OrgLogo(logoUrl: logoUrl),
          const SizedBox(height: 32),

          // --- App Title: "SpeakUp MONHS" ---
          Text(
            'SpeakUp',
            style: theme.textTheme.displaySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              height: 1,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            orgName,
            style: theme.textTheme.displaySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // --- Tagline ---
          Text(
            tagline,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(flex: 2),

          // --- Get Started Button ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go(Routes.login),
              child: const Text('Get Started'),
            ),
          ),

          const SizedBox(height: 12),

          // --- Learn More ---
          TextButton(
            onPressed: () {
              // TODO: Show organization info bottom sheet
            },
            child: const Text('Learn More'),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _OrgLogo extends StatelessWidget {
  const _OrgLogo({this.logoUrl});

  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (logoUrl != null) {
      return CircleAvatar(
        radius: 56,
        backgroundImage: NetworkImage(logoUrl!),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
      );
    }

    // Default placeholder icon
    return CircleAvatar(
      radius: 56,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Icon(
        Icons.campaign_rounded,
        size: 48,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
