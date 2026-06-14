import 'package:go_router/go_router.dart';

/// Normalizes a GoRouter location for comparison with assignable route paths.
String normalizeTranslationRoute(String location) {
  var path = Uri.parse(location).path;
  if (path.length > 1 && path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }
  return path;
}

/// Current app route path from [GoRouter], or empty when unavailable.
String currentTranslationRoute(GoRouter router) {
  return normalizeTranslationRoute(router.routerDelegate.state.matchedLocation);
}

/// Whether translation edit badges should appear on this route.
bool isTranslationBadgeRouteEnabled(
  Set<String> badgeEnabledRoutes,
  String route,
) {
  if (badgeEnabledRoutes.isEmpty) return false;
  return badgeEnabledRoutes.contains(normalizeTranslationRoute(route));
}
