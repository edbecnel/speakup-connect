import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/announcements/data/repositories/bulletin_repository_impl.dart';
import 'package:speakup_connect/features/announcements/domain/entities/bulletin_entity.dart';
import 'package:speakup_connect/features/announcements/domain/repositories/bulletin_repository.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/features/notifications/presentation/providers/notification_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_config.dart';
import 'package:speakup_connect/features/reminders/presentation/widgets/expiration_picker_section.dart';

String? bulletinIdFromNotificationData(Map<String, dynamic> data) {
  return data['bulletinId'] as String?;
}

final bulletinRepositoryProvider = Provider<BulletinRepository>((ref) {
  return BulletinRepositoryImpl(
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
  );
});

/// Admins, `postBulletinOrgWide`, or any group leader may compose announcements.
final canPostAnnouncementsProvider = Provider<bool>((ref) {
  if (ref.watch(userProfileProvider).value?.isAdmin == true) return true;
  if (ref.watch(hasPermissionProvider(AppPermission.postBulletinOrgWide))) {
    return true;
  }
  return ref.watch(isLeaderOfAnyGroupProvider);
});

/// True when the user may post a school-wide announcement attributed to [groupId].
final canPostAnnouncementForGroupProvider =
    Provider.autoDispose.family<bool, String>((ref, groupId) {
  if (!ref.watch(canPostAnnouncementsProvider)) return false;
  if (ref.watch(userProfileProvider).value?.isAdmin == true) return true;
  if (ref.watch(hasPermissionProvider(AppPermission.postBulletinOrgWide))) {
    return true;
  }
  return ref.watch(canBroadcastToGroupProvider(groupId));
});

/// Leader without org-wide bulletin permission — posts via callable on behalf of a group.
final isGroupLeaderOnlyAnnouncementComposerProvider = Provider<bool>((ref) {
  if (!ref.watch(canPostAnnouncementsProvider)) return false;
  if (ref.watch(userProfileProvider).value?.isAdmin == true) return false;
  if (ref.watch(hasPermissionProvider(AppPermission.postBulletinOrgWide))) {
    return false;
  }
  return ref.watch(isLeaderOfAnyGroupProvider);
});

final publishedBulletinsProvider =
    StreamProvider.autoDispose<List<BulletinEntity>>((ref) {
  return ref
      .watch(bulletinRepositoryProvider)
      .watchPublishedBulletins(AppConfig.defaultOrganizationId);
});

final pendingBulletinsProvider = StreamProvider<List<BulletinEntity>>((ref) {
  ref.keepAlive();
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(const []);

  return ref
      .watch(bulletinRepositoryProvider)
      .watchPendingBulletins(AppConfig.defaultOrganizationId);
});

final pendingAnnouncementCountProvider = Provider<int>((ref) {
  if (!ref.watch(canReviewPendingRemindersProvider)) return 0;
  return ref.watch(pendingBulletinsProvider).maybeWhen(
        data: (items) => items.length,
        orElse: () => 0,
      );
});

final myBulletinsProvider =
    StreamProvider.autoDispose<List<BulletinEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(bulletinRepositoryProvider).watchMyBulletins(
        organizationId: AppConfig.defaultOrganizationId,
        authorId: user.uid,
      );
});

final bulletinByIdProvider = FutureProvider.autoDispose
    .family<BulletinEntity?, String>((ref, bulletinId) {
  return ref.watch(bulletinRepositoryProvider).getBulletin(
        organizationId: AppConfig.defaultOrganizationId,
        bulletinId: bulletinId,
      );
});

class ComposeAnnouncementState {
  const ComposeAnnouncementState({
    this.title = '',
    this.body = '',
    this.sourceGroupId,
    this.sourceGroupLabel,
    this.isPinned = false,
    this.scheduledAt,
    this.expiration = const ExpirationPickerValue(),
    this.responseConfig = const ReminderResponseConfig(),
    this.imagePath,
  });

  final String title;
  final String body;
  final String? sourceGroupId;
  final String? sourceGroupLabel;
  final bool isPinned;
  final DateTime? scheduledAt;
  final ExpirationPickerValue expiration;
  final ReminderResponseConfig responseConfig;
  final String? imagePath;

  bool get isValid {
    if (title.trim().length < 3) return false;
    if (body.trim().length < 5) return false;
    if (expiration.isEnabled &&
        !expiration.isValid(scheduledAt: scheduledAt)) {
      return false;
    }
    if (responseConfig.enabled && !responseConfig.isValid) return false;
    return true;
  }

