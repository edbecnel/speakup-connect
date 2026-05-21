import 'package:speakup_connect/features/organization/domain/entities/organization_config_entity.dart';

/// Abstract repository interface for organization configuration.
///
/// The data layer implements this interface. The domain layer and
/// presentation layer depend only on this interface, never on the
/// concrete Firestore implementation.
abstract class OrganizationRepository {
  /// Loads the organization configuration once for the given [organizationId].
  Future<OrganizationConfigEntity> getOrganizationConfig(String organizationId);

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
}
