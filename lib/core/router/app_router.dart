import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/features/admin/presentation/screens/admin_branding_screen.dart';
import 'package:speakup_connect/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/auth/presentation/screens/apply_to_join_screen.dart';
import 'package:speakup_connect/features/auth/presentation/screens/login_screen.dart';
import 'package:speakup_connect/features/auth/presentation/screens/pending_approval_screen.dart';
import 'package:speakup_connect/features/auth/presentation/screens/register_screen.dart';
import 'package:speakup_connect/features/auth/presentation/screens/splash_screen.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/features/reports/presentation/screens/home_dashboard_screen.dart';
import 'package:speakup_connect/features/reports/presentation/screens/my_reports_screen.dart';
import 'package:speakup_connect/features/reports/presentation/screens/report_confirmation_screen.dart';
import 'package:speakup_connect/features/reports/presentation/screens/report_details_screen.dart';
import 'package:speakup_connect/features/reports/presentation/screens/submit_report_screen.dart';
import 'package:speakup_connect/features/settings/presentation/screens/settings_screen.dart';

part 'app_router.g.dart';

/// Provides the [GoRouter] instance for the entire app.
///
/// The router watches [authStateChangesProvider] and [currentUserRoleProvider]
/// to determine whether to redirect to login or admin screens.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // Do NOT use ref.watch here — watching auth/profile state would recreate
  // the entire GoRouter on every auth change, resetting navigation to
  // initialLocation. The _AuthStateListenable already triggers redirect
  // re-evaluation via notifyListeners(); we only need ref.read inside redirect.
  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: _AuthStateListenable(ref),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authStateChangesProvider);
      final profileAsync = ref.read(userProfileProvider);

      final isAuthenticated = authState.value != null;
      final isAuthLoading = authState.isLoading;
      final isProfileLoading = profileAsync.isLoading;

      // Don't redirect while auth or profile state is loading.
      if (isAuthLoading || isProfileLoading) return null;

      final loc = state.matchedLocation;

      final isOnAuthPage = loc == Routes.login ||
          loc == Routes.register ||
          loc == Routes.splash;

      final isOnJoinFlow = loc == Routes.applyToJoin ||
          loc == Routes.pendingApproval;

      // Unauthenticated → login.
      if (!isAuthenticated && !isOnAuthPage) {
        return Routes.login;
      }

      if (isAuthenticated) {
        final profile = profileAsync.asData?.value;

        // No profile yet → prompt to apply (regardless of which page they
        // are on, including login — this handles the post-signup redirect).
        if (profile == null && !isOnJoinFlow) {
          return Routes.applyToJoin;
        }

        // Profile pending or rejected → pending screen.
        if (profile != null && !profile.isApproved && !isOnJoinFlow) {
          return Routes.pendingApproval;
        }

        // Profile approved → redirect away from auth/join pages.
        if (profile != null && profile.isApproved) {
          if (isOnAuthPage || isOnJoinFlow) return Routes.home;
        }
      }

      return null;
    },
    routes: [
      // --- Splash ---
      GoRoute(
        path: Routes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // --- Auth ---
      GoRoute(
        path: Routes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // --- Join Flow ---
      GoRoute(
        path: Routes.applyToJoin,
        name: 'applyToJoin',
        builder: (context, state) => const ApplyToJoinScreen(),
      ),
      GoRoute(
        path: Routes.pendingApproval,
        name: 'pendingApproval',
        builder: (context, state) => const PendingApprovalScreen(),
      ),

      // --- Main App ---
      GoRoute(
        path: Routes.home,
        name: 'home',
        builder: (context, state) => const HomeDashboardScreen(),
      ),
      GoRoute(
        path: Routes.submitReport,
        name: 'submitReport',
        builder: (context, state) => const SubmitReportScreen(),
      ),
      GoRoute(
        path: Routes.reportConfirmation,
        name: 'reportConfirmation',
        builder: (context, state) {
          final referenceNumber =
              state.extra as String? ?? '';
          return ReportConfirmationScreen(referenceNumber: referenceNumber);
        },
      ),
      GoRoute(
        path: Routes.myReports,
        name: 'myReports',
        builder: (context, state) => const MyReportsScreen(),
      ),
      GoRoute(
        path: Routes.reportDetails,
        name: 'reportDetails',
        builder: (context, state) {
          final reportId = state.pathParameters['reportId']!;
          return ReportDetailsScreen(reportId: reportId);
        },
      ),
      GoRoute(
        path: Routes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // --- Admin ---
      GoRoute(
        path: Routes.adminDashboard,
        name: 'adminDashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: Routes.adminReportDetail,
        name: 'adminReportDetail',
        builder: (context, state) {
          final reportId = state.pathParameters['reportId']!;
          return AdminReportDetailScreen(reportId: reportId);
        },
      ),
      GoRoute(
        path: Routes.adminSettings,
        name: 'adminSettings',
        builder: (context, state) => const AdminBrandingScreen(),
      ),
    ],
  );
}

/// A [Listenable] that notifies go_router when the auth state changes,
/// triggering a redirect evaluation.
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(this._ref) {
    _ref.listen(authStateChangesProvider, (_, __) => _maybeNotify());
    _ref.listen(userProfileProvider, (_, __) => _maybeNotify());
    // Hold off redirecting for 5 seconds so the branded splash content is
    // always visible long enough to read, even when auth resolves from cache.
    Future.delayed(const Duration(seconds: 5), () {
      _splashLockExpired = true;
      _maybeNotify();
    });
  }

  bool _splashLockExpired = false;
  final Ref _ref;

  void _maybeNotify() {
    if (_splashLockExpired) notifyListeners();
  }
}

/// Placeholder for admin report detail screen (defined in admin feature).
/// This stub prevents circular imports at the router level.
class AdminReportDetailScreen extends StatelessWidget {
  const AdminReportDetailScreen({required this.reportId, super.key});
  final String reportId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Detail')),
      body: Center(child: Text('Report: $reportId')),
    );
  }
}
