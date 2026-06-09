import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_entity.dart';
import 'package:speakup_connect/features/reminders/presentation/providers/reminder_provider.dart';
import 'package:speakup_connect/features/reminders/presentation/widgets/expiration_picker_section.dart';
import 'package:speakup_connect/features/roles/presentation/providers/roles_provider.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';

/// Compose Reminder screen — lets authorized members broadcast a reminder to
/// the whole org, a group, or a role, now or at a scheduled time.
///
/// Gated on [AppPermission.broadcastReminders] (also enforced by the route
/// guard and Firestore rules).
class ComposeReminderScreen extends ConsumerStatefulWidget {
  const ComposeReminderScreen({super.key});

  @override
  ConsumerState<ComposeReminderScreen> createState() =>
      _ComposeReminderScreenState();
}

class _ComposeReminderScreenState extends ConsumerState<ComposeReminderScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canBroadcast =
        ref.watch(hasPermissionProvider(AppPermission.broadcastReminders));
    final form = ref.watch(composeReminderProvider);
    final notifier = ref.read(composeReminderProvider.notifier);
    final submitState = ref.watch(submitReminderProvider);

    final requireApproval = ref
            .watch(organizationConfigProvider)
            .asData
            ?.value
            .requireReminderApproval ??
        false;
    final canApprove =
        ref.watch(hasPermissionProvider(AppPermission.approveReminders));
    final willNeedApproval = requireApproval && !canApprove;

    ref.listen(submitReminderProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading) {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to send: ${next.error}'),
            backgroundColor: theme.colorScheme.error,
          ));
        } else if (next.asData?.value != null) {
          final result = next.asData!.value!;
          final isPending = result.status == ReminderStatus.pending;
          final isScheduled = result.reminder.isScheduled;
          final msg = isPending
              ? 'Reminder submitted for approval.'
              : isScheduled
                  ? 'Reminder scheduled.'
                  : 'Reminder published.';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(msg),
            backgroundColor: Colors.green.shade700,
          ));
          if (context.canPop()) context.pop();
        }
      }
    });

    if (!canBroadcast) {
      return Scaffold(
        appBar: AppBar(title: const Text('Compose Reminder')),
        body: const _NoAccessPlaceholder(),
      );
    }

    final submitLabel =
        willNeedApproval ? 'Submit for Approval' : 'Send Reminder';

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Compose Reminder'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (willNeedApproval)
              _ApprovalBanner(),
            TextField(
              controller: _titleCtrl,
              onChanged: notifier.setTitle,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 80,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Early dismissal Friday',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyCtrl,
              onChanged: notifier.setBody,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 5,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Write the reminder details…',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            Text('Audience', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            _AudienceSelector(
              selected: form.audienceType,
              onChanged: notifier.setAudienceType,
            ),
            const SizedBox(height: 12),
            if (form.audienceType == ReminderAudienceType.group)
              _GroupPicker(form: form, notifier: notifier),
            if (form.audienceType == ReminderAudienceType.role)
              _RolePicker(form: form, notifier: notifier),
            const SizedBox(height: 16),
            _ScheduleSection(form: form, notifier: notifier),
            const SizedBox(height: 8),
            ExpirationPickerSection(
              value: form.expiration,
              scheduledAt: form.scheduledAt,
              onChanged: notifier.setExpiration,
            ),
            const SizedBox(height: 28),
            AppButton.primary(
              label: submitLabel,
              icon: willNeedApproval
                  ? Icons.send_outlined
                  : Icons.campaign_outlined,
              isLoading: submitState.isLoading,
              onPressed: form.isValid
                  ? () => ref.read(submitReminderProvider.notifier).submit()
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ApprovalBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              size: 18, color: theme.colorScheme.onSecondaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your organization requires reminders to be approved. This will '
              'be submitted for review before it is published.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AudienceSelector extends StatelessWidget {
  const _AudienceSelector({required this.selected, required this.onChanged});

  final ReminderAudienceType selected;
  final ValueChanged<ReminderAudienceType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ReminderAudienceType>(
      segments: const [
        ButtonSegment(
          value: ReminderAudienceType.all,
          label: Text('Everyone'),
          icon: Icon(Icons.groups_outlined),
        ),
        ButtonSegment(
          value: ReminderAudienceType.group,
          label: Text('Group'),
          icon: Icon(Icons.diversity_3_outlined),
        ),
        ButtonSegment(
          value: ReminderAudienceType.role,
          label: Text('Role'),
          icon: Icon(Icons.badge_outlined),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _GroupPicker extends ConsumerWidget {
  const _GroupPicker({required this.form, required this.notifier});

  final ComposeReminderState form;
  final ComposeReminderNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(audienceGroupsProvider);
    return groupsAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('Could not load groups: $e'),
      data: (groups) {
        if (groups.isEmpty) {
          return const Text('No groups exist yet. Create a group first.');
        }
        return DropdownButtonFormField<String>(
          initialValue: form.targetId,
          decoration: const InputDecoration(
            labelText: 'Select group',
            border: OutlineInputBorder(),
          ),
          items: groups
              .map((g) => DropdownMenuItem(value: g.id, child: Text(g.label)))
              .toList(),
          onChanged: (id) {
            if (id == null) return;
            final label = groups.firstWhere((g) => g.id == id).label;
            notifier.setTarget(id, label);
          },
        );
      },
    );
  }
}

class _RolePicker extends ConsumerWidget {
  const _RolePicker({required this.form, required this.notifier});

  final ComposeReminderState form;
  final ComposeReminderNotifier notifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(rolesProvider);
    return rolesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('Could not load roles: $e'),
      data: (roles) {
        if (roles.isEmpty) {
          return const Text('No roles defined yet.');
        }
        return DropdownButtonFormField<String>(
          initialValue: form.targetId,
          decoration: const InputDecoration(
            labelText: 'Select role',
            border: OutlineInputBorder(),
          ),
          items: roles
              .map((r) =>
                  DropdownMenuItem(value: r.id, child: Text(r.displayName)))
              .toList(),
          onChanged: (id) {
            if (id == null) return;
            final label = roles.firstWhere((r) => r.id == id).displayName;
            notifier.setTarget(id, label);
          },
        );
      },
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection({required this.form, required this.notifier});

  final ComposeReminderState form;
  final ComposeReminderNotifier notifier;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: form.scheduledAt ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        form.scheduledAt ?? now.add(const Duration(hours: 1)),
      ),
    );
    if (time == null) return;
    final when =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    notifier.setSchedule(when);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheduled = form.scheduledAt != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Schedule for later'),
          subtitle: Text(
            scheduled
                ? _formatDateTime(form.scheduledAt!)
                : 'Off — send immediately',
          ),
          value: scheduled,
          onChanged: (on) {
            if (on) {
              _pick(context);
            } else {
              notifier.setSchedule(null);
            }
          },
        ),
        if (scheduled)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _pick(context),
              icon: const Icon(Icons.edit_calendar_outlined, size: 18),
              label: Text(
                'Change time',
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ),
      ],
    );
  }
}

String _formatDateTime(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final ampm = dt.hour < 12 ? 'AM' : 'PM';
  return '${dt.year}-${two(dt.month)}-${two(dt.day)} · $h:${two(dt.minute)} $ampm';
}

class _NoAccessPlaceholder extends StatelessWidget {
  const _NoAccessPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline,
                size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'You don\'t have permission to broadcast reminders.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}