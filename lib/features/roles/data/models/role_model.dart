import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakup_connect/features/roles/domain/entities/role_entity.dart';

/// Firestore data model for a role definition document.
///
/// Document path: `organizations/{orgId}/roles/{roleId}`
class RoleModel extends RoleEntity {
  const RoleModel({
    required super.id,
    required super.displayName,
    super.description,
    required super.isSystemRole,
    required super.capabilities,
    required super.customCapabilities,
    required super.createdAt,
    required super.updatedAt,
  });

  factory RoleModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return RoleModel(
      id: documentId,
      displayName: data['displayName'] as String? ?? '',
      description: data['description'] as String?,
      isSystemRole: data['isSystemRole'] as bool? ?? false,
      capabilities: List<String>.from(
        (data['capabilities'] as List<dynamic>?) ?? [],
      ),
      customCapabilities: List<String>.from(
        (data['customCapabilities'] as List<dynamic>?) ?? [],
      ),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      if (description != null) 'description': description,
      'isSystemRole': isSystemRole,
      'capabilities': capabilities,
      'customCapabilities': customCapabilities,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
