import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_entity.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_membership_policy.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_membership_provider.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/app_text_field.dart';

/// Bottom sheet for admins/leaders to configure join and leave policies.
Future<void> showGroupMembershipPolicySheet({
  required BuildContext context,
  required WidgetRef ref,
  required GroupEntity group,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _GroupMembershipPolicySheet(group: group),
  );
}

class _GroupMembershipPolicySheet extends ConsumerStatefulWidget {
  const _GroupMembershipPolicySheet({required this.group});

  final GroupEntity group;

  @override
  ConsumerState<_GroupMembershipPolicySheet> createState() =>
      _GroupMembershipPolicySheetState();
}

class _GroupMembershipPolicySheetState
    extends ConsumerState<_GroupMembershipPolicySheet> {
  late bool _allowJoin;
  late MemberLeavePolicy _leavePolicy;
  late final TextEditingController _hintController;

  @override
  void initState() {
    super.initState();
    _allowJoin = widget.group.allowJoinRequests;
    _leavePolicy = widget.group.memberLeavePolicy;
    _hintController = TextEditingController(text: widget.group.joinRequestHint);
  }

  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ok = await ref
        .read(groupMembershipActionsProvider.notifier)
        .updatePolicies(
          groupId: widget.group.groupId,
          allowJoinRequests: _allowJoin,
          memberLeavePolicy: _leavePolicy,
          joinRequestHint: _hintController.text,
        );
    if (!mounted) return;
    final l10n = context.l10n;
    if (ok) {
      ref.invalidate(groupByIdProvider(widget.group.groupId));
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.groupsGroupSettingsSaved)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLoading = ref.watch(groupMembershipActionsProvider).isLoading;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.groupsMembershipSettings,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.group.name,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.groupsAllowJoinRequests),
                        subtitle: Text(l10n.groupsAllowJoinRequestsSubtitle),
                        value: _allowJoin,
                        onChanged:
                            isLoading ? null : (v) => setState(() => _allowJoin = v),
                      ),
                      if (_allowJoin) ...[
                        const SizedBox(height: 8),
                        AppTextField(
                          controller: _hintController,
                          label: l10n.groupsJoinHintLabel,
                          hint: l10n.groupsJoinHintHint,
                          maxLength: 120,
                          maxLines: 2,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        l10n.groupsMemberLeavePolicy,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      RadioListTile<MemberLeavePolicy>(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.groupsLeaveAnytime),
                        subtitle: Text(l10n.groupsLeaveAnytimeSubtitle),
                        value: MemberLeavePolicy.voluntary,
                        groupValue: _leavePolicy,
                        onChanged: isLoading
                            ? null
                            : (v) => setState(() => _leavePolicy = v!),
                      ),
                      RadioListTile<MemberLeavePolicy>(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.groupsMustRequestToLeave),
                        subtitle: Text(l10n.groupsMustRequestToLeaveSubtitle),
                        value: MemberLeavePolicy.requestRequired,
                        groupValue: _leavePolicy,
                        onChanged: isLoading
                            ? null
                            : (v) => setState(() => _leavePolicy = v!),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: AppButton.primary(
                  label: l10n.commonSave,
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
