import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/features/reminders/data/repositories/reminder_repository_impl.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_entity.dart';
import 'package:speakup_connect/features/reminders/domain/repositories/reminder_repository.dart';

// ── Infrastructure ───────────────────────────────────────────────────────────

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepositoryImpl(FirebaseFirestore.instance);
});

// ── Streams ──────────────────────────────────────────────────────────────────

/// Reminders awaiting approval — drives the Admin Approval Queue.
final pendingRemindersProvider =
    StreamProvider.autoDispose<List<ReminderEntity>>((ref) {
  return ref
      .watch(reminderRepositoryProvider)
      .watchPendingReminders(AppConfig.defaultOrganizationId);
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

/// Streams the org's groups for the audience picker (id + display label).
final audienceGroupsProvider =
    StreamProvider.autoDispose<List<AudienceOption>>((ref) {
  return FirebaseFirestore.instance
      .collection(AppConstants.organizationsCollection)
      .doc(AppConfig.defaultOrganizationId)
      .collection(AppConstants.groupsCollection)
      .snapshots()
      .map((snap) => snap.docs.map((d) {
            final data = d.data();
            final label = (data['name'] as String?) ??
                (data['displayName'] as String?) ??
                d.id;
            return AudienceOption(id: d.id, label: label);
          }).toList());
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
  });

  final String title;
  final String body;
  final ReminderAudienceType audienceType;
  final String? targetId;
  final String? targetLabel;

  /// Null = send now; a future value schedules the reminder.
  final DateTime? scheduledAt;

  bool get isValid {
    if (title.trim().length < 3) return false;
    if (body.trim().length < 5) return false;
    if (audienceType != ReminderAudienceType.all && targetId == null) {
      return false;
    }
    return true;
  }

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

  void reset() => state = const ComposeReminderState();
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

    final requireApproval = ref
            .read(organizationConfigProvider)
            .asData
            ?.value
            .requireReminderApproval ??
        false;
    final canApprove =
        ref.read(hasPermissionProvider(AppPermission.approveReminders));

    final status = (requireApproval && !canApprove)
        ? ReminderStatus.pending
        : ReminderStatus.published;

    final authorName =
        ref.read(userProfileProvider).asData?.value?.displayName ??
            user.displayName;

    state = const AsyncLoading();
    try {
      final reminder =
          await ref.read(reminderRepositoryProvider).createReminder(
                organizationId: AppConfig.defaultOrganizationId,
                title: form.title.trim(),
                body: form.body.trim(),
                audience: form.audience,
                status: status,
                createdBy: user.uid,
                createdByName: authorName,
                scheduledAt: form.scheduledAt,
              );

      final result = SubmitReminderResult(status: status, reminder: reminder);
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
