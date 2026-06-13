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
  static const String composeReminder = '/reminders/compose';

  /// Opens compose with a group pre-selected (for group leaders).
  static String composeReminderForGroupPath(String groupId) =>
      '/reminders/compose?groupId=$groupId';
  static const String reminderApprovals = '/reminders/approvals';
  static const String myBroadcasts = '/reminders/mine';
  static const String notificationHistory = '/notifications/history';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String changePassword = '/settings/change-password';
  static const String helpHub = '/help';
  static const String helpArticle = '/help/:articleId';
  static const String organizationInfo = '/org/info';
  static const String announcements = '/announcements';
  static const String composeAnnouncement = '/announcements/compose';
  static const String myAnnouncements = '/announcements/mine';
  static const String announcementDetail = '/announcements/:bulletinId';

  // --- Admin ---
  static const String adminDashboard = '/admin';
  static const String adminReportDetail = '/admin/reports/:reportId';
  static const String adminSettings = '/admin/settings';
  static const String memberApprovals = '/join-applications';
  static const String enrolledUsers = '/enrolled-users';
  static const String editMember = '/enrolled-users/:userId/edit';
  static String editMemberPath(String userId) => '/enrolled-users/$userId/edit';
  static const String rosterManagement = '/roster';
  static const String addStudent = '/roster/add';
  static const String schoolGradesSettings = '/school-grades';
  static const String groupsList = '/groups';
  static const String myGroups = '/my-groups';
  static const String browseGroups = '/groups/browse';
  static const String createGroup = '/groups/new';
  static const String groupMembershipRequests =
      '/groups/:groupId/membership-requests';
  static const String groupMembers = '/groups/:groupId/members';
  static const String addGroupMembers = '/groups/:groupId/members/add';
  static const String editGroupPositionRoles = '/groups/:groupId/roles';
  static const String accountBlocked = '/account-blocked';
  static const String accountUnenrolled = '/account-unenrolled';

  // --- Admin: Roles & Permissions ---
  static const String adminRoles = '/admin/roles';
  static const String adminRoleNew = '/admin/roles/new';
  static const String adminRoleEdit = '/admin/roles/:roleId/edit';
  static const String adminRoleAssign = '/admin/roles/:roleId/assign';
  static const String adminCapabilities = '/admin/capabilities';
  static const String adminUserAssignments = '/admin/roles/assignments';
  static const String translationWorkspace = '/admin/translations';

  // --- Helpers ---

  /// Builds the report details path with a concrete [reportId].
  static String reportDetailsPath(String reportId) => '/reports/$reportId';

  /// Builds the admin report detail path with a concrete [reportId].
  static String adminReportDetailPath(String reportId) =>
      '/admin/reports/$reportId';

  /// Builds the role editor path for an existing [roleId].
  static String adminRoleEditPath(String roleId) =>
      '/admin/roles/$roleId/edit';

  /// Builds the role assignment path for a concrete [roleId].
  static String adminRoleAssignPath(String roleId) =>
      '/admin/roles/$roleId/assign';

  /// Builds the group members roster path for a concrete [groupId].
  static String groupMembersPath(String groupId) => '/groups/$groupId/members';

  /// Builds the add-members picker path for a concrete [groupId].
  static String addGroupMembersPath(String groupId) =>
      '/groups/$groupId/members/add';

  /// Builds the club positions editor path for a concrete [groupId].
  static String editGroupPositionRolesPath(String groupId) =>
      '/groups/$groupId/roles';

  /// Builds the membership requests review path for a concrete [groupId].
  static String groupMembershipRequestsPath(String groupId) =>
      '/groups/$groupId/membership-requests';

  /// Builds the help article path for a concrete [articleId] (`member`, `admin`).
  static String helpArticlePath(String articleId) => '/help/$articleId';

  static String announcementDetailPath(String bulletinId) =>
      '/announcements/$bulletinId';

  static String composeAnnouncementForGroupPath(String groupId) =>
      '/announcements/compose?groupId=$groupId';
}
