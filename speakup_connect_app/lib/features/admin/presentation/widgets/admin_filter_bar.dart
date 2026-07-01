import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/reports/domain/entities/report_category_entity.dart';
import 'package:speakup_connect/features/reports/presentation/providers/report_provider.dart';

/// State provider for the selected category filters in the admin dashboard.
/// An empty set means "All categories".
final adminCategoryFilterProvider =
    NotifierProvider<_AdminCategoryFilterNotifier, Set<String>>(
  _AdminCategoryFilterNotifier.new,
);

/// State provider for the admin dashboard search query.
/// An empty string means no active search filter.
final adminSearchQueryProvider = NotifierProvider<_AdminSearchQueryNotifier, String>(
  _AdminSearchQueryNotifier.new,
);

class _AdminSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String query) => state = query;
}

class _AdminCategoryFilterNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String categoryId) {
    final current = state;
    if (current.contains(categoryId)) {
      state = Set.unmodifiable(current.difference({categoryId}));
    } else {
      state = Set.unmodifiable({...current, categoryId});
    }
  }

  void clearAll() => state = const {};
}

/// Horizontal chip row that lets admins filter the report list by category.
///
/// Reads [reportCategoriesProvider] for the category list and
/// updates [adminCategoryFilterProvider] when a chip is tapped.
class AdminFilterBar extends ConsumerWidget {
  const AdminFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(reportCategoriesProvider);
    final selectedCategories = ref.watch(adminCategoryFilterProvider);
    final notifier = ref.read(adminCategoryFilterProvider.notifier);
    final allowedCategories = ref.watch(allowedReportCategoryIdsProvider);

    return categoriesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (categories) {
        final visible = allowedCategories == null
            ? categories
            : categories
                .where((c) => allowedCategories.contains(c.categoryId))
                .toList();
        if (visible.isEmpty) return const SizedBox.shrink();

        return _ChipRow(
          categories: visible,
          selectedCategories: selectedCategories,
          onToggle: notifier.toggle,
          onClearAll: notifier.clearAll,
        );
      },
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.categories,
    required this.selectedCategories,
    required this.onToggle,
    required this.onClearAll,
  });

  final List<ReportCategoryEntity> categories;
  final Set<String> selectedCategories;
  final ValueChanged<String> onToggle;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final allSelected = selectedCategories.isEmpty;

    return Container(
      color: theme.colorScheme.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // "All" chip — clears every other selection when tapped
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(l10n.commonAll),
                selected: allSelected,
                onSelected: (_) => onClearAll(),
              ),
            ),
            // Category chips — independent toggles
            ...categories.map(
              (cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(cat.label),
                  selected: selectedCategories.contains(cat.categoryId),
                  onSelected: (_) => onToggle(cat.categoryId),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
