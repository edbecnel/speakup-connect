import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/announcements/presentation/providers/announcement_provider.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/features/reminders/data/repositories/reminder_repository_impl.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_entity.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_config.dart';
import 'package:speakup_connect/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:speakup_connect/features/reminders/presentation/widgets/expiration_picker_section.dart';

/// Extracts the source reminder ID from a feed notification, if any.
String? reminderIdFromNotificationData(Map<String, dynamic> data) {
  return data['reminderId'] as String?;
}

// ── Infrastructure ───────────────────────────────────────────────────────────

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepositoryImpl(FirebaseFirestore.instance);
});

// ── Streams ──────────────────────────────────────────────────────────────────

/// Reminders awaiting approval — drives the Admin Approval Queue.
///
/// Kept alive so badge counts and the queue screen share one Firestore
/// listener. Access to the queue UI is gated separately via
/// [canReviewPendingRemindersProvider] (do not gate the stream itself —
/// returning an empty stream on permission flicker was clearing real data).
final pendingRemindersProvider = StreamProvider<List<ReminderEntity>>((ref) {
  ref.keepAlive();

  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(const []);

  return ref
      .watch(reminderRepositoryProvider)
      .watchPendingReminders(AppConfig.defaultOrganizationId);
});

/// Count of reminders and announcements awaiting approval — for admin badges.
final pendingReminderCountProvider = Provider<int>((ref) {
  if (!ref.watch(canReviewPendingRemindersProvider)) return 0;

  final reminders = ref.watch(pendingRemindersProvider).maybeWhen(
        data: (items) => items.length,
        orElse: () => 0,
      );
  final announcements = ref.watch(pendingBulletinsProvider).maybeWhen(
        data: (items) => items.length,
        orElse: () => 0,
      );
  return reminders + announcements;
});

/// Reminders authored by the current user — drives the compose-history list
/// and the "My Broadcasts" management screen.
final myRemindersProvider =
    StreamProvider.autoDispose<List<ReminderEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(reminderRepositoryProvider).watchMyReminders(
        organizationId: AppConfig.defaultOrganizationId,
        userId: user.uid,
      );
});

// ── Audience options ─────────────────────────────────────────────────────────

/// A selectable target for a reminder's audience (a group or a role).
class AudienceOption {
  const AudienceOption({required this.id, required this.label});

  final String id;
  final String label;
}

/// Streams groups available in the compose audience picker.
///
/// Org-wide broadcasters see every group; group leaders only see groups they
/// lead.
final audienceGroupsProvider =
    StreamProvider.autoDispose<List<AudienceOption>>((ref) {
  final orgWide = ref.watch(canBroadcastOrgWideProvider);
  final ledIds = ref
      .watch(ledGroupMembershipsProvider)
      .map((m) => m.group.groupId)
      .toSet();

  return ref
      .watch(getGroupsUseCaseProvider)
      .call(AppConfig.defaultOrganizationId)
      .map(
        (groups) => groups
            .where((g) => orgWide || ledIds.contains(g.groupId))
            .map((g) => AudienceOption(id: g.groupId, label: g.name))
            .toList(),
      );
});

// ── Compose Form ─────────────────────────────────────────────────────────────

class ComposeReminderState {
  const ComposeReminderState({
    this.title = '',
    this.body = '',
    this.audienceType = ReminderAudienceType.all,
    this.targetId,
    this.targetLabel,
    this.scheduledAt,
    this.expiration = const ExpirationPickerValue(),
    this.responseConfig = const ReminderResponseConfig(),
  });

  final String title;
  final String body;
  final ReminderAudienceType audienceType;
  final String? targetId;
  final String? targetLabel;

  /// Null = send now; a future value schedules the reminder.
  final DateTime? scheduledAt;

  final ExpirationPickerValue expiration;
  final ReminderResponseConfig responseConfig;

  DateTime? get resolvedExpiresAt =>
      expiration.resolve(scheduledAt: scheduledAt);

  bool get isValid => validationMessage == null;

  /// Human-readable reason the compose form cannot be submitted yet.
  String? get validationMessage {
    if (title.trim().length < 3) {
      return 'Title must be at least 3 characters.';
    }
    if (body.trim().length < 5) {
      return 'Message must be at least 5 characters.';
    }
    if (audienceType != ReminderAudienceType.all && targetId == null) {
      return audienceType == ReminderAudienceType.group
          ? 'Select a group for this alert.'
          : 'Select an audience for this reminder.';
    }
    if (expiration.isEnabled && !expiration.isValid(scheduledAt: scheduledAt)) {
      return 'Set a valid expiration date and time.';
    }
    if (responseConfig.enabled && !responseConfig.isValid) {
      return responseConfig.type == ReminderResponseType.checkbox
          ? 'Add at least one checkbox option with a label.'
          : responseConfig.type == ReminderResponseType.multipleChoice
              ? 'Add at least 2 answer choices with labels.'
              : 'Set a valid character limit for responses.';
    }
    return null;
  }

