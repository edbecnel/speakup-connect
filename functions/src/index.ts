import { onDocumentWritten, onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { logger } from 'firebase-functions';
import * as admin from 'firebase-admin';
import {
  assertStudentPasswordLength,
  normalizeContactEmail,
  studentAuthEmail,
} from './student_auth';

admin.initializeApp();

const db = admin.firestore();

// ── Helpers ───────────────────────────────────────────────────────────────────

/**
 * Fetch Firestore documents by IDs using Admin SDK getAll().
 * Chunks requests to stay within the 10-document-per-call limit.
 */
async function fetchByIds(
  collectionRef: admin.firestore.CollectionReference,
  ids: string[],
): Promise<Array<admin.firestore.DocumentData & { id: string }>> {
  if (ids.length === 0) return [];
  const results: Array<admin.firestore.DocumentData & { id: string }> = [];
  for (let i = 0; i < ids.length; i += 10) {
    const refs = ids.slice(i, i + 10).map((id) => collectionRef.doc(id));
    const snaps = await db.getAll(...refs);
    for (const snap of snaps) {
      if (snap.exists) results.push({ id: snap.id, ...snap.data() });
    }
  }
  return results;
}

// ── Core resolution logic ─────────────────────────────────────────────────────

/**
 * Resolves the flat set of permission keys and tag scopes for a user
 * by reading their role assignments, roles, and custom capabilities from
 * Firestore.
 *
 * This mirrors the logic in PermissionsRepositoryImpl.resolvePermissions()
 * (Dart) so both the app and Security Rules always see the same permissions.
 */
async function resolveUserPermissions(
  orgId: string,
  userId: string,
): Promise<{ permissions: string[]; tagScopes: string[] }> {
  const assignmentsSnap = await db
    .collection('organizations').doc(orgId)
    .collection('users').doc(userId)
    .collection('roleAssignments')
    .get();

  if (assignmentsSnap.empty) {
    return { permissions: [], tagScopes: [] };
  }

  // 1. Load all referenced roles (deduplicated).
  const roleIds = [
    ...new Set(
      assignmentsSnap.docs
        .map((d) => d.data()['roleId'] as string | undefined)
        .filter((id): id is string => Boolean(id)),
    ),
  ];

  const rolesRef = db
    .collection('organizations').doc(orgId)
    .collection('roles');
  const roles = await fetchByIds(rolesRef, roleIds);

  // 2. Load all custom capabilities (deduplicated).
  const customCapIds = [
    ...new Set(
      roles.flatMap((r) => (r['customCapabilities'] as string[] | undefined) ?? []),
    ),
  ];

  const capsRef = db
    .collection('organizations').doc(orgId)
    .collection('customCapabilities');
  const customCaps = await fetchByIds(capsRef, customCapIds);
  const capIndex = new Map(customCaps.map((c) => [c['id'] as string, c]));

  // 3. Resolve to a flat set of permission keys + tag scopes.
  const permissions = new Set<string>();
  const tagScopes = new Set<string>();

  for (const assignmentDoc of assignmentsSnap.docs) {
    const data = assignmentDoc.data();
    const role = roles.find((r) => r['id'] === data['roleId']);
    if (!role) continue; // role may have been deleted

    for (const capKey of (role['capabilities'] as string[] | undefined) ?? []) {
      if (capKey) permissions.add(capKey);
    }

    for (const capId of (role['customCapabilities'] as string[] | undefined) ?? []) {
      const cap = capIndex.get(capId);
      if (!cap) continue;
      const resolved = cap['resolvedAction'] as string | undefined;
      if (resolved) permissions.add(resolved);
      const tagScope = cap['tagScope'] as string | undefined;
      if (tagScope) tagScopes.add(tagScope);
    }
  }

  return { permissions: Array.from(permissions), tagScopes: Array.from(tagScopes) };
}

// ── Trigger: syncCustomClaims ─────────────────────────────────────────────────

/**
 * Triggered on any write to a user's roleAssignments subcollection.
 *
 * Resolves the user's full permission set and writes it to their Firebase
 * Auth custom claims so Firestore Security Rules can reference
 * `request.auth.token.permissions` without an extra Firestore get() call.
 *
 * Custom claims written:
 *   permissions  — string[]  — all AppPermission keys the user currently holds
 *   tagScopes    — string[]  — union of all tag restrictions across all grants
 *   orgId        — string    — the organization this user belongs to
 *
 * Any pre-existing claims (e.g. 'role', 'organizationId') are preserved via
 * spread so backward-compatible rules that check `request.auth.token.role`
 * continue to work without modification.
 *
 * Token expiry note: new claims take effect immediately for Security Rules
 * on all requests that call getIdToken(true) (force-refresh). Without a
 * force-refresh the client token can be stale for up to 1 hour. The Flutter
 * permissionProvider calls getIdToken(true) automatically on each assignment
 * change, so UI gates and Security Rules stay in sync.
 */
export const syncCustomClaims = onDocumentWritten(
  'organizations/{orgId}/users/{userId}/roleAssignments/{assignmentId}',
  async (event) => {
    const { orgId, userId } = event.params;
    logger.info('syncCustomClaims triggered', { orgId, userId });

    const { permissions, tagScopes } = await resolveUserPermissions(orgId, userId);

    // Mirror profile role + org onto JWT so legacy Security Rule helpers
    // (isOrgModerator, isOrgMember) work without an extra Firestore get().
    const profileSnap = await db
      .collection('organizations').doc(orgId)
      .collection('users').doc(userId)
      .get();
    const profile = profileSnap.data() ?? {};
    const profileRole = (profile['role'] as string | undefined) ?? 'user';
    const profileOrgId =
      (profile['organizationId'] as string | undefined) ?? orgId;

    // Preserve any existing claims this function does not own.
    let existingClaims: Record<string, unknown> = {};
    try {
      const userRecord = await admin.auth().getUser(userId);
      existingClaims = (userRecord.customClaims as Record<string, unknown>) ?? {};
    } catch (err) {
      logger.warn('User not found in Firebase Auth — skipping claims update', {
        userId,
        err,
      });
      return;
    }

    await admin.auth().setCustomUserClaims(userId, {
      ...existingClaims,
      permissions,
      tagScopes,
      orgId,
      organizationId: profileOrgId,
      role: profileRole,
    });

    logger.info('Custom claims synced', {
      userId,
      permissionCount: permissions.length,
      tagScopeCount: tagScopes.length,
    });
  },
);

// ── Callable: refreshMyPermissions ───────────────────────────────────────────

/**
 * Callable function that forces a re-sync of the calling user's custom claims.
 *
 * The roleAssignment trigger only fires when an *assignment* changes. If an
 * admin updates the capabilities on a *role definition* the trigger does NOT
 * fire, and affected users' claims would be stale for up to 1 hour. Admins
 * can invoke this from the admin panel to immediately propagate a role change
 * to all affected users (call once per user, or schedule a batch refresh).
 *
 * After the function resolves, the Flutter app must force-refresh its token:
 *   await FirebaseAuth.instance.currentUser?.getIdToken(true);
 *
 * Returns: { ok: true, permissionCount: number }
 */
export const refreshMyPermissions = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      'unauthenticated',
      'Must be signed in to refresh permissions.',
    );
  }

  const userId = request.auth.uid;
  const token = request.auth.token as Record<string, unknown>;
  const bodyOrgId = (request.data as { orgId?: string } | undefined)?.orgId;
  let orgId = (token['orgId'] as string | undefined)
    ?? (token['organizationId'] as string | undefined)
    ?? bodyOrgId?.trim();

  const profileSnap = orgId
    ? await db
        .collection('organizations').doc(orgId)
        .collection('users').doc(userId)
        .get()
    : null;

  if (!orgId || !profileSnap?.exists) {
    throw new HttpsError(
      'failed-precondition',
      'No organization membership found. Sign out and sign in again, or contact support.',
    );
  }

  const { permissions, tagScopes } = await resolveUserPermissions(orgId, userId);

  const profile = profileSnap.data() ?? {};
  const profileRole = (profile['role'] as string | undefined) ?? 'user';
  const profileOrgId =
    (profile['organizationId'] as string | undefined) ?? orgId;

  let existingClaims: Record<string, unknown> = {};
  try {
    const userRecord = await admin.auth().getUser(userId);
    existingClaims = (userRecord.customClaims as Record<string, unknown>) ?? {};
  } catch {
    throw new HttpsError('not-found', 'User not found in Firebase Auth.');
  }

  await admin.auth().setCustomUserClaims(userId, {
    ...existingClaims,
    permissions,
    tagScopes,
    orgId,
    organizationId: profileOrgId,
    role: profileRole,
  });

  return { ok: true, permissionCount: permissions.length };
});

