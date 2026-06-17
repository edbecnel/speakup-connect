import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography configuration for SpeakUp Connect.
///
/// Confirmed branding §12 — May 21, 2026:
/// - Display / Heading: Plus Jakarta Sans (700, 600)
/// - Body / Label:      Inter (400, 500)
/// - Monospace:         JetBrains Mono (not used in TextTheme — apply manually)
abstract class AppTypography {
  /// Returns the [TextTheme] configured for the app.
  /// [isDark] controls text brightness for light/dark mode.
  static TextTheme textTheme({bool isDark = false}) {
    final baseColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827);
    final subtleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return TextTheme(
      // --- Display (Plus Jakarta Sans) ---
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.20,
        color: baseColor,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: baseColor,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.30,
        color: baseColor,
      ),

      // --- Headline (Plus Jakarta Sans) ---
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: baseColor,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.30,
        color: baseColor,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: baseColor,
      ),

      // --- Title (Plus Jakarta Sans) ---
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.40,
        color: baseColor,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.50,
        color: baseColor,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43,
        color: baseColor,
      ),

      // --- Body (Inter) ---
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.50,
        color: baseColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        color: baseColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.50,
        color: subtleColor,
      ),

      // --- Label (Inter) ---
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        color: baseColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: baseColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: subtleColor,
      ),
    );
  }
}
