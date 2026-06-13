import 'package:flutter/material.dart';
import 'package:speakup_connect/features/groups/data/models/group_position_role_codec.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/groups/domain/entities/group_position_role.dart';
import 'package:uuid/uuid.dart';

/// Editable list of customizable club positions (President, Secretary, etc.).
class GroupPositionRolesEditor extends StatefulWidget {
  const GroupPositionRolesEditor({
    required this.roles,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final List<GroupPositionRole> roles;
  final ValueChanged<List<GroupPositionRole>> onChanged;
  final bool enabled;

  @override
  State<GroupPositionRolesEditor> createState() =>
      _GroupPositionRolesEditorState();
}

class _GroupPositionRolesEditorState extends State<GroupPositionRolesEditor> {
  late List<_EditableRole> _items;

  @override
  void initState() {
    super.initState();
    _items = _fromRoles(widget.roles);
  }

  List<_EditableRole> _fromRoles(List<GroupPositionRole> roles) {
    return roles
        .map(
          (r) => _EditableRole(
            id: r.id,
            controller: TextEditingController(text: r.label),
          ),
        )
        .toList();
  }

  void _emit() {
    final usedIds = <String>{};
    final roles = <GroupPositionRole>[];
    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      final label = item.controller.text.trim();
      if (label.isEmpty) continue;
      var id = item.id ?? GroupPositionRoleCodec.idFromLabel(label);
      while (usedIds.contains(id)) {
        id = '${id}-${const Uuid().v4().substring(0, 4)}';
      }
      usedIds.add(id);
      roles.add(GroupPositionRole(id: id, label: label, sortOrder: i));
    }
    widget.onChanged(roles);
  }

  void _addRole() {
    setState(() {
      _items.add(_EditableRole(controller: TextEditingController()));
    });
  }

  void _removeAt(int index) {
    setState(() {
      _items[index].controller.dispose();
      _items.removeAt(index);
    });
    _emit();
  }

  void _move(int index, int delta) {
    final target = index + delta;
    if (target < 0 || target >= _items.length) return;
    setState(() {
      final item = _items.removeAt(index);
      _items.insert(target, item);
    });
    _emit();
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.groupsClubPositionsSectionTitle,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(
          l10n.groupsClubPositionsSectionSubtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        if (_items.isEmpty)
          Text(
            'No positions defined yet.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ...List.generate(_items.length, (i) {
          final item = _items[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: item.controller,
                    enabled: widget.enabled,
                    decoration: InputDecoration(
                      labelText: 'Position ${i + 1}',
                      hintText: 'e.g. Vice President',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _emit(),
                  ),
                ),
                const SizedBox(width: 4),
                Column(
                  children: [
                    IconButton(
                      tooltip: 'Move up',
                      onPressed: widget.enabled && i > 0
                          ? () => _move(i, -1)
                          : null,
                      icon: const Icon(Icons.arrow_upward, size: 20),
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      tooltip: 'Move down',
                      onPressed: widget.enabled && i < _items.length - 1
                          ? () => _move(i, 1)
                          : null,
                      icon: const Icon(Icons.arrow_downward, size: 20),
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      tooltip: 'Remove',
                      onPressed:
                          widget.enabled ? () => _removeAt(i) : null,
                      icon: const Icon(Icons.delete_outline, size: 20),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: widget.enabled ? _addRole : null,
            icon: const Icon(Icons.add),
            label: Text(l10n.groupsAddPosition),
          ),
        ),
      ],
    );
  }
}

class _EditableRole {
  _EditableRole({this.id, required this.controller});

  final String? id;
  final TextEditingController controller;
}
