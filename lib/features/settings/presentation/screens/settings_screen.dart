import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
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
    final supportsGrades = ref.watch(orgSupportsStudentGradesProvider);
    final canTriageReports = ref.watch(canAccessAdminReportsProvider);
    final canManageGroups = ref.watch(canManageGroupsProvider);

    final orgName = orgConfigAsync.value?.displayName ?? '—';
    final theme = Theme.of(context);

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
                CircleAvatar(
                  radius: 32,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    _initials(user?.displayName),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Anonymous',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (user?.email != null)
                        Text(
                          user!.email!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      Text(
                        'SpeakUp $orgName',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
            onTap: () {
              // TODO: Navigate to change password — Sprint 2
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Change password — coming soon')),
              );
            },
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

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
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