// ── Trigger: notifyReporterOnStatusChange ─────────────────────────────────────

/**
 * Triggered on every update to a report document.
 *
 * When the `status` field changes, sends an FCM push notification to the
 * original reporter (if non-anonymous and notifications are enabled).
 *
 * Stale FCM tokens (error: registration-token-not-registered) are
 * automatically removed from the user document after each send.
 */
export const notifyReporterOnStatusChange = onDocumentUpdated(
  'organizations/{orgId}/reports/{reportId}',
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    // Only proceed if status actually changed.
    if (!before || !after || before['status'] === after['status']) {
      return;
    }

    const submittedBy = after['submittedBy'] as string | null | undefined;
    if (!submittedBy) {
      // Anonymous report — cannot send a notification.
      return;
    }

    const { orgId, reportId } = event.params;
    const newStatus = after['status'] as string;
    const reportTitle = (after['title'] as string | undefined) ?? 'Your report';

    // Load the reporter's profile for FCM tokens and notification preferences.
    const userDoc = await db
      .collection('organizations').doc(orgId)
      .collection('users').doc(submittedBy)
      .get();

    if (!userDoc.exists) {
      logger.warn('notifyReporterOnStatusChange: user not found', { submittedBy });
      return;
    }

    const userData = userDoc.data()!;
    const prefs = userData['notificationPreferences'] as
      | Record<string, unknown>
      | undefined;

    if (prefs?.['statusUpdates'] === false) {
      // Reporter has opted out of status update notifications.
      return;
    }

    const fcmTokens = (userData['fcmTokens'] as string[] | undefined) ?? [];
    if (fcmTokens.length === 0) {
      return;
    }

    const statusLabels: Record<string, string> = {
      submitted: 'Submitted',
      under_review: 'Under Review',
      in_progress: 'In Progress',
      resolved: 'Resolved',
      closed: 'Closed',
    };
    const statusLabel = statusLabels[newStatus] ?? newStatus;

    const messaging = admin.messaging();
    const result = await messaging.sendEachForMulticast({
      tokens: fcmTokens,
      notification: {
        title: 'Report Status Updated',
        body: `"${reportTitle}" is now ${statusLabel}.`,
      },
      data: {
        reportId,
        type: 'status_update',
        newStatus,
      },
      android: {
        priority: 'high',
        notification: { channelId: 'status_updates' },
      },
    });

    // Prune stale tokens to keep the user's token list clean.
    const staleTokens: string[] = [];
    result.responses.forEach((resp, i) => {
      if (
        !resp.success &&
        resp.error?.code === 'messaging/registration-token-not-registered'
      ) {
        staleTokens.push(fcmTokens[i]);
      }
    });

    if (staleTokens.length > 0) {
      await userDoc.ref.update({
        fcmTokens: admin.firestore.FieldValue.arrayRemove(...staleTokens),
      });
      logger.info('Removed stale FCM tokens', {
        submittedBy,
        count: staleTokens.length,
      });
    }

    logger.info('notifyReporterOnStatusChange completed', {
      orgId,
      reportId,
      newStatus,
      successCount: result.successCount,
      failureCount: result.failureCount,
    });
  },
);

// ── Notification history & expiration ───────────────────────────────────────

type RemovalReason = 'expired' | 'recalled' | 'user_dismissed' | 'cleared_all';

interface ResponseOption {
  id?: string;
  label?: string;
}

interface ResponseConfig {
  enabled?: boolean;
  responseRequired?: boolean;
  type?: string;
  maxTextLength?: number;
  allowAdditionalText?: boolean;
  /** When false, responses are locked after the first submission. */
  allowResponseUpdates?: boolean;
  options?: ResponseOption[];
}

interface ReminderData {
  title?: string;
  body?: string;
  status?: string;
  audienceType?: string;
  audienceId?: string | null;
  audienceLabel?: string | null;
  scheduledAt?: admin.firestore.Timestamp | null;
  deliveredAt?: admin.firestore.Timestamp | null;
  publishedAt?: admin.firestore.Timestamp | null;
  expiresAt?: admin.firestore.Timestamp | null;
  createdBy?: string;
  createdByName?: string;
  responseConfig?: ResponseConfig;
}

async function getFeedCopiesForReminder(
  orgId: string,
  reminderId: string,
): Promise<admin.firestore.QueryDocumentSnapshot[]> {
  const notifSnap = await db
    .collectionGroup('notifications')
    .where('data.reminderId', '==', reminderId)
    .get();
  return notifSnap.docs.filter((d) => {
    const orgDoc = d.ref.parent.parent?.parent.parent;
    return orgDoc?.id === orgId;
  });
}

async function writeBroadcastHistory(
  orgId: string,
  reminderId: string,
  data: ReminderData,
  reason: RemovalReason,
  removedBy: string | null,
  feedCopiesAffected: number,
): Promise<void> {
  await db
    .collection('organizations').doc(orgId)
    .collection('notification_history')
    .add({
      organizationId: orgId,
      sourceType: 'reminder',
      sourceId: reminderId,
      reminderId,
      title: data.title ?? '',
      body: data.body ?? '',
      type: 'reminder',
      audienceType: data.audienceType ?? 'all',
      audienceId: data.audienceId ?? null,
      audienceLabel: data.audienceLabel ?? null,
      createdBy: data.createdBy ?? null,
      createdByName: data.createdByName ?? null,
      publishedAt: data.publishedAt ?? data.deliveredAt ?? null,
      expiresAt: data.expiresAt ?? null,
      removedAt: admin.firestore.FieldValue.serverTimestamp(),
      removalReason: reason,
      removedBy,
      feedCopiesAffected,
    });
}

async function archiveAndRemoveBroadcast(
  orgId: string,
  reminderId: string,
  reason: RemovalReason,
  removedBy: string | null,
): Promise<{ deletedNotifications: number }> {
  const reminderRef = db
    .collection('organizations').doc(orgId)
    .collection('reminders').doc(reminderId);
  const snap = await reminderRef.get();
  const data = (snap.data() ?? {}) as ReminderData;

  const toDelete = await getFeedCopiesForReminder(orgId, reminderId);

  if (snap.exists) {
    await writeBroadcastHistory(
      orgId,
      reminderId,
      data,
      reason,
      removedBy,
      toDelete.length,
    );
  }

  let deletedNotifications = 0;
  for (let i = 0; i < toDelete.length; i += 450) {
    const batch = db.batch();
    const slice = toDelete.slice(i, i + 450);
    for (const d of slice) batch.delete(d.ref);
    await batch.commit();
    deletedNotifications += slice.length;
  }

  if (snap.exists) {
    await reminderRef.delete();
  }

  return { deletedNotifications };
}

// ── Callable: recallReminder ──────────────────────────────────────────────────

/**
 * Recalls a broadcast: deletes the reminder document AND removes every copy
 * already delivered to recipients' in-app notification feeds.
 *
 * Authorized for the reminder's author, org admins, or holders of
 * `approveReminders`. Per-user feed entries can only be removed server-side
 * (the Admin SDK bypasses the owner-only delete rule), which is why this runs
 * as a callable rather than a client-side delete.
 *
 * Returns: { ok: true, deletedNotifications: number }
 */
