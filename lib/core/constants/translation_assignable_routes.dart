/// App routes that can be assigned a translation screen name (one name per route).
class TranslationAssignableRoute {
  const TranslationAssignableRoute({
    required this.route,
    required this.label,
  });

  final String route;
  final String label;
}

/// Keep in sync with [functions/src/data/assignable_routes.json] and
/// [tools/translation-helper/assignable-routes.js].
const kTranslationAssignableRoutes = [
  TranslationAssignableRoute(route: '/login', label: 'Login'),
  TranslationAssignableRoute(route: '/register', label: 'Register'),
  TranslationAssignableRoute(route: '/forgot-password', label: 'Forgot Password'),
  TranslationAssignableRoute(route: '/apply-to-join', label: 'Apply to Join'),
  TranslationAssignableRoute(route: '/pending-approval', label: 'Pending Approval'),
  TranslationAssignableRoute(route: '/home', label: 'Home'),
  TranslationAssignableRoute(route: '/report/submit', label: 'Submit Report'),
  TranslationAssignableRoute(
    route: '/report/confirmation',
    label: 'Report Confirmation',
  ),
  TranslationAssignableRoute(route: '/reports/mine', label: 'My Reports'),
  TranslationAssignableRoute(route: '/alerts', label: 'Alerts'),
  TranslationAssignableRoute(
    route: '/reminders/compose',
    label: 'Compose Reminder',
  ),
  TranslationAssignableRoute(
    route: '/reminders/approvals',
    label: 'Reminder Approvals',
  ),
  TranslationAssignableRoute(route: '/reminders/mine', label: 'My Broadcasts'),
  TranslationAssignableRoute(
    route: '/notifications/history',
    label: 'Notification History',
  ),
  TranslationAssignableRoute(route: '/profile', label: 'Profile'),
  TranslationAssignableRoute(route: '/settings', label: 'Settings'),
  TranslationAssignableRoute(
    route: '/settings/change-password',
    label: 'Change Password',
  ),
  TranslationAssignableRoute(route: '/help', label: 'Help Hub'),
  TranslationAssignableRoute(route: '/org/info', label: 'Organization Info'),
  TranslationAssignableRoute(route: '/announcements', label: 'Announcements'),
  TranslationAssignableRoute(
    route: '/announcements/compose',
    label: 'Compose Announcement',
  ),
  TranslationAssignableRoute(
    route: '/announcements/mine',
    label: 'My Announcements',
  ),
  TranslationAssignableRoute(route: '/admin', label: 'Admin Dashboard'),
  TranslationAssignableRoute(route: '/admin/settings', label: 'Admin Settings'),
  TranslationAssignableRoute(
    route: '/join-applications',
    label: 'Member Approvals',
  ),
  TranslationAssignableRoute(route: '/enrolled-users', label: 'Enrolled Users'),
  TranslationAssignableRoute(route: '/roster', label: 'Roster Management'),
  TranslationAssignableRoute(route: '/roster/add', label: 'Add Student'),
  TranslationAssignableRoute(route: '/school-grades', label: 'School Grades'),
  TranslationAssignableRoute(route: '/groups', label: 'Groups List'),
  TranslationAssignableRoute(route: '/my-groups', label: 'My Groups'),
  TranslationAssignableRoute(route: '/groups/browse', label: 'Browse Groups'),
  TranslationAssignableRoute(route: '/groups/new', label: 'Create Group'),
  TranslationAssignableRoute(route: '/admin/roles', label: 'Roles Management'),
  TranslationAssignableRoute(route: '/admin/capabilities', label: 'Capabilities'),
  TranslationAssignableRoute(
    route: '/admin/roles/assignments',
    label: 'User Assignments',
  ),
  TranslationAssignableRoute(
    route: '/admin/translations',
    label: 'Translation Workspace',
  ),
  TranslationAssignableRoute(route: '/account-blocked', label: 'Account Blocked'),
  TranslationAssignableRoute(
    route: '/account-unenrolled',
    label: 'Account Unenrolled',
  ),
];

String? translationRouteLabel(String? route) {
  if (route == null || route.isEmpty) return null;
  for (final item in kTranslationAssignableRoutes) {
    if (item.route == route) return item.label;
  }
  return route;
}
