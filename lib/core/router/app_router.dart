import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/announcements/presentation/screens/announcement_detail_screen.dart';
import 'package:speakup_connect/features/announcements/presentation/screens/announcements_screen.dart';
import 'package:speakup_connect/features/announcements/presentation/screens/compose_announcement_screen.dart';
import 'package:speakup_connect/features/announcements/presentation/screens/my_announcements_screen.dart';
import 'package:speakup_connect/features/translations/presentation/providers/translation_provider.dart';
import 'package:speakup_connect/features/translations/presentation/screens/translation_workspace_screen.dart';
import 'package:speakup_connect/features/admin/presentation/screens/admin_branding_screen.dart';
import 'package:speakup_connect/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:speakup_connect/features/admin/presentation/screens/admin_report_detail_screen.dart';
import 'package:speakup_connect/features/admin/presentation/screens/enrolled_users_screen.dart';
import 'package:speakup_connect/features/admin/presentation/screens/member_approval_queue_screen.dart';
import 'package:speakup_connect/features/admin/presentation/screens/add_student_screen.dart';
import 'package:speakup_connect/features/admin/presentation/screens/edit_member_screen.dart';
import 'package:speakup_connect/features/admin/presentation/screens/roster_management_screen.dart';
import 'package:speakup_connect/features/admin/presentation/screens/school_grades_settings_screen.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/auth/presentation/screens/apply_to_join_screen.dart';
import 'package:speakup_connect/features/auth/presentation/screens/blocked_account_screen.dart';
import 'package:speakup_connect/features/auth/presentation/screens/unenrolled_account_screen.dart';
import 'package:speakup_connect/features/auth/presentation/screens/login_screen.dart';
import 'package:speakup_connect/features/auth/presentation/screens/pending_approval_screen.dart';
import 'package:speakup_connect/features/auth/presentation/screens/register_screen.dart';
import 'package:speakup_connect/features/auth/presentation/screens/splash_screen.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/features/groups/presentation/screens/add_group_members_screen.dart';
import 'package:speakup_connect/features/groups/presentation/screens/create_group_screen.dart';
import 'package:speakup_connect/features/groups/presentation/screens/edit_group_position_roles_screen.dart';
import 'package:speakup_connect/features/groups/presentation/screens/group_members_screen.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_membership_provider.dart';
import 'package:speakup_connect/features/groups/presentation/screens/browse_groups_screen.dart';
import 'package:speakup_connect/features/groups/presentation/screens/group_membership_requests_screen.dart';
import 'package:speakup_connect/features/groups/presentation/screens/groups_list_screen.dart';
import 'package:speakup_connect/features/groups/presentation/screens/my_groups_screen.dart';
import 'package:speakup_connect/features/help/presentation/screens/help_article_screen.dart';
import 'package:speakup_connect/features/help/presentation/screens/help_hub_screen.dart';
import 'package:speakup_connect/features/notifications/presentation/screens/alerts_screen.dart';
import 'package:speakup_connect/features/notifications/presentation/screens/notification_history_screen.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/features/reminders/presentation/screens/compose_reminder_screen.dart';
import 'package:speakup_connect/features/reminders/presentation/screens/my_broadcasts_screen.dart';
import 'package:speakup_connect/features/reminders/presentation/screens/reminder_approval_queue_screen.dart';
import 'package:speakup_connect/features/reports/presentation/screens/home_dashboard_screen.dart';
import 'package:speakup_connect/features/reports/presentation/screens/my_reports_screen.dart';
import 'package:speakup_connect/features/reports/presentation/screens/report_confirmation_screen.dart';
import 'package:speakup_connect/features/reports/presentation/screens/report_details_screen.dart';
import 'package:speakup_connect/features/reports/presentation/screens/submit_report_screen.dart';
import 'package:speakup_connect/features/roles/presentation/screens/assign_role_screen.dart';
import 'package:speakup_connect/features/roles/presentation/screens/capabilities_screen.dart';
import 'package:speakup_connect/features/roles/presentation/screens/role_editor_screen.dart';
import 'package:speakup_connect/features/roles/presentation/screens/roles_management_screen.dart';
import 'package:speakup_connect/features/roles/presentation/screens/user_assignments_screen.dart';
import 'package:speakup_connect/features/settings/presentation/screens/change_password_screen.dart';
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

      final isOnBlockedScreen = loc == Routes.accountBlocked;
      final isOnUnenrolledScreen = loc == Routes.accountUnenrolled;

      // Unauthenticated → login.
      if (!isAuthenticated && !isOnAuthPage) {
        return Routes.login;
      }

      if (isAuthenticated) {
        final profile = profileAsync.asData?.value;

        // No profile yet, or profile exists but join form not submitted.
        if (!isOnJoinFlow &&
            (profile == null || !profile.applicationSubmitted)) {
          return Routes.applyToJoin;
        }

        // Join form submitted — pending or rejected → waiting screen.
        if (profile != null &&
            profile.applicationSubmitted &&
            !profile.isApproved &&
            !isOnJoinFlow) {
          return Routes.pendingApproval;
        }

        // Unenrolled former members.
        if (profile != null && profile.isUnenrolled) {
          if (!isOnUnenrolledScreen) return Routes.accountUnenrolled;
        } else if (isOnUnenrolledScreen) {
          return Routes.home;
        }

        // Blocked enrolled members → restriction screen only.
        if (profile != null && profile.isApproved && profile.isBlocked) {
          if (!isOnBlockedScreen) return Routes.accountBlocked;
        } else if (isOnBlockedScreen) {
          return Routes.home;
        }

        // Profile approved → redirect away from auth/join pages.
        if (profile != null && profile.isApproved) {
          if (isOnAuthPage || isOnJoinFlow) return Routes.home;
          // Admin routes — report triage vs full admin settings.
          if (loc.startsWith('/admin')) {
            final canTriageReports = ref.read(canAccessAdminReportsProvider);
            final isReportTriageRoute = loc == Routes.adminDashboard ||
                loc.startsWith('/admin/reports/');
            if (isReportTriageRoute && !canTriageReports) {
              return Routes.home;
            }
            if (!isReportTriageRoute && !profile.isAdmin) {
              if (loc == Routes.translationWorkspace &&
                  ref.read(canManageTranslationsProvider)) {
                // Translation moderators may access /admin/translations only.
              } else {
                return Routes.home;
              }
            }
          }
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
      GoRoute(
        path: Routes.changePassword,
        name: 'changePassword',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: Routes.announcements,
        name: 'announcements',
        builder: (context, state) => const AnnouncementsScreen(),
      ),
      GoRoute(
        path: Routes.composeAnnouncement,
        name: 'composeAnnouncement',
        builder: (context, state) => ComposeAnnouncementScreen(
          initialGroupId: state.uri.queryParameters['groupId'],
        ),
      ),
      GoRoute(
        path: Routes.myAnnouncements,
        name: 'myAnnouncements',
        builder: (context, state) => const MyAnnouncementsScreen(),
      ),
      GoRoute(
        path: Routes.announcementDetail,
        name: 'announcementDetail',
        builder: (context, state) {
          final bulletinId = state.pathParameters['bulletinId']!;
          return AnnouncementDetailScreen(bulletinId: bulletinId);
        },
      ),
      GoRoute(
        path: Routes.helpHub,
        name: 'helpHub',
        builder: (context, state) => const HelpHubScreen(),
      ),
      GoRoute(
        path: Routes.helpArticle,
        name: 'helpArticle',
        builder: (context, state) {
          final articleId = state.pathParameters['articleId']!;
          return HelpArticleScreen(articleId: articleId);
        },
      ),

      // --- Alerts & Reminders ---
      GoRoute(
        path: Routes.alerts,
        name: 'alerts',
        builder: (context, state) => const AlertsScreen(),
      ),
      GoRoute(
        path: Routes.composeReminder,
        name: 'composeReminder',
        builder: (context, state) => ComposeReminderScreen(
          initialGroupId: state.uri.queryParameters['groupId'],
        ),
      ),
      GoRoute(
        path: Routes.reminderApprovals,
        name: 'reminderApprovals',
        builder: (context, state) => const ReminderApprovalQueueScreen(),
      ),
      GoRoute(
        path: Routes.myBroadcasts,
        name: 'myBroadcasts',
        builder: (context, state) => const MyBroadcastsScreen(),
      ),
      GoRoute(
        path: Routes.notificationHistory,
        name: 'notificationHistory',
        builder: (context, state) => const NotificationHistoryScreen(),
      ),
      GoRoute(
        path: Routes.memberApprovals,
        name: 'memberApprovals',
        builder: (context, state) => const MemberApprovalQueueScreen(),
      ),
      GoRoute(
        path: Routes.enrolledUsers,
        name: 'enrolledUsers',
        builder: (context, state) => const EnrolledUsersScreen(),
      ),
      GoRoute(
        path: Routes.editMember,
        name: 'editMember',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return EditMemberScreen(userId: userId);
        },
      ),
      GoRoute(
        path: Routes.rosterManagement,
        name: 'rosterManagement',
        builder: (context, state) => const RosterManagementScreen(),
      ),
      GoRoute(
        path: Routes.addStudent,
        name: 'addStudent',
        builder: (context, state) => const AddStudentScreen(),
      ),
      GoRoute(
        path: Routes.schoolGradesSettings,
        name: 'schoolGradesSettings',
        builder: (context, state) => const SchoolGradesSettingsScreen(),
      ),
      GoRoute(
        path: Routes.groupsList,
        name: 'groupsList',
        builder: (context, state) => const GroupsListScreen(),
      ),
      GoRoute(
        path: Routes.myGroups,
        name: 'myGroups',
        builder: (context, state) => const MyGroupsScreen(),
      ),
      GoRoute(
        path: Routes.browseGroups,
        name: 'browseGroups',
        builder: (context, state) => const BrowseGroupsScreen(),
      ),
      GoRoute(
        path: Routes.groupMembershipRequests,
        name: 'groupMembershipRequests',
        redirect: (context, state) {
          final groupId = state.pathParameters['groupId'];
          if (groupId == null) return Routes.groupsList;
          final canReview =
              ref.read(canReviewGroupMembershipRequestsProvider(groupId));
          if (!canReview) return Routes.groupMembersPath(groupId);
          return null;
        },
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return GroupMembershipRequestsScreen(groupId: groupId);
        },
      ),
      GoRoute(
        path: Routes.createGroup,
        name: 'createGroup',
        redirect: (context, state) {
          final canManage = ref.read(canManageGroupsProvider);
          return canManage ? null : Routes.groupsList;
        },
        builder: (context, state) => const CreateGroupScreen(),
      ),
      GoRoute(
        path: Routes.groupMembers,
        name: 'groupMembers',
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return GroupMembersScreen(groupId: groupId);
        },
        routes: [
          GoRoute(
            path: 'add',
            name: 'addGroupMembers',
            redirect: (context, state) {
              final groupId = state.pathParameters['groupId'];
              if (groupId == null) return Routes.groupsList;
              final canManage =
                  ref.read(canManageGroupRosterProvider(groupId));
              if (!canManage) return Routes.groupMembersPath(groupId);
              return null;
            },
            builder: (context, state) {
              final groupId = state.pathParameters['groupId']!;
              return AddGroupMembersScreen(groupId: groupId);
            },
          ),
        ],
      ),
      GoRoute(
        path: Routes.editGroupPositionRoles,
        name: 'editGroupPositionRoles',
        redirect: (context, state) {
          final canManage = ref.read(canManageGroupsProvider);
          final groupId = state.pathParameters['groupId'];
          if (!canManage) {
            return groupId != null
                ? Routes.groupMembersPath(groupId)
                : Routes.groupsList;
          }
          return null;
        },
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return EditGroupPositionRolesScreen(groupId: groupId);
        },
      ),
      GoRoute(
        path: Routes.accountBlocked,
        name: 'accountBlocked',
        builder: (context, state) => const BlockedAccountScreen(),
      ),
      GoRoute(
        path: Routes.accountUnenrolled,
        name: 'accountUnenrolled',
        builder: (context, state) => const UnenrolledAccountScreen(),
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
        path: Routes.translationWorkspace,
        name: 'translationWorkspace',
        builder: (context, state) => const TranslationWorkspaceScreen(),
      ),
      GoRoute(
        path: Routes.adminSettings,
        name: 'adminSettings',
        builder: (context, state) => const AdminBrandingScreen(),
      ),
      GoRoute(
        path: Routes.adminRoles,
        name: 'adminRoles',
        builder: (context, state) => const RolesManagementScreen(),
      ),
      GoRoute(
        path: Routes.adminRoleNew,
        name: 'adminRoleNew',
        builder: (context, state) => const RoleEditorScreen(roleId: 'new'),
      ),
      GoRoute(
        path: Routes.adminRoleEdit,
        name: 'adminRoleEdit',
        builder: (context, state) {
          final roleId = state.pathParameters['roleId']!;
          return RoleEditorScreen(roleId: roleId);
        },
      ),
      GoRoute(
        path: Routes.adminRoleAssign,
        name: 'adminRoleAssign',
        builder: (context, state) {
          final roleId = state.pathParameters['roleId']!;
          return AssignRoleScreen(roleId: roleId);
        },
      ),
      GoRoute(
        path: Routes.adminCapabilities,
        name: 'adminCapabilities',
        builder: (context, state) => const CapabilitiesScreen(),
      ),
      GoRoute(
        path: Routes.adminUserAssignments,
        name: 'adminUserAssignments',
        builder: (context, state) => const UserAssignmentsScreen(),
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