export const recallReminder = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const { orgId, reminderId } = (request.data ?? {}) as {
    orgId?: string;
    reminderId?: string;
  };
  if (!orgId || !reminderId) {
    throw new HttpsError(
      'invalid-argument',
      'orgId and reminderId are required.',
    );
  }

  const uid = request.auth.uid;
  const token = request.auth.token as Record<string, unknown>;
  const permissions = (token['permissions'] as string[] | undefined) ?? [];
  const role = token['role'] as string | undefined;
  const isAdmin =
    role === 'admin' || role === 'super_admin' || role === 'owner';
  const canApprove = permissions.includes('approveReminders');

  const reminderRef = db
    .collection('organizations').doc(orgId)
    .collection('reminders').doc(reminderId);
  const snap = await reminderRef.get();
  if (!snap.exists) {
    throw new HttpsError('not-found', 'Reminder not found.');
  }

  const data = snap.data() as ReminderData;
  const isOwner = data.createdBy === uid;
  if (!isOwner && !isAdmin && !canApprove) {
    throw new HttpsError(
      'permission-denied',
      'You do not have permission to recall this reminder.',
    );
  }

  const { deletedNotifications } = await archiveAndRemoveBroadcast(
    orgId,
    reminderId,
    'recalled',
    uid,
  );

  logger.info('recallReminder completed', {
    orgId,
    reminderId,
    deletedNotifications,
    by: uid,
  });

  return { ok: true, deletedNotifications };
});

// ── Callable: retryReminderDelivery ───────────────────────────────────────────

/**
 * Re-attempts delivery for a published reminder that was never delivered
 * (e.g. a prior delivery attempt failed after claiming).
 */
export const retryReminderDelivery = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const { orgId, reminderId } = (request.data ?? {}) as {
    orgId?: string;
    reminderId?: string;
  };
  if (!orgId || !reminderId) {
    throw new HttpsError(
      'invalid-argument',
      'orgId and reminderId are required.',
    );
  }

  const uid = request.auth.uid;
  const token = request.auth.token as Record<string, unknown>;
  const permissions = (token['permissions'] as string[] | undefined) ?? [];
  const role = token['role'] as string | undefined;
  const isAdmin =
    role === 'admin' || role === 'super_admin' || role === 'owner';

  const reminderRef = db
    .collection('organizations').doc(orgId)
    .collection('reminders').doc(reminderId);
  const snap = await reminderRef.get();
  if (!snap.exists) {
    throw new HttpsError('not-found', 'Reminder not found.');
  }

  const data = snap.data() as ReminderData;
  const isOwner = data.createdBy === uid;
  if (!isOwner && !isAdmin && !permissions.includes('broadcastReminders')) {
    throw new HttpsError(
      'permission-denied',
      'You do not have permission to retry this reminder.',
    );
  }
  if (data.status !== 'published') {
    throw new HttpsError(
      'failed-precondition',
      'Only published reminders can be retried.',
    );
  }

  await reminderRef.update({
    deliveredAt: admin.firestore.FieldValue.delete(),
  });
  const delivered = await deliverReminder(orgId, reminderId);

  return { ok: true, delivered };
});

// ── Callable: updateReminder ──────────────────────────────────────────────────

/**
 * Updates a reminder's title/body and propagates the change to every delivered
 * in-app notification copy (matched by `data.reminderId`).
 *
 * Authorized for the reminder's author or org admins.
 *
 * Returns: { ok: true, updatedNotifications: number }
 */
export const updateReminder = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const { orgId, reminderId, title, body, expiresAt, clearExpiresAt } =
    (request.data ?? {}) as {
      orgId?: string;
      reminderId?: string;
      title?: string;
      body?: string;
      expiresAt?: number;
      clearExpiresAt?: boolean;
    };
  if (!orgId || !reminderId) {
    throw new HttpsError(
      'invalid-argument',
      'orgId and reminderId are required.',
    );
  }

  const trimmedTitle = (title ?? '').trim();
  const trimmedBody = (body ?? '').trim();
  if (!trimmedTitle || !trimmedBody) {
    throw new HttpsError(
      'invalid-argument',
      'title and body are required.',
    );
  }

  const uid = request.auth.uid;
  const token = request.auth.token as Record<string, unknown>;
  const role = token['role'] as string | undefined;
  const isAdmin =
    role === 'admin' || role === 'super_admin' || role === 'owner';

  const reminderRef = db
    .collection('organizations').doc(orgId)
    .collection('reminders').doc(reminderId);
  const snap = await reminderRef.get();
  if (!snap.exists) {
    throw new HttpsError('not-found', 'Reminder not found.');
  }

  const data = snap.data() as ReminderData;
  const isOwner = data.createdBy === uid;
  if (!isOwner && !isAdmin) {
    throw new HttpsError(
      'permission-denied',
      'You do not have permission to edit this reminder.',
    );
  }

  const reminderUpdate: Record<string, unknown> = {
    title: trimmedTitle,
    body: trimmedBody,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  if (clearExpiresAt) {
    reminderUpdate.expiresAt = admin.firestore.FieldValue.delete();
  } else if (typeof expiresAt === 'number' && expiresAt > 0) {
    reminderUpdate.expiresAt = admin.firestore.Timestamp.fromMillis(expiresAt);
  }

  await reminderRef.update(reminderUpdate);

  const toUpdate = await getFeedCopiesForReminder(orgId, reminderId);
  const feedUpdate: Record<string, unknown> = {
    title: trimmedTitle,
    body: trimmedBody,
  };
  if (clearExpiresAt) {
    feedUpdate.expiresAt = admin.firestore.FieldValue.delete();
  } else if (typeof expiresAt === 'number' && expiresAt > 0) {
    feedUpdate.expiresAt = admin.firestore.Timestamp.fromMillis(expiresAt);
  }

  let updatedNotifications = 0;
  for (let i = 0; i < toUpdate.length; i += 450) {
    const batch = db.batch();
    const slice = toUpdate.slice(i, i + 450);
    for (const d of slice) {
      batch.update(d.ref, feedUpdate);
    }
    await batch.commit();
    updatedNotifications += slice.length;
  }

  logger.info('updateReminder completed', {
    orgId,
    reminderId,
    updatedNotifications,
    by: uid,
  });

  return { ok: true, updatedNotifications };
});

async function isResponseRequiredForReminder(
  orgId: string,
  reminderId: string,
): Promise<boolean> {
  const snap = await db
    .collection('organizations').doc(orgId)
    .collection('reminders').doc(reminderId)
    .get();
  if (!snap.exists) return false;
  const config = (snap.data() as ReminderData).responseConfig;
  return config?.enabled === true && config?.responseRequired === true;
}

async function userHasReminderResponse(
  orgId: string,
  reminderId: string,
  uid: string,
): Promise<boolean> {
  const snap = await db
    .collection('organizations').doc(orgId)
    .collection('reminders').doc(reminderId)
    .collection('responses').doc(uid)
    .get();
  return snap.exists;
}

async function markUserReminderNotificationsRead(
  orgId: string,
  uid: string,
  reminderId: string,
): Promise<void> {
  try {
    const snap = await db
      .collection('organizations').doc(orgId)
      .collection('users').doc(uid)
      .collection('notifications')
      .where('data.reminderId', '==', reminderId)
      .get();
    if (snap.empty) return;

    const batch = db.batch();
    for (const doc of snap.docs) {
      batch.update(doc.ref, {
        read: true,
        readAt: admin.firestore.FieldValue.serverTimestamp(),
        'data.hasResponded': true,
      });
    }
    await batch.commit();
  } catch (err) {
    // Response is already saved; do not fail the callable if feed sync fails.
    logger.warn('markUserReminderNotificationsRead failed', {
      orgId,
      uid,
      reminderId,
      err,
    });
  }
}

// ── Callable: dismissNotification ─────────────────────────────────────────────

