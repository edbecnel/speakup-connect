import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/router/app_router.dart';
import 'package:speakup_connect/core/theme/app_theme.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/settings/presentation/providers/settings_provider.dart';

/// Root application widget.
///
/// Responsibilities:
/// - Builds [MaterialApp.router] with go_router
/// - Applies dynamic organization theme (colors from org config)
/// - Applies user theme preference (dark/light)
/// - Provides the app-level router
class SpeakUpConnectApp extends ConsumerWidget {
  const SpeakUpConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Watch org config to apply dynamic branding.
    // Falls back to AppConfig.defaultThemeColors while the config is loading.
    // After the first launch the local cache warms up and the org config
    // provider sets the correct branding before the first frame is painted.
    final orgConfigAsync = ref.watch(organizationConfigProvider);
    final orgColors =
        orgConfigAsync.value?.themeColors ?? AppConfig.defaultThemeColors;

    return MaterialApp.router(
      title: 'SpeakUp Connect',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light(orgColors: orgColors),
      darkTheme: AppTheme.dark(orgColors: orgColors),
      themeMode: themeMode,
    );
  }
}
