import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speakup_connect/core/theme/app_colors.dart';
import 'package:speakup_connect/features/organization/domain/entities/organization_config_entity.dart';

/// Persists org branding fields (display name + theme colors) to
/// [SharedPreferences] so they are available on the very first frame of
/// every subsequent app launch — before any Firestore data arrives.
///
/// Usage:
/// ```dart
/// // Save after Firestore loads:
/// await OrgConfigCacheService.save(config);
///
/// // Read on startup (inside async build):
/// final cached = await OrgConfigCacheService.load();
/// if (cached != null) state = AsyncValue.data(cached);
/// ```
class OrgConfigCacheService {
  OrgConfigCacheService._();

  static const String _keyDisplayName = 'org_display_name';
  static const String _keyPrimaryColor = 'org_primary_color';
  static const String _keySecondaryColor = 'org_secondary_color';
  static const String _keyRequireReminderApproval =
      'org_require_reminder_approval';

  /// Saves the branding fields from [config] to local storage.
  static Future<void> save(OrganizationConfigEntity config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDisplayName, config.displayName);
    await prefs.setString(_keyPrimaryColor, _toHex(config.themeColors.primary));
    await prefs.setString(
        _keySecondaryColor, _toHex(config.themeColors.secondary));
    await prefs.setBool(
      _keyRequireReminderApproval,
      config.requireReminderApproval,
    );
  }

  /// Loads cached branding, or returns null if no cache exists yet
  /// (i.e., the very first app launch on this device).
  static Future<CachedOrgBranding?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyDisplayName);
    final primaryHex = prefs.getString(_keyPrimaryColor);
    final secondaryHex = prefs.getString(_keySecondaryColor);
    if (name == null || primaryHex == null || secondaryHex == null) return null;
    return CachedOrgBranding(
      displayName: name,
      colors: OrgThemeColors(
        primary: _fromHex(primaryHex),
        secondary: _fromHex(secondaryHex),
      ),
      requireReminderApproval:
          prefs.getBool(_keyRequireReminderApproval) ?? false,
    );
  }

  static Color _fromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String _toHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }
}

/// Lightweight branding snapshot loaded from local cache on startup.
class CachedOrgBranding {
  const CachedOrgBranding({
    required this.displayName,
    required this.colors,
    this.requireReminderApproval = false,
  });

  final String displayName;
  final OrgThemeColors colors;
  final bool requireReminderApproval;
}
