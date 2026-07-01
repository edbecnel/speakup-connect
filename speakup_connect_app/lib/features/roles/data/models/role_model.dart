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
    super.allowedCategoryIds,
    required super.createdAt,
    required super.updatedAt,
  });

  factory RoleModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    final isSystemRole = data['isSystemRole'] as bool? ?? false;
    return RoleModel(
      id: documentId,
      displayName: data['displayName'] as String? ?? '',
      description: data['description'] as String?,
      isSystemRole: isSystemRole,
      capabilities: List<String>.from(
        (data['capabilities'] as List<dynamic>?) ?? [],
      ),
      customCapabilities: List<String>.from(
        (data['customCapabilities'] as List<dynamic>?) ?? [],
      ),
      allowedCategoryIds: parseAllowedCategoryIds(
        data: data,
        roleId: documentId,
        isSystemRole: isSystemRole,
      ),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Parses [allowedCategoryIds] with org-admin unrestricted semantics.
  static List<String>? parseAllowedCategoryIds({
    required Map<String, dynamic> data,
    required String roleId,
    required bool isSystemRole,
  }) {
    if (!data.containsKey('allowedCategoryIds')) {
      if (roleId == 'org-admin') return null;
      return const [];
    }
    final raw = data['allowedCategoryIds'];
    if (raw == null) {
      return roleId == 'org-admin' ? null : const [];
    }
    return List<String>.from(raw as List<dynamic>);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      if (description != null) 'description': description,
      'isSystemRole': isSystemRole,
      'capabilities': capabilities,
      'customCapabilities': customCapabilities,
      if (allowedCategoryIds != null)
        'allowedCategoryIds': allowedCategoryIds,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
