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
import 'package:speakup_connect/features/roles/presentation/providers/roles_provider.dart';
import 'package:speakup_connect/l10n/app_localizations.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

/// Streams all approved users in the org.
final _usersProvider = StreamProvider.autoDispose<List<UserProfileEntity>>((ref) {
  return FirebaseFirestore.instance
      .collection(AppConstants.organizationsCollection)
      .doc(AppConfig.defaultOrganizationId)
      .collection(AppConstants.usersCollection)
      .where('approvalStatus', isEqualTo: 'approved')
      .orderBy('displayName')
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => UserProfileModel.fromFirestore(d.data(), d.id))
          .where((u) => u.isApproved)
          .toList());
});

/// Streams all role assignments for a single user.
final _userAssignmentsProvider = StreamProvider.autoDispose
    .family<List<RoleAssignmentEntity>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection(AppConstants.organizationsCollection)
      .doc(AppConfig.defaultOrganizationId)
      .collection(AppConstants.usersCollection)
      .doc(userId)
      .collection(AppConstants.roleAssignmentsCollection)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => RoleAssignmentModel.fromFirestore(d.data(), d.id))
          .toList());
});

// ── Screen ────────────────────────────────────────────────────────────────────

/// Lists every approved user and their current role assignments.
///
/// Accessible from Roles & Permissions screen → "View Assignments" AppBar action.
class UserAssignmentsScreen extends ConsumerWidget {
  const UserAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final usersAsync = ref.watch(_usersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.roleAssignmentsTitle)),
      body: usersAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (users) {
          if (users.isEmpty) {
            return Center(child: Text(l10n.roleAssignmentsNoUsers));
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) => _UserAssignmentRow(user: users[i]),
          );
        },
      ),
    );
  }
}

// ── User Assignment Row ───────────────────────────────────────────────────────

class _UserAssignmentRow extends ConsumerWidget {
  const _UserAssignmentRow({required this.user});

  final UserProfileEntity user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final assignmentsAsync = ref.watch(_userAssignmentsProvider(user.userId));
    final rolesAsync = ref.watch(rolesProvider);

    final initial = user.displayName.isNotEmpty
        ? user.displayName[0].toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(child: Text(initial)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (user.email != null)
                  Text(
                    user.email!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 6),
                assignmentsAsync.when(
                  loading: () => const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, _) => Text(
                    l10n.commonErrorPrefix('$e'),
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 11,
                    ),
                  ),
                  data: (assignments) {
                    if (assignments.isEmpty) {
                      return Text(
                        l10n.roleAssignmentsNoRoles,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    }
                    final roles = rolesAsync.asData?.value ?? [];
                    return Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: assignments
                          .map((a) => _RoleChip(
                                assignment: a,
                                roles: roles,
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Role Chip ─────────────────────────────────────────────────────────────────

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.assignment, required this.roles});

  final RoleAssignmentEntity assignment;
  final List<RoleEntity> roles;

  String get _roleName {
    for (final r in roles) {
      if (r.id == assignment.roleId) return r.displayName;
    }
    return assignment.roleId;
  }

  String _scopeLabel(AppLocalizations l10n) {
    return localizedOrgScopeAssignmentLabel(
      l10n,
      assignment.scopeType,
      scopeId: assignment.scopeId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Chip(
      avatar: const Icon(Icons.shield_outlined, size: 14),
      label: Text(l10n.assignRoleRoleChip(_roleName, _scopeLabel(l10n))),
      labelStyle: theme.textTheme.labelSmall,
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.4)),
      backgroundColor:
          theme.colorScheme.primaryContainer.withOpacity(0.3),
      padding: EdgeInsets.zero,
    );
  }
}
