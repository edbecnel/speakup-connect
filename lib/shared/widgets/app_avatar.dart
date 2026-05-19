import 'package:flutter/material.dart';

/// A circular avatar widget that shows a network image, an asset image,
/// or falls back to initials when no image is available.
///
/// Usage:
/// ```dart
/// AppAvatar(displayName: 'Maria Santos', photoUrl: user.photoUrl, radius: 24)
/// AppAvatar(orgName: 'MONHS', radius: 20) // initials from org name
/// ```
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.photoUrl,
    this.displayName,
    this.radius = 20,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// Remote image URL (e.g. Firebase Storage download URL or Google profile photo).
  final String? photoUrl;

  /// Used to derive initials when [photoUrl] is null or fails to load.
  /// Falls back to a generic icon if also null.
  final String? displayName;

  /// Radius of the circular avatar. Default 20 (40 px diameter).
  final double radius;

  /// Background color for the initials fallback. Defaults to [ColorScheme.primaryContainer].
  final Color? backgroundColor;

  /// Text / icon color for the initials fallback. Defaults to [ColorScheme.onPrimaryContainer].
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.primaryContainer;
    final fgColor = foregroundColor ?? theme.colorScheme.onPrimaryContainer;
    final initials = _initials(displayName);

    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        child: ClipOval(
          child: Image.network(
            photoUrl!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _InitialsFallback(
              initials: initials,
              radius: radius,
              bgColor: bgColor,
              fgColor: fgColor,
            ),
          ),
        ),
      );
    }

    return _InitialsFallback(
      initials: initials,
      radius: radius,
      bgColor: bgColor,
      fgColor: fgColor,
    );
  }

  /// Extracts up to 2 uppercase initials from a display name.
  /// "Maria Santos" → "MS", "Admin" → "A", null → null
  static String? _initials(String? name) {
    if (name == null || name.trim().isEmpty) return null;
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}

class _InitialsFallback extends StatelessWidget {
  const _InitialsFallback({
    required this.initials,
    required this.radius,
    required this.bgColor,
    required this.fgColor,
  });

  final String? initials;
  final double radius;
  final Color bgColor;
  final Color fgColor;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: initials != null
          ? Text(
              initials!,
              style: TextStyle(
                color: fgColor,
                fontSize: radius * 0.7,
                fontWeight: FontWeight.w600,
              ),
            )
          : Icon(
              Icons.person_rounded,
              color: fgColor,
              size: radius * 1.1,
            ),
    );
  }
}
