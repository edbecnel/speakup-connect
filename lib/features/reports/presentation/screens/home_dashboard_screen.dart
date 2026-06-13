import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/core/l10n/organization_type_l10n.dart';
import 'package:speakup_connect/core/theme/app_theme.dart';
import 'package:speakup_connect/features/announcements/presentation/providers/announcement_provider.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/groups/presentation/widgets/my_groups_home_section.dart';
import 'package:speakup_connect/features/notifications/presentation/providers/notification_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/shared/widgets/language_selector.dart';
import 'package:speakup_connect/shared/widgets/notification_badge_icon.dart';

/// Home Dashboard — the main screen for authenticated users.
///
/// Matches wireframe screen 3:
/// - App bar: hamburger menu, "Home" title, notification bell
/// - Welcome card with user name and org message
/// - 2×2 feature tile grid
/// - Bottom navigation bar
class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgConfigAsync = ref.watch(organizationConfigProvider);
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    final orgConfig = orgConfigAsync.value;
    final l10n = context.l10n;
    final firstName = user?.displayName?.split(' ').first ?? 'there';
    final unreadAlerts = ref.watch(unreadNotificationCountProvider);
    final unreadAnnouncements = ref.watch(unreadAnnouncementCountProvider);

    final welcomeMessage = homeWelcomeMessageForConfig(
      orgConfig,
      l10n,
      languageCode: Localizations.localeOf(context).languageCode,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {
            // TODO: Open drawer/side menu
          },
        ),
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            icon: NotificationBadgeIcon(
              icon: Icons.notifications_outlined,
              unreadCount: unreadAlerts,
            ),
            onPressed: () => context.push(Routes.alerts),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HomeLanguageSelector(),
              const SizedBox(height: 16),

              // --- Welcome Card ---
              _WelcomeCard(
                firstName: firstName,
                message: welcomeMessage,
              ),
              const SizedBox(height: 24),

              // --- Feature Grid ---
              Text(
                l10n.homeQuickActions,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _DashboardTile(
                    icon: Icons.edit_note_rounded,
                    label: l10n.homeSubmitConcern,
                    color: theme.colorScheme.primary,
                    onTap: () => context.push(Routes.submitReport),
                  ),
                  _DashboardTile(
                    icon: Icons.list_alt_rounded,
                    label: l10n.homeMyReports,
                    color: theme.colorScheme.secondary,
                    onTap: () => context.push(Routes.myReports),
                  ),
                  _DashboardTile(
                    icon: Icons.campaign_rounded,
                    label: l10n.homeAnnouncements,
                    color: unreadAnnouncements > 0
                        ? theme.colorScheme.primary
                        : const Color(0xFFF57C00),
                    badgeCount: unreadAnnouncements,
                    onTap: () => context.push(Routes.announcements),
                  ),
                  _DashboardTile(
                    icon: Icons.info_outline_rounded,
                    label: l10n.homeOrgInformation(
                      orgConfig?.displayName ?? l10n.homeOrgFallback,
                    ),
                    color: const Color(0xFF37474F),
                    onTap: () {
                      // TODO: Navigate to org info — Sprint 2
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.homeOrgInfoComingSoon)),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const MyGroupsHomeSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _AppBottomNavBar(
        currentIndex: 0,
        unreadAlerts: unreadAlerts,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.submitReport),
        child: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

/// Prominent language control — native option names stay visible before UI is translated.
class _HomeLanguageSelector extends StatelessWidget {
  const _HomeLanguageSelector();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: LanguageSelectorDropdown(),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.firstName, required this.message});

  final String firstName;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.homeWelcome(firstName),
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Ensure the tile color is visible on the current surface — e.g. a black
    // secondary in dark mode would be invisible without this adjustment.
    final effectiveColor = AppTheme.effectiveForeground(
      color,
      theme.colorScheme.onSurface,
      theme.colorScheme.surface,
    );

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Badge(
                isLabelVisible: badgeCount > 0,
                label: Text(badgeCount > 99 ? '99+' : '$badgeCount'),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: effectiveColor, size: 28),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom navigation bar used across main app screens.
class _AppBottomNavBar extends StatelessWidget {
  const _AppBottomNavBar({
    required this.currentIndex,
    required this.unreadAlerts,
  });

  final int currentIndex;
  final int unreadAlerts;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go(Routes.home);
          case 1:
            context.go(Routes.myReports);
          case 3:
            context.go(Routes.alerts);
          case 4:
            context.go(Routes.settings);
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home_rounded),
          label: l10n.homeTitle,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.list_alt_outlined),
          activeIcon: const Icon(Icons.list_alt_rounded),
          label: l10n.homeNavMyReports,
        ),
        // Index 2 is the FAB — represented as a spacer
        const BottomNavigationBarItem(
          icon: SizedBox.shrink(),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: NotificationBadgeIcon(
            icon: Icons.notifications_outlined,
            unreadCount: unreadAlerts,
          ),
          activeIcon: NotificationBadgeIcon(
            icon: Icons.notifications_rounded,
            unreadCount: unreadAlerts,
          ),
          label: l10n.homeNavAlerts,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline_rounded),
          activeIcon: const Icon(Icons.person_rounded),
          label: l10n.homeNavProfile,
        ),
      ],
    );
  }
}
