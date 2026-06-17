import 'package:speakup_connect/features/groups/domain/entities/group_position_role.dart';
import 'package:uuid/uuid.dart';

/// Serializes [GroupPositionRole] lists to/from Firestore.
abstract class GroupPositionRoleCodec {
  static List<GroupPositionRole> fromList(dynamic raw) {
    if (raw is! List) return const [];
    final roles = <GroupPositionRole>[];
    for (var i = 0; i < raw.length; i++) {
      final item = raw[i];
      if (item is! Map<String, dynamic>) continue;
      final label = (item['label'] as String? ?? '').trim();
      if (label.isEmpty) continue;
      final id = (item['id'] as String? ?? '').trim();
      roles.add(
        GroupPositionRole(
          id: id.isEmpty ? const Uuid().v4() : id,
          label: label,
          sortOrder: (item['sortOrder'] as num?)?.toInt() ?? i,
        ),
      );
    }
    roles.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return roles;
  }

  /// Stable slug for new roles (e.g. "Vice President" → "vice-president").
  static String idFromLabel(String label) {
    final slug = label
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return slug.isEmpty ? const Uuid().v4() : slug;
  }

  static List<Map<String, dynamic>> toList(List<GroupPositionRole> roles) {
    return roles
        .asMap()
        .entries
        .map(
          (e) => {
            'id': e.value.id,
            'label': e.value.label.trim(),
            'sortOrder': e.key,
          },
        )
        .where((m) => (m['label'] as String).isNotEmpty)
        .toList();
  }
}
