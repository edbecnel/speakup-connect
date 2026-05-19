import 'package:speakup_connect/features/organization/domain/entities/organization_config_entity.dart';

/// Abstract repository interface for organization configuration.
///
/// The data layer implements this interface. The domain layer and
/// presentation layer depend only on this interface, never on the
/// concrete Firestore implementation.
abstract class OrganizationRepository {
  /// Loads the organization configuration for the given [organizationId].
  ///
  /// Throws [NotFoundFailure] if no organization with this ID exists.
  /// Throws [NetworkFailure] if there is no connectivity.
  Future<OrganizationConfigEntity> getOrganizationConfig(String organizationId);
}
