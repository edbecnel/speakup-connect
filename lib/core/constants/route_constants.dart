/// Named route path constants for go_router.
///
/// All navigation in the app uses these constants rather than
/// inline string paths to prevent typos and enable refactoring.
abstract class Routes {
  // --- Auth ---
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // --- Onboarding / Join Flow ---
  static const String applyToJoin = '/apply-to-join';
  static const String pendingApproval = '/pending-approval';

  // --- Main App (User) ---
  static const String home = '/home';
  static const String submitReport = '/report/submit';
  static const String reportConfirmation = '/report/confirmation';
  static const String myReports = '/reports/mine';
  static const String reportDetails = '/reports/:reportId';
  static const String alerts = '/alerts';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String organizationInfo = '/org/info';
  static const String announcements = '/announcements';

  // --- Admin ---
  static const String adminDashboard = '/admin';
  static const String adminReportDetail = '/admin/reports/:reportId';
  static const String adminSettings = '/admin/settings';

  // --- Helpers ---

  /// Builds the report details path with a concrete [reportId].
  static String reportDetailsPath(String reportId) => '/reports/$reportId';

  /// Builds the admin report detail path with a concrete [reportId].
  static String adminReportDetailPath(String reportId) =>
      '/admin/reports/$reportId';
}
