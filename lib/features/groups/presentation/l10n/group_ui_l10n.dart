import 'package:flutter/widgets.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_member_entity.dart';

extension GroupUiL10n on BuildContext {
  String localizedGroupRole(GroupRole role) {
    final l10n = this.l10n;
    return switch (role) {
      GroupRole.leader => l10n.groupsRoleLeader,
      GroupRole.member => l10n.groupsRoleMember,
    };
  }
}
