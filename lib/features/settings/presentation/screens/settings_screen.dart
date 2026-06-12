import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/core/l10n/locale_provider.dart';
import 'package:speakup_connect/l10n/app_localizations.dart';
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
import 'package:speakup_connect/shared/widgets/language_selector.dart';
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

    final l10n = context.l10n;
    final orgName = orgConfigAsync.value?.displayName ?? l10n.settingsOrgUnavailable;
    final theme = Theme.of(context);
    final photoBusy = ref.watch(profilePhotoProvider).isLoading;
    final allowPersonalPhotos = ref.watch(allowMemberProfilePhotosProvider);
    final displayName =
        user?.displayName ?? profile?.fullName ?? l10n.settingsAnonymous;

    ref.listen(profilePhotoProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading && next.hasError) {
        final err = next.error;
        final message = err is AppException
            ? err.message
            : err?.toString() ?? l10n.settingsUnknownError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settingsPhotoUpdateFailed(message)),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(Routes.home)),
        title: Text(l10n.settingsTitle),
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
                          SnackBar(
                            content: Text(l10n.settingsPersonalPhotosDisabled),
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
                        SnackBar(
                          content: Text(l10n.settingsPersonalPhotoUpdated),
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
                              SnackBar(
                                content: Text(l10n.settingsPersonalPhotoRemoved),
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
                        l10n.settingsSpeakUpOrg(orgName),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        allowPersonalPhotos
                            ? l10n.settingsTapPhotoChange
                            : (profile?.officialPhotoUrl != null &&
                                    profile!.officialPhotoUrl!.isNotEmpty
                                ? l10n.settingsSchoolPhotoOnFile
                                : l10n.settingsPersonalUploadsRequireApproval),
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
          _SectionHeader(title: l10n.settingsSectionGroups),
          ListTile(
            leading: NotificationBadgeIcon(
              icon: Icons.groups_outlined,
              unreadCount: pendingGroupRequestsCount,
            ),
            title: Text(l10n.settingsMyGroups),
            subtitle: Text(
              pendingGroupRequestsCount > 0
                  ? l10n.settingsPendingMembershipRequests(
                      pendingGroupRequestsCount,
                    )
                  : l10n.settingsGroupsSubtitle,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(Routes.myGroups),
          ),
          ListTile(
            leading: const Icon(Icons.search_rounded),
            title: Text(l10n.settingsBrowseGroups),
            subtitle: Text(l10n.settingsBrowseGroupsSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(Routes.browseGroups),
          ),
          if (canComposeAlerts)
            ListTile(
              leading: const Icon(Icons.outbox_outlined),
              title: Text(
                leaderOnlyAlerts
                    ? l10n.settingsSentGroupAlerts
                    : l10n.settingsMyBroadcasts,
              ),
              subtitle: Text(
                leaderOnlyAlerts
                    ? l10n.settingsSentGroupAlertsSubtitle
                    : l10n.settingsMyBroadcastsSubtitle,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(Routes.myBroadcasts),
            ),

          const Divider(),

          // --- Appearance ---
          _SectionHeader(title: l10n.settingsSectionAppearance),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.settingsLanguage),
            subtitle: Text(
              kLanguageNativeLabels[ref.watch(appLocaleProvider).languageCode] ??
                  l10n.settingsLanguageEnglish,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => showLanguagePickerSheet(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: Text(l10n.settingsTheme),
            subtitle: Text(_themeModeLabel(l10n, themeMode)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showThemeSelector(context, ref, themeMode, l10n),
          ),

          const Divider(),

          // --- Account ---
          _SectionHeader(title: l10n.settingsSectionAccount),
          ListTile(
            leading: const Icon(Icons.lock_outline_rounded),
            title: Text(l10n.settingsChangePassword),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(Routes.changePassword),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(l10n.settingsNotificationPreferences),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              // TODO — Sprint 2
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.settingsNotificationsComingSoon)),
              );
            },
          ),

          const Divider(),

          // --- Help ---
          _SectionHeader(title: l10n.settingsSectionHelp),
          ListTile(
            leading: const Icon(Icons.help_outline_rounded),
            title: Text(l10n.settingsHelpCenter),
            subtitle: Text(l10n.settingsHelpCenterSubtitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(Routes.helpHub),
          ),

          const Divider(),

          // --- About ---
          _SectionHeader(title: l10n.settingsSectionAbout),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(l10n.settingsAboutApp(AppConfig.appName)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: l10n.settingsSpeakUpOrg(orgName),
                applicationVersion: '1.0.0',
                applicationLegalese: l10n.settingsAboutLegalese,
              );
            },
          ),

          const Divider(),

          // --- Admin ---
          if (profile?.isAdmin == true ||
              canTriageReports ||
              canManageGroups) ...[
            _SectionHeader(title: l10n.settingsSectionAdmin),
            if (canTriageReports)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_outlined),
                title: Text(l10n.settingsAdminDashboard),
                subtitle: Text(l10n.settingsAdminDashboardSubtitle),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(Routes.adminDashboard),
              ),
            if (profile?.isAdmin == true || canManageGroups) ...[
              ListTile(
                leading: const Icon(Icons.groups_outlined),
                title: Text(l10n.settingsAdminGroups),
                subtitle: Text(l10n.settingsAdminGroupsSubtitle),
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
                title: Text(l10n.settingsJoinApplications),
                subtitle: Text(l10n.settingsJoinApplicationsSubtitle),
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
                title: Text(l10n.settingsPendingApprovals),
                subtitle: Text(l10n.settingsPendingApprovalsSubtitle),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(Routes.reminderApprovals),
              ),
              ListTile(
                leading: const Icon(Icons.people_outline),
                title: Text(l10n.settingsMemberManagement),
                subtitle: Text(l10n.settingsMemberManagementSubtitle),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(Routes.enrolledUsers),
              ),
              if (supportsGrades) ...[
                ListTile(
                  leading: const Icon(Icons.school_outlined),
                  title: Text(l10n.settingsStudentRoster),
                  subtitle: Text(l10n.settingsStudentRosterSubtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(Routes.rosterManagement),
                ),
                ListTile(
                  leading: const Icon(Icons.format_list_numbered_outlined),
                  title: Text(l10n.settingsSchoolGrades),
                  subtitle: Text(l10n.settingsSchoolGradesSubtitle),
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
              label: l10n.settingsSignOut,
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

  void _showThemeSelector(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
    AppLocalizations l10n,
  ) {
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
                      title: Text(_themeModeLabel(l10n, mode)),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

}

String _themeModeLabel(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
      ThemeMode.system => l10n.settingsThemeSystem,
      ThemeMode.light => l10n.settingsThemeLight,
      ThemeMode.dark => l10n.settingsThemeDark,
    };

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

