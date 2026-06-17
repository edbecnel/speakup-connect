import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:speakup_connect/core/theme/app_colors.dart';
import 'package:speakup_connect/core/theme/app_typography.dart';

/// Factory for Material Design 3 [ThemeData].
///
/// Creates light and dark themes with optional organization-specific
/// primary/secondary color overrides. When [orgColors] is null, the
/// default [AppColors] palette is used.
abstract class AppTheme {
  /// Builds the light [ThemeData].
  static ThemeData light({OrgThemeColors? orgColors}) {
    final primary = orgColors?.primary ?? AppColors.primary;
    final secondary = orgColors?.secondary ?? AppColors.secondary;

    // If the stored primary is invisible on a light surface, use secondary
    // as the effective primary so that ALL Material components (not just
    // explicitly themed ones) render with a visible color.
    const lightSurface = Color(0xFFFFFBFE);
    final effectivePrimary = effectiveForeground(primary, secondary, lightSurface);

    final seed = ColorScheme.fromSeed(
      seedColor: effectivePrimary,
      primary: effectivePrimary,
      secondary: secondary,
    );
    final colorScheme = seed.copyWith(
      onPrimary: _onColor(effectivePrimary),
      onSecondary: _onColor(secondary),
    );

    return _buildTheme(colorScheme: colorScheme, isDark: false);
  }

  /// Builds the dark [ThemeData].
  static ThemeData dark({OrgThemeColors? orgColors}) {
    final primary = orgColors?.primary ?? AppColors.primary;
    final secondary = orgColors?.secondary ?? AppColors.secondary;

    // In dark mode, use the stored primary/secondary as-is — the dark surface
    // provides enough contrast for most colors, and swapping would break the
    // intended dark-mode palette (e.g. white primary looks fine on dark bg).
    //
    // However, M3 generates onPrimary at tonal tone 20, which is designed for
    // the auto-generated light-pink dark-mode primary (tone 80). When we
    // explicitly override primary (e.g. institutional red #CE1126 at tone ~35),
    // that tone-20 onPrimary is a very dark shade that looks black on the banner.
    // Re-derive onPrimary as whichever of white/black contrasts better with the
    // actual primary we're using.
    final seed = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      brightness: Brightness.dark,
    );
    final colorScheme = seed.copyWith(
      onPrimary: _onColor(primary),
      onSecondary: _onColor(secondary),
    );

    return _buildTheme(colorScheme: colorScheme, isDark: true);
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    final textTheme = AppTypography.textTheme(isDark: isDark);
    // Prefer primary for foreground; fall back to secondary if primary would
    // blend into the surface (e.g. white primary on a light background).
    final effectiveFg = effectiveForeground(
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.surface,
    );
    // The "on" color for surfaces filled with effectiveFg (buttons, FAB).
    // Computed directly from effectiveFg so it's always white-or-black,
    // whichever contrasts better — regardless of which color was chosen.
    final effectiveFgContent = _onColor(effectiveFg);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      brightness: isDark ? Brightness.dark : Brightness.light,

