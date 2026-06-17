import 'package:flutter/material.dart';

/// A standardized button widget used throughout SpeakUp Connect.
///
/// Supports three variants:
/// - [AppButton.primary] — filled button (default action)
/// - [AppButton.secondary] — outlined button (secondary action)
/// - [AppButton.text] — text-only button (tertiary/link action)
class AppButton extends StatelessWidget {
  const AppButton.primary({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.icon,
    this.minimumWidth,
  }) : _variant = _ButtonVariant.primary;

  const AppButton.secondary({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.icon,
    this.minimumWidth,
  }) : _variant = _ButtonVariant.secondary;

  const AppButton.text({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.icon,
    this.minimumWidth,
  }) : _variant = _ButtonVariant.text;

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? minimumWidth;
  final _ButtonVariant _variant;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final isCompact = minimumWidth == 0;

    Widget buildLabel() {
      return Text(
        label,
        maxLines: isCompact ? 2 : 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      );
    }

    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Flexible(child: buildLabel()),
                ],
              )
            : buildLabel();

    final fullWidthMinSize = Size(minimumWidth ?? double.infinity, 52);
    final compactMinSize = const Size(0, 0);
    final compactPadding =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10);

    switch (_variant) {
      case _ButtonVariant.primary:
        return ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: isCompact ? compactMinSize : fullWidthMinSize,
            tapTargetSize:
                isCompact ? MaterialTapTargetSize.shrinkWrap : null,
            padding: isCompact ? compactPadding : null,
          ),
          child: child,
        );
      case _ButtonVariant.secondary:
        return OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: isCompact ? compactMinSize : fullWidthMinSize,
            tapTargetSize:
                isCompact ? MaterialTapTargetSize.shrinkWrap : null,
            padding: isCompact ? compactPadding : null,
          ),
          child: child,
        );
      case _ButtonVariant.text:
        return TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            minimumSize: isCompact ? compactMinSize : fullWidthMinSize,
            tapTargetSize:
                isCompact ? MaterialTapTargetSize.shrinkWrap : null,
            padding: isCompact ? compactPadding : null,
          ),
          child: child,
        );
    }
  }
}

enum _ButtonVariant { primary, secondary, text }
