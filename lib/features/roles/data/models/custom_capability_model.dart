import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakup_connect/features/roles/domain/entities/custom_capability_entity.dart';

/// Firestore data model for a custom capability alias document.
///
/// Document path: `organizations/{orgId}/customCapabilities/{id}`
class CustomCapabilityModel extends CustomCapabilityEntity {
  const CustomCapabilityModel({
    required super.id,
    required super.displayName,
    super.description,
    required super.resolvedAction,
    super.tagScope,
    required super.usedInRoles,
    required super.createdBy,
    required super.createdAt,
  });

  factory CustomCapabilityModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return CustomCapabilityModel(
      id: documentId,
      displayName: data['displayName'] as String? ?? '',
      description: data['description'] as String?,
      resolvedAction: data['resolvedAction'] as String? ?? '',
      tagScope: data['tagScope'] as String?,
      usedInRoles: List<String>.from(
        (data['usedInRoles'] as List<dynamic>?) ?? [],
      ),
      createdBy: data['createdBy'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      if (description != null) 'description': description,
      'resolvedAction': resolvedAction,
      if (tagScope != null) 'tagScope': tagScope,
      'usedInRoles': usedInRoles,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