  ReminderResponseConfig? get resolvedResponseConfig =>
      responseConfig.enabled && responseConfig.isValid
          ? responseConfig.copyWith(options: responseConfig.validOptions)
          : null;

  ReminderAudience get audience => ReminderAudience(
        type: audienceType,
        targetId: audienceType == ReminderAudienceType.all ? null : targetId,
        targetLabel:
            audienceType == ReminderAudienceType.all ? null : targetLabel,
      );

  ComposeReminderState copyWith({
    String? title,
    String? body,
    ReminderAudienceType? audienceType,
    String? targetId,
    String? targetLabel,
    DateTime? scheduledAt,
    ExpirationPickerValue? expiration,
    ReminderResponseConfig? responseConfig,
    bool clearTarget = false,
    bool clearSchedule = false,
  }) {
    return ComposeReminderState(
      title: title ?? this.title,
      body: body ?? this.body,
      audienceType: audienceType ?? this.audienceType,
      targetId: clearTarget ? null : (targetId ?? this.targetId),
      targetLabel: clearTarget ? null : (targetLabel ?? this.targetLabel),
      scheduledAt: clearSchedule ? null : (scheduledAt ?? this.scheduledAt),
      expiration: expiration ?? this.expiration,
      responseConfig: responseConfig ?? this.responseConfig,
    );
  }
}

class ComposeReminderNotifier extends Notifier<ComposeReminderState> {
  @override
  ComposeReminderState build() => const ComposeReminderState();

  void setTitle(String v) => state = state.copyWith(title: v);
  void setBody(String v) => state = state.copyWith(body: v);

  void setAudienceType(ReminderAudienceType type) {
    // Switching audience type clears any previously selected target.
    state = state.copyWith(audienceType: type, clearTarget: true);
  }

  void setTarget(String id, String label) =>
      state = state.copyWith(targetId: id, targetLabel: label);

  void setSchedule(DateTime? when) => when == null
      ? state = state.copyWith(clearSchedule: true)
      : state = state.copyWith(scheduledAt: when);

  void setExpiration(ExpirationPickerValue value) =>
      state = state.copyWith(expiration: value);

  void setResponseConfig(ReminderResponseConfig value) =>
      state = state.copyWith(responseConfig: value);

  void reset() => state = const ComposeReminderState();

  /// Pre-fills a group audience (used when leaders tap Send Alert from My Groups).
  void presetGroupAudience({required String groupId, required String groupName}) {
    state = state.copyWith(
      audienceType: ReminderAudienceType.group,
      targetId: groupId,
      targetLabel: groupName,
    );
  }
}

final composeReminderProvider =
    NotifierProvider<ComposeReminderNotifier, ComposeReminderState>(
  ComposeReminderNotifier.new,
);

// ── Submit ───────────────────────────────────────────────────────────────────

/// Result of a submit so the UI can tailor its confirmation message.
class SubmitReminderResult {
  const SubmitReminderResult({required this.status, required this.reminder});

  final ReminderStatus status;
  final ReminderEntity reminder;
}

class SubmitReminderNotifier extends Notifier<AsyncValue<SubmitReminderResult?>> {
  @override
  AsyncValue<SubmitReminderResult?> build() => const AsyncData(null);

