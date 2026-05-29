import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/features/roles/domain/entities/role_entity.dart';
import 'package:speakup_connect/features/roles/presentation/providers/roles_provider.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';

/// Admin screen listing all role definitions for the organisation.
///
/// Provides entry points to create new roles, edit existing ones, and
/// navigate to the Capabilities catalog. System roles can be viewed and
/// edited (capability assignments), but cannot be deleted.
class RolesManagementScreen extends ConsumerWidget {
  const RolesManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(rolesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Roles & Permissions'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(Routes.adminCapabilities),
            icon: const Icon(Icons.tune_outlined),
            label: const Text('Capabilities'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.adminRoleNew),
        icon: const Icon(Icons.add),
        label: const Text('Create Role'),
        shape: const StadiumBorder(),
      ),
      body: rolesAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (roles) {
          if (roles.isEmpty) {
            return _EmptyRolesPlaceholder(
              onCreateTap: () => context.push(Routes.adminRoleNew),
            );
          }
          return _RolesList(roles: roles);
        },
      ),
    );
  }
}

// ── Role List ─────────────────────────────────────────────────────────────────

class _RolesList extends ConsumerWidget {
  const _RolesList({required this.roles});

  final List<RoleEntity> roles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Partition into system vs custom.
    final system = roles.where((r) => r.isSystemRole).toList();
    final custom = roles.where((r) => !r.isSystemRole).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        if (system.isNotEmpty) ...[
          _SectionHeader(title: 'System Roles', count: system.length),
          ...system.map((r) => _RoleCard(role: r)),
        ],
        if (custom.isNotEmpty) ...[
          _SectionHeader(title: 'Custom Roles', count: custom.length),
          ...custom.map((r) => _RoleCard(role: r)),
        ],
        if (system.isEmpty && custom.isEmpty)
          const SizedBox.shrink(),
      ],
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Role Card ─────────────────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.role});

  final RoleEntity role;

  @override
  Widget build(BuildContext context, ) {
    final theme = Theme.of(context);
    final resolvedCaps = role.capabilities
        .map(AppPermission.fromKey)
        .whereType<AppPermission>()
        .toList();

    const maxChips = 3;
    final visibleCaps = resolvedCaps.take(maxChips).toList();
    final overflow = resolvedCaps.length - maxChips;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    role.displayName,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (role.isSystemRole)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'System',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
              ],
            ),

            // ── Description ────────────────────────────────────────────────
            if (role.description != null && role.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                role.description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // ── Capability chips ───────────────────────────────────────────
            if (resolvedCaps.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  ...visibleCaps.map(
                    (p) => Chip(
                      label: Text(p.displayName),
                      labelStyle: theme.textTheme.labelSmall,
                      visualDensity: VisualDensity.compact,
                      side: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.4),
                      ),
                      backgroundColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  if (overflow > 0)
                    ActionChip(
                      label: Text('+$overflow more'),
                      labelStyle: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                      visualDensity: VisualDensity.compact,
                      side: BorderSide(color: theme.colorScheme.primary),
                      backgroundColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('${role.displayName} — All Capabilities'),
                          content: SingleChildScrollView(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: resolvedCaps
                                  .map(
                                    (p) => Chip(
                                      label: Text(p.displayName),
                                      labelStyle: theme.textTheme.labelSmall,
                                      visualDensity: VisualDensity.compact,
                                      backgroundColor: Colors.transparent,
                                      side: BorderSide(
                                        color: theme.colorScheme.outline
                                            .withOpacity(0.4),
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'No capabilities assigned',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            // ── Action buttons ─────────────────────────────────────────────
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => context.push(
                    Routes.adminRoleAssignPath(role.id),
                  ),
                  icon: const Icon(Icons.person_add_outlined, size: 18),
                  label: const Text('Assign Users'),
                ),
                const SizedBox(width: 8),
                AppButton.secondary(
                  label: 'Edit',
                  minimumWidth: 80,
                  onPressed: () => context.push(
                    Routes.adminRoleEditPath(role.id),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty Placeholder ─────────────────────────────────────────────────────────

class _EmptyRolesPlaceholder extends ConsumerWidget {
  const _EmptyRolesPlaceholder({required this.onCreateTap});

  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final seedState = ref.watch(seedRolesProvider);

    ref.listen(seedRolesProvider, (prev, next) {
      if (!next.isLoading && prev?.isLoading == true) {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Seed failed: ${next.error}'),
            backgroundColor: theme.colorScheme.error,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Default roles added successfully'),
            backgroundColor: Colors.green,
          ));
        }
      }
    });

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.manage_accounts_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No roles defined yet',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first custom role to grant staff\nspecific capabilities within this organisation.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: seedState.isLoading
                    ? null
                    : () => ref.read(seedRolesProvider.notifier).seed(),
                icon: seedState.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_fix_high_outlined),
                label: Text(
                  seedState.isLoading ? 'Seeding…' : 'Seed Default Roles',
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: seedState.isLoading ? null : onCreateTap,
                icon: const Icon(Icons.add),
                label: const Text('Create Role Manually'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
