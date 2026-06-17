/// Domain entity representing an org-admin-defined capability alias.
///
/// Stored in Firestore at:
///   `organizations/{orgId}/customCapabilities/{id}`
///
/// A custom capability is a human-readable name (e.g. "Review Guidance
/// Referral") that maps to a pre-built [AppPermission] action. Org admins
/// create these via the admin panel to give school-meaningful labels to
/// capabilities without requiring a code change.
///
/// The [resolvedAction] string is an [AppPermission.key] — it is resolved
/// to the actual enum value at runtime by the permission provider.
class CustomCapabilityEntity {
  const CustomCapabilityEntity({
    required this.id,
    required this.displayName,
    this.description,
    required this.resolvedAction,
    this.tagScope,
    required this.usedInRoles,
    required this.createdBy,
    required this.createdAt,
  });

  /// Firestore document ID (e.g. "cc_review-guidance-referral").
  final String id;

  /// Human-readable name shown in the admin panel.
  final String displayName;

  final String? description;

  /// The [AppPermission.key] this alias resolves to at runtime.
  /// Example: "approveReport"
  final String resolvedAction;

  /// Optional content tag that further restricts this capability.
  ///
  /// When set, this capability only applies to content tagged with this
  /// value, regardless of the role assignment's scope. Example: "guidance"
  /// restricts [resolvedAction] to guidance-tagged content only.
  final String? tagScope;

  /// IDs of roles that include this custom capability.
  final List<String> usedInRoles;

  /// UID of the admin who created this custom capability.
  final String createdBy;

  final DateTime createdAt;
}
