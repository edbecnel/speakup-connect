import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/auth/presentation/screens/login_screen.dart';
import 'package:speakup_connect/features/auth/presentation/screens/register_screen.dart';
import 'package:speakup_connect/features/auth/presentation/screens/splash_screen.dart';
import 'package:speakup_connect/features/reports/presentation/screens/home_dashboard_screen.dart';
import 'package:speakup_connect/features/reports/presentation/screens/my_reports_screen.dart';
import 'package:speakup_connect/features/reports/presentation/screens/report_details_screen.dart';
import 'package:speakup_connect/features/reports/presentation/screens/submit_report_screen.dart';
import 'package:speakup_connect/features/reports/presentation/screens/report_confirmation_screen.dart';
import 'package:speakup_connect/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:speakup_connect/features/settings/presentation/screens/settings_screen.dart';

part 'app_router.g.dart';

/// Provides the [GoRouter] instance for the entire app.
///
/// The router watches [authStateChangesProvider] and [currentUserRoleProvider]
/// to determine whether to redirect to login or admin screens.
@riverpod
GoRouter appRouter(Ref ref) {
  // Listen to auth state for reactive redirects
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: _AuthStateListenable(ref),
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = authState.value != null;
      final isLoading = authState.isLoading;

      // Don't redirect while auth state is loading
      if (isLoading) return null;

      final isOnAuthPage = state.matchedLocation == Routes.login ||
          state.matchedLocation == Routes.register ||
          state.matchedLocation == Routes.splash;

      // Redirect unauthenticated users to login
      if (!isAuthenticated && !isOnAuthPage) {
        return Routes.login;
      }

      // Redirect authenticated users away from auth pages
      if (isAuthenticated && state.matchedLocation == Routes.login) {
        return Routes.home;
      }
      if (isAuthenticated && state.matchedLocation == Routes.register) {
        return Routes.home;
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
    ],
  );
}

/// A [Listenable] that notifies go_router when the auth state changes,
/// triggering a redirect evaluation.
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(this._ref) {
    _ref.listen(authStateChangesProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
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
