import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_membership_policy.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_position_role.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/features/groups/presentation/widgets/group_position_roles_editor.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';
import 'package:speakup_connect/shared/widgets/app_text_field.dart';

/// Edit group name, description, policies, and club positions (not members).
class EditGroupScreen extends ConsumerStatefulWidget {
  const EditGroupScreen({required this.groupId, super.key});

  final String groupId;

  @override
  ConsumerState<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends ConsumerState<EditGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _joinHintController = TextEditingController();

  bool _initialized = false;
  bool _definePositions = false;
  bool _allowJoinRequests = false;
  bool _isActive = true;
  MemberLeavePolicy _leavePolicy = MemberLeavePolicy.requestRequired;
  List<GroupPositionRole> _positionRoles = const [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _joinHintController.dispose();
    super.dispose();
  }

  void _initializeFromGroup({
    required String name,
    String? description,
    bool allowJoinRequests = false,
    String? joinRequestHint,
    MemberLeavePolicy memberLeavePolicy = MemberLeavePolicy.requestRequired,
    List<GroupPositionRole> positionRoles = const [],
    bool isActive = true,
  }) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = name;
    _descriptionController.text = description ?? '';
    _allowJoinRequests = allowJoinRequests;
    _joinHintController.text = joinRequestHint ?? '';
    _leavePolicy = memberLeavePolicy;
    _definePositions = positionRoles.isNotEmpty;
    _positionRoles = List<GroupPositionRole>.from(positionRoles);
    _isActive = isActive;
  }

  Future<void> _submit({
    required bool canEditPositions,
    required bool canDeactivate,
  }) async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(updateGroupActionProvider.notifier).submit(
          groupId: widget.groupId,
          name: _nameController.text,
          description: _descriptionController.text,
          positionRoles: canEditPositions
              ? (_definePositions ? _positionRoles : const [])
              : null,
          allowJoinRequests: _allowJoinRequests,
          memberLeavePolicy: _leavePolicy,
          joinRequestHint:
              _allowJoinRequests ? _joinHintController.text : '',
          isActive: canDeactivate ? _isActive : null,
        );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group settings saved')),
      );
      context.pop();
    } else {
      final error = ref.read(updateGroupActionProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error?.toString() ?? 'Could not save group settings'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(groupByIdProvider(widget.groupId));
    final saveState = ref.watch(updateGroupActionProvider);
    final canEditPositions = ref.watch(canManageGroupsProvider);
    final canDeactivate = ref.watch(canDeactivateGroupProvider);
    final isLoading = saveState.isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: groupAsync.when(
          data: (g) => Text(g?.name ?? 'Edit Group'),
          loading: () => const Text('Edit Group'),
          error: (_, __) => const Text('Edit Group'),
        ),
      ),
      body: groupAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (group) {
          if (group == null) {
            return const AppErrorWidget(message: 'Group not found');
          }

          _initializeFromGroup(
            name: group.name,
            description: group.description,
            allowJoinRequests: group.allowJoinRequests,
            joinRequestHint: group.joinRequestHint,
            memberLeavePolicy: group.memberLeavePolicy,
            positionRoles: group.positionRoles,
            isActive: group.isActive,
          );

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                AppTextField(
                  controller: _nameController,
                  label: 'Group name',
                  hint: 'e.g. Journalism Club',
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter a group name';
                    }
                    if (v.trim().length > 120) {
                      return 'Name must be 120 characters or fewer';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Description (optional)',
                  hint: 'What is this group about?',
                  maxLines: 4,
                  maxLength: 500,
                ),
                if (canEditPositions) ...[
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Define club positions'),
                    subtitle: const Text(
                      'Optional offices like President or Treasurer',
                    ),
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
                ],
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Allow join requests'),
                  subtitle: const Text(
                    'Let students request to join (off for elected groups like SSLG)',
                  ),
                  value: _allowJoinRequests,
                  onChanged: isLoading
                      ? null
                      : (v) => setState(() => _allowJoinRequests = v),
                ),
                if (_allowJoinRequests) ...[
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _joinHintController,
                    label: 'Join hint (optional)',
                    hint: 'e.g. Auditions in August',
                    maxLength: 120,
                    maxLines: 2,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Member leave policy',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                RadioListTile<MemberLeavePolicy>(
                  title: const Text('Leave anytime'),
                  value: MemberLeavePolicy.voluntary,
                  groupValue: _leavePolicy,
                  onChanged: isLoading
                      ? null
                      : (v) => setState(() => _leavePolicy = v!),
                ),
                RadioListTile<MemberLeavePolicy>(
                  title: const Text('Must request to leave'),
                  value: MemberLeavePolicy.requestRequired,
                  groupValue: _leavePolicy,
                  onChanged: isLoading
                      ? null
                      : (v) => setState(() => _leavePolicy = v!),
                ),
                if (canDeactivate) ...[
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Group is active'),
                    subtitle: const Text(
                      'Inactive groups are hidden from browse and lists',
                    ),
                    value: _isActive,
                    onChanged: isLoading
                        ? null
                        : (v) => setState(() => _isActive = v),
                  ),
                ],
                const SizedBox(height: 24),
                AppButton.primary(
                  label: 'Save Changes',
                  isLoading: isLoading,
                  onPressed: isLoading
                      ? null
                      : () => _submit(
                            canEditPositions: canEditPositions,
                            canDeactivate: canDeactivate,
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