/**
 * Archives and removes a single notification from the caller's feed.
 */
export const dismissNotification = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const { orgId, notificationId } = (request.data ?? {}) as {
    orgId?: string;
    notificationId?: string;
  };
  if (!orgId || !notificationId) {
    throw new HttpsError(
      'invalid-argument',
      'orgId and notificationId are required.',
    );
  }

  const uid = request.auth.uid;
  const ref = db
    .collection('organizations').doc(orgId)
    .collection('users').doc(uid)
    .collection('notifications').doc(notificationId);
  const snap = await ref.get();
  if (!snap.exists) {
    throw new HttpsError('not-found', 'Notification not found.');
  }

  const data = snap.data() as Record<string, unknown>;
  const payload = (data['data'] as Record<string, unknown> | undefined) ?? {};
  const reminderId = payload['reminderId'] as string | undefined;
  const responseRequired =
    payload['responseRequired'] === true ||
    (reminderId
      ? await isResponseRequiredForReminder(orgId, reminderId)
      : false);

  if (responseRequired && reminderId) {
    const responded = await userHasReminderResponse(orgId, reminderId, uid);
    if (!responded) {
      throw new HttpsError(
        'failed-precondition',
        'Submit your response before dismissing this alert.',
      );
    }
  }

  await db
    .collection('organizations').doc(orgId)
    .collection('notification_history')
    .add({
      organizationId: orgId,
      sourceType: 'notification',
      sourceId: notificationId,
      reminderId: (payload['reminderId'] as string | undefined) ?? null,
      userId: uid,
      title: (data['title'] as string | undefined) ?? '',
      body: (data['body'] as string | undefined) ?? '',
      type: (data['type'] as string | undefined) ?? 'general',
      expiresAt: data['expiresAt'] ?? null,
      removedAt: admin.firestore.FieldValue.serverTimestamp(),
      removalReason: 'user_dismissed',
      removedBy: uid,
    });

  await ref.delete();
  return { ok: true };
});

// ── Callable: clearNotificationFeed ───────────────────────────────────────────

/**
 * Archives and removes every notification in the caller's feed.
 */
export const clearNotificationFeed = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const { orgId } = (request.data ?? {}) as { orgId?: string };
  if (!orgId) {
    throw new HttpsError('invalid-argument', 'orgId is required.');
  }

  const uid = request.auth.uid;
  const feedRef = db
    .collection('organizations').doc(orgId)
    .collection('users').doc(uid)
    .collection('notifications');
  const all = await feedRef.get();
  if (all.empty) return { ok: true, cleared: 0 };

  let cleared = 0;
  for (let i = 0; i < all.docs.length; i += 200) {
    const slice = all.docs.slice(i, i + 200);
    const batch = db.batch();
    for (const doc of slice) {
      const data = doc.data() as Record<string, unknown>;
      const payload =
        (data['data'] as Record<string, unknown> | undefined) ?? {};
      const reminderId = payload['reminderId'] as string | undefined;
      const responseRequired =
        payload['responseRequired'] === true ||
        (reminderId
          ? await isResponseRequiredForReminder(orgId, reminderId)
          : false);
      if (responseRequired && reminderId) {
        const responded = await userHasReminderResponse(
          orgId,
          reminderId,
          uid,
        );
        if (!responded) continue;
      }
      const historyRef = db
        .collection('organizations').doc(orgId)
        .collection('notification_history')
        .doc();
      batch.set(historyRef, {
        organizationId: orgId,
        sourceType: 'notification',
        sourceId: doc.id,
        reminderId: (payload['reminderId'] as string | undefined) ?? null,
        userId: uid,
        title: (data['title'] as string | undefined) ?? '',
        body: (data['body'] as string | undefined) ?? '',
        type: (data['type'] as string | undefined) ?? 'general',
        expiresAt: data['expiresAt'] ?? null,
        removedAt: admin.firestore.FieldValue.serverTimestamp(),
        removalReason: 'cleared_all',
        removedBy: uid,
      });
      batch.delete(doc.ref);
      cleared++;
    }
    await batch.commit();
  }

  return { ok: true, cleared };
});

// ── Callable: submitReminderResponse ──────────────────────────────────────────

/**
 * Validates and stores a recipient's response to a published reminder.
 */
export const submitReminderResponse = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const { orgId, reminderId, text, selectedOptionIds, selectedOptionId } =
    (request.data ?? {}) as {
      orgId?: string;
      reminderId?: string;
      text?: string;
      selectedOptionIds?: string[];
      selectedOptionId?: string;
    };
  if (!orgId || !reminderId) {
    throw new HttpsError(
      'invalid-argument',
      'orgId and reminderId are required.',
    );
  }

  const uid = request.auth.uid;
  const reminderRef = db
    .collection('organizations').doc(orgId)
    .collection('reminders').doc(reminderId);
  const reminderSnap = await reminderRef.get();
  if (!reminderSnap.exists) {
    throw new HttpsError('not-found', 'Reminder not found.');
  }

  const reminder = reminderSnap.data() as ReminderData;
  if (reminder.status !== 'published') {
    throw new HttpsError(
      'failed-precondition',
      'This reminder is not accepting responses.',
    );
  }
  if (reminder.expiresAt && reminder.expiresAt.toMillis() <= Date.now()) {
    throw new HttpsError(
      'failed-precondition',
      'This reminder has expired.',
    );
  }

  const config = reminder.responseConfig;
  if (!config?.enabled) {
    throw new HttpsError(
      'failed-precondition',
      'This reminder does not accept responses.',
    );
  }

  const allowResponseUpdates = config.allowResponseUpdates !== false;
  const existingResponseSnap = await reminderRef
    .collection('responses').doc(uid)
    .get();
  if (existingResponseSnap.exists && !allowResponseUpdates) {
    throw new HttpsError(
      'failed-precondition',
      'This response cannot be changed after submission.',
    );
  }

  const responseType = config.type ?? 'free_text';
  const optionIds = new Set(
    (config.options ?? [])
      .map((o) => o.id)
      .filter((id): id is string => Boolean(id)),
  );

  const payload: Record<string, unknown> = {
    organizationId: orgId,
    reminderId,
    responseType,
    submittedAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  if (responseType === 'free_text') {
    const trimmed = (text ?? '').trim();
    const maxLen = config.maxTextLength ?? 500;
    if (!trimmed) {
      throw new HttpsError('invalid-argument', 'Response text is required.');
    }
    if (trimmed.length > maxLen) {
      throw new HttpsError(
        'invalid-argument',
        `Response must be at most ${maxLen} characters.`,
      );
    }
    payload.text = trimmed;
  } else if (responseType === 'checkbox') {
    const ids = (selectedOptionIds ?? []).filter((id) => optionIds.has(id));
    payload.selectedOptionIds = ids;
  } else if (responseType === 'multiple_choice') {
    const id = selectedOptionId ?? '';
    if (!optionIds.has(id)) {
      throw new HttpsError('invalid-argument', 'Select a valid option.');
    }
    payload.selectedOptionId = id;
  } else {
    throw new HttpsError('invalid-argument', 'Unknown response type.');
  }

  if (
    responseType !== 'free_text' &&
    config.allowAdditionalText === true
  ) {
    const trimmed = (text ?? '').trim();
    const maxLen = config.maxTextLength ?? 500;
    if (trimmed.length > maxLen) {
      throw new HttpsError(
        'invalid-argument',
        `Explanation must be at most ${maxLen} characters.`,
      );
    }
    if (trimmed) {
      payload.text = trimmed;
    }
  }

  const userSnap = await db
    .collection('organizations').doc(orgId)
    .collection('users').doc(uid)
    .get();
  const displayName = userSnap.data()?.['displayName'] as string | undefined;
  if (displayName) payload.userDisplayName = displayName;

  await reminderRef.collection('responses').doc(uid).set(payload, { merge: true });
  await markUserReminderNotificationsRead(orgId, uid, reminderId);

  logger.info('submitReminderResponse completed', { orgId, reminderId, uid });
  return { ok: true, reminderId };
});

