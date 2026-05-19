import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/features/reports/domain/entities/report_entity.dart';
import 'package:speakup_connect/features/reports/presentation/providers/report_provider.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';

/// Report Details screen — deep view of a single report.
class ReportDetailsScreen extends ConsumerWidget {
  const ReportDetailsScreen({super.key, required this.reportId});

  final String reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(reportByIdProvider(reportId));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Report Details'),
      ),
      body: reportAsync.when(
        loading: () => const AppLoadingIndicator(message: 'Loading report...'),
        error: (e, _) => AppErrorWidget(
          message: 'Failed to load report',
          onRetry: () => ref.invalidate(reportByIdProvider(reportId)),
        ),
        data: (report) => _ReportDetailView(report: report),
      ),
    );
  }
}

class _ReportDetailView extends StatelessWidget {
  const _ReportDetailView({required this.report});

  final ReportEntity report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Card(
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
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _StatusBadge(status: report.status),
                    ],
                  ),
                  if (report.referenceNumber != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      report.referenceNumber!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Submitted ${_formatDate(report.createdAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (report.isAnonymous) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.visibility_off_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Submitted anonymously',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Description
          _SectionHeader(title: 'Description'),
          const SizedBox(height: 8),
          Text(report.description, style: theme.textTheme.bodyMedium),

          // Photos
          if (report.hasPhotos) ...[
            const SizedBox(height: 24),
            _SectionHeader(title: 'Photos (${report.photoUrls.length})'),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: report.photoUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    report.photoUrls[i],
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 120,
                      height: 120,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Status Timeline
          if (report.statusHistory.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionHeader(title: 'Status History'),
            const SizedBox(height: 8),
            ...report.statusHistory.reversed.map(
              (entry) => _TimelineEntry(entry: entry),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.entry});

  final StatusHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dt = entry.changedAt;
    final date = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 8,
                backgroundColor: theme.colorScheme.primary,
                child: const SizedBox.shrink(),
              ),
              Container(
                width: 2,
                height: 32,
                color: theme.colorScheme.outlineVariant,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.toStatus.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (entry.note != null) ...[
                  const SizedBox(height: 2),
                  Text(entry.note!, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ],
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
      ReportStatus.submitted => (const Color(0xFF1565C0), const Color(0xFFE3F2FD)),
      ReportStatus.underReview => (const Color(0xFFF57F17), const Color(0xFFFFFDE7)),
      ReportStatus.inProgress => (const Color(0xFF6A1B9A), const Color(0xFFF3E5F5)),
      ReportStatus.resolved => (const Color(0xFF2E7D32), const Color(0xFFE8F5E9)),
      ReportStatus.closed => (theme.colorScheme.onSurfaceVariant, theme.colorScheme.surfaceContainerHighest),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// --- Provider for single report ---

final reportByIdProvider = FutureProvider.family<ReportEntity, String>((ref, reportId) async {
  return ref.watch(reportRepositoryProvider).getReportById(
        organizationId: AppConfig.defaultOrganizationId,
        reportId: reportId,
      );
});
