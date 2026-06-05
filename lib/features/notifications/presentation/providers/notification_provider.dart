import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:speakup_connect/features/notifications/domain/entities/app_notification_entity.dart';
import 'package:speakup_connect/features/notifications/domain/repositories/notification_repository.dart';

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

/// Count of unread notifications (drives the app-bar badge).
final unreadNotificationCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(notificationsProvider).asData?.value.where((n) => !n.read).length ??
      0;
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
      await ref.read(notificationRepositoryProvider).markAllAsRead(
            organizationId: AppConfig.defaultOrganizationId,
            userId: user.uid,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> delete(String notificationId) async {
    if (notificationId.startsWith('broadcast-')) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      await ref.read(notificationRepositoryProvider).deleteNotification(
            organizationId: AppConfig.defaultOrganizationId,
            userId: user.uid,
            notificationId: notificationId,
          );
    } catch (e, st) {
      state = AsyncError(e, st);
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
