import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';

/// Splash / Welcome screen — the first screen the user sees.
///
/// Displays the organization's branding:
/// - Logo (from org config, or a default placeholder)
/// - App title: "SpeakUp {orgDisplayName}" (e.g., "SpeakUp Riverside High")
/// - Tagline (from org config)
/// - "Get Started" button
///
/// Automatically redirects authenticated users to the Home screen.
/// The go_router redirect guard handles this, but we also check here
/// to show appropriate UI while auth state loads.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  // Ensures the blue loading screen is always visible long enough for the
  // spinner to be seen — even when org config resolves from cache instantly.
  bool _minTimeElapsed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _minTimeElapsed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orgConfigAsync = ref.watch(organizationConfigProvider);

    // Show the blue loading screen until BOTH conditions are met:
    //  1. org config has resolved (data or error)
    //  2. minimum display time has elapsed
    // This guarantees the spinner is always visible from the very first frame.
    if (!_minTimeElapsed || orgConfigAsync.isLoading) {
      return const _LoadingScreen();
    }

    return Scaffold(
      body: SafeArea(
        child: orgConfigAsync.when(
          loading: () => _SplashContent(
            orgName: AppConfig.clientDisplayName,
            tagline: 'Your voice. Our action.',
          ),
          error: (_, __) => _SplashContent(
            orgName: AppConfig.clientDisplayName,
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

          // --- App Title: "SpeakUp {orgName}" ---
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

/// Shown until org config resolves — a full-screen Scaffold matching the
/// native Android launch background so the blue → spinner transition is
/// seamless from the very first Flutter frame.
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    // Must match launchBackground in res/values/colors.xml
    return const Scaffold(
      backgroundColor: Color(0xFF2563EB),
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
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
