import 'package:flutter/material.dart';
import 'package:speakup_connect/core/theme/app_colors.dart';

/// [BuildContext] extension methods for convenient access to
/// theme, screen dimensions, and navigation helpers.
extension ContextExtensions on BuildContext {
  // --- Theme ---
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // --- Screen Size ---
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isSmallScreen => screenWidth < 400;
  bool get isMediumScreen => screenWidth >= 400 && screenWidth < 600;

  // --- Padding ---
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;
  double get bottomPadding => MediaQuery.of(this).viewPadding.bottom;

  // --- Status Colors ---
  Color statusColor(String status) {
    switch (status) {
      case 'submitted':
        return AppColors.statusSubmitted;
      case 'under_review':
        return AppColors.statusUnderReview;
      case 'in_progress':
        return AppColors.statusInProgress;
      case 'resolved':
        return AppColors.statusResolved;
      case 'closed':
        return AppColors.statusClosed;
      default:
        return AppColors.grey500;
    }
  }

  /// Displays a standard [SnackBar] message.
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }
}