// ── Callable: createGroupLeaderReminder ───────────────────────────────────────

async function assertGroupLeader(
  orgId: string,
  groupId: string,
  uid: string,
): Promise<void> {
  const rosterSnap = await db
    .collection('organizations').doc(orgId)
    .collection('groups').doc(groupId)
    .collection('members').doc(uid)
    .get();
  if (rosterSnap.exists
      && rosterSnap.data()?.['groupRole'] === 'leader') {
    return;
  }

  const indexSnap = await db
    .collection('organizations').doc(orgId)
    .collection('users').doc(uid)
    .collection('groupMemberships').doc(groupId)
    .get();
  if (indexSnap.exists
      && indexSnap.data()?.['groupRole'] === 'leader') {
    return;
  }

  throw new HttpsError(
    'permission-denied',
    'You must be a leader of this group to send alerts.',
  );
}

async function resolveAuthorReminderStatus(
  orgId: string,
  uid: string,
  tokenPermissions: string[],
): Promise<'pending' | 'published'> {
  const orgSnap = await db.collection('organizations').doc(orgId).get();
  const requireApproval =
    orgSnap.data()?.['requireReminderApproval'] === true;
  if (!requireApproval) return 'published';

  const profileSnap = await db
    .collection('organizations').doc(orgId)
    .collection('users').doc(uid)
    .get();
  const profile = profileSnap.data() ?? {};
  const role = (profile['role'] as string | undefined) ?? 'user';
  if (['admin', 'super_admin', 'owner'].includes(role)) {
    return 'published';
  }

  const profilePerms =
    (profile['permissions'] as string[] | undefined) ?? [];
  if (tokenPermissions.includes('approveReminders')
      || profilePerms.includes('approveReminders')) {
    return 'published';
  }

  return 'pending';
}

/**
 * Creates a group-targeted reminder for a verified group leader (Admin SDK).
 * Avoids fragile client-side Security Rule edge cases for student leaders.
 */
export const createGroupLeaderReminder = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const {
    orgId,
    title,
    body,
    groupId,
    groupLabel,
    scheduledAt,
    expiresAt,
    responseConfig,
  } = (request.data ?? {}) as {
    orgId?: string;
    title?: string;
    body?: string;
    groupId?: string;
    groupLabel?: string;
    scheduledAt?: string;
    expiresAt?: string;
    responseConfig?: ResponseConfig;
  };

  if (!orgId || !groupId) {
    throw new HttpsError(
      'invalid-argument',
      'orgId and groupId are required.',
    );
  }

  const trimmedTitle = (title ?? '').trim();
  const trimmedBody = (body ?? '').trim();
  if (trimmedTitle.length < 3) {
    throw new HttpsError(
      'invalid-argument',
      'Title must be at least 3 characters.',
    );
  }
  if (trimmedBody.length < 5) {
    throw new HttpsError(
      'invalid-argument',
      'Message must be at least 5 characters.',
    );
  }

  const uid = request.auth.uid;
  await assertGroupLeader(orgId, groupId, uid);

  const tokenPerms =
    (request.auth.token['permissions'] as string[] | undefined) ?? [];
  const status = await resolveAuthorReminderStatus(orgId, uid, tokenPerms);

  const userSnap = await db
    .collection('organizations').doc(orgId)
    .collection('users').doc(uid)
    .get();
  const createdByName =
    (userSnap.data()?.['displayName'] as string | undefined) ?? null;

  const reminderRef = db
    .collection('organizations').doc(orgId)
    .collection('reminders').doc();

  const payload: Record<string, unknown> = {
    organizationId: orgId,
    title: trimmedTitle,
    body: trimmedBody,
    audienceType: 'group',
    audienceId: groupId,
    audienceLabel: groupLabel ?? null,
    status,
    createdBy: uid,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  if (createdByName) payload['createdByName'] = createdByName;

  if (scheduledAt) {
    payload['scheduledAt'] = admin.firestore.Timestamp.fromDate(
      new Date(scheduledAt),
    );
  }
  if (expiresAt) {
    payload['expiresAt'] = admin.firestore.Timestamp.fromDate(
      new Date(expiresAt),
    );
  }
  if (responseConfig?.enabled) {
    payload['responseConfig'] = responseConfig;
  }

  await reminderRef.set(payload);

  logger.info('createGroupLeaderReminder completed', {
    orgId,
    reminderId: reminderRef.id,
    groupId,
    uid,
    status,
  });

  return {
    ok: true,
    reminderId: reminderRef.id,
    status,
  };
});

// ── Reminders: delivery helpers ───────────────────────────────────────────────

/**
 * Resolves the set of recipient user IDs for a reminder based on its audience.
 *
 *   - `all`   → every approved member of the org
 *   - `group` → members of `groups/{audienceId}/members`
 *   - `role`  → every user holding a roleAssignment with roleId == audienceId
 */
async function resolveReminderRecipients(
  orgId: string,
  audienceType: string,
  audienceId: string | null | undefined,
): Promise<string[]> {
  const usersRef = db.collection('organizations').doc(orgId).collection('users');

  if (audienceType === 'all') {
    const snap = await usersRef
      .where('approvalStatus', '==', 'approved')
      .get();
    return snap.docs.map((d) => d.id);
  }

  if (audienceType === 'group' && audienceId) {
    const recipientIds = new Set<string>();

    const membersSnap = await db
      .collection('organizations').doc(orgId)
      .collection('groups').doc(audienceId)
      .collection('members')
      .get();
    for (const d of membersSnap.docs) {
      recipientIds.add((d.data()['userId'] as string | undefined) ?? d.id);
    }

    // Union My Groups indexes when available (optional — roster is primary).
    try {
      const indexSnap = await db
        .collectionGroup('groupMemberships')
        .where('organizationId', '==', orgId)
        .where('groupId', '==', audienceId)
        .get();
      for (const doc of indexSnap.docs) {
        const userId = doc.ref.parent.parent?.id;
        if (userId) recipientIds.add(userId);
      }
    } catch (err) {
      logger.warn('resolveReminderRecipients: groupMemberships query failed', {
        orgId,
        audienceId,
        err,
      });
    }

    return Array.from(recipientIds);
  }

  if (audienceType === 'role' && audienceId) {
    const assignmentsSnap = await db
      .collectionGroup('roleAssignments')
      .where('roleId', '==', audienceId)
      .get();
    const ids = new Set<string>();
    for (const doc of assignmentsSnap.docs) {
      // Path: organizations/{orgId}/users/{userId}/roleAssignments/{id}
      const userDoc = doc.ref.parent.parent;
      const orgDoc = userDoc?.parent.parent;
      if (userDoc && orgDoc?.id === orgId) ids.add(userDoc.id);
    }
    return Array.from(ids);
  }

  return [];
}

/**
 * Performs delivery for a published, due reminder:
 *   1. Atomically "claims" the reminder (sets deliveredAt) so the publish
 *      trigger and the scheduled publisher never deliver the same reminder
 *      twice.
 *   2. Writes a notification document into each recipient's feed.
 *   3. Sends an FCM push to each recipient's registered tokens.
 *
 * No-ops (returns false) if the reminder is not published, not yet due, or has
 * already been delivered.
 */
