import 'package:flutter/material.dart';

/// Default color palette for SpeakUp Connect.
///
/// These are the fallback colors used when no organization config is loaded.
/// Each organization overrides [primaryColor] and [secondaryColor] via their
/// Firestore config document.
abstract class AppColors {
  // --- Primary Palette (Default — overridden per organization) ---
  // Confirmed branding §11 — May 21, 2026

  /// Default primary color: Speakup Blue. Organizations replace this with their brand color.
  static const Color primary = Color(0xFF2563EB); // Speakup Blue
  static const Color primaryLight = Color(0xFF3B82F6); // blue-500
  static const Color primaryDark = Color(0xFF1D4ED8); // blue-700
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Default secondary/accent color: Speakup Green.
  static const Color secondary = Color(0xFF10B981); // Speakup Green
  static const Color secondaryLight = Color(0xFF34D399); // emerald-400
  static const Color secondaryDark = Color(0xFF059669); // emerald-600
  static const Color onSecondary = Color(0xFFFFFFFF);

  // --- Surface & Background ---
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6); // Card Grey
  static const Color background = Color(0xFFFAFAFA); // Surface White
  static const Color onSurface = Color(0xFF111827); // Text Primary
  static const Color onBackground = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280); // Neutral Mid
  static const Color dividerColor = Color(0xFFE5E7EB); // Neutral Light

  // --- Dark Theme ---
  static const Color surfaceDark = Color(0xFF1F2937); // gray-800
  static const Color surfaceVariantDark = Color(0xFF374151); // gray-700
  static const Color backgroundDark = Color(0xFF111827); // gray-900
  static const Color onSurfaceDark = Color(0xFFF9FAFB); // gray-50
  static const Color primaryDarkMode = Color(0xFF60A5FA); // Speakup Blue Light

  // --- Status Colors (Report statuses) ---
  static const Color statusSubmitted = Color(0xFF1565C0);   // Blue
  static const Color statusUnderReview = Color(0xFFF57C00); // Orange
  static const Color statusInProgress = Color(0xFF7B1FA2);  // Purple
  static const Color statusResolved = Color(0xFF2E7D32);    // Green
  static const Color statusClosed = Color(0xFF616161);      // Grey

  // --- Semantic Colors ---
  static const Color error = Color(0xFFDC2626); // Alert Red
  static const Color errorLight = Color(0xFFEF4444);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF10B981); // matches secondary
  static const Color warning = Color(0xFFF59E0B); // Caution Amber
  static const Color info = Color(0xFF2563EB); // matches primary

  // --- Neutral ---
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // --- Report Category Colors ---
  static const Color categorySafety = Color(0xFFD32F2F);
  static const Color categoryBullying = Color(0xFFE64A19);
  static const Color categoryMaintenance = Color(0xFF1565C0);
  static const Color categoryFacilities = Color(0xFF00838F);
  static const Color categoryHarassment = Color(0xFF6A1B9A);
  static const Color categorySuggestions = Color(0xFF558B2F);
  static const Color categoryCleanliness = Color(0xFF00897B);
  static const Color categorySecurity = Color(0xFF37474F);
  static const Color categoryOther = Color(0xFF78909C);
}

/// Holds organization-specific theme colors loaded from Firestore.
/// Passed to [AppTheme] to override default palette.
class OrgThemeColors {
  const OrgThemeColors({
    required this.primary,
    required this.secondary,
  });

  final Color primary;
  final Color secondary;

  /// Parses hex color string (e.g., '#1976D2') to a Flutter [Color].
  static Color fromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