  /// Human-readable reason the compose form cannot be submitted yet.
  String? validationMessage(AppLocalizations l10n) {
    if (title.trim().length < 3) {
      return l10n.composeAnnouncementValidationTitleMin;
    }
    if (body.trim().length < 5) {
      return l10n.composeAnnouncementValidationMessageMin;
    }
    if (expiration.isEnabled &&
        !expiration.isValid(scheduledAt: scheduledAt)) {
      return l10n.composeAnnouncementValidationExpiration;
    }
    if (responseConfig.enabled && !responseConfig.isValid) {
      return l10n.composeAnnouncementValidationResponse;
    }
    return null;
  }

  DateTime? get resolvedExpiresAt =>
      expiration.resolve(scheduledAt: scheduledAt);

  ComposeAnnouncementState copyWith({
    String? title,
    String? body,
    String? sourceGroupId,
    String? sourceGroupLabel,
    bool? isPinned,
    DateTime? scheduledAt,
    ExpirationPickerValue? expiration,
    ReminderResponseConfig? responseConfig,
    String? imagePath,
    bool clearImage = false,
    bool clearSourceGroup = false,
    bool clearSchedule = false,
  }) {
    return ComposeAnnouncementState(
      title: title ?? this.title,
      body: body ?? this.body,
      sourceGroupId:
          clearSourceGroup ? null : (sourceGroupId ?? this.sourceGroupId),
      sourceGroupLabel: clearSourceGroup
          ? null
          : (sourceGroupLabel ?? this.sourceGroupLabel),
      isPinned: isPinned ?? this.isPinned,
      scheduledAt: clearSchedule ? null : (scheduledAt ?? this.scheduledAt),
      expiration: expiration ?? this.expiration,
      responseConfig: responseConfig ?? this.responseConfig,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
    );
  }
}

class ComposeAnnouncementNotifier extends Notifier<ComposeAnnouncementState> {
  @override
  ComposeAnnouncementState build() => const ComposeAnnouncementState();

  void setTitle(String value) => state = state.copyWith(title: value);
  void setBody(String value) => state = state.copyWith(body: value);
  void setSourceGroup({required String id, required String label}) {
    state = state.copyWith(sourceGroupId: id, sourceGroupLabel: label);
  }

  void setPinned(bool value) => state = state.copyWith(isPinned: value);
  void setSchedule(DateTime? when) => state = when == null
      ? state.copyWith(clearSchedule: true)
      : state.copyWith(scheduledAt: when);
  void setExpiration(ExpirationPickerValue value) =>
      state = state.copyWith(expiration: value);
  void setResponseConfig(ReminderResponseConfig value) =>
      state = state.copyWith(responseConfig: value);
  void setImagePath(String path) => state = state.copyWith(imagePath: path);
  void clearImage() => state = state.copyWith(clearImage: true);

  void reset() => state = const ComposeAnnouncementState();
}

final composeAnnouncementProvider =
    NotifierProvider<ComposeAnnouncementNotifier, ComposeAnnouncementState>(
  ComposeAnnouncementNotifier.new,
);

class SubmitAnnouncementResult {
  const SubmitAnnouncementResult({
    required this.status,
    required this.bulletin,
  });

  final BulletinStatus status;
  final BulletinEntity bulletin;
}