async function deliverReminder(
  orgId: string,
  reminderId: string,
): Promise<boolean> {
  const reminderRef = db
    .collection('organizations').doc(orgId)
    .collection('reminders').doc(reminderId);

  // 1. Claim delivery transactionally.
  const claimed = await db.runTransaction<ReminderData | null>(async (tx) => {
    const snap = await tx.get(reminderRef);
    if (!snap.exists) return null;
    const data = snap.data() as ReminderData;

    if (data.status !== 'published') return null;
    if (data.deliveredAt) return null; // already delivered
    if (data.scheduledAt && data.scheduledAt.toMillis() > Date.now()) {
      return null; // scheduled for the future — not due yet
    }

    tx.update(reminderRef, {
      deliveredAt: admin.firestore.FieldValue.serverTimestamp(),
      publishedAt:
        data.publishedAt ?? admin.firestore.FieldValue.serverTimestamp(),
    });
    return data;
  });

  if (!claimed) return false;

  const title = claimed.title ?? 'New reminder';
  const body = claimed.body ?? '';
  const audienceType = claimed.audienceType ?? 'all';
  const audienceId = claimed.audienceId ?? null;

  let recipientIds = await resolveReminderRecipients(
    orgId,
    audienceType,
    audienceId,
  );

  // Authors always receive a copy (group leaders may only be on the index).
  const authorId = claimed.createdBy;
  if (authorId && !recipientIds.includes(authorId)) {
    recipientIds = [...recipientIds, authorId];
  }

  if (recipientIds.length === 0) {
    logger.warn('deliverReminder: no recipients — rolling back claim', {
      orgId,
      reminderId,
      audienceType,
      audienceId,
    });
    await reminderRef.update({
      deliveredAt: admin.firestore.FieldValue.delete(),
    });
    return false;
  }

  // 2. Write in-app feed entries (batched, ≤450 writes per batch).
  const responseConfig = claimed.responseConfig;
  const responseRequired =
    responseConfig?.enabled === true &&
    responseConfig?.responseRequired === true;
  const notificationData: Record<string, unknown> = {
    reminderId,
    audienceType,
  };
  if (responseRequired) {
    notificationData.responseRequired = true;
  }

  const notification: Record<string, unknown> = {
    type: 'reminder',
    title,
    body,
    read: false,
    data: notificationData,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  if (claimed.expiresAt) {
    notification.expiresAt = claimed.expiresAt;
  }

  for (let i = 0; i < recipientIds.length; i += 450) {
    const batch = db.batch();
    for (const uid of recipientIds.slice(i, i + 450)) {
      const ref = db
        .collection('organizations').doc(orgId)
        .collection('users').doc(uid)
        .collection('notifications').doc();
      batch.set(ref, notification);
    }
    await batch.commit();
  }

  // 3. Send push notifications to recipients' FCM tokens.
  const userDocs = await fetchByIds(
    db.collection('organizations').doc(orgId).collection('users'),
    recipientIds,
  );

  const tokenOwner = new Map<string, string>(); // token → uid (for pruning)
  const tokens: string[] = [];
  for (const u of userDocs) {
    const prefs = u['notificationPreferences'] as
      | Record<string, unknown>
      | undefined;
    if (prefs?.['reminders'] === false) continue; // opted out of reminder push
    const userTokens = (u['fcmTokens'] as string[] | undefined) ?? [];
    for (const t of userTokens) {
      tokens.push(t);
      tokenOwner.set(t, u.id);
    }
  }

  if (tokens.length === 0) {
    logger.info('deliverReminder: no FCM tokens', { orgId, reminderId });
    return true;
  }

  const messaging = admin.messaging();
  const staleByUser = new Map<string, string[]>();
  let successCount = 0;

  // Multicast supports up to 500 tokens per call.
  for (let i = 0; i < tokens.length; i += 500) {
    const chunk = tokens.slice(i, i + 500);
    const result = await messaging.sendEachForMulticast({
      tokens: chunk,
      notification: { title, body },
      data: { reminderId, type: 'reminder' },
      android: {
        priority: 'high',
        notification: { channelId: 'reminders' },
      },
    });
    successCount += result.successCount;
    result.responses.forEach((resp, idx) => {
      if (
        !resp.success &&
        resp.error?.code === 'messaging/registration-token-not-registered'
      ) {
        const token = chunk[idx];
        const uid = tokenOwner.get(token);
        if (uid) {
          const list = staleByUser.get(uid) ?? [];
          list.push(token);
          staleByUser.set(uid, list);
        }
      }
    });
  }

  // Prune stale tokens.
  for (const [uid, stale] of staleByUser) {
    await db
      .collection('organizations').doc(orgId)
      .collection('users').doc(uid)
      .update({
        fcmTokens: admin.firestore.FieldValue.arrayRemove(...stale),
      });
  }

  logger.info('deliverReminder completed', {
    orgId,
    reminderId,
    recipientCount: recipientIds.length,
    pushSuccess: successCount,
  });
  return true;
}

// ── Trigger: onReminderPublished ──────────────────────────────────────────────

/**
 * Triggered on any write to a reminder document.
 *
 * Delivers the reminder (push + in-app feed) the moment it becomes `published`
 * and is due (no future `scheduledAt`). Reminders scheduled for a future time
 * are left for [publishDueReminders] to deliver when they come due. Delivery is
 * idempotent — [deliverReminder] claims each reminder atomically.
 */
export const onReminderPublished = onDocumentWritten(
  'organizations/{orgId}/reminders/{reminderId}',
  async (event) => {
    const after = event.data?.after.data() as ReminderData | undefined;
    if (!after) return; // deleted

    if (after.status !== 'published') return;
    if (after.deliveredAt) return; // already delivered
    if (after.scheduledAt && after.scheduledAt.toMillis() > Date.now()) {
      return; // future schedule — handled by publishDueReminders
    }

    const { orgId, reminderId } = event.params;
    await deliverReminder(orgId, reminderId);
  },
);

// ── Scheduled: publishDueReminders ────────────────────────────────────────────

/**
 * Runs every 5 minutes and delivers any `published` reminders whose
 * `scheduledAt` time has arrived but which have not yet been delivered.
 *
 * Uses a collection-group query so a single scheduled function serves every
 * organization. Delivery is idempotent via [deliverReminder].
 */
export const publishDueReminders = onSchedule('every 5 minutes', async () => {
  const now = admin.firestore.Timestamp.now();
  const dueSnap = await db
    .collectionGroup('reminders')
    .where('status', '==', 'published')
    .where('scheduledAt', '<=', now)
    .get();

  let delivered = 0;
  for (const doc of dueSnap.docs) {
    const data = doc.data() as ReminderData;
    if (data.deliveredAt) continue; // already delivered

    // Path: organizations/{orgId}/reminders/{reminderId}
    const orgDoc = doc.ref.parent.parent;
    if (!orgDoc) continue;
    const ok = await deliverReminder(orgDoc.id, doc.id);
    if (ok) delivered++;
  }

  logger.info('publishDueReminders completed', {
    candidates: dueSnap.size,
    delivered,
  });
});

// ── Scheduled: expireReminders ────────────────────────────────────────────────

/**
 * Runs every 5 minutes and archives + removes published reminders whose
 * `expiresAt` time has passed.
 */
export const expireReminders = onSchedule('every 5 minutes', async () => {
  const now = admin.firestore.Timestamp.now();
  const expiredSnap = await db
    .collectionGroup('reminders')
    .where('status', '==', 'published')
    .where('expiresAt', '<=', now)
    .get();

  let expired = 0;
  for (const doc of expiredSnap.docs) {
    const orgDoc = doc.ref.parent.parent;
    if (!orgDoc) continue;
    await archiveAndRemoveBroadcast(orgDoc.id, doc.id, 'expired', null);
    expired++;
  }

  logger.info('expireReminders completed', {
    candidates: expiredSnap.size,
    expired,
  });
});

// ── Trigger: onMemberApproved ─────────────────────────────────────────────────

/**
 * When a member is approved (or re-enrolled), backfill any org-wide broadcasts
 * they missed while not in the approved recipient set.
 */
async function backfillMissedBroadcasts(
  orgId: string,
  userId: string,
): Promise<number> {
  const publishedSnap = await db
    .collection('organizations').doc(orgId)
    .collection('reminders')
    .where('status', '==', 'published')
    .get();

  let written = 0;
  for (const doc of publishedSnap.docs) {
    const data = doc.data() as ReminderData;
    if (data.expiresAt && data.expiresAt.toMillis() <= Date.now()) continue;
    if ((data.audienceType ?? 'all') !== 'all') continue;

    const existing = await db
      .collection('organizations').doc(orgId)
      .collection('users').doc(userId)
      .collection('notifications')
      .where('data.reminderId', '==', doc.id)
      .limit(1)
      .get();
    if (!existing.empty) continue;

    const backfillEntry: Record<string, unknown> = {
      type: 'reminder',
      title: data.title ?? 'New reminder',
      body: data.body ?? '',
      read: false,
      data: { reminderId: doc.id, audienceType: 'all' },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    if (data.expiresAt) {
      const expiresAt = data.expiresAt.toMillis();
      if (expiresAt > Date.now()) {
        backfillEntry.expiresAt = data.expiresAt;
      } else {
        continue;
      }
    }
    await db
      .collection('organizations').doc(orgId)
      .collection('users').doc(userId)
      .collection('notifications')
      .add(backfillEntry);
    written++;
  }
  return written;
}

export const onMemberApproved = onDocumentUpdated(
  'organizations/{orgId}/users/{userId}',
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;
    if (before['approvalStatus'] === after['approvalStatus']) return;
    if (after['approvalStatus'] !== 'approved') return;

    const { orgId, userId } = event.params;

    // Ensure JWT claims include org membership for Storage rules and RBAC.
    try {
      const { permissions, tagScopes } = await resolveUserPermissions(
        orgId,
        userId,
      );
      const profileRole = (after['role'] as string | undefined) ?? 'user';
      const profileOrgId =
        (after['organizationId'] as string | undefined) ?? orgId;
      let existingClaims: Record<string, unknown> = {};
      try {
        const userRecord = await admin.auth().getUser(userId);
        existingClaims =
          (userRecord.customClaims as Record<string, unknown>) ?? {};
      } catch (err) {
        logger.warn('onMemberApproved: user not in Auth', { userId, err });
      }
      await admin.auth().setCustomUserClaims(userId, {
        ...existingClaims,
        permissions,
        tagScopes,
        orgId,
        organizationId: profileOrgId,
        role: profileRole,
      });
      logger.info('onMemberApproved: synced custom claims', { orgId, userId });
    } catch (err) {
      logger.error('onMemberApproved: failed to sync claims', {
        orgId,
        userId,
        err,
      });
    }

    const count = await backfillMissedBroadcasts(orgId, userId);
    if (count > 0) {
      logger.info('onMemberApproved: backfilled broadcasts', {
        orgId,
        userId,
        count,
      });
    }
  },
);

// ── Callable: provisionStudent ────────────────────────────────────────────────

/**
 * Creates a pre-approved student account: roster row, Firebase Auth user
 * (synthetic email), profile, and default member role assignment.
 *
 * Students sign in with their school ID as both username and password until
 * email-based auth is enabled.
 */
async function assertOrgAdminCaller(
  uid: string,
  orgId: string,
  token: Record<string, unknown>,
): Promise<void> {
  const role = token['role'] as string | undefined;
  const tokenOrg =
    (token['orgId'] as string | undefined) ??
    (token['organizationId'] as string | undefined);
  if (
    tokenOrg === orgId &&
    (role === 'admin' || role === 'super_admin' || role === 'owner')
  ) {
    return;
  }

  const profileSnap = await db
    .collection('organizations').doc(orgId)
    .collection('users').doc(uid)
    .get();
  const profile = profileSnap.data() ?? {};
  const profileRole = profile['role'] as string | undefined;
  if (
    profile['organizationId'] === orgId &&
    profile['approvalStatus'] === 'approved' &&
    (profileRole === 'admin' ||
      profileRole === 'super_admin' ||
      profileRole === 'owner')
  ) {
    return;
  }

  throw new HttpsError(
    'permission-denied',
    'Only organization admins can provision students.',
  );
}

export const provisionStudent = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const { orgId, studentId, fullName, gradeLevel, email } = (request.data ?? {}) as {
    orgId?: string;
    studentId?: string;
    fullName?: string;
    gradeLevel?: number;
    email?: string;
  };

  if (!orgId || !studentId || !fullName) {
    throw new HttpsError(
      'invalid-argument',
      'orgId, studentId, and fullName are required.',
    );
  }

  const trimmedId = studentId.trim();
  const trimmedName = fullName.trim();
  const trimmedContactEmail = email?.trim() ?? '';
  if (!trimmedId || !trimmedName) {
    throw new HttpsError(
      'invalid-argument',
      'studentId and fullName cannot be empty.',
    );
  }

  if (gradeLevel == null || gradeLevel <= 0) {
    throw new HttpsError('invalid-argument', 'gradeLevel is required.');
  }

  if (
    trimmedContactEmail &&
    !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(trimmedContactEmail)
  ) {
    throw new HttpsError('invalid-argument', 'Invalid email address.');
  }

  try {
    assertStudentPasswordLength(trimmedId);
  } catch (err) {
    throw new HttpsError(
      'invalid-argument',
      err instanceof Error ? err.message : 'Invalid student ID.',
    );
  }

  const adminUid = request.auth.uid;
  const token = request.auth.token as Record<string, unknown>;
  await assertOrgAdminCaller(adminUid, orgId, token);

  const rosterRef = db
    .collection('organizations').doc(orgId)
    .collection('roster').doc(trimmedId);
  const existingRoster = await rosterRef.get();
  if (existingRoster.exists && existingRoster.data()?.['isRegistered'] === true) {
    throw new HttpsError(
      'already-exists',
      'A student with this ID is already registered.',
    );
  }

  const authEmail = studentAuthEmail(orgId, trimmedId);
  let uid: string;

  try {
    const userRecord = await admin.auth().createUser({
      email: authEmail,
      password: trimmedId,
      displayName: trimmedName,
    });
    uid = userRecord.uid;
  } catch (err) {
    const code = (err as { code?: string }).code;
    if (code === 'auth/email-already-exists') {
      throw new HttpsError(
        'already-exists',
        'An account already exists for this student ID.',
      );
    }
    logger.error('provisionStudent: createUser failed', { err, authEmail });
    throw new HttpsError('internal', 'Failed to create student login.');
  }

  const now = admin.firestore.FieldValue.serverTimestamp();
  const userRef = db
    .collection('organizations').doc(orgId)
    .collection('users').doc(uid);

  const profileData: Record<string, unknown> = {
    userId: uid,
    organizationId: orgId,
    displayName: trimmedName,
    fullName: trimmedName,
    studentId: trimmedId,
    gradeLevel,
    role: 'user',
    approvalStatus: 'approved',
    applicationSubmitted: true,
    isActive: true,
    permissions: [],
    provisionedBy: adminUid,
    provisionSource: 'admin',
    createdAt: now,
    updatedAt: now,
  };
  if (trimmedContactEmail) {
    profileData['email'] = normalizeContactEmail(trimmedContactEmail);
  }

  const rosterData: Record<string, unknown> = {
    studentId: trimmedId,
    fullName: trimmedName,
    grade: `Grade ${gradeLevel}`,
    isRegistered: true,
    registeredUserId: uid,
    importedAt: now,
    importSource: 'admin',
    updatedAt: now,
  };
  if (trimmedContactEmail) {
    rosterData['email'] = normalizeContactEmail(trimmedContactEmail);
  }

  const batch = db.batch();
  batch.set(userRef, profileData, { merge: false });
  batch.set(rosterRef, rosterData, { merge: true });

  const assignmentRef = userRef
    .collection('roleAssignments')
    .doc();
  batch.set(assignmentRef, {
    roleId: 'member',
    scopeType: 'org',
    assignedBy: adminUid,
    assignedAt: now,
  });

  try {
    await batch.commit();
  } catch (err) {
    await admin.auth().deleteUser(uid);
    logger.error('provisionStudent: Firestore write failed', { err, uid });
    throw new HttpsError('internal', 'Failed to save student profile.');
  }

  await admin.auth().setCustomUserClaims(uid, {
    orgId,
    organizationId: orgId,
    role: 'user',
    permissions: [],
    tagScopes: [],
  });

  logger.info('provisionStudent completed', {
    orgId,
    studentId: trimmedId,
    uid,
    by: adminUid,
  });

  return {
    ok: true,
    studentId: trimmedId,
    userId: uid,
    authEmail,
  };
});

