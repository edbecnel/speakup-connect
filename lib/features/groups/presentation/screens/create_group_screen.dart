import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_membership_policy.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_position_role.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/features/groups/presentation/widgets/group_position_roles_editor.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/app_text_field.dart';

/// Admin form to create a new group or club.
class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _definePositions = false;
  bool _allowJoinRequests = false;
  MemberLeavePolicy _leavePolicy = MemberLeavePolicy.requestRequired;
  List<GroupPositionRole> _positionRoles = const [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final group = await ref.read(createGroupActionProvider.notifier).submit(
          name: _nameController.text,
          description: _descriptionController.text,
          positionRoles: _definePositions ? _positionRoles : const [],
          allowJoinRequests: _allowJoinRequests,
          memberLeavePolicy: _leavePolicy,
        );

    if (!mounted) return;
    final l10n = context.l10n;

    if (group != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.groupsCreated(group.name))),
      );
      context.go(Routes.groupMembersPath(group.groupId));
    } else {
      final error = ref.read(createGroupActionProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error?.toString() ?? l10n.groupsCouldNotCreate),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLoading = ref.watch(createGroupActionProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.groupsCreateGroupTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              controller: _nameController,
              label: l10n.groupsGroupNameLabel,
              hint: l10n.groupsGroupNameHint,
              textInputAction: TextInputAction.next,
              autofocus: true,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return l10n.groupsGroupNameRequired;
                }
                if (v.trim().length > 120) {
                  return l10n.validationMaxLength(l10n.groupsGroupNameLabel, 120);
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _descriptionController,
              label: l10n.groupsDescriptionLabel,
              hint: l10n.groupsDescriptionHint,
              maxLines: 4,
              maxLength: 500,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.groupsDefineClubPositions),
              subtitle: Text(l10n.groupsDefineClubPositionsSubtitle),
              value: _definePositions,
              onChanged: isLoading
                  ? null
                  : (v) => setState(() {
                        _definePositions = v;
                        if (v && _positionRoles.isEmpty) {
                          _positionRoles = const [
                            GroupPositionRole(
                              id: 'president',
                              label: 'President',
                            ),
                            GroupPositionRole(
                              id: 'vice-president',
                              label: 'Vice President',
                            ),
                          ];
                        }
                      }),
            ),
            if (_definePositions) ...[
              const SizedBox(height: 8),
              GroupPositionRolesEditor(
                roles: _positionRoles,
                enabled: !isLoading,
                onChanged: (roles) =>
                    setState(() => _positionRoles = roles),
              ),
            ],
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.groupsAllowJoinRequests),
              subtitle: Text(l10n.groupsAllowJoinRequestsSubtitle),
              value: _allowJoinRequests,
              onChanged: isLoading
                  ? null
                  : (v) => setState(() => _allowJoinRequests = v),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.groupsMemberLeavePolicy,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            RadioListTile<MemberLeavePolicy>(
              title: Text(l10n.groupsLeaveAnytime),
              value: MemberLeavePolicy.voluntary,
              groupValue: _leavePolicy,
              onChanged: isLoading
                  ? null
                  : (v) => setState(() => _leavePolicy = v!),
            ),
            RadioListTile<MemberLeavePolicy>(
              title: Text(l10n.groupsMustRequestToLeave),
              value: MemberLeavePolicy.requestRequired,
              groupValue: _leavePolicy,
              onChanged: isLoading
                  ? null
                  : (v) => setState(() => _leavePolicy = v!),
            ),
            const SizedBox(height: 24),
            AppButton.primary(
              label: l10n.groupsCreateGroup,
              isLoading: isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
