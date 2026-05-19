import 'package:flutter/material.dart';

/// Default color palette for SpeakUp Connect.
///
/// These are the fallback colors used when no organization config is loaded.
/// Each organization overrides [primaryColor] and [secondaryColor] via their
/// Firestore config document.
abstract class AppColors {
  // --- Primary Palette (Default — overridden per organization) ---

  /// Default primary color. Organizations replace this with their brand color.
  static const Color primary = Color(0xFF1565C0); // Deep Blue
  static const Color primaryLight = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Default secondary/accent color.
  static const Color secondary = Color(0xFF00897B); // Teal
  static const Color secondaryLight = Color(0xFF26A69A);
  static const Color secondaryDark = Color(0xFF00695C);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // --- Surface & Background ---
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color background = Color(0xFFF8F9FA);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onBackground = Color(0xFF1C1B1F);

  // --- Dark Theme ---
  static const Color surfaceDark = Color(0xFF1E1E2E);
  static const Color surfaceVariantDark = Color(0xFF2A2A3E);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color onSurfaceDark = Color(0xFFE6E1E5);

  // --- Status Colors (Report statuses) ---
  static const Color statusSubmitted = Color(0xFF1565C0);   // Blue
  static const Color statusUnderReview = Color(0xFFF57C00); // Orange
  static const Color statusInProgress = Color(0xFF7B1FA2);  // Purple
  static const Color statusResolved = Color(0xFF2E7D32);    // Green
  static const Color statusClosed = Color(0xFF616161);      // Grey

  // --- Semantic Colors ---
  static const Color error = Color(0xFFB71C1C);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1565C0);

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
