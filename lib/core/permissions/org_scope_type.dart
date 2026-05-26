/// Defines every scope type that can be applied to a role assignment.
///
/// A scope type narrows the set of resources a capability applies to.
/// Not all scope types are valid for every [OrgType] — see
/// [OrgType.supportedScopeTypes] for the valid set per organization type.
///
/// Adding a new scope type requires:
///   1. Adding the enum value here
///   2. Adding the corresponding Firestore collection schema
///   3. Updating [OrgType.supportedScopeTypes] for the relevant org types
///   4. Updating the permission provider scope resolution logic
///   5. Deploying the app update
enum OrgScopeType {
  /// The capability applies across the entire organization.
  org,

  /// The capability applies only to content tagged with [scopeId].
  /// Tag values are org-admin-defined (e.g. "guidance", "discipline").
  tag,

  /// The capability applies to a specific academic class or section.
  /// School organizations only. [scopeId] references a `classes/{classId}`.
  classUnit,

  /// The capability applies to a specific extracurricular group or club.
  /// Valid for all organization types. [scopeId] references a
  /// `groups/{groupId}`.
  group,

  /// The capability applies to a specific department or office.
  /// Municipality organizations only. [scopeId] references a
  /// `departments/{departmentId}`.
  department,

  /// The capability applies to a specific barangay unit.
  /// Municipality organizations only. [scopeId] references a
  /// `barangays/{barangayId}`.
  barangay;

  // ── Serialization ──────────────────────────────────────────────────────────

  /// The string stored in Firestore role assignment documents.
  /// Must remain stable — changing a key is a breaking schema change.
  ///
  /// Note: [classUnit] serializes to `"class"` (not `"classUnit"`) for
  /// human-readable Firestore documents. All other values use their Dart name.
  String get key => switch (this) {
        OrgScopeType.classUnit => 'class',
        _ => name,
      };

  /// Deserializes a Firestore string back to an [OrgScopeType].
  /// Returns `null` for unknown keys so callers can gracefully handle values
  /// introduced by newer app versions.
  static OrgScopeType? fromKey(String key) {
    for (final type in OrgScopeType.values) {
      if (type.key == key) return type;
    }
    return null;
  }
}
