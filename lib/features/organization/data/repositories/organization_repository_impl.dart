import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';
import 'package:speakup_connect/features/organization/data/models/organization_config_model.dart';
import 'package:speakup_connect/features/organization/domain/entities/organization_config_entity.dart';
import 'package:speakup_connect/features/organization/domain/repositories/organization_repository.dart';
// ignore_for_file: avoid_catches_without_on_clauses

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

  @override
  Stream<OrganizationConfigEntity> watchOrganizationConfig(
    String organizationId,
  ) {
    return _firestore
        .collection(AppConstants.organizationsCollection)
        .doc(organizationId)
        .snapshots()
        .map((snap) {
      if (!snap.exists || snap.data() == null) {
        throw NotFoundException(
          message: 'Organization "$organizationId" not found.',
        );
      }
      return OrganizationConfigModel.fromJson(organizationId, snap.data()!);
    });
  }

  @override
  Future<void> updateThemeColors({
    required String organizationId,
    required String primaryHex,
    required String secondaryHex,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.organizationsCollection)
          .doc(organizationId)
          .update({
        'primaryColor': primaryHex,
        'secondaryColor': secondaryHex,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const PermissionException();
      }
      throw DatabaseException(
        message: e.message ?? 'Failed to update theme colors',
        code: e.code,
      );
    }
  }

  @override
  Future<void> updateBranding({
    required String organizationId,
    required String displayName,
    required String primaryHex,
    required String secondaryHex,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.organizationsCollection)
          .doc(organizationId)
          .update({
        'displayName': displayName,
        'primaryColor': primaryHex,
        'secondaryColor': secondaryHex,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const PermissionException();
      }
      throw DatabaseException(
        message: e.message ?? 'Failed to update branding',
        code: e.code,
      );
    }
  }

  @override
  Future<void> updateReminderApproval({
    required String organizationId,
    required bool requireApproval,
  }) async {
    try {
      await _firestore
          .collection(AppConstants.organizationsCollection)
          .doc(organizationId)
          .update({
        'requireReminderApproval': requireApproval,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw const PermissionException();
      }
      throw DatabaseException(
        message: e.message ?? 'Failed to update reminder approval setting',
        code: e.code,
      );
    }
  }
}
