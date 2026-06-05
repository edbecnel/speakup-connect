import { onDocumentWritten, onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { logger } from 'firebase-functions';
import * as admin from 'firebase-admin';

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
  const orgId = (request.auth.token as Record<string, unknown>)['orgId'] as
    | string
    | undefined;

  if (!orgId) {
    throw new HttpsError(
      'failed-precondition',
      'No orgId claim found. Join an organization before refreshing permissions.',
    );
  }

  const { permissions, tagScopes } = await resolveUserPermissions(orgId, userId);

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

  const data = snap.data() as ReminderData & { createdBy?: string };
  const isOwner = data.createdBy === uid;
  if (!isOwner && !isAdmin && !canApprove) {
    throw new HttpsError(
      'permission-denied',
      'You do not have permission to recall this reminder.',
    );
  }

  // Remove delivered feed copies (matched by data.reminderId), scoped to this org.
  const notifSnap = await db
    .collectionGroup('notifications')
    .where('data.reminderId', '==', reminderId)
    .get();
  const toDelete = notifSnap.docs.filter((d) => {
    // Path: organizations/{orgId}/users/{uid}/notifications/{id}
    const orgDoc = d.ref.parent.parent?.parent.parent;
    return orgDoc?.id === orgId;
  });

  let deletedNotifications = 0;
  for (let i = 0; i < toDelete.length; i += 450) {
    const batch = db.batch();
    const slice = toDelete.slice(i, i + 450);
    for (const d of slice) batch.delete(d.ref);
    await batch.commit();
    deletedNotifications += slice.length;
  }

  await reminderRef.delete();

  logger.info('recallReminder completed', {
    orgId,
    reminderId,
    deletedNotifications,
    by: uid,
  });

  return { ok: true, deletedNotifications };
});

// ── Reminders: delivery helpers ───────────────────────────────────────────────

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
}

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
    const membersSnap = await db
      .collection('organizations').doc(orgId)
      .collection('groups').doc(audienceId)
      .collection('members')
      .get();
    return membersSnap.docs.map(
      (d) => (d.data()['userId'] as string | undefined) ?? d.id,
    );
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

  const recipientIds = await resolveReminderRecipients(
    orgId,
    audienceType,
    audienceId,
  );

  if (recipientIds.length === 0) {
    logger.info('deliverReminder: no recipients', { orgId, reminderId });
    return true;
  }

  // 2. Write in-app feed entries (batched, ≤450 writes per batch).
  const notification = {
    type: 'reminder',
    title,
    body,
    read: false,
    data: { reminderId, audienceType },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };

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
