import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/features/reports/domain/entities/report_entity.dart';
import 'package:speakup_connect/features/reports/presentation/providers/report_provider.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';

/// Admin-only detail view for a single report.
///
/// Displays full report information plus admin tools: status update,
/// add notes, and status history.
class AdminReportDetailScreen extends ConsumerWidget {
  const AdminReportDetailScreen({required this.reportId, super.key});

  final String reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(adminReportByIdProvider(reportId));

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Report Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(adminReportByIdProvider(reportId)),
          ),
        ],
      ),
      body: reportAsync.when(
        loading: () => const AppLoadingIndicator(message: 'Loading report...'),
        error: (e, _) => AppErrorWidget(
          message: 'Failed to load report',
          onRetry: () => ref.invalidate(adminReportByIdProvider(reportId)),
        ),
        data: (report) => _AdminDetailView(report: report, reportId: reportId),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Detail view
// ─────────────────────────────────────────────────────────────────────────────

class _AdminDetailView extends ConsumerWidget {
  const _AdminDetailView({required this.report, required this.reportId});

  final ReportEntity report;
  final String reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header card ──────────────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          report.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(status: report.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _PriorityBadge(priority: report.priority),
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
                  const SizedBox(height: 4),
                  if (report.isAnonymous)
                    Row(
                      children: [
                        Icon(
                          Icons.visibility_off_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Anonymous submission',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      'By: ${report.submitterDisplayName ?? report.submittedBy ?? 'Unknown'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Description ──────────────────────────────────────────────────
          _SectionHeader(title: 'Description'),
          const SizedBox(height: 8),
          Text(report.description, style: theme.textTheme.bodyMedium),

          // ── Photos ───────────────────────────────────────────────────────
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

          // ── Admin actions ─────────────────────────────────────────────────
          const SizedBox(height: 24),
          _SectionHeader(title: 'Admin Actions'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.swap_horiz_outlined),
                  label: const Text('Update Status'),
                  onPressed: () => _showStatusUpdateDialog(context, ref, report),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.note_add_outlined),
                  label: const Text('Add Note'),
                  onPressed: () => _showAddNoteDialog(context, ref, report),
                ),
              ),
            ],
          ),

          // ── Admin notes ───────────────────────────────────────────────────
          if (report.adminNotes.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionHeader(title: 'Admin Notes (${report.adminNotes.length})'),
            const SizedBox(height: 8),
            ...report.adminNotes.reversed.map(
              (note) => _AdminNoteCard(note: note),
            ),
          ],

          // ── Status history ────────────────────────────────────────────────
          if (report.statusHistory.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionHeader(title: 'Status History'),
            const SizedBox(height: 8),
            ...report.statusHistory.reversed.map(
              (entry) => _TimelineEntry(entry: entry),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _showStatusUpdateDialog(
    BuildContext context,
    WidgetRef ref,
    ReportEntity report,
  ) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => _StatusUpdateDialog(report: report, ref: ref),
    );
    if (updated == true) {
      ref.invalidate(adminReportByIdProvider(reportId));
    }
  }

  Future<void> _showAddNoteDialog(
    BuildContext context,
    WidgetRef ref,
    ReportEntity report,
  ) async {
    final added = await showDialog<bool>(
      context: context,
      builder: (_) => _AddNoteDialog(report: report, ref: ref),
    );
    if (added == true) {
      ref.invalidate(adminReportByIdProvider(reportId));
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Update Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _StatusUpdateDialog extends ConsumerStatefulWidget {
  const _StatusUpdateDialog({required this.report, required this.ref});

  final ReportEntity report;
  final WidgetRef ref;

  @override
  ConsumerState<_StatusUpdateDialog> createState() => _StatusUpdateDialogState();
}

class _StatusUpdateDialogState extends ConsumerState<_StatusUpdateDialog> {
  late ReportStatus _selectedStatus;
  final _noteController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.report.status;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedStatus == widget.report.status) {
      Navigator.of(context).pop(false);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final user = widget.ref.read(currentUserProvider);
      await widget.ref.read(reportRepositoryProvider).updateReportStatus(
            organizationId: AppConfig.defaultOrganizationId,
            reportId: widget.report.reportId,
            newStatus: _selectedStatus,
            changedByUid: user?.uid ?? 'admin',
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Update Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current: ${widget.report.status.label}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ReportStatus>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              labelText: 'New Status',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: ReportStatus.values
                .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                .toList(),
            onChanged: _isSaving
                ? null
                : (v) {
                    if (v != null) setState(() => _selectedStatus = v);
                  },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            enabled: !_isSaving,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              border: OutlineInputBorder(),
              hintText: 'Add a note about this status change…',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Note Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _AddNoteDialog extends ConsumerStatefulWidget {
  const _AddNoteDialog({required this.report, required this.ref});

  final ReportEntity report;
  final WidgetRef ref;

  @override
  ConsumerState<_AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends ConsumerState<_AddNoteDialog> {
  final _noteController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final content = _noteController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      final user = widget.ref.read(currentUserProvider);
      final profile = widget.ref.read(userProfileProvider).asData?.value;
      await widget.ref.read(reportRepositoryProvider).addAdminNote(
            organizationId: AppConfig.defaultOrganizationId,
            reportId: widget.report.reportId,
            authorId: user?.uid ?? 'admin',
            authorName: profile?.displayName ?? user?.displayName ?? 'Admin',
            content: content,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add note: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Admin Note'),
      content: TextField(
        controller: _noteController,
        enabled: !_isSaving,
        maxLines: 5,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Note',
          border: OutlineInputBorder(),
          hintText: 'Enter your note…',
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Supporting widgets
// ─────────────────────────────────────────────────────────────────────────────

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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (color, bg) = switch (status) {
      ReportStatus.submitted =>
        (const Color(0xFF1565C0), const Color(0xFFE3F2FD)),
      ReportStatus.underReview =>
        (const Color(0xFFF57F17), const Color(0xFFFFFDE7)),
      ReportStatus.inProgress =>
        (const Color(0xFF6A1B9A), const Color(0xFFF3E5F5)),
      ReportStatus.resolved =>
        (const Color(0xFF2E7D32), const Color(0xFFE8F5E9)),
      ReportStatus.closed => (
          theme.colorScheme.onSurfaceVariant,
          theme.colorScheme.surfaceContainerHighest
        ),
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

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final ReportPriority priority;

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (priority) {
      ReportPriority.low =>
        (const Color(0xFF37474F), const Color(0xFFECEFF1)),
      ReportPriority.medium =>
        (const Color(0xFF1565C0), const Color(0xFFE3F2FD)),
      ReportPriority.high =>
        (const Color(0xFFF57F17), const Color(0xFFFFF8E1)),
      ReportPriority.urgent =>
        (const Color(0xFFB71C1C), const Color(0xFFFFEBEE)),
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

class _AdminNoteCard extends StatelessWidget {
  const _AdminNoteCard({required this.note});

  final AdminNote note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dt = note.createdAt;
    final date = '${months[dt.month - 1]} ${dt.day}, ${dt.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: theme.colorScheme.surfaceContainerLow,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  note.authorName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  date,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(note.content, style: theme.textTheme.bodySmall),
          ],
        ),
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
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
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

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final adminReportByIdProvider =
    FutureProvider.family<ReportEntity, String>((ref, reportId) async {
  return ref.watch(reportRepositoryProvider).getReportById(
        organizationId: AppConfig.defaultOrganizationId,
        reportId: reportId,
      );
});
