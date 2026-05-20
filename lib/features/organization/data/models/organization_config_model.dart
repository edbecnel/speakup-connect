import 'package:flutter/material.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/theme/app_colors.dart';
import 'package:speakup_connect/features/organization/domain/entities/organization_config_entity.dart';

/// Firestore data model for organization configuration.
///
/// Extends [OrganizationConfigEntity] with JSON serialization
/// for reading/writing Firestore documents.
class OrganizationConfigModel extends OrganizationConfigEntity {
  const OrganizationConfigModel({
    required super.organizationId,
    required super.displayName,
    required super.type,
    required super.themeColors,
    required super.allowAnonymousReports,
    required super.reportCodePrefix,
    super.logoUrl,
    super.tagline,
    super.welcomeMessage,
    super.country,
    super.isActive,
  });

  factory OrganizationConfigModel.fromJson(
    String organizationId,
    Map<String, dynamic> json,
  ) {
    final primaryHex = json['primaryColor'] as String? ?? '#1565C0';
    final secondaryHex = json['secondaryColor'] as String? ?? '#00897B';

    return OrganizationConfigModel(
      organizationId: organizationId,
      displayName: json['displayName'] as String? ?? 'My Organization',
      type: OrganizationType.fromValue(json['type'] as String? ?? 'other'),
      themeColors: OrgThemeColors(
        primary: OrgThemeColors.fromHex(primaryHex),
        secondary: OrgThemeColors.fromHex(secondaryHex),
      ),
      allowAnonymousReports: json['allowAnonymousReports'] as bool? ?? true,
      reportCodePrefix: json['reportCodePrefix'] as String? ?? 'ORG',
      logoUrl: json['logoUrl'] as String?,
      tagline: json['tagline'] as String?,
      welcomeMessage: json['welcomeMessage'] as String?,
      country: json['country'] as String? ?? 'PH',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      AppConstants.fieldOrganizationId: organizationId,
      'displayName': displayName,
      'type': type.value,
      'primaryColor': _colorToHex(themeColors.primary),
      'secondaryColor': _colorToHex(themeColors.secondary),
      'allowAnonymousReports': allowAnonymousReports,
      'reportCodePrefix': reportCodePrefix,
      'logoUrl': logoUrl,
      'tagline': tagline,
      'welcomeMessage': welcomeMessage,
      'country': country,
      'isActive': isActive,
    };
  }

  static String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Returns a hardcoded config for the MONHS pilot deployment.
  /// Used as fallback when Firestore is unreachable during development.
  factory OrganizationConfigModel.monhsDev() => const OrganizationConfigModel(
        organizationId: 'monhs-ph-001',
        displayName: 'MONHS',
        type: OrganizationType.school,
        themeColors: OrgThemeColors(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        allowAnonymousReports: true,
        reportCodePrefix: 'MONHS',
        tagline: 'Your voice. Our action. A better school for all.',
        welcomeMessage: 'How can we help make our school better?',
      );
}
