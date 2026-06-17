import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class AlertsSelectionState {
  const AlertsSelectionState({
    required this.isSelecting,
    required this.selectedIds,
  });

  const AlertsSelectionState.idle()
      : isSelecting = false,
        selectedIds = const <String>{};

  final bool isSelecting;
  final Set<String> selectedIds;

  AlertsSelectionState copyWith({
    bool? isSelecting,
    Set<String>? selectedIds,
  }) {
    return AlertsSelectionState(
      isSelecting: isSelecting ?? this.isSelecting,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

class AlertsSelection extends Notifier<AlertsSelectionState> {
  @override
  AlertsSelectionState build() => const AlertsSelectionState.idle();

  void enterSelection() {
    state = state.copyWith(isSelecting: true);
  }

  void exitSelection() {
    state = const AlertsSelectionState.idle();
  }

  void clearSelection() {
    if (state.selectedIds.isEmpty) return;
    state = state.copyWith(selectedIds: <String>{});
  }

  void toggle(String notificationId) {
    final current = state.selectedIds;
    final next = Set<String>.from(current);
    if (next.contains(notificationId)) {
      next.remove(notificationId);
    } else {
      next.add(notificationId);
    }
    state = state.copyWith(isSelecting: true, selectedIds: next);
  }
}

final alertsSelectionProvider =
    NotifierProvider<AlertsSelection, AlertsSelectionState>(
  AlertsSelection.new,
);