  /// Submits the current compose-form state.
  ///
  /// Decides the resulting [ReminderStatus]:
  ///   - If the org requires approval AND the author lacks `approveReminders`
  ///     → `pending` (queued for review).
  ///   - Otherwise → `published` (delivered now, or at the scheduled time).
  Future<SubmitReminderResult?> submit() async {
    final form = ref.read(composeReminderProvider);
    if (!form.isValid) return null;

    final user = ref.read(currentUserProvider);
    if (user == null) return null;

    if (ref.read(isGroupLeaderOnlyComposerProvider)) {
      final groupId = form.audience.targetId;
      if (form.audience.type != ReminderAudienceType.group || groupId == null) {
        state = AsyncError(
          StateError('Select a group for this alert.'),
          StackTrace.current,
        );
        return null;
      }
      if (!ref.read(canBroadcastToGroupProvider(groupId))) {
        state = AsyncError(
          StateError('You can only send alerts to groups you lead.'),
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
    final leaderOnly = ref.read(isGroupLeaderOnlyComposerProvider);

    final status = (requireApproval && !canPublishDirectly)
        ? ReminderStatus.pending
        : ReminderStatus.published;

    final authorName =
        ref.read(userProfileProvider).asData?.value?.displayName ??
            user.displayName;

    state = const AsyncLoading();
    try {
      final repo = ref.read(reminderRepositoryProvider);
      final ReminderEntity reminder;

      if (leaderOnly) {
        final groupId = form.audience.targetId!;
        reminder = await repo.createGroupLeaderReminder(
          organizationId: AppConfig.defaultOrganizationId,
          title: form.title.trim(),
          body: form.body.trim(),
          groupId: groupId,
          groupLabel: form.audience.targetLabel,
          createdBy: user.uid,
          scheduledAt: form.scheduledAt,
          expiresAt: form.resolvedExpiresAt,
          responseConfig: form.resolvedResponseConfig,
        );
      } else {
        reminder = await repo.createReminder(
          organizationId: AppConfig.defaultOrganizationId,
          title: form.title.trim(),
          body: form.body.trim(),
          audience: form.audience,
          status: status,
          createdBy: user.uid,
          createdByName: authorName,
          scheduledAt: form.scheduledAt,
          expiresAt: form.resolvedExpiresAt,
          responseConfig: form.resolvedResponseConfig,
        );
      }

      final resultStatus = reminder.status;
      final result = SubmitReminderResult(status: resultStatus, reminder: reminder);
      state = AsyncData(result);
      ref.read(composeReminderProvider.notifier).reset();
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final submitReminderProvider =
    NotifierProvider<SubmitReminderNotifier, AsyncValue<SubmitReminderResult?>>(
  SubmitReminderNotifier.new,
);

// ── Approval actions ─────────────────────────────────────────────────────────

class ReminderReviewNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  String? get _reviewerName =>
      ref.read(userProfileProvider).asData?.value?.displayName ??
      ref.read(currentUserProvider)?.displayName;

  Future<void> approve(String reminderId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    state = const AsyncLoading();
    try {
      await ref.read(reminderRepositoryProvider).approveReminder(
            organizationId: AppConfig.defaultOrganizationId,
            reminderId: reminderId,
            reviewerId: user.uid,
            reviewerName: _reviewerName,
          );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> reject(String reminderId, String reason) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    state = const AsyncLoading();
    try {
      await ref.read(reminderRepositoryProvider).rejectReminder(
            organizationId: AppConfig.defaultOrganizationId,
            reminderId: reminderId,
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

final reminderReviewProvider =
    NotifierProvider<ReminderReviewNotifier, AsyncValue<void>>(
  ReminderReviewNotifier.new,
);

// ── Recall / delete ──────────────────────────────────────────────────────────

/// Recalls (deletes) a reminder and removes any delivered feed copies.
/// Result holds the number of feed entries removed on success.
class RecallReminderNotifier extends Notifier<AsyncValue<int?>> {
  @override
  AsyncValue<int?> build() => const AsyncData(null);

  Future<bool> recall(String reminderId) async {
    state = const AsyncLoading();
    try {
      final removed = await ref.read(reminderRepositoryProvider).recallReminder(
            organizationId: AppConfig.defaultOrganizationId,
            reminderId: reminderId,
          );
      state = AsyncData(removed);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final recallReminderProvider =
    NotifierProvider<RecallReminderNotifier, AsyncValue<int?>>(
  RecallReminderNotifier.new,
);

// ── Lookup & permissions ─────────────────────────────────────────────────────

final reminderByIdProvider =
    FutureProvider.autoDispose.family<ReminderEntity?, String>((ref, id) {
  return ref.read(reminderRepositoryProvider).getReminder(
        organizationId: AppConfig.defaultOrganizationId,
        reminderId: id,
      );
});

/// True when the current user may edit or globally delete a broadcast
/// (author or org admin).
final canManageBroadcastProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, reminderId) async {
  final reminder = await ref.watch(reminderByIdProvider(reminderId).future);
  if (reminder == null) return false;
  final user = ref.watch(currentUserProvider);
  final profile = ref.watch(userProfileProvider).value;
  if (user == null) return false;
  return reminder.createdBy == user.uid || (profile?.isAdmin ?? false);
});

// ── Update ───────────────────────────────────────────────────────────────────

class UpdateReminderNotifier extends Notifier<AsyncValue<int?>> {
  @override
  AsyncValue<int?> build() => const AsyncData(null);

  Future<bool> update({
    required String reminderId,
    required String title,
    required String body,
    DateTime? expiresAt,
    bool clearExpiration = false,
  }) async {
    state = const AsyncLoading();
    try {
      final updated = await ref.read(reminderRepositoryProvider).updateReminder(
            organizationId: AppConfig.defaultOrganizationId,
            reminderId: reminderId,
            title: title,
            body: body,
            expiresAt: expiresAt,
            clearExpiration: clearExpiration,
          );
      state = AsyncData(updated);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final updateReminderProvider =
    NotifierProvider<UpdateReminderNotifier, AsyncValue<int?>>(
  UpdateReminderNotifier.new,
);
