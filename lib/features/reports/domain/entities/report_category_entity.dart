/// Domain entity representing a report category.
///
/// Categories are configurable per organization and loaded from:
/// `organizations/{organizationId}/categories/{categoryId}`
class ReportCategoryEntity {
  const ReportCategoryEntity({
    required this.categoryId,
    required this.label,
    required this.iconName,
    required this.sortOrder,
    this.colorHex,
    this.requiresPhoto = false,
    this.isActive = true,
  });

  final String categoryId;
  final String label;

  /// Material icon name (used with [Icons] lookup).
  final String iconName;

  /// Hex color string for this category (e.g., '#D32F2F').
  final String? colorHex;

  /// Whether this category requires at least one photo.
  final bool requiresPhoto;

  /// Whether this category is available for selection.
  final bool isActive;

  /// Display order in category pickers.
  final int sortOrder;
}
