import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/reports/domain/entities/report_entity.dart';
import 'package:speakup_connect/features/reports/presentation/providers/report_provider.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';

/// Admin Dashboard — visible only to users with the 'admin' role.
///
/// Shows all organization reports with filter tabs and status management.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Admin Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                // TODO: Admin settings — Sprint 2
              },
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
        body: TabBarView(
          children: [
            _AdminReportsList(filterStatus: null),
            _AdminReportsList(filterStatus: ReportStatus.submitted),
            _AdminReportsList(filterStatus: ReportStatus.inProgress),
            _AdminReportsList(filterStatus: ReportStatus.resolved),
          ],
        ),
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
        if (reports.isEmpty) {
          return AppEmptyState(
            icon: Icons.assignment_outlined,
            message: 'No reports',
            subtitle: filterStatus == null
                ? 'No reports submitted yet.'
                : 'No "${filterStatus!.label}" reports.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (_, i) => _AdminReportCard(report: reports[i]),
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
