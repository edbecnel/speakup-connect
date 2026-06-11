import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/groups/domain/entities/my_group_membership.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_entity.dart';
import 'package:speakup_connect/features/reminders/presentation/providers/reminder_provider.dart';
import 'package:speakup_connect/features/reminders/presentation/widgets/expiration_picker_section.dart';
import 'package:speakup_connect/features/reminders/presentation/widgets/response_config_section.dart';
import 'package:speakup_connect/features/roles/presentation/providers/roles_provider.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/schedule_for_later_section.dart';

/// Compose Reminder screen — lets authorized members broadcast a reminder to
/// the whole org, a group, or a role, now or at a scheduled time.
///
/// Gated on [AppPermission.broadcastReminders] (also enforced by the route
/// guard and Firestore rules).
class ComposeReminderScreen extends ConsumerStatefulWidget {
  const ComposeReminderScreen({this.initialGroupId, super.key});

  /// When set, pre-selects this group as the audience (group leaders).
  final String? initialGroupId;

  @override
  ConsumerState<ComposeReminderScreen> createState() =>
      _ComposeReminderScreenState();
}

class _ComposeReminderScreenState extends ConsumerState<ComposeReminderScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  var _didPresetGroup = false;
  var _scheduledPreset = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canBroadcast = ref.watch(canComposeRemindersProvider);
    final leaderOnly = ref.watch(isGroupLeaderOnlyComposerProvider);
    final form = ref.watch(composeReminderProvider);
    final notifier = ref.read(composeReminderProvider.notifier);
    final submitState = ref.watch(submitReminderProvider);

    if (!_scheduledPreset) {
      _scheduledPreset = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _tryPresetLeaderAudience();
      });
    }

    if (leaderOnly) {
      ref.listen(myGroupMembershipsProvider, (prev, next) {
        if (next.isLoading || _didPresetGroup) return;
        _tryPresetLeaderAudience();
      });
      ref.listen(ledGroupMembershipsProvider, (prev, next) {
        if (_didPresetGroup) return;
        _tryPresetLeaderAudience();
      });
    }

    final requireApproval = ref
            .watch(organizationConfigProvider)
            .asData
            ?.value
            .requireReminderApproval ??
        false;
    final canPublishDirectly =
        ref.watch(canReviewPendingRemindersProvider);
    final willNeedApproval = requireApproval && !canPublishDirectly;

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

    if (leaderOnly) {
      return _buildScaffold(
        context: context,
        theme: theme,
        form: form,
        notifier: notifier,
        submitState: submitState,
        submitLabel: willNeedApproval ? 'Submit for Approval' : 'Send Reminder',
        leaderOnly: true,
        willNeedApproval: willNeedApproval,
      );
    }

    final submitLabel =
        willNeedApproval ? 'Submit for Approval' : 'Send Reminder';

    return _buildScaffold(
      context: context,
      theme: theme,
      form: form,
      notifier: notifier,
      submitState: submitState,
      submitLabel: submitLabel,
      leaderOnly: false,
      willNeedApproval: willNeedApproval,
    );
  }

  void _tryPresetLeaderAudience() {
    if (_didPresetGroup || !ref.read(isGroupLeaderOnlyComposerProvider)) {
      return;
    }
    final notifier = ref.read(composeReminderProvider.notifier);
    _ensureLeaderGroupAudience(notifier);
    _maybePresetGroupAudience(true, notifier);
  }

  void _ensureLeaderGroupAudience(ComposeReminderNotifier notifier) {
    if (ref.read(composeReminderProvider).audienceType !=
        ReminderAudienceType.group) {
      notifier.setAudienceType(ReminderAudienceType.group);
    }
  }

  MyGroupMembership? _ledMembershipFor(String groupId) {
    for (final m in ref.read(ledGroupMembershipsProvider)) {
      if (m.group.groupId == groupId) return m;
    }
    final all = ref.read(myGroupMembershipsProvider).asData?.value;
    if (all == null) return null;
    for (final m in all) {
      if (m.group.groupId == groupId && m.membership.isLeader) return m;
    }
    return null;
  }

  void _maybePresetGroupAudience(
    bool leaderOnly,
    ComposeReminderNotifier notifier,
  ) {
    if (_didPresetGroup || !leaderOnly) return;

    final groupId = widget.initialGroupId;
    if (groupId != null) {
      final membership = _ledMembershipFor(groupId);
      if (membership == null) return;
      _didPresetGroup = true;
      notifier.presetGroupAudience(
        groupId: groupId,
        groupName: membership.group.name,
      );
      return;
    }

    final led = ref.read(ledGroupMembershipsProvider);
    if (led.length == 1) {
      _didPresetGroup = true;
      notifier.presetGroupAudience(
        groupId: led.first.group.groupId,
        groupName: led.first.group.name,
      );
    }
  }

  Widget _buildScaffold({
    required BuildContext context,
    required ThemeData theme,
    required ComposeReminderState form,
    required ComposeReminderNotifier notifier,
    required AsyncValue<SubmitReminderResult?> submitState,
    required String submitLabel,
    required bool leaderOnly,
    required bool willNeedApproval,
  }) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(leaderOnly ? 'Send Group Alert' : 'Compose Reminder'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leaderOnly)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'This alert will be sent only to members of the group you select.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            if (willNeedApproval) _ApprovalBanner(),
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
            if (leaderOnly)
              _GroupPicker(form: form, notifier: notifier)
            else ...[
              _AudienceSelector(
                selected: form.audienceType,
                onChanged: notifier.setAudienceType,
              ),
              const SizedBox(height: 12),
              if (form.audienceType == ReminderAudienceType.group)
                _GroupPicker(form: form, notifier: notifier),
              if (form.audienceType == ReminderAudienceType.role)
                _RolePicker(form: form, notifier: notifier),
            ],
            const SizedBox(height: 16),
            ScheduleForLaterSection(
              scheduledAt: form.scheduledAt,
              onChanged: notifier.setSchedule,
            ),
            const SizedBox(height: 8),
            ExpirationPickerSection(
              value: form.expiration,
              scheduledAt: form.scheduledAt,
              onChanged: notifier.setExpiration,
            ),
            const SizedBox(height: 8),
            ResponseConfigSection(
              value: form.responseConfig,
              onChanged: notifier.setResponseConfig,
            ),
            const SizedBox(height: 28),
            if (!form.isValid && form.validationMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  form.validationMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            AppButton.primary(
              label: submitLabel,
              icon: submitLabel.contains('Approval')
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
        final selectedId = form.targetId != null &&
                groups.any((g) => g.id == form.targetId)
            ? form.targetId
            : null;
        return DropdownButtonFormField<String>(
          isExpanded: true,
          value: selectedId,
          decoration: const InputDecoration(
            labelText: 'Select group',
            border: OutlineInputBorder(),
          ),
          items: groups
              .map(
                (g) => DropdownMenuItem(
                  value: g.id,
                  child: Text(
                    g.label,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              )
              .toList(),
          selectedItemBuilder: (context) => groups
              .map(
                (g) => Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    g.label,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              )
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
          isExpanded: true,
          initialValue: form.targetId,
          decoration: const InputDecoration(
            labelText: 'Select role',
            border: OutlineInputBorder(),
          ),
          items: roles
              .map(
                (r) => DropdownMenuItem(
                  value: r.id,
                  child: Text(
                    r.displayName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              )
              .toList(),
          selectedItemBuilder: (context) => roles
              .map(
                (r) => Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    r.displayName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              )
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