// ── Trigger: syncUserGroupMembershipIndex ─────────────────────────────────────

/**
 * Keeps `users/{userId}/groupMemberships/{groupId}` in sync when roster
 * managers add, update, or remove group members. Powers the My Groups screen
 * for non-admin members without a collectionGroup query on `members`.
 */
export const syncUserGroupMembershipIndex = onDocumentWritten(
  'organizations/{orgId}/groups/{groupId}/members/{userId}',
  async (event) => {
    const { orgId, groupId, userId } = event.params;
    const indexRef = db
      .collection('organizations').doc(orgId)
      .collection('users').doc(userId)
      .collection('groupMemberships').doc(groupId);

    if (!event.data?.after.exists) {
      await indexRef.delete();
      logger.info('groupMembership index removed', { orgId, groupId, userId });
      return;
    }

    const memberData = event.data.after.data() ?? {};
    const groupSnap = await db
      .collection('organizations').doc(orgId)
      .collection('groups').doc(groupId)
      .get();
    const groupData = groupSnap.data() ?? {};

    const indexPayload: Record<string, unknown> = {
      organizationId: orgId,
      groupId,
      groupName: (groupData['name'] as string | undefined) ?? 'Group',
      groupRole: (memberData['groupRole'] as string | undefined) ?? 'member',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    const positionRoleId = memberData['positionRoleId'] as string | undefined;
    if (positionRoleId) {
      indexPayload['positionRoleId'] = positionRoleId;
    }

    await indexRef.set(indexPayload, { merge: true });
    logger.info('groupMembership index synced', { orgId, groupId, userId });
  },
);

// ── Callable: backfillGroupMembershipIndexes ──────────────────────────────────

/**
 * One-time (or repair) sync of all group member docs into per-user
 * groupMemberships indexes. Org admin only.
 */
export const backfillGroupMembershipIndexes = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const orgId = request.data?.['orgId'] as string | undefined;
  if (!orgId || typeof orgId !== 'string') {
    throw new HttpsError('invalid-argument', 'orgId is required.');
  }

  const adminUid = request.auth.uid;
  const token = request.auth.token as Record<string, unknown>;
  await assertOrgAdminCaller(adminUid, orgId, token);

  const groupsSnap = await db
    .collection('organizations').doc(orgId)
    .collection('groups')
    .get();

  let synced = 0;
  const batchSize = 400;
  let batch = db.batch();
  let batchCount = 0;

  for (const groupDoc of groupsSnap.docs) {
    const groupData = groupDoc.data();
    const groupName = (groupData['name'] as string | undefined) ?? 'Group';
    const membersSnap = await groupDoc.ref.collection('members').get();

    for (const memberDoc of membersSnap.docs) {
      const memberData = memberDoc.data();
      const userId = memberDoc.id;
      const indexRef = db
        .collection('organizations').doc(orgId)
        .collection('users').doc(userId)
        .collection('groupMemberships').doc(groupDoc.id);

      const indexPayload: Record<string, unknown> = {
        organizationId: orgId,
        groupId: groupDoc.id,
        groupName,
        groupRole: (memberData['groupRole'] as string | undefined) ?? 'member',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };
      const positionRoleId = memberData['positionRoleId'] as string | undefined;
      if (positionRoleId) {
        indexPayload['positionRoleId'] = positionRoleId;
      }

      batch.set(indexRef, indexPayload, { merge: true });
      batchCount++;
      synced++;

      if (batchCount >= batchSize) {
        await batch.commit();
        batch = db.batch();
        batchCount = 0;
      }
    }
  }

  if (batchCount > 0) {
    await batch.commit();
  }

  logger.info('backfillGroupMembershipIndexes completed', { orgId, synced, by: adminUid });
  return { ok: true, synced };
});

