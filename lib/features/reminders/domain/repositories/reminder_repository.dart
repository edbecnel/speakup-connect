import 'package:speakup_connect/features/reminders/domain/entities/reminder_entity.dart';

/// Abstract repository for reminder CRUD and the approval workflow.
///
/// The presentation layer decides *which* [ReminderStatus] a new reminder
/// gets (publish directly vs. submit for approval) based on the author's
/// permissions and the org's `requireReminderApproval` flag. The repository
/// simply persists the decision and exposes the workflow transitions.
abstract class ReminderRepository {
  /// Creates a new reminder document with the caller-supplied [status].
  ///
  /// Delivery (push + in-app feed) is performed server-side by the
  /// `onReminderPublished` Cloud Function once the reminder becomes
  /// `published` and is due, so this method never writes to the feed directly.
  Future<ReminderEntity> createReminder({
    required String organizationId,
    required String title,
    required String body,
    required ReminderAudience audience,
    required ReminderStatus status,
    required String createdBy,
    String? createdByName,
    DateTime? scheduledAt,
  });

  /// Streams reminders awaiting approval, newest first.
  Stream<List<ReminderEntity>> watchPendingReminders(String organizationId);

  /// Streams reminders authored by [userId], newest first.
  Stream<List<ReminderEntity>> watchMyReminders({
    required String organizationId,
    required String userId,
  });

  /// Approves a pending reminder, transitioning it to `published`.
  ///
  /// If the reminder has a future `scheduledAt`, it stays queued for the
  /// scheduled publisher; otherwise the publish trigger delivers it at once.
  Future<void> approveReminder({
    required String organizationId,
    required String reminderId,
    required String reviewerId,
    String? reviewerName,
  });

  /// Rejects a pending reminder with a [reason].
  Future<void> rejectReminder({
    required String organizationId,
    required String reminderId,
    required String reviewerId,
    String? reviewerName,
    required String reason,
  });

  /// Recalls a reminder: deletes the reminder document and removes any copies
  /// already delivered to recipients' feeds (server-side via Cloud Function).
  ///
  /// Returns the number of delivered feed entries that were removed.
  Future<int> recallReminder({
    required String organizationId,
    required String reminderId,
  });
}
