import 'package:flutter/material.dart';
import 'package:speakup_connect/config/app_config.dart';
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
    final primaryHex = json['primaryColor'] as String?;
    final secondaryHex = json['secondaryColor'] as String?;

    return OrganizationConfigModel(
      organizationId: organizationId,
      displayName: json['displayName'] as String? ?? '',
      type: OrganizationType.fromValue(json['type'] as String? ?? 'other'),
      themeColors: OrgThemeColors(
        primary: primaryHex != null
            ? OrgThemeColors.fromHex(primaryHex)
            : AppConfig.defaultThemeColors.primary,
        secondary: secondaryHex != null
            ? OrgThemeColors.fromHex(secondaryHex)
            : AppConfig.defaultThemeColors.secondary,
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

  /// Returns a minimal offline-safe config using the app-level defaults
  /// from [AppConfig]. Used when Firestore is unreachable and no local
  /// cache exists (e.g., the very first launch with no network).
  ///
  /// The [organizationId] is read from [AppConfig.defaultOrganizationId] —
  /// the only place in the codebase where a specific org ID is configured.
  factory OrganizationConfigModel.offline() => OrganizationConfigModel(
        organizationId: AppConfig.defaultOrganizationId,
        displayName: AppConfig.clientDisplayName,
        type: OrganizationType.other,
        themeColors: AppConfig.defaultThemeColors,
        allowAnonymousReports: false,
        reportCodePrefix: 'ORG',
      );
}
