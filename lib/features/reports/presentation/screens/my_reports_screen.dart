import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/admin/presentation/l10n/admin_ui_l10n.dart';
import 'package:speakup_connect/features/reports/domain/entities/report_entity.dart';
import 'package:speakup_connect/features/reports/presentation/providers/report_provider.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';

/// "My Reports" screen — shows reports submitted by the current user.
class MyReportsScreen extends ConsumerWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tabs = [
      (label: l10n.myReportsTabAll, status: null as ReportStatus?),
      (
        label: l10n.adminDashboardTabSubmitted,
        status: ReportStatus.submitted,
      ),
      (label: l10n.myReportsTabInProgress, status: ReportStatus.inProgress),
      (label: l10n.myReportsTabResolved, status: ReportStatus.resolved),
    ];

    return DefaultTabController(
      length: tabs.length,
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
          title: Text(l10n.myReportsTitle),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: tabs.map((t) => Tab(text: t.label)).toList(),
          ),
        ),
        body: TabBarView(
          children: tabs
              .map((t) => _ReportsList(filterStatus: t.status))
              .toList(),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push(Routes.submitReport),
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.myReportsNewReport),
          shape: const StadiumBorder(),
        ),
      ),
    );
  }
}

class _ReportsList extends ConsumerWidget {
  const _ReportsList({this.filterStatus});

  final ReportStatus? filterStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final reportsAsync = ref.watch(myReportsProvider);

    return reportsAsync.when(
      loading: () => AppLoadingIndicator(message: l10n.adminReportDetailLoading),
      error: (error, _) => AppErrorWidget(
        message: l10n.adminReportDetailLoadFailed,
        onRetry: () => ref.invalidate(myReportsProvider),
      ),
      data: (reports) {
        final filtered = filterStatus == null
            ? reports
            : reports.where((r) => r.status == filterStatus).toList();

        if (filtered.isEmpty) {
          return AppEmptyState(
            icon: Icons.assignment_outlined,
            message: l10n.myReportsNoReportsYet,
            subtitle: filterStatus == null
                ? l10n.myReportsEmptyAll
                : l10n.myReportsEmptyFiltered(
                    localizedReportStatus(l10n, filterStatus!),
                  ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (_, i) => _ReportCard(report: filtered[i]),
        );
      },
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final ReportEntity report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(
          Routes.reportDetails.replaceAll(':reportId', report.reportId),
        ),
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
                  _StatusBadge(status: report.status),
                ],
              ),
              if (report.referenceNumber != null) ...[
                const SizedBox(height: 6),
                Text(
                  report.referenceNumber!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                DateFormat.yMMMd().format(report.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (color, bg) = switch (status) {
      ReportStatus.submitted => (
          const Color(0xFF1565C0),
          const Color(0xFFE3F2FD),
        ),
      ReportStatus.underReview => (
          const Color(0xFFF57F17),
          const Color(0xFFFFFDE7),
        ),
      ReportStatus.inProgress => (
          const Color(0xFF6A1B9A),
          const Color(0xFFF3E5F5),
        ),
      ReportStatus.resolved => (
          const Color(0xFF2E7D32),
          const Color(0xFFE8F5E9),
        ),
      ReportStatus.closed => (
          theme.colorScheme.onSurfaceVariant,
          theme.colorScheme.surfaceContainerHighest,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        localizedReportStatus(context.l10n, status),
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
