import { onDocumentWritten, onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
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
