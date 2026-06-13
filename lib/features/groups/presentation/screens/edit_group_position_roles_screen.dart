import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_position_role.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/features/groups/presentation/widgets/group_position_roles_editor.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';

/// Admin screen to customize club position labels for an existing group.
class EditGroupPositionRolesScreen extends ConsumerStatefulWidget {
  const EditGroupPositionRolesScreen({required this.groupId, super.key});

  final String groupId;

  @override
  ConsumerState<EditGroupPositionRolesScreen> createState() =>
      _EditGroupPositionRolesScreenState();
}

class _EditGroupPositionRolesScreenState
    extends ConsumerState<EditGroupPositionRolesScreen> {
  List<GroupPositionRole> _roles = const [];
  bool _initialized = false;

  Future<void> _save() async {
    final ok = await ref
        .read(updateGroupPositionRolesProvider.notifier)
        .submit(groupId: widget.groupId, positionRoles: _roles);

    if (!mounted) return;
    final l10n = context.l10n;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.groupsClubPositionsSaved)),
      );
      context.pop();
    } else {
      final error = ref.read(updateGroupPositionRolesProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error?.toString() ?? l10n.groupsCouldNotSavePositions),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final groupAsync = ref.watch(groupByIdProvider(widget.groupId));
    final saveState = ref.watch(updateGroupPositionRolesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: groupAsync.when(
          data: (g) => Text(g?.name ?? l10n.groupsClubPositionsTitle),
          loading: () => Text(l10n.groupsClubPositionsTitle),
          error: (_, __) => Text(l10n.groupsClubPositionsTitle),
        ),
      ),
      body: groupAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (group) {
          if (group == null) {
            return AppErrorWidget(message: l10n.groupsGroupNotFound);
          }

          if (!_initialized) {
            _initialized = true;
            _roles = List<GroupPositionRole>.from(group.positionRoles);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GroupPositionRolesEditor(
                roles: _roles,
                enabled: !saveState.isLoading,
                onChanged: (roles) => setState(() => _roles = roles),
              ),
              const SizedBox(height: 24),
              AppButton.primary(
                label: l10n.groupsSavePositions,
                isLoading: saveState.isLoading,
                onPressed: _save,
              ),
            ],
          );
        },
      ),
    );
  }
}
