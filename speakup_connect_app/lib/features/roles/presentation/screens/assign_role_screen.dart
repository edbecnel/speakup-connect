import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/core/permissions/org_scope_type.dart';
import 'package:speakup_connect/features/organization/data/models/user_profile_model.dart';
import 'package:speakup_connect/features/organization/domain/entities/user_profile_entity.dart';
import 'package:speakup_connect/features/roles/data/models/role_assignment_model.dart';
import 'package:speakup_connect/features/roles/domain/entities/role_assignment_entity.dart';
import 'package:speakup_connect/features/roles/domain/entities/role_entity.dart';
import 'package:speakup_connect/features/roles/presentation/l10n/roles_ui_l10n.dart';
import 'package:speakup_connect/l10n/app_localizations.dart';
import 'package:speakup_connect/features/roles/presentation/providers/roles_provider.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';
import 'package:speakup_connect/shared/widgets/app_text_field.dart';
import 'package:speakup_connect/shared/widgets/secondary_app_bar.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

/// Fetches all approved users in the default org once (no stream).
/// A one-shot get() avoids the cache→server double-emit that causes
/// the list to flash on every rebuild.
final _orgUsersProvider =
    FutureProvider.autoDispose<List<UserProfileEntity>>((ref) async {
  final snap = await FirebaseFirestore.instance
      .collection(AppConstants.organizationsCollection)
      .doc(AppConfig.defaultOrganizationId)
      .collection(AppConstants.usersCollection)
      .where('approvalStatus', isEqualTo: 'approved')
      .orderBy('displayName')
      .get();
  return snap.docs
      .map((d) => UserProfileModel.fromFirestore(d.data(), d.id))
      .where((u) => u.isApproved)
      .toList();
});

/// Streams the role assignments for [userId] that match [roleId].
final _userRoleAssignmentsProvider = StreamProvider.autoDispose
    .family<List<RoleAssignmentEntity>, ({String userId, String roleId})>(
        (ref, args) {
  return FirebaseFirestore.instance
      .collection(AppConstants.organizationsCollection)
      .doc(AppConfig.defaultOrganizationId)
      .collection(AppConstants.usersCollection)
      .doc(args.userId)
      .collection(AppConstants.roleAssignmentsCollection)
      .where('roleId', isEqualTo: args.roleId)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => RoleAssignmentModel.fromFirestore(d.data(), d.id))
          .toList());
});

// ── AssignRoleScreen ──────────────────────────────────────────────────────────

/// Admin screen for assigning a role to one or more users.
///
/// Loads the role definition to show context at the top. The admin
/// searches for users by display name or student ID, selects one, then
/// chooses a [OrgScopeType] and optional scope ID before confirming the
/// assignment. The write is fire-and-confirm via [RoleAssignmentWriter].
class AssignRoleScreen extends ConsumerStatefulWidget {
  const AssignRoleScreen({super.key, required this.roleId});

  final String roleId;

  @override
  ConsumerState<AssignRoleScreen> createState() => _AssignRoleScreenState();
}

class _AssignRoleScreenState extends ConsumerState<AssignRoleScreen> {
  final _searchCtrl = TextEditingController();
  String _filter = '';

