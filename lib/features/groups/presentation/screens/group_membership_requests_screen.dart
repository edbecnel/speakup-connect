import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_join_request_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_leave_request_entity.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_membership_provider.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';

/// Review pending join and leave requests for a group.
class GroupMembershipRequestsScreen extends ConsumerStatefulWidget {
  const GroupMembershipRequestsScreen({required this.groupId, super.key});

  final String groupId;

  @override
  ConsumerState<GroupMembershipRequestsScreen> createState() =>
      _GroupMembershipRequestsScreenState();
}

class _GroupMembershipRequestsScreenState
    extends ConsumerState<GroupMembershipRequestsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _reviewJoin(GroupJoinRequestEntity req, bool approve) async {
    String? reason;
    if (!approve) {
      reason = await showDialog<String>(
        context: context,
        builder: (_) => const _DeclineReasonDialog(
          title: 'Decline join request?',
          label: 'Reason (optional)',
          confirmLabel: 'Decline',
        ),
      );
      if (reason == null) return;
    }

    final ok = await ref
        .read(groupMembershipActionsProvider.notifier)
        .reviewJoinRequest(
          groupId: widget.groupId,
          userId: req.userId,
          approve: approve,
          rejectionReason: reason,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Join request updated' : 'Action failed')),
      );
    }
  }

  Future<void> _reviewLeave(GroupLeaveRequestEntity req, bool approve) async {
    String? reason;
    if (!approve) {
      reason = await showDialog<String>(
        context: context,
        builder: (_) => const _DeclineReasonDialog(
          title: 'Deny leave request',
          label: 'Reason (required)',
          confirmLabel: 'Deny',
          required: true,
        ),
      );
      if (reason == null) return;
    }

    final ok = await ref
        .read(groupMembershipActionsProvider.notifier)
        .reviewLeaveRequest(
          groupId: widget.groupId,
          userId: req.userId,
          approve: approve,
          rejectionReason: reason,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Leave request updated' : 'Action failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(groupByIdProvider(widget.groupId));
    final joinAsync = ref.watch(pendingJoinRequestsProvider(widget.groupId));
    final leaveAsync = ref.watch(pendingLeaveRequestsProvider(widget.groupId));
    final isBusy = ref.watch(groupMembershipActionsProvider).isLoading;
    final groupName = groupAsync.asData?.value?.name ?? 'Group';

    return Scaffold(
      appBar: AppBar(
        title: Text('$groupName — Requests'),
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(
              text: 'Join (${joinAsync.asData?.value.length ?? 0})',
            ),
            Tab(
              text: 'Leave (${leaveAsync.asData?.value.length ?? 0})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          joinAsync.when(
            loading: () => const AppLoadingIndicator(),
            error: (e, _) => AppErrorWidget(message: e.toString()),
            data: (items) => _JoinRequestList(
              items: items,
              isBusy: isBusy,
              onApprove: (r) => _reviewJoin(r, true),
              onDecline: (r) => _reviewJoin(r, false),
            ),
          ),
          leaveAsync.when(
            loading: () => const AppLoadingIndicator(),
            error: (e, _) => AppErrorWidget(message: e.toString()),
            data: (items) => _LeaveRequestList(
              items: items,
              isBusy: isBusy,
              onApprove: (r) => _reviewLeave(r, true),
              onDeny: (r) => _reviewLeave(r, false),
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinRequestList extends StatelessWidget {
  const _JoinRequestList({
    required this.items,
    required this.isBusy,
    required this.onApprove,
    required this.onDecline,
  });

  final List<GroupJoinRequestEntity> items;
  final bool isBusy;
  final void Function(GroupJoinRequestEntity) onApprove;
  final void Function(GroupJoinRequestEntity) onDecline;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No pending join requests'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final req = items[i];
        return Card(
          child: ListTile(
            title: Text(req.displayName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (req.studentId != null) Text('ID: ${req.studentId}'),
                if (req.message != null && req.message!.isNotEmpty)
                  Text(req.message!),
              ],
            ),
            isThreeLine: true,
            trailing: isBusy
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Approve',
                        icon: const Icon(Icons.check_circle_outline),
                        onPressed: () => onApprove(req),
                      ),
                      IconButton(
                        tooltip: 'Decline',
                        icon: const Icon(Icons.cancel_outlined),
                        onPressed: () => onDecline(req),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _LeaveRequestList extends StatelessWidget {
  const _LeaveRequestList({
    required this.items,
    required this.isBusy,
    required this.onApprove,
    required this.onDeny,
  });

  final List<GroupLeaveRequestEntity> items;
  final bool isBusy;
  final void Function(GroupLeaveRequestEntity) onApprove;
  final void Function(GroupLeaveRequestEntity) onDeny;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No pending leave requests'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final req = items[i];
        return Card(
          child: ListTile(
            title: Text(req.displayName),
            subtitle: Text(req.reason),
            isThreeLine: true,
            trailing: isBusy
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Approve leave',
                        icon: const Icon(Icons.check_circle_outline),
                        onPressed: () => onApprove(req),
                      ),
                      IconButton(
                        tooltip: 'Deny',
                        icon: const Icon(Icons.cancel_outlined),
                        onPressed: () => onDeny(req),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _DeclineReasonDialog extends StatefulWidget {
  const _DeclineReasonDialog({
    required this.title,
    required this.label,
    required this.confirmLabel,
    this.required = false,
  });

  final String title;
  final String label;
  final String confirmLabel;
  final bool required;

  @override
  State<_DeclineReasonDialog> createState() => _DeclineReasonDialogState();
}

class _DeclineReasonDialogState extends State<_DeclineReasonDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (widget.required && text.isEmpty) {
      setState(() => _error = 'A reason is required');
      return;
    }
    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: widget.label,
          errorText: _error,
          border: const OutlineInputBorder(),
        ),
        maxLines: 3,
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
