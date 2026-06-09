/// A customizable office/position label within a group (e.g. President).
class GroupPositionRole {
  const GroupPositionRole({
    required this.id,
    required this.label,
    this.sortOrder = 0,
  });

  final String id;
  final String label;
  final int sortOrder;

  GroupPositionRole copyWith({
    String? id,
    String? label,
    int? sortOrder,
  }) {
    return GroupPositionRole(
      id: id ?? this.id,
      label: label ?? this.label,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

/// Default SSLG officer positions seeded for MONHS demos.
abstract class SslgDefaultPositionRoles {
  static const List<GroupPositionRole> roles = [
    GroupPositionRole(id: 'president', label: 'President', sortOrder: 0),
    GroupPositionRole(
      id: 'vice-president',
      label: 'Vice President',
      sortOrder: 1,
    ),
    GroupPositionRole(id: 'treasurer', label: 'Treasurer', sortOrder: 2),
    GroupPositionRole(id: 'secretary', label: 'Secretary', sortOrder: 3),
    GroupPositionRole(id: 'other', label: 'Other', sortOrder: 4),
  ];

  static List<Map<String, dynamic>> toFirestoreMaps() => roles
      .map(
        (r) => {
          'id': r.id,
          'label': r.label,
          'sortOrder': r.sortOrder,
        },
      )
      .toList();
}