  UserProfileEntity? _selectedUser;
  OrgScopeType _scopeType = OrgScopeType.org;
  final _scopeIdCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scopeIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _assign() async {
    if (_selectedUser == null) return;
    await ref.read(roleAssignmentWriterProvider.notifier).assignRole(
          targetUserId: _selectedUser!.userId,
          roleId: widget.roleId,
          scopeType: _scopeType,
          scopeId: _scopeIdCtrl.text.trim().isEmpty
              ? null
              : _scopeIdCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final roleAsync = ref.watch(roleByIdProvider(widget.roleId));
    final writerState = ref.watch(roleAssignmentWriterProvider);

    ref.listen(roleAssignmentWriterProvider, (prev, next) {
      if (!next.isLoading && prev?.isLoading == true) {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.assignRoleFailed('${next.error}')),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        } else {
          setState(() {
            _selectedUser = null;
            _scopeIdCtrl.clear();
            _scopeType = OrgScopeType.org;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.assignRoleSuccess)),
          );
        }
      }
    });

    final roleName = roleAsync.asData?.value?.displayName ?? l10n.commonRole;

    return Scaffold(
      appBar: SecondaryAppBar(title: l10n.assignRoleTitle(roleName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Role context card ──────────────────────────────────────────
          roleAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (role) => role == null
                ? const SizedBox.shrink()
                : _RoleContextCard(role: role),
          ),

          const SizedBox(height: 20),

          // ── User search ────────────────────────────────────────────────
          Text(
            l10n.assignRoleSelectUser,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: _searchCtrl,
            label: l10n.assignRoleSearchHint,
            prefixIcon: Icons.search,
            onChanged: (v) => setState(() => _filter = v.toLowerCase()),
          ),
          const SizedBox(height: 8),
          _UserPickerList(
            filter: _filter,
            selectedUserId: _selectedUser?.userId,
            onSelect: (u) => setState(() => _selectedUser = u),
          ),

          // ── Current assignments for selected user ──────────────────
          if (_selectedUser != null) ...[
            const SizedBox(height: 20),
            _CurrentAssignmentsSection(
              userId: _selectedUser!.userId,
              roleId: widget.roleId,
            ),
          ],

          const SizedBox(height: 20),

          // ── Scope configuration ────────────────────────────────────────
          if (_selectedUser != null) ...[
            _AssignmentForm(
              selectedUser: _selectedUser!,
              scopeType: _scopeType,
              scopeIdCtrl: _scopeIdCtrl,
              onScopeTypeChanged: (t) =>
                  setState(() => _scopeType = t),
            ),
            const SizedBox(height: 24),
            AppButton.primary(
              label: writerState.isLoading
                  ? l10n.assignRoleAssigning
                  : l10n.assignRoleConfirmAssignment,
              onPressed: writerState.isLoading ? null : _assign,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Role Context Card ─────────────────────────────────────────────────────────

class _RoleContextCard extends StatelessWidget {
  const _RoleContextCard({required this.role});
  final RoleEntity role;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primaryContainer,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 18),
              const SizedBox(width: 8),
              Text(
                role.displayName,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (role.description != null && role.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              role.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            '${role.capabilities.length} built-in + '
            '${role.customCapabilities.length} custom capabilities',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── User Picker List ──────────────────────────────────────────────────────────

class _UserPickerList extends ConsumerWidget {
  const _UserPickerList({
    required this.filter,
    required this.selectedUserId,
    required this.onSelect,
  });

  final String filter;
  final String? selectedUserId;
  final void Function(UserProfileEntity) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(_orgUsersProvider);

    return usersAsync.when(
      loading: () => const AppLoadingIndicator(),
      error: (e, _) => AppErrorWidget(message: e.toString()),
      data: (users) {
        final filtered = filter.isEmpty
            ? users
            : users
                .where(
                  (u) =>
                      u.displayName.toLowerCase().contains(filter) ||
                      (u.studentId?.toLowerCase().contains(filter) ?? false),
                )
                .toList();

        if (filtered.isEmpty) {
          final l10n = context.l10n;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              l10n.assignRoleNoUsersFound,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          );
        }

        return Container(
          constraints: const BoxConstraints(maxHeight: 240),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final user = filtered[i];
                final isSelected = user.userId == selectedUserId;
                return ListTile(
                  selected: isSelected,
                  onTap: () => onSelect(user),
                  leading: CircleAvatar(
                    child: Text(
                      user.displayName.isNotEmpty
                          ? user.displayName[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(user.displayName),
                  subtitle: user.studentId != null
                      ? Text(user.studentId!)
                      : (user.email != null ? Text(user.email!) : null),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  dense: true,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ── Assignment Form ───────────────────────────────────────────────────────────

class _AssignmentForm extends StatelessWidget {
  const _AssignmentForm({
    required this.selectedUser,
    required this.scopeType,
    required this.scopeIdCtrl,
    required this.onScopeTypeChanged,
  });

  final UserProfileEntity selectedUser;
  final OrgScopeType scopeType;
  final TextEditingController scopeIdCtrl;
  final void Function(OrgScopeType) onScopeTypeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final needsScopeId = scopeType != OrgScopeType.org;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CircleAvatar(
                child: Text(
                  selectedUser.displayName.isNotEmpty
                      ? selectedUser.displayName[0].toUpperCase()
                      : '?',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedUser.displayName,
                      style: theme.textTheme.titleSmall,
                    ),
                    if (selectedUser.studentId != null)
                      Text(
                        selectedUser.studentId!,
                        style: theme.textTheme.labelSmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.assignRoleScopeTitle,
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.assignRoleScopeSubtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<OrgScopeType>(
          value: scopeType,
          decoration: InputDecoration(
            labelText: l10n.assignRoleScopeType,
            border: const OutlineInputBorder(),
          ),
          items: OrgScopeType.values
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(localizedOrgScopeDropdownLabel(l10n, s)),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onScopeTypeChanged(v);
          },
        ),
        if (needsScopeId) ...[
          const SizedBox(height: 12),
          AppTextField(
            controller: scopeIdCtrl,
            label: localizedOrgScopeIdFieldLabel(l10n, scopeType),
            hint: localizedOrgScopeIdHint(l10n, scopeType),
          ),
        ],
      ],
    );
  }
}

// ── Current Assignments Section ───────────────────────────────────────────────

/// Shows the existing assignments of [roleId] for [userId] with a
/// remove button for each. Uses a live stream so it updates instantly
/// after an assignment is added or removed.
class _CurrentAssignmentsSection extends ConsumerWidget {
  const _CurrentAssignmentsSection({
    required this.userId,
    required this.roleId,
  });

  final String userId;
  final String roleId;

  String _scopeDescription(RoleAssignmentEntity a, AppLocalizations l10n) {
    return localizedOrgScopeAssignmentLabelFromEntity(l10n, a);
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    RoleAssignmentEntity assignment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.assignRoleRemoveTitle),
        content: Text(
          context.l10n.assignRoleRemoveConfirm(
            localizedOrgScopeAssignmentLabelFromEntity(
              context.l10n,
              assignment,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              context.l10n.commonRemove,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(roleAssignmentWriterProvider.notifier).removeAssignment(
            targetUserId: userId,
            assignmentId: assignment.assignmentId,
          );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final assignmentsAsync = ref.watch(
      _userRoleAssignmentsProvider((userId: userId, roleId: roleId)),
    );

    return assignmentsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (assignments) {
        if (assignments.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.assignRoleCurrentAssignments,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < assignments.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.shield_outlined, size: 18),
                      title: Text(_scopeDescription(assignments[i], l10n)),
                      subtitle: Text(
                        l10n.assignRoleAssignedDate(
                          _formatDate(assignments[i].assignedAt),
                        ),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: theme.colorScheme.error,
                        ),
                        tooltip: l10n.assignRoleRemoveTooltip,
                        onPressed: () => _confirmRemove(
                          context,
                          ref,
                          assignments[i],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.assignRoleRevokeHint,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