// ── Callable: syncMyGroupMemberships ────────────────────────────────────────────

/**
 * Rebuilds the calling user's groupMemberships index from group rosters.
 * Any approved org member may invoke this for themselves (no collectionGroup).
 */
export const syncMyGroupMemberships = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const orgId = request.data?.['orgId'] as string | undefined;
  if (!orgId || typeof orgId !== 'string') {
    throw new HttpsError('invalid-argument', 'orgId is required.');
  }

  const uid = request.auth.uid;
  const profileSnap = await db
    .collection('organizations').doc(orgId)
    .collection('users').doc(uid)
    .get();
  const profile = profileSnap.data() ?? {};
  if (
    profile['organizationId'] !== orgId ||
    profile['approvalStatus'] !== 'approved'
  ) {
    throw new HttpsError('permission-denied', 'Not an approved member of this org.');
  }

  const groupsSnap = await db
    .collection('organizations').doc(orgId)
    .collection('groups')
    .get();

  const activeGroupIds = new Set<string>();
  let synced = 0;
  const batch = db.batch();

  for (const groupDoc of groupsSnap.docs) {
    const memberSnap = await groupDoc.ref.collection('members').doc(uid).get();
    if (!memberSnap.exists) continue;

    activeGroupIds.add(groupDoc.id);
    const memberData = memberSnap.data() ?? {};
    const groupData = groupDoc.data();
    const indexRef = db
      .collection('organizations').doc(orgId)
      .collection('users').doc(uid)
      .collection('groupMemberships').doc(groupDoc.id);

    const indexPayload: Record<string, unknown> = {
      organizationId: orgId,
      groupId: groupDoc.id,
      groupName: (groupData['name'] as string | undefined) ?? 'Group',
      groupRole: (memberData['groupRole'] as string | undefined) ?? 'member',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    const positionRoleId = memberData['positionRoleId'] as string | undefined;
    if (positionRoleId) {
      indexPayload['positionRoleId'] = positionRoleId;
    }

    batch.set(indexRef, indexPayload, { merge: true });
    synced++;
  }

  const indexSnap = await db
    .collection('organizations').doc(orgId)
    .collection('users').doc(uid)
    .collection('groupMemberships')
    .get();

  for (const indexDoc of indexSnap.docs) {
    if (!activeGroupIds.has(indexDoc.id)) {
      batch.delete(indexDoc.ref);
    }
  }

  await batch.commit();

  logger.info('syncMyGroupMemberships completed', { orgId, uid, synced });
  return { ok: true, synced };
});

export {
  submitGroupJoinRequest,
  withdrawGroupJoinRequest,
  reviewGroupJoinRequest,
  voluntaryLeaveGroup,
  submitGroupLeaveRequest,
  withdrawGroupLeaveRequest,
  reviewGroupLeaveRequest,
  removeGroupMemberWithNotification,
} from './group_membership';

export { resolveLoginEmail } from './resolve_login';
export { updateOrgMember } from './update_org_member';
export {
  uploadMemberAvatar,
  setMemberAvatarUrl,
  setOfficialPhotoUrl,
} from './profile_photos';
export { resetOrgMemberPassword } from './reset_org_member_password';
export {
  createGroupLeaderAnnouncement,
  onBulletinPublished,
  publishDueBulletins,
  submitBulletinResponse,
  setBulletinImageUrl,
  updateBulletin,
  deleteBulletin,
} from './announcements';
export {
  getTranslationWorkspaceAccess,
  importTranslationSource,
  listTranslationEntries,
  saveTranslationEntry,
  draftTranslation,
  batchDraftTranslations,
  batchApproveSavedTranslations,
  batchSaveAiDrafts,
  importTranslationTargets,
  exportTranslationArb,
} from './translation_helper';
export {
  listTranslationScreens,
  createTranslationScreen,
  updateTranslationScreen,
  deleteTranslationScreen,
} from './translation_screens';
