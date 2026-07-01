/// Domain entity representing a role definition.
///
/// Stored in Firestore at:
///   `organizations/{orgId}/roles/{roleId}`
///
/// A role is a named collection of capability keys and custom capability IDs.
/// The actual [AppPermission] values are resolved at runtime from these keys.
class RoleEntity {
  const RoleEntity({
    required this.id,
    required this.displayName,
    this.description,
    required this.isSystemRole,
    required this.capabilities,
    required this.customCapabilities,
    this.allowedCategoryIds,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firestore document ID (e.g. "guidance-counselor", "org-admin").
  final String id;

  /// Human-readable name shown in the admin panel.
  final String displayName;

  final String? description;

  /// System roles are seeded on org creation and cannot be deleted.
  /// Examples: "org-admin", "member".
  final bool isSystemRole;

  /// List of [AppPermission.key] strings granted directly by this role.
  final List<String> capabilities;

  /// List of custom capability document IDs from
  /// `organizations/{orgId}/customCapabilities/` that this role includes.
  ///
  /// These are resolved to their [AppPermission] at runtime via the
  /// custom capability registry.
  final List<String> customCapabilities;

  /// Report categories this role may access for report-related capabilities.
  ///
  /// `null` on [org-admin] = all categories. Empty list = no report access.
  final List<String>? allowedCategoryIds;

  final DateTime createdAt;
  final DateTime updatedAt;
}
