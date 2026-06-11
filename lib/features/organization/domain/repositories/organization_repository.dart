import 'package:speakup_connect/features/organization/domain/entities/organization_config_entity.dart';

/// Abstract repository interface for organization configuration.
///
/// The data layer implements this interface. The domain layer and
/// presentation layer depend only on this interface, never on the
/// concrete Firestore implementation.
abstract class OrganizationRepository {
  /// Loads the organization configuration once for the given [organizationId].
  ///
  /// When [preferServer] is true, reads from the Firestore server first to
  /// bypass a stale on-device cache (e.g. after verifying a settings write).
  Future<OrganizationConfigEntity> getOrganizationConfig(
    String organizationId, {
    bool preferServer = false,
  });

  /// Emits a new [OrganizationConfigEntity] every time the org document
  /// changes in Firestore, enabling real-time theme propagation to all
  /// connected clients without an app restart.
  Stream<OrganizationConfigEntity> watchOrganizationConfig(
    String organizationId,
  );

  /// Writes updated theme colors to the org document in Firestore.
  ///
  /// Only callable by users with role `super_admin`. Firestore security rules
  /// enforce this server-side; the client should also guard the UI.
  ///
  /// [primaryHex] and [secondaryHex] must be 6-digit hex strings prefixed
  /// with `#`, e.g. `'#CC0000'`.
  Future<void> updateThemeColors({
    required String organizationId,
    required String primaryHex,
    required String secondaryHex,
  });

  /// Writes all branding fields (display name + theme colors) to Firestore.
  ///
  /// Used by the admin branding screen so a single save updates both the
  /// Firestore document (real-time propagation to all connected clients) and
  /// the local SharedPreferences cache (instant startup colors on the device
  /// where the change was made).
  Future<void> updateBranding({
    required String organizationId,
    required String displayName,
    required String primaryHex,
    required String secondaryHex,
  });

  /// Toggles whether reminders require approval before publishing.
  ///
  /// When enabled, members holding `broadcastReminders` but not
  /// `approveReminders` have their reminders saved as `pending` for review.
  Future<void> updateReminderApproval({
    required String organizationId,
    required bool requireApproval,
  });

  /// Toggles whether members may upload a personal profile photo in Settings.
  ///
  /// Does not affect admin-managed [officialPhotoUrl] records on profiles.
  Future<void> updateMemberProfilePhotos({
    required String organizationId,
    required bool allowMemberProfilePhotos,
  });

  /// Updates the grade levels offered by a school-type organization.
  Future<void> updateGradeLevels({
    required String organizationId,
    required List<int> gradeLevels,
  });

  /// Updates the organization type (school, NGO, municipality, etc.).
  Future<void> updateOrganizationType({
    required String organizationId,
    required OrganizationType type,
  });
}
