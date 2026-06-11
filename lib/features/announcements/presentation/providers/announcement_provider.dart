import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/announcements/data/repositories/bulletin_repository_impl.dart';
import 'package:speakup_connect/features/announcements/domain/entities/bulletin_entity.dart';
import 'package:speakup_connect/features/announcements/domain/repositories/bulletin_repository.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/features/reminders/presentation/widgets/expiration_picker_section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

String? bulletinIdFromNotificationData(Map<String, dynamic> data) {
  return data['bulletinId'] as String?;
}

final bulletinRepositoryProvider = Provider<BulletinRepository>((ref) {
  return BulletinRepositoryImpl(FirebaseFirestore.instance);
});

/// Admins, `postBulletinOrgWide`, or any group leader may compose announcements.
final canPostAnnouncementsProvider = Provider<bool>((ref) {
  if (ref.watch(userProfileProvider).value?.isAdmin == true) return true;
  if (ref.watch(hasPermissionProvider(AppPermission.postBulletinOrgWide))) {
    return true;
  }
  return ref.watch(isLeaderOfAnyGroupProvider);
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
    this.expiration = const ExpirationPickerValue(),
  });

  final String title;
  final String body;
  final String? sourceGroupId;
  final String? sourceGroupLabel;
  final bool isPinned;
  final ExpirationPickerValue expiration;

  bool get isValid =>
      title.trim().length >= 3 && body.trim().length >= 5;

  DateTime? get resolvedExpiresAt => expiration.resolve();

  ComposeAnnouncementState copyWith({
    String? title,
    String? body,
    String? sourceGroupId,
    String? sourceGroupLabel,
    bool? isPinned,
    ExpirationPickerValue? expiration,
    bool clearSourceGroup = false,
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
      expiration: expiration ?? this.expiration,
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
  void setExpiration(ExpirationPickerValue value) =>
      state = state.copyWith(expiration: value);

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

  Future<SubmitAnnouncementResult?> submit() async {
    final form = ref.read(composeAnnouncementProvider);
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
      final BulletinEntity bulletin;

      if (leaderOnly) {
        bulletin = await repo.createGroupLeaderAnnouncement(
          organizationId: AppConfig.defaultOrganizationId,
          title: form.title.trim(),
          body: form.body.trim(),
          groupId: form.sourceGroupId!,
          groupLabel: form.sourceGroupLabel,
          authorId: user.uid,
          expiresAt: form.resolvedExpiresAt,
        );
      } else {
        bulletin = await repo.createBulletin(
          organizationId: AppConfig.defaultOrganizationId,
          title: form.title.trim(),
          body: form.body.trim(),
          status: status,
          authorId: user.uid,
          authorName: authorName,
          sourceGroupId: form.sourceGroupId,
          sourceGroupName: form.sourceGroupLabel,
          isPinned: form.isPinned,
          expiresAt: form.resolvedExpiresAt,
        );
      }

      final result = SubmitAnnouncementResult(
        status: bulletin.status,
        bulletin: bulletin,
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
