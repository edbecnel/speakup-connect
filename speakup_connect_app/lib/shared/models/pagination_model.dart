import 'package:cloud_firestore/cloud_firestore.dart';

/// Holds a page of results and the cursor needed to fetch the next page.
///
/// Uses Firestore's [DocumentSnapshot]-based cursor pagination so results
/// remain stable even when new documents are inserted between pages.
///
/// Typical usage:
/// ```dart
/// // First page
/// final page1 = await repo.getReports(organizationId: 'monhs', limit: 20);
///
/// // Next page
/// if (page1.hasMore) {
///   final page2 = await repo.getReports(
///     organizationId: 'monhs',
///     limit: 20,
///     startAfterDocument: page1.lastDocument,
///   );
/// }
/// ```
class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.hasMore,
    this.lastDocument,
  });

  /// The items returned for this page.
  final List<T> items;

  /// Whether more pages exist after this one.
  final bool hasMore;

  /// The last Firestore [DocumentSnapshot] in this page.
  /// Pass this as `startAfterDocument` to fetch the next page.
  final DocumentSnapshot? lastDocument;

  bool get isEmpty => items.isEmpty;
  int get length => items.length;

  @override
  String toString() =>
      'PaginatedResult(count: ${items.length}, hasMore: $hasMore)';
}

/// Parameters for a paginated Firestore query.
class PaginationParams {
  const PaginationParams({
    this.limit = 20,
    this.startAfterDocument,
  }) : assert(limit > 0 && limit <= 100, 'limit must be 1–100');

  /// Maximum number of documents to return. Defaults to 20, max 100.
  final int limit;

  /// Cursor from the previous page's [PaginatedResult.lastDocument].
  /// Null means start from the beginning.
  final DocumentSnapshot? startAfterDocument;

  bool get isFirstPage => startAfterDocument == null;
}
