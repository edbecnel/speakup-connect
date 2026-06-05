import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/features/admin/presentation/widgets/admin_filter_bar.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/features/reports/domain/entities/report_entity.dart';
import 'package:speakup_connect/features/reports/presentation/providers/report_provider.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';
import 'package:speakup_connect/shared/widgets/notification_badge_icon.dart';

/// Admin Dashboard — visible only to users with the 'admin' role.
///
/// Shows all organization reports with filter tabs and status management.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(pendingMemberApplicationCountProvider);
    final supportsGrades = ref.watch(orgSupportsStudentGradesProvider);

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(Routes.home);
              }
            },
          ),
          title: const Text('Admin Dashboard'),
          actions: [
            IconButton(
              tooltip: 'Join Applications',
              onPressed: () => context.push(Routes.memberApprovals),
              icon: NotificationBadgeIcon(
                icon: Icons.person_add_alt_1_outlined,
                unreadCount: pendingCount,
              ),
            ),
            IconButton(
              tooltip: 'Member Management',
              onPressed: () => context.push(Routes.enrolledUsers),
              icon: const Icon(Icons.people_outline),
            ),
            if (supportsGrades) ...[
              IconButton(
                tooltip: 'Student Roster',
                onPressed: () => context.push(Routes.rosterManagement),
                icon: const Icon(Icons.school_outlined),
              ),
              IconButton(
                tooltip: 'School Grades',
                onPressed: () => context.push(Routes.schoolGradesSettings),
                icon: const Icon(Icons.format_list_numbered_outlined),
              ),
            ],
            IconButton(
              icon: const Icon(Icons.manage_accounts_outlined),
              tooltip: 'Roles & Permissions',
              onPressed: () => context.push(Routes.adminRoles),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Organization Settings',
              onPressed: () => context.push(Routes.adminSettings),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Submitted'),
              Tab(text: 'Under Review'),
              Tab(text: 'In Progress'),
              Tab(text: 'Resolved'),
              Tab(text: 'Closed'),
            ],
          ),
        ),
        body: const Column(
          children: [
            _QuickStatsHeader(),
            _SearchBar(),
            AdminFilterBar(),
            Divider(height: 1),
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
                      label: 'Total',
                      count: total,
                      color: theme.colorScheme.primary,
                      selected: selectedTab == AdminReportsTab.allActive.tabIndex,
                      onTap: () => selectTab(AdminReportsTab.allActive),
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'Submitted',
                      count: submitted,
                      color: const Color(0xFF1565C0),
                      selected:
                          selectedTab == AdminReportsTab.submitted.tabIndex,
                      onTap: () => selectTab(AdminReportsTab.submitted),
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'Under Review',
                      count: underReview,
                      color: const Color(0xFFF9A825),
                      selected:
                          selectedTab == AdminReportsTab.underReview.tabIndex,
                      onTap: () => selectTab(AdminReportsTab.underReview),
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'In Progress',
                      count: inProgress,
                      color: const Color(0xFFF57F17),
                      selected:
                          selectedTab == AdminReportsTab.inProgress.tabIndex,
                      onTap: () => selectTab(AdminReportsTab.inProgress),
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'Resolved',
                      count: resolved,
                      color: const Color(0xFF2E7D32),
                      selected:
                          selectedTab == AdminReportsTab.resolved.tabIndex,
                      onTap: () => selectTab(AdminReportsTab.resolved),
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'Closed',
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
  });

  final String label;
  final int count;
  final Color color;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label: $count reports',
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
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                  ),
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
    final query = ref.watch(adminSearchQueryProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by title or reference number...',
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
    final allReportsAsync = ref.watch(allReportsProvider(tab));

    return allReportsAsync.when(
      loading: () => const AppLoadingIndicator(message: 'Loading reports...'),
      error: (e, _) => AppErrorWidget(
        message: 'Failed to load reports',
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
            message: searchQuery.isNotEmpty ? 'No results' : 'No reports',
            subtitle: searchQuery.isNotEmpty
                ? 'No reports match "$searchQuery".'
                : switch (tab) {
                    AdminReportsTab.allActive =>
                      'No active reports submitted yet.',
                    AdminReportsTab.closed => 'No closed reports.',
                    _ => 'No "${tab.label}" reports.',
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
    final theme = Theme.of(context);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dt = report.createdAt;
    final dateLabel = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';

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
                  ? 'Anonymous · $dateLabel'
                  : '${report.submitterDisplayName ?? 'Unknown'} · $dateLabel',
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
    final user = ref.read(currentUserProvider);

    return DropdownButtonFormField<ReportStatus>(
      initialValue: report.status,
      decoration: const InputDecoration(
        labelText: 'Status',
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      items: ReportStatus.values
          .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
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
              SnackBar(content: Text('Failed to update status: $e')),
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
        priority.label,
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
