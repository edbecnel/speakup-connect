import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/features/admin/presentation/widgets/admin_filter_bar.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
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

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.go(Routes.home)),
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
              icon: const Icon(Icons.manage_accounts_outlined),
              tooltip: 'Roles & Permissions',
              onPressed: () => context.push(Routes.adminRoles),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Branding Settings',
              onPressed: () => context.push(Routes.adminSettings),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Submitted'),
              Tab(text: 'In Progress'),
              Tab(text: 'Resolved'),
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
                  _AdminReportsList(),
                  _AdminReportsList(filterStatus: ReportStatus.submitted),
                  _AdminReportsList(filterStatus: ReportStatus.inProgress),
                  _AdminReportsList(filterStatus: ReportStatus.resolved),
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
    final allAsync = ref.watch(allReportsProvider(null));
    final theme = Theme.of(context);

    return allAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (reports) {
        final total = reports.length;
        final submitted =
            reports.where((r) => r.status == ReportStatus.submitted).length;
        final inProgress =
            reports.where((r) => r.status == ReportStatus.inProgress).length;
        final resolved =
            reports.where((r) => r.status == ReportStatus.resolved).length;

        return Container(
          color: theme.colorScheme.surfaceContainerLow,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _StatChip(label: 'Total', count: total, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              _StatChip(label: 'Submitted', count: submitted, color: const Color(0xFF1565C0)),
              const SizedBox(width: 8),
              _StatChip(label: 'In Progress', count: inProgress, color: const Color(0xFFF57F17)),
              const SizedBox(width: 8),
              _StatChip(label: 'Resolved', count: resolved, color: const Color(0xFF2E7D32)),
            ],
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
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
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
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
  const _AdminReportsList({this.filterStatus});

  final ReportStatus? filterStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allReportsAsync = ref.watch(allReportsProvider(filterStatus));

    return allReportsAsync.when(
      loading: () => const AppLoadingIndicator(message: 'Loading reports...'),
      error: (e, _) => AppErrorWidget(
        message: 'Failed to load reports',
        onRetry: () => ref.invalidate(allReportsProvider(filterStatus)),
      ),
      data: (reports) {
        final categoryFilter = ref.watch(adminCategoryFilterProvider);
        final searchQuery =
            ref.watch(adminSearchQueryProvider).trim().toLowerCase();

        var filtered = categoryFilter.isEmpty
            ? reports
            : reports.where((r) => categoryFilter.contains(r.categoryId)).toList();

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
                : filterStatus == null
                    ? 'No reports submitted yet.'
                    : 'No "${filterStatus!.label}" reports.',
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

// --- Providers ---

final allReportsProvider = StreamProvider.family<List<ReportEntity>, ReportStatus?>(
  (ref, filterStatus) => ref.watch(reportRepositoryProvider).watchAllReports(
        organizationId: AppConfig.defaultOrganizationId,
        filterStatus: filterStatus,
      ),
);
