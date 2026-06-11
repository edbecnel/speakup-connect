import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_membership_provider.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/reminders/presentation/providers/reminder_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/profile_photo_provider.dart';
import 'package:speakup_connect/features/organization/presentation/widgets/member_profile_account_section.dart';
import 'package:speakup_connect/features/organization/presentation/widgets/profile_photo_picker.dart';
import 'package:speakup_connect/features/settings/presentation/providers/settings_provider.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/notification_badge_icon.dart';

/// Settings / Profile screen.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final orgConfigAsync = ref.watch(organizationConfigProvider);
    final themeMode = ref.watch(themeModeProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.value;
    final pendingJoinCount = ref.watch(pendingMemberApplicationCountProvider);
    final pendingReminderCount = ref.watch(pendingReminderCountProvider);
    final pendingGroupRequestsCount =
        ref.watch(myReviewablePendingMembershipCountProvider);
    final supportsGrades = ref.watch(orgSupportsStudentGradesProvider);
    final canTriageReports = ref.watch(canAccessAdminReportsProvider);
    final canManageGroups = ref.watch(canManageGroupsProvider);
    final canComposeAlerts = ref.watch(canComposeRemindersProvider);
    final leaderOnlyAlerts = ref.watch(isGroupLeaderOnlyComposerProvider);

    final orgName = orgConfigAsync.value?.displayName ?? '—';
    final theme = Theme.of(context);
    final photoBusy = ref.watch(profilePhotoProvider).isLoading;
    final allowPersonalPhotos = ref.watch(allowMemberProfilePhotosProvider);
    final displayName =
        user?.displayName ?? profile?.fullName ?? 'Anonymous';

    ref.listen(profilePhotoProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading && next.hasError) {
        final err = next.error;
        final message = err is AppException
            ? err.message
            : err?.toString() ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not update photo: $message'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(Routes.home)),
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // --- Profile Section ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ProfilePhotoPicker(
                  displayName: displayName,
                  avatarUrl: profile?.avatarUrl,
                  officialPhotoUrl: profile?.officialPhotoUrl,
                  isLoading: photoBusy,
                  showRemove: allowPersonalPhotos &&
                      profile?.avatarUrl != null &&
                      profile!.avatarUrl!.isNotEmpty,
                  onPick: (path) async {
                    if (!allowPersonalPhotos) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Personal profile photos are not enabled. '
                              'Ask an administrator to turn on “Allow personal '
                              'profile photos” under Organization Settings.',
                            ),
                          ),
                        );
                      }
                      return;
                    }
                    final ok = await ref
                        .read(profilePhotoProvider.notifier)
                        .uploadMemberAvatar(path);
                    if (context.mounted && ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Personal profile photo updated'),
                        ),
                      );
                    }
                  },
                  onRemove: allowPersonalPhotos
                      ? () async {
                          final ok = await ref
                              .read(profilePhotoProvider.notifier)
                              .clearMemberAvatar();
                          if (context.mounted && ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Personal photo removed — showing school photo',
                                ),
                              ),
                            );
                          }
                        }
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'SpeakUp $orgName',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        allowPersonalPhotos
                            ? 'Tap your photo to change your personal badge'
                            : (profile?.officialPhotoUrl != null &&
                                    profile!.officialPhotoUrl!.isNotEmpty
                                ? 'School photo on file — ask an admin to enable personal uploads'
                                : 'Tap your photo — personal uploads require admin approval'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const MemberProfileAccountSection(),

          const Divider(),

          // --- My groups ---
          const _SectionHeader(title: 'Groups & Clubs'),
          ListTile(
            leading: NotificationBadgeIcon(
              icon: Icons.groups_outlined,
              unreadCount: pendingGroupRequestsCount,
            ),
            title: const Text('My Groups & Clubs'),
            subtitle: Text(
              pendingGroupRequestsCount > 0
                  ? '$pendingGroupRequestsCount pending membership request(s)'
                  : 'Clubs and organizations you belong to',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(Routes.myGroups),
          ),
          ListTile(
            leading: const Icon(Icons.search_rounded),
            title: const Text('Browse Groups & Clubs'),
            subtitle: const Text('Discover clubs and request to join'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(Routes.browseGroups),
          ),
          if (canComposeAlerts)
            ListTile(
              leading: const Icon(Icons.outbox_outlined),
              title: Text(leaderOnlyAlerts ? 'Sent Group Alerts' : 'My Broadcasts'),
              subtitle: Text(
                leaderOnlyAlerts
                    ? 'View alerts you sent and member responses'
                    : 'Manage sent reminders and view responses',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(Routes.myBroadcasts),
            ),

          const Divider(),

          // --- Appearance ---
          const _SectionHeader(title: 'Appearance'),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Theme'),
            subtitle: Text(themeMode.label),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showThemeSelector(context, ref, themeMode),
          ),

          const Divider(),

          // --- Account ---
          const _SectionHeader(title: 'Account'),
          ListTile(
            leading: const Icon(Icons.lock_outline_rounded),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(Routes.changePassword),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notification Preferences'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              // TODO — Sprint 2
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications — coming soon')),
              );
            },
          ),

          const Divider(),

          // --- Help ---
          const _SectionHeader(title: 'Help & Support'),
          ListTile(
            leading: const Icon(Icons.help_outline_rounded),
            title: const Text('Help Center'),
            subtitle: const Text('Guides for members and administrators'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(Routes.helpHub),
          ),

          const Divider(),

          // --- About ---
          const _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text('About ${AppConfig.appName}'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'SpeakUp $orgName',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2026 SpeakUp Connect',
              );
            },
          ),

          const Divider(),

          // --- Admin ---
          if (profile?.isAdmin == true ||
              canTriageReports ||
              canManageGroups) ...[
            const _SectionHeader(title: 'Administration'),
            if (canTriageReports)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_outlined),
                title: const Text('Admin Dashboard'),
                subtitle: const Text('Review and manage submitted reports'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(Routes.adminDashboard),
              ),
            if (profile?.isAdmin == true || canManageGroups) ...[
              ListTile(
                leading: const Icon(Icons.groups_outlined),
                title: const Text('Groups & Clubs'),
                subtitle: const Text('Create groups and manage member rosters'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(Routes.groupsList),
              ),
            ],
            if (profile?.isAdmin == true) ...[
              ListTile(
                leading: SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: NotificationBadgeIcon(
                      icon: Icons.person_add_alt_1_outlined,
                      unreadCount: pendingJoinCount,
                    ),
                  ),
                ),
                title: const Text('Join Applications'),
                subtitle: const Text('Approve new member sign-ups'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(Routes.memberApprovals),
              ),
              ListTile(
                leading: SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: NotificationBadgeIcon(
                      icon: Icons.fact_check_outlined,
                      unreadCount: pendingReminderCount,
                    ),
                  ),
                ),
                title: const Text('Pending Approvals'),
                subtitle: const Text(
                  'Review announcements and group alerts awaiting publish',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(Routes.reminderApprovals),
              ),
              ListTile(
                leading: const Icon(Icons.people_outline),
                title: const Text('Member Management'),
                subtitle: const Text(
                  'View, block, unenroll, unblock, or re-enroll members',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(Routes.enrolledUsers),
              ),
              if (supportsGrades) ...[
                ListTile(
                  leading: const Icon(Icons.school_outlined),
                  title: const Text('Student Roster'),
                  subtitle: const Text(
                    'Add students, assign grades individually or in bulk',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(Routes.rosterManagement),
                ),
                ListTile(
                  leading: const Icon(Icons.format_list_numbered_outlined),
                  title: const Text('School Grades'),
                  subtitle: const Text('Define which grade levels your school uses'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(Routes.schoolGradesSettings),
                ),
              ],
            ],
            const Divider(),
          ],

          // --- Danger Zone ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton.text(
              label: 'Sign Out',
              onPressed: () async {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) {
                  context.go(Routes.splash);
                }
              },
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref, ThemeMode current) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: RadioGroup<ThemeMode>(
          groupValue: current,
          onChanged: (v) {
            if (v != null) {
              ref.read(themeModeProvider.notifier).setThemeMode(v);
            }
            Navigator.pop(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeMode.values
                .map((mode) => RadioListTile<ThemeMode>(
                      value: mode,
                      title: Text(mode.label),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

extension on ThemeMode {
  String get label => switch (this) {
        ThemeMode.system => 'System Default',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };
}
