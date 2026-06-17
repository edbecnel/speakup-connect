import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakup_connect/core/permissions/org_scope_type.dart';
import 'package:speakup_connect/features/roles/domain/entities/role_assignment_entity.dart';

/// Firestore data model for a role assignment document.
///
/// Document path:
///   `organizations/{orgId}/users/{userId}/roleAssignments/{assignmentId}`
class RoleAssignmentModel extends RoleAssignmentEntity {
  const RoleAssignmentModel({
    required super.assignmentId,
    required super.roleId,
    required super.scopeType,
    super.scopeId,
    required super.assignedBy,
    required super.assignedAt,
  });

  factory RoleAssignmentModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return RoleAssignmentModel(
      assignmentId: documentId,
      roleId: data['roleId'] as String? ?? '',
      scopeType: OrgScopeType.fromKey(
            data['scopeType'] as String? ?? '',
          ) ??
          OrgScopeType.org,
      scopeId: data['scopeId'] as String?,
      assignedBy: data['assignedBy'] as String? ?? '',
      assignedAt:
          (data['assignedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'roleId': roleId,
      'scopeType': scopeType.key,
      if (scopeId != null) 'scopeId': scopeId,
      'assignedBy': assignedBy,
      'assignedAt': FieldValue.serverTimestamp(),
    };
  }
}
