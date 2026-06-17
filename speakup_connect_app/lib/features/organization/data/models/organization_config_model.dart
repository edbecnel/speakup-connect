import 'package:flutter/material.dart';
import 'package:speakup_connect/client_org_defaults.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/theme/app_colors.dart';
import 'package:speakup_connect/features/organization/domain/entities/organization_config_entity.dart';
import 'package:speakup_connect/flavor_config.dart';

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
    super.requireReminderApproval,
    super.allowMemberProfilePhotos,
    super.gradeLevels,
  });

  factory OrganizationConfigModel.fromJson(
    String organizationId,
    Map<String, dynamic> json,
  ) {
    final primaryHex = json['primaryColor'] as String?;
    final secondaryHex = json['secondaryColor'] as String?;

    return OrganizationConfigModel(
      organizationId: organizationId,
      displayName: (json['displayName'] as String?)?.trim().isNotEmpty == true
          ? json['displayName'] as String
          : AppConfig.clientDisplayName,
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
      requireReminderApproval: _parseBool(
        json['requireReminderApproval'],
        defaultValue: false,
      ),
      allowMemberProfilePhotos: _parseBool(
        json['allowMemberProfilePhotos'],
        defaultValue: false,
      ),
      gradeLevels: _parseGradeLevels(json['gradeLevels']),
    );
  }

  /// Accepts Firestore bools and legacy string/number encodings.
  static bool _parseBool(dynamic raw, {required bool defaultValue}) {
    if (raw == null) return defaultValue;
    if (raw is bool) return raw;
    if (raw is num) return raw != 0;
    if (raw is String) {
      final normalized = raw.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
        return true;
      }
      if (normalized == 'false' || normalized == '0' || normalized == 'no') {
        return false;
      }
    }
    return defaultValue;
  }

  static List<int>? _parseGradeLevels(dynamic raw) {
    if (raw is! List) return null;
    final levels = raw
        .map((v) => v is num ? v.toInt() : int.tryParse('$v'))
        .whereType<int>()
        .where((g) => g > 0)
        .toSet()
        .toList()
      ..sort();
    return levels.isEmpty ? null : levels;
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
      'requireReminderApproval': requireReminderApproval,
      'allowMemberProfilePhotos': allowMemberProfilePhotos,
      if (gradeLevels != null) 'gradeLevels': gradeLevels,
    };
  }

  static String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Client-build defaults baked into the APK (see [FlavorConfig.orgDefaults]).
  factory OrganizationConfigModel.fromClientDefaults(
    ClientOrgDefaults defaults, {
    required String organizationId,
  }) =>
      OrganizationConfigModel(
        organizationId: organizationId,
        displayName: defaults.displayName,
        type: defaults.type,
        themeColors: defaults.themeColors,
        allowAnonymousReports: true,
        reportCodePrefix: defaults.effectiveReportCodePrefix,
      );

  /// Returns a minimal offline-safe config using flavor defaults for client
  /// builds, or generic [AppConfig] values for the standard app.
  factory OrganizationConfigModel.offline() {
    final orgId = AppConfig.defaultOrganizationId;
    final baked = FlavorConfig.instance.orgDefaults;
    if (baked != null && orgId.isNotEmpty) {
      return OrganizationConfigModel.fromClientDefaults(
        baked,
        organizationId: orgId,
      );
    }

    return OrganizationConfigModel(
      organizationId: orgId,
      displayName: AppConfig.clientDisplayName,
      type: OrganizationType.other,
      themeColors: AppConfig.defaultThemeColors,
      allowAnonymousReports: false,
      reportCodePrefix: 'ORG',
    );
  }
}
