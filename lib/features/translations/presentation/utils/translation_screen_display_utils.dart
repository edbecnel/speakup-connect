import 'package:speakup_connect/core/constants/translation_assignable_routes.dart';
import 'package:speakup_connect/features/translations/presentation/providers/translation_screens_provider.dart';

/// Resolves the display label for a translation entry's canonical [route].
///
/// Option B precedence:
/// - org screen override name (if assigned to this route and non-empty)
/// - built-in route label from [kTranslationAssignableRoutes]
/// - raw route string
/// - fallback label when route is missing
String translationScreenDisplayLabel({
  required String? route,
  required TranslationScreensState? screensState,
  String unassignedLabel = 'Unassigned',
}) {
  final normalized = route?.trim();
  final hasRoute = normalized != null && normalized.isNotEmpty;

  if (hasRoute && screensState != null) {
    final overrideName = screensState.screenForRoute(normalized!)?.name.trim();
    if (overrideName != null && overrideName.isNotEmpty) {
      return overrideName;
    }
  }

  if (!hasRoute) return unassignedLabel;

  return translationRouteLabel(normalized) ?? normalized!;
}

