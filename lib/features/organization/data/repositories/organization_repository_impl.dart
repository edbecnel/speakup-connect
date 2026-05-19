import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';
import 'package:speakup_connect/features/organization/data/models/organization_config_model.dart';
import 'package:speakup_connect/features/organization/domain/entities/organization_config_entity.dart';
import 'package:speakup_connect/features/organization/domain/repositories/organization_repository.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  OrganizationRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<OrganizationConfigEntity> getOrganizationConfig(
    String organizationId,
  ) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.organizationsCollection)
          .doc(organizationId)
          .get();

      if (!doc.exists || doc.data() == null) {
        throw NotFoundException(
          message: 'Organization "$organizationId" not found.',
        );
      }

      return OrganizationConfigModel.fromJson(organizationId, doc.data()!);
    } on NotFoundException {
      rethrow;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const PermissionException();
      }
      throw DatabaseException(message: e.message ?? 'Database error', code: e.code);
    } catch (e) {
      throw DatabaseException(message: e.toString());
    }
  }
}
