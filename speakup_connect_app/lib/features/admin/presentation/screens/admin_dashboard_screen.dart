import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/admin/presentation/l10n/admin_ui_l10n.dart';
import 'package:speakup_connect/features/admin/presentation/widgets/admin_filter_bar.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/features/reminders/presentation/providers/reminder_provider.dart';
import 'package:speakup_connect/features/reports/domain/entities/report_entity.dart';
import 'package:speakup_connect/features/reports/presentation/providers/report_provider.dart';
import 'package:speakup_connect/features/translations/presentation/widgets/translation_anchor.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';
import 'package:speakup_connect/shared/widgets/notification_badge_icon.dart';

/// Admin Dashboard — visible only to users with the 'admin' role.
///
/// Shows all organization reports with filter tabs and status management.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  static const BoxConstraints _actionConstraints = BoxConstraints(
    minWidth: 42,
    minHeight: 42,
  );
  static const VisualDensity _actionDensity = VisualDensity(
    horizontal: -2,
    vertical: -2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pendingCount = ref.watch(pendingMemberApplicationCountProvider);
    final pendingReminderCount = ref.watch(pendingReminderCountProvider);
    final supportsGrades = ref.watch(orgSupportsStudentGradesProvider);

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 60,
          leading: BackButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(Routes.home);
              }
            },
          ),
          actions: [
            IconButton(
              constraints: _actionConstraints,
              visualDensity: _actionDensity,
              padding: const EdgeInsets.all(6),
              tooltip: l10n.adminDashboardJoinApplicationsTooltip,
              onPressed: () => context.push(Routes.memberApprovals),
              icon: NotificationBadgeIcon(
                icon: Icons.person_add_alt_1_outlined,
                unreadCount: pendingCount,
              ),
            ),
            IconButton(
              constraints: _actionConstraints,
              visualDensity: _actionDensity,
              padding: const EdgeInsets.all(6),
              tooltip: l10n.adminDashboardPendingApprovalsTooltip,
              onPressed: () => context.push(Routes.reminderApprovals),
              icon: NotificationBadgeIcon(
                icon: Icons.fact_check_outlined,
                unreadCount: pendingReminderCount,
              ),
            ),
            IconButton(
              constraints: _actionConstraints,
              visualDensity: _actionDensity,
              padding: const EdgeInsets.all(6),
              tooltip: l10n.adminDashboardMemberManagementTooltip,
              onPressed: () => context.push(Routes.enrolledUsers),
              icon: const Icon(Icons.people_outline),
            ),
            if (supportsGrades) ...[
              IconButton(
                constraints: _actionConstraints,
                visualDensity: _actionDensity,
                padding: const EdgeInsets.all(6),
                tooltip: l10n.adminDashboardStudentRosterTooltip,
                onPressed: () => context.push(Routes.rosterManagement),
                icon: const Icon(Icons.school_outlined),
              ),
              IconButton(
                constraints: _actionConstraints,
                visualDensity: _actionDensity,
                padding: const EdgeInsets.all(6),
                tooltip: l10n.adminDashboardSchoolGradesTooltip,
                onPressed: () => context.push(Routes.schoolGradesSettings),
                icon: const Icon(Icons.format_list_numbered_outlined),
              ),
            ],
            IconButton(
              constraints: _actionConstraints,
              visualDensity: _actionDensity,
              padding: const EdgeInsets.all(6),
              icon: const Icon(Icons.manage_accounts_outlined),
              tooltip: l10n.adminDashboardRolesTooltip,
              onPressed: () => context.push(Routes.adminRoles),
            ),
            IconButton(
              constraints: _actionConstraints,
              visualDensity: _actionDensity,
              padding: const EdgeInsets.all(6),
              icon: const Icon(Icons.settings_outlined),
              tooltip: l10n.adminDashboardOrgSettingsTooltip,
              onPressed: () => context.push(Routes.adminSettings),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(
                child: TranslationAnchor(
                  stringKey: 'adminDashboardTabAll',
                  text: l10n.adminDashboardTabAll,
                  maxLines: 1,
                ),
              ),
              Tab(
                child: TranslationAnchor(
                  stringKey: 'adminDashboardTabSubmitted',
                  text: l10n.adminDashboardTabSubmitted,
                  maxLines: 1,
                ),
              ),
              Tab(
                child: TranslationAnchor(
                  stringKey: 'adminDashboardTabUnderReview',
                  text: l10n.adminDashboardTabUnderReview,
                  maxLines: 1,
                ),
              ),
              Tab(
                child: TranslationAnchor(
                  stringKey: 'adminDashboardTabInProgress',
                  text: l10n.adminDashboardTabInProgress,
                  maxLines: 1,
                ),
              ),
              Tab(
                child: TranslationAnchor(
                  stringKey: 'adminDashboardTabResolved',
                  text: l10n.adminDashboardTabResolved,
                  maxLines: 1,
                ),
              ),
              Tab(
                child: TranslationAnchor(
                  stringKey: 'adminDashboardTabClosed',
                  text: l10n.adminDashboardTabClosed,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            const _QuickStatsHeader(),
            const _SearchBar(),
            const AdminFilterBar(),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                children: [
                  _AdminReportsList(tab: AdminReportsTab.allActive),
                  _AdminReportsList(tab: AdminReportsTab.submitted),
                  _AdminReportsList(tab: AdminReportsTab.underReview),
                  _AdminReportsList(tab: AdminReportsTab.inProgress),
                  _AdminReportsList(tab: AdminReportsTab.resolved),
                  _AdminReportsList(tab: AdminReportsTab.closed),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStatsHeader extends ConsumerWidget {
  const _QuickStatsHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final allAsync = ref.watch(allReportsProvider(AdminReportsTab.allActive));
    final theme = Theme.of(context);

    return allAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (reports) {
        final active = _activeReports(reports);
        final total = active.length;
        final submitted =
            active.where((r) => r.status == ReportStatus.submitted).length;
        final underReview =
            active.where((r) => r.status == ReportStatus.underReview).length;
        final inProgress =
            active.where((r) => r.status == ReportStatus.inProgress).length;
        final resolved =
            active.where((r) => r.status == ReportStatus.resolved).length;
        final closed =
            reports.where((r) => r.status == ReportStatus.closed).length;

        final tabController = DefaultTabController.of(context);

        return Container(
          color: theme.colorScheme.surfaceContainerLow,
          child: AnimatedBuilder(
            animation: tabController,
            builder: (context, _) {
              final selectedTab = tabController.index;

              void selectTab(AdminReportsTab tab) {
                tabController.animateTo(tab.tabIndex);
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _StatChip(
                      stringKey: 'adminDashboardStatTotal',
                      label: localizedAdminReportsStatLabel(
                        l10n,
                        AdminReportsTab.allActive,
                      ),
                      count: total,
                      color: theme.colorScheme.primary,
                      selected: selectedTab == AdminReportsTab.allActive.tabIndex,
                      onTap: () => selectTab(AdminReportsTab.allActive),
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      stringKey: 'adminDashboardStatSubmitted',
                      label: localizedAdminReportsStatLabel(
                        l10n,
                        AdminReportsTab.submitted,
                      ),
                      count: submitted,
                      color: const Color(0xFF1565C0),
                      selected:
                          selectedTab == AdminReportsTab.submitted.tabIndex,
                      onTap: () => selectTab(AdminReportsTab.submitted),
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      stringKey: 'adminDashboardStatUnderReview',
                      label: localizedAdminReportsStatLabel(
                        l10n,
                        AdminReportsTab.underReview,
                      ),
                      count: underReview,
                      color: const Color(0xFFF9A825),
                      selected:
                          selectedTab == AdminReportsTab.underReview.tabIndex,
                      onTap: () => selectTab(AdminReportsTab.underReview),
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      stringKey: 'adminDashboardStatInProgress',
                      label: localizedAdminReportsStatLabel(
                        l10n,
                        AdminReportsTab.inProgress,
                      ),
                      count: inProgress,
                      color: const Color(0xFFF57F17),
                      selected:
                          selectedTab == AdminReportsTab.inProgress.tabIndex,
                      onTap: () => selectTab(AdminReportsTab.inProgress),
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      stringKey: 'adminDashboardStatResolved',
                      label: localizedAdminReportsStatLabel(
                        l10n,
                        AdminReportsTab.resolved,
                      ),
                      count: resolved,
                      color: const Color(0xFF2E7D32),
                      selected:
                          selectedTab == AdminReportsTab.resolved.tabIndex,
                      onTap: () => selectTab(AdminReportsTab.resolved),
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      stringKey: 'adminDashboardStatClosed',
                      label: localizedAdminReportsStatLabel(
                        l10n,
                        AdminReportsTab.closed,
                      ),
                      count: closed,
                      color: theme.colorScheme.onSurfaceVariant,
                      selected: selectedTab == AdminReportsTab.closed.tabIndex,
                      onTap: () => selectTab(AdminReportsTab.closed),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
    this.selected = false,
    this.stringKey,
  });

  final String label;
  final int count;
  final Color color;
  final VoidCallback onTap;
  final bool selected;
  final String? stringKey;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labelStyle = TextStyle(
      fontSize: 11,
      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      color: color,
    );
    return Semantics(
      button: true,
      label: l10n.adminDashboardReportsCount(label, count),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            width: 88,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: selected ? 0.22 : 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withValues(alpha: selected ? 0.85 : 0.3),
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                if (stringKey != null)
                  TranslationAnchor(
                    stringKey: stringKey!,
                    text: label,
                    style: labelStyle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  )
                else
                  Text(
                    label,
                    style: labelStyle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends ConsumerWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final query = ref.watch(adminSearchQueryProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        decoration: InputDecoration(
          hintText: l10n.adminDashboardSearchHint,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () =>
                      ref.read(adminSearchQueryProvider.notifier).set(''),
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
        onChanged: (value) =>
            ref.read(adminSearchQueryProvider.notifier).set(value),
      ),
    );
  }
}

class _AdminReportsList extends ConsumerWidget {
  const _AdminReportsList({required this.tab});

  final AdminReportsTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final allReportsAsync = ref.watch(allReportsProvider(tab));

    return allReportsAsync.when(
      loading: () =>
          AppLoadingIndicator(message: l10n.adminDashboardLoadingReports),
      error: (e, _) => AppErrorWidget(
        message: l10n.adminDashboardLoadFailed,
        onRetry: () => ref.invalidate(allReportsProvider(tab)),
      ),
      data: (reports) {
        final categoryFilter = ref.watch(adminCategoryFilterProvider);
        final searchQuery =
            ref.watch(adminSearchQueryProvider).trim().toLowerCase();

        var filtered = _reportsForTab(reports, tab);

        filtered = categoryFilter.isEmpty
            ? filtered
            : filtered.where((r) => categoryFilter.contains(r.categoryId)).toList();

        if (searchQuery.isNotEmpty) {
          filtered = filtered
              .where((r) =>
                  r.title.toLowerCase().contains(searchQuery) ||
                  (r.referenceNumber?.toLowerCase().contains(searchQuery) ??
                      false))
              .toList();
        }

        if (filtered.isEmpty) {
          return AppEmptyState(
            icon: Icons.assignment_outlined,
            message: searchQuery.isNotEmpty
                ? l10n.adminDashboardNoResults
                : l10n.adminDashboardNoReports,
            subtitle: searchQuery.isNotEmpty
                ? l10n.adminDashboardNoReportsMatch(searchQuery)
                : switch (tab) {
                    AdminReportsTab.allActive =>
                      l10n.adminDashboardNoActiveReports,
                    AdminReportsTab.closed => l10n.adminDashboardNoClosedReports,
                    _ => l10n.adminDashboardNoTabReports(
                        localizedAdminReportsTab(l10n, tab),
                      ),
                  },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (_, i) => _AdminReportCard(report: filtered[i]),
        );
      },
    );
  }
}

class _AdminReportCard extends ConsumerWidget {
  const _AdminReportCard({required this.report});

  final ReportEntity report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final dt = report.createdAt;
    final dateLabel = DateFormat.yMMMd().format(dt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(Routes.adminReportDetailPath(report.reportId)),
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    report.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _PriorityBadge(priority: report.priority),
              ],
            ),
            const SizedBox(height: 6),
            if (report.referenceNumber != null)
              Text(
                report.referenceNumber!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              report.isAnonymous
                  ? l10n.adminDashboardAnonymousDate(dateLabel)
                  : l10n.adminDashboardSubmitterDate(
                      report.submitterDisplayName ?? l10n.commonUnknown,
                      dateLabel,
                    ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatusDropdown(report: report),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _StatusDropdown extends ConsumerWidget {
  const _StatusDropdown({required this.report});

  final ReportEntity report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.read(currentUserProvider);

    return DropdownButtonFormField<ReportStatus>(
      initialValue: report.status,
      decoration: InputDecoration(
        labelText: l10n.commonStatus,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      items: ReportStatus.values
          .map(
            (s) => DropdownMenuItem(
              value: s,
              child: Text(localizedReportStatus(l10n, s)),
            ),
          )
          .toList(),
      onChanged: (newStatus) async {
        if (newStatus == null || newStatus == report.status) return;
        try {
          await ref.read(reportRepositoryProvider).updateReportStatus(
                organizationId: AppConfig.defaultOrganizationId,
                reportId: report.reportId,
                newStatus: newStatus,
                changedByUid: user?.uid ?? 'admin',
              );
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.adminDashboardUpdateStatusFailed('$e')),
              ),
            );
          }
        }
      },
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final ReportPriority priority;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (color, bg) = switch (priority) {
      ReportPriority.low => (const Color(0xFF37474F), const Color(0xFFECEFF1)),
      ReportPriority.medium => (const Color(0xFF1565C0), const Color(0xFFE3F2FD)),
      ReportPriority.high => (const Color(0xFFF57F17), const Color(0xFFFFF8E1)),
      ReportPriority.urgent => (const Color(0xFFB71C1C), const Color(0xFFFFEBEE)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        localizedReportPriority(l10n, priority),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// --- Tab filter ---

/// Admin dashboard report tabs. [allActive] excludes closed reports.
enum AdminReportsTab {
  allActive('All'),
  submitted('Submitted'),
  underReview('Under Review'),
  inProgress('In Progress'),
  resolved('Resolved'),
  closed('Closed');

  const AdminReportsTab(this.label);

  final String label;

  ReportStatus? get statusFilter => switch (this) {
        AdminReportsTab.allActive => null,
        AdminReportsTab.submitted => ReportStatus.submitted,
        AdminReportsTab.underReview => ReportStatus.underReview,
        AdminReportsTab.inProgress => ReportStatus.inProgress,
        AdminReportsTab.resolved => ReportStatus.resolved,
        AdminReportsTab.closed => ReportStatus.closed,
      };

  /// Index in the dashboard [TabBar] / [TabBarView].
  int get tabIndex => AdminReportsTab.values.indexOf(this);
}

List<ReportEntity> _activeReports(List<ReportEntity> reports) =>
    reports.where((r) => r.status != ReportStatus.closed).toList();

List<ReportEntity> _reportsForTab(List<ReportEntity> reports, AdminReportsTab tab) {
  if (tab == AdminReportsTab.allActive) return _activeReports(reports);
  final status = tab.statusFilter;
  if (status == null) return reports;
  return reports.where((r) => r.status == status).toList();
}

// --- Providers ---

final allReportsProvider = StreamProvider.family<List<ReportEntity>, AdminReportsTab>(
  (ref, tab) => ref.watch(reportRepositoryProvider).watchAllReports(
        organizationId: AppConfig.defaultOrganizationId,
        filterStatus: tab.statusFilter,
      ),
);
