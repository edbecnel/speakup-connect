import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/org_scope_type.dart';

/// Defines the organization types supported by SpeakUp Connect.
///
/// The org type is chosen by the client super admin during initial setup and
/// stored on the organization document. It determines:
///   - Which [OrgScopeType]s are valid for role assignments
///   - Which [AppPermission]s are relevant and shown in the capability catalog
///   - Which Firestore sub-collections are created under the org
///   - Which default system roles are seeded on org creation
///
/// Adding a new org type requires:
///   1. Adding the enum value here
///   2. Defining its [supportedScopeTypes]
///   3. Adding any new [AppPermission] values for org-type-specific actions
///   4. Adding the Firestore schema for any new org-type-specific collections
///   5. Implementing the default role seeding logic for the new type
///   6. Deploying the app update
enum OrgType {
  /// A school or educational institution (e.g. MONHS — Grades 7–10).
  /// Supports academic classes/sections and extracurricular groups.
  school,

  /// A local government unit or municipality.
  /// Supports departments/offices and barangay units.
  municipality;

  // ── Serialization ──────────────────────────────────────────────────────────

  /// The string stored in the organization's Firestore document.
  /// Must remain stable — changing a key is a breaking schema change.
  String get key => name;

  /// Deserializes a Firestore string back to an [OrgType].
  /// Returns `null` for unknown keys (e.g. a type added in a newer app version).
  static OrgType? fromKey(String key) {
    for (final type in OrgType.values) {
      if (type.key == key) return type;
    }
    return null;
  }

  // ── Scope Types ────────────────────────────────────────────────────────────

  /// The role assignment scope types valid for this organization type.
  ///
  /// The admin panel uses this to filter the scope type picker when assigning
  /// roles. The permission provider uses this to validate incoming assignments.
  Set<OrgScopeType> get supportedScopeTypes => switch (this) {
        OrgType.school => const {
            OrgScopeType.org,
            OrgScopeType.tag,
            OrgScopeType.classUnit,
            OrgScopeType.group,
          },
        OrgType.municipality => const {
            OrgScopeType.org,
            OrgScopeType.tag,
            OrgScopeType.department,
            OrgScopeType.barangay,
            OrgScopeType.group,
          },
      };

  // ── Capability Catalog ─────────────────────────────────────────────────────

  /// The [AppPermission]s relevant to this organization type.
  ///
  /// Used by the admin panel to filter the capability catalog — org-type-
  /// irrelevant capabilities are hidden to avoid confusing admins.
  /// All permissions are still enforced regardless; this is a UX filter only.
  Set<AppPermission> get relevantPermissions => AppPermission.values
      .where((p) => p.supportedOrgTypes.contains(this))
      .toSet();
}
