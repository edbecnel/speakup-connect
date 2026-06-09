import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:speakup_connect/features/notifications/domain/entities/app_notification_entity.dart';
import 'package:speakup_connect/features/notifications/domain/repositories/notification_repository.dart';
import 'package:speakup_connect/features/reminders/presentation/providers/reminder_response_provider.dart';

// ── Infrastructure ───────────────────────────────────────────────────────────

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(FirebaseFirestore.instance);
});

// ── Streams ──────────────────────────────────────────────────────────────────

/// Streams the current user's alert feed (notifications + org broadcasts).
final notificationsProvider =
    StreamProvider.autoDispose<List<AppNotificationEntity>>((ref) async* {
  final user = await ref.watch(authStateChangesProvider.future);
  if (user == null) {
    yield const <AppNotificationEntity>[];
    return;
  }
  yield* ref.watch(notificationRepositoryProvider).watchAlertFeed(
        organizationId: AppConfig.defaultOrganizationId,
        userId: user.uid,
      );
});

/// Count of notifications needing attention (drives the app-bar badge).
///
/// Includes unread items and response-required alerts until the user submits
/// a response.
final unreadNotificationCountProvider = Provider.autoDispose<int>((ref) {
  final items = ref.watch(notificationsProvider).asData?.value ?? const [];
  var count = 0;
  for (final n in items) {
    final reminderId = n.reminderId;
    final hasResponded = reminderId != null && n.responseRequired
        ? ref.watch(myReminderResponseProvider(reminderId)).value != null
        : true;
    if (n.needsAttention(hasResponded: hasResponded)) count++;
  }
  return count;
});

// ── Actions ──────────────────────────────────────────────────────────────────

class NotificationActions extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> markRead(String notificationId) async {
    if (notificationId.startsWith('broadcast-')) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      await ref.read(notificationRepositoryProvider).markAsRead(
            organizationId: AppConfig.defaultOrganizationId,
            userId: user.uid,
            notificationId: notificationId,
          );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> markAllRead() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    state = const AsyncLoading();
    try {
      final items = ref.read(notificationsProvider).value ?? const [];
      final repo = ref.read(notificationRepositoryProvider);
      final orgId = AppConfig.defaultOrganizationId;
      for (final n in items) {
        if (n.read) continue;
        final reminderId = n.reminderId;
        if (n.responseRequired && reminderId != null) {
          final responded =
              ref.read(myReminderResponseProvider(reminderId)).value != null;
          if (!responded) continue;
        }
        await repo.markAsRead(
          organizationId: orgId,
          userId: user.uid,
          notificationId: n.id,
        );
      }
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<bool> delete(String notificationId) async {
    if (notificationId.startsWith('broadcast-')) return false;
    final user = ref.read(currentUserProvider);
    if (user == null) return false;
    try {
      await ref.read(notificationRepositoryProvider).deleteNotification(
            organizationId: AppConfig.defaultOrganizationId,
            userId: user.uid,
            notificationId: notificationId,
          );
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> clearAll() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    state = const AsyncLoading();
    try {
      await ref.read(notificationRepositoryProvider).clearAll(
            organizationId: AppConfig.defaultOrganizationId,
            userId: user.uid,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final notificationActionsProvider =
    NotifierProvider<NotificationActions, AsyncValue<void>>(
  NotificationActions.new,
);