class SubmitAnnouncementNotifier
    extends Notifier<AsyncValue<SubmitAnnouncementResult?>> {
  @override
  AsyncValue<SubmitAnnouncementResult?> build() => const AsyncData(null);

  Future<SubmitAnnouncementResult?> submit({String? imagePath}) async {
    final form = ref.read(composeAnnouncementProvider);
    final resolvedImagePath = imagePath ?? form.imagePath;
    if (!form.isValid) return null;

    final user = ref.read(currentUserProvider);
    if (user == null) return null;

    final leaderOnly =
        ref.read(isGroupLeaderOnlyAnnouncementComposerProvider);
    if (leaderOnly) {
      final groupId = form.sourceGroupId;
      if (groupId == null) {
        state = AsyncError(
          StateError('Select the group this announcement is for.'),
          StackTrace.current,
        );
        return null;
      }
      if (!ref.read(canBroadcastToGroupProvider(groupId))) {
        state = AsyncError(
          StateError('You can only post on behalf of groups you lead.'),
          StackTrace.current,
        );
        return null;
      }
    }

    final orgConfig = ref.read(organizationConfigProvider);
    if (!orgConfig.hasValue) {
      state = AsyncError(
        StateError(
          'Organization settings are still loading. Wait a moment and try again.',
        ),
        StackTrace.current,
      );
      return null;
    }

    final requireApproval = orgConfig.value!.requireReminderApproval;
    final canPublishDirectly =
        ref.read(canReviewPendingRemindersProvider);
    final status = (requireApproval && !canPublishDirectly)
        ? BulletinStatus.pending
        : BulletinStatus.published;

    final authorName =
        ref.read(userProfileProvider).asData?.value?.displayName ??
            user.displayName;

    state = const AsyncLoading();
    try {
      final repo = ref.read(bulletinRepositoryProvider);
      final orgId = AppConfig.defaultOrganizationId;
      BulletinEntity finalBulletin;

      if (leaderOnly) {
        final bulletin = await repo.createGroupLeaderAnnouncement(
          organizationId: orgId,
          title: form.title.trim(),
          body: form.body.trim(),
          groupId: form.sourceGroupId!,
          groupLabel: form.sourceGroupLabel,
          authorId: user.uid,
          scheduledAt: form.scheduledAt,
          expiresAt: form.resolvedExpiresAt,
          responseConfig: form.responseConfig.enabled ? form.responseConfig : null,
        );
        finalBulletin = bulletin;
        if (resolvedImagePath != null) {
          try {
            final imageUrl = await repo.uploadAnnouncementImage(
              organizationId: orgId,
              bulletinId: bulletin.bulletinId,
              localPath: resolvedImagePath,
            );
            finalBulletin = await repo.setAnnouncementImageUrl(
              organizationId: orgId,
              bulletinId: bulletin.bulletinId,
              imageUrl: imageUrl,
            );
          } catch (e) {
            throw StateError(
              'Announcement was posted but the image could not be attached: $e',
            );
          }
        }
      } else {
        final bulletinId = const Uuid().v4();
        String? imageUrl;
        if (resolvedImagePath != null) {
          imageUrl = await repo.uploadAnnouncementImage(
            organizationId: orgId,
            bulletinId: bulletinId,
            localPath: resolvedImagePath,
          );
        }
        finalBulletin = await repo.createBulletin(
          organizationId: orgId,
          bulletinId: bulletinId,
          title: form.title.trim(),
          body: form.body.trim(),
          status: status,
          authorId: user.uid,
          authorName: authorName,
          sourceGroupId: form.sourceGroupId,
          sourceGroupName: form.sourceGroupLabel,
          isPinned: form.isPinned,
          scheduledAt: form.scheduledAt,
          expiresAt: form.resolvedExpiresAt,
          responseConfig: form.responseConfig.enabled ? form.responseConfig : null,
          imageUrl: imageUrl,
        );
      }

      final result = SubmitAnnouncementResult(
        status: finalBulletin.status,
        bulletin: finalBulletin,
      );
      state = AsyncData(result);
      ref.read(composeAnnouncementProvider.notifier).reset();
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final submitAnnouncementProvider = NotifierProvider<SubmitAnnouncementNotifier,
    AsyncValue<SubmitAnnouncementResult?>>(
  SubmitAnnouncementNotifier.new,
);

class BulletinReviewNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  String? get _reviewerName =>
      ref.read(userProfileProvider).asData?.value?.displayName ??
      ref.read(currentUserProvider)?.displayName;

  Future<void> approve(String bulletinId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    state = const AsyncLoading();
    try {
      await ref.read(bulletinRepositoryProvider).approveBulletin(
            organizationId: AppConfig.defaultOrganizationId,
            bulletinId: bulletinId,
            reviewerId: user.uid,
            reviewerName: _reviewerName,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> reject(String bulletinId, String reason) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    state = const AsyncLoading();
    try {
      await ref.read(bulletinRepositoryProvider).rejectBulletin(
            organizationId: AppConfig.defaultOrganizationId,
            bulletinId: bulletinId,
            reviewerId: user.uid,
            reviewerName: _reviewerName,
            reason: reason,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final bulletinReviewProvider =
    NotifierProvider<BulletinReviewNotifier, AsyncValue<void>>(
  BulletinReviewNotifier.new,
);

/// Unread school-wide announcement notifications (drives the Home tile badge).
final unreadAnnouncementCountProvider = Provider.autoDispose<int>((ref) {
  final items = ref.watch(notificationsProvider).asData?.value ?? const [];
  var count = 0;
  for (final n in items) {
    if (n.type != 'bulletin') continue;
    if (ref.watch(notificationAttentionProvider(n)).needsAttention) count++;
  }
  return count;
});

class AnnouncementReadNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> markAllBulletinNotificationsRead() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final items = ref.read(notificationsProvider).value ?? const [];
    final repo = ref.read(notificationRepositoryProvider);
    final orgId = AppConfig.defaultOrganizationId;

    for (final n in items) {
      if (n.type != 'bulletin' || n.read) continue;
      if (ref.read(notificationAttentionProvider(n)).responsePending) continue;
      await repo.markAsRead(
        organizationId: orgId,
        userId: user.uid,
        notificationId: n.id,
      );
    }
  }

  Future<void> markBulletinNotificationRead(String bulletinId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final items = ref.read(notificationsProvider).value ?? const [];
    final repo = ref.read(notificationRepositoryProvider);
    final orgId = AppConfig.defaultOrganizationId;

    for (final n in items) {
      if (n.type != 'bulletin' || n.read) continue;
      if (n.bulletinId != bulletinId) continue;
      if (ref.read(notificationAttentionProvider(n)).responsePending) continue;
      await repo.markAsRead(
        organizationId: orgId,
        userId: user.uid,
        notificationId: n.id,
      );
    }
  }
}

final announcementReadProvider =
    NotifierProvider<AnnouncementReadNotifier, AsyncValue<void>>(
  AnnouncementReadNotifier.new,
);

/// True when the current user may edit or delete an announcement (author or admin).
final canManageAnnouncementProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, bulletinId) async {
  final bulletin = await ref.watch(bulletinByIdProvider(bulletinId).future);
  if (bulletin == null) return false;
  final user = ref.watch(currentUserProvider);
  final profile = ref.watch(userProfileProvider).value;
  if (user == null) return false;
  return bulletin.authorId == user.uid || (profile?.isAdmin ?? false);
});

class UpdateAnnouncementNotifier extends Notifier<AsyncValue<int?>> {
  @override
  AsyncValue<int?> build() => const AsyncData(null);

  Future<bool> update({
    required String bulletinId,
    required String title,
    required String body,
    DateTime? expiresAt,
    bool clearExpiration = false,
    ReminderResponseConfig? responseConfig,
    bool clearResponseConfig = false,
    String? newImageLocalPath,
    bool clearImage = false,
    String? imageUrl,
    bool clearImageUrl = false,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(bulletinRepositoryProvider);
      final orgId = AppConfig.defaultOrganizationId;

      String? resolvedImageUrl = imageUrl;
      if (newImageLocalPath != null) {
        resolvedImageUrl = await repo.uploadAnnouncementImage(
          organizationId: orgId,
          bulletinId: bulletinId,
          localPath: newImageLocalPath,
        );
      }

      final updated = await repo.updateBulletin(
        organizationId: orgId,
        bulletinId: bulletinId,
        title: title,
        body: body,
        expiresAt: expiresAt,
        clearExpiration: clearExpiration,
        imageUrl: resolvedImageUrl,
        clearImageUrl: clearImage || clearImageUrl,
        responseConfig:
            responseConfig?.enabled == true ? responseConfig : null,
        clearResponseConfig: clearResponseConfig,
      );

      state = AsyncData(updated);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final updateAnnouncementProvider =
    NotifierProvider<UpdateAnnouncementNotifier, AsyncValue<int?>>(
  UpdateAnnouncementNotifier.new,
);

class DeleteAnnouncementNotifier extends Notifier<AsyncValue<int?>> {
  @override
  AsyncValue<int?> build() => const AsyncData(null);

  Future<bool> delete(String bulletinId) async {
    state = const AsyncLoading();
    try {
      final removed =
          await ref.read(bulletinRepositoryProvider).deleteBulletin(
                organizationId: AppConfig.defaultOrganizationId,
                bulletinId: bulletinId,
              );
      state = AsyncData(removed);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final deleteAnnouncementProvider =
    NotifierProvider<DeleteAnnouncementNotifier, AsyncValue<int?>>(
  DeleteAnnouncementNotifier.new,
);

class UpdateAnnouncementImageNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> upload({
    required String bulletinId,
    required String localPath,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(bulletinRepositoryProvider);
      final orgId = AppConfig.defaultOrganizationId;
      final imageUrl = await repo.uploadAnnouncementImage(
        organizationId: orgId,
        bulletinId: bulletinId,
        localPath: localPath,
      );
      await repo.setAnnouncementImageUrl(
        organizationId: orgId,
        bulletinId: bulletinId,
        imageUrl: imageUrl,
      );
      ref.invalidate(bulletinByIdProvider(bulletinId));
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> remove(String bulletinId) async {
    state = const AsyncLoading();
    try {
      await ref.read(bulletinRepositoryProvider).setAnnouncementImageUrl(
            organizationId: AppConfig.defaultOrganizationId,
            bulletinId: bulletinId,
            imageUrl: null,
          );
      ref.invalidate(bulletinByIdProvider(bulletinId));
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final updateAnnouncementImageProvider =
    NotifierProvider<UpdateAnnouncementImageNotifier, AsyncValue<void>>(
  UpdateAnnouncementImageNotifier.new,
);