      // --- AppBar ---
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),

      // --- Bottom Navigation ---
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: effectiveFg,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        backgroundColor: colorScheme.surface,
        elevation: 8,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: textTheme.labelSmall,
      ),

      // --- Elevated Button ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveFg,
          foregroundColor: effectiveFgContent,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),

      // --- Filled Button ---
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: effectiveFg,
          foregroundColor: effectiveFgContent,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // --- Outlined Button ---
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveFg,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: effectiveFg, width: 1.5),
          textStyle: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // --- Text Button ---
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: effectiveFg,
          textStyle: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // --- Input Decoration ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: effectiveFg,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // --- Card ---
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        color: colorScheme.surface,
        margin: EdgeInsets.zero,
      ),

      // --- Chip ---
      // Selected chips fill with the brand's effective foreground color so the
      // selection state is always readable: unselected chips sit on the surface
      // with normal text, selected chips invert (effectiveFg background +
      // effectiveFgContent text), mirroring the filled-button convention.
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: textTheme.labelMedium,
        selectedColor: effectiveFg,
        secondarySelectedColor: effectiveFg,
        checkmarkColor: effectiveFgContent,
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: effectiveFgContent,
        ),
      ),

      // --- Switch ---
      // Active (on) track = secondary; thumb tinted with onSecondary.
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.secondary;
          }
          return null; // defer to M3 default
        }),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onSecondary;
          }
          return null;
        }),
      ),

      // --- Checkbox ---
      // Checked fill = secondary; checkmark = onSecondary.
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.secondary;
          }
          return null;
        }),
        checkColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onSecondary;
          }
          return null;
        }),
      ),

      // --- Radio ---
      // Selected fill = secondary, consistent with Checkbox.
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.secondary;
          }
          return null;
        }),
      ),

      // --- FloatingActionButton ---
      // Do NOT set shape here: regular FABs default to CircleBorder and
      // extended FABs default to StadiumBorder — let each use its own default.
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: effectiveFg,
        foregroundColor: effectiveFgContent,
        elevation: 4,
      ),

      // --- Divider ---
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),

      // --- SnackBar ---
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }

  // ── Contrast utilities ─────────────────────────────────────────────────────

  /// Returns [primary] if it achieves ≥3:1 contrast against [surface];
  /// falls back to [secondary], then [primary] if neither qualifies.
  static Color effectiveForeground(
    Color primary,
    Color secondary,
    Color surface,
  ) {
    const minRatio = 3.0;
    if (_contrastRatio(primary, surface) >= minRatio) return primary;
    if (_contrastRatio(secondary, surface) >= minRatio) return secondary;
    return primary;
  }

  /// True when neither [primary] nor [secondary] achieves 3:1 contrast against
  /// [surface] — the app cannot auto-resolve the conflict via fallback alone.
  static bool colorsNeedContrastWarning(
    Color primary,
    Color secondary,
    Color surface,
  ) {
    const minRatio = 3.0;
    return _contrastRatio(primary, surface) < minRatio &&
        _contrastRatio(secondary, surface) < minRatio;
  }

  /// True when [primary] alone fails 3:1 contrast against [surface],
  /// regardless of whether [secondary] could serve as a fallback.
  /// Use this to warn admins when their chosen brand color isn't visible,
  /// even if the app can auto-resolve at runtime.
  static bool primaryNeedsContrastWarning(Color primary, Color surface) {
    return _contrastRatio(primary, surface) < 3.0;
  }

  /// Blends [color] toward black (light surface) or white (dark surface) until
  /// it achieves [minRatio]:1 contrast, then returns the adjusted color.
  static Color autoAdjustForContrast(
    Color color,
    Color surface, {
    double minRatio = 4.5,
  }) {
    if (_contrastRatio(color, surface) >= minRatio) return color;
    final target = _relativeLuminance(surface) > 0.5
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
    Color adjusted = color;
    for (int i = 0; i < 100; i++) {
      if (_contrastRatio(adjusted, surface) >= minRatio) return adjusted;
      adjusted = Color.lerp(adjusted, target, 0.05)!;
    }
    return adjusted;
  }

  static double _relativeLuminance(Color c) {
    double lin(double v) {
      return v <= 0.04045
          ? v / 12.92
          : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    }
    return 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
  }

  static double _contrastRatio(Color a, Color b) {
    final la = _relativeLuminance(a);
    final lb = _relativeLuminance(b);
    final lighter = la > lb ? la : lb;
    final darker = la > lb ? lb : la;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Returns white or black — whichever contrasts better against [background].
  /// Used for all "on" colors (onPrimary, onSecondary, button text, FAB icon)
  /// so text is always legible regardless of the org's chosen brand colors.
  static Color _onColor(Color background) {
    const white = Color(0xFFFFFFFF);
    const black = Color(0xFF000000);
    return _contrastRatio(background, white) >= _contrastRatio(background, black)
        ? white
        : black;
  }
}
