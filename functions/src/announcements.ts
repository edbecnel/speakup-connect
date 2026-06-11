import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

type BulletinData = {
  title?: string;
  body?: string;
  status?: string;
  authorId?: string;
  deliveredAt?: admin.firestore.Timestamp;
  expiresAt?: admin.firestore.Timestamp;
  publishedAt?: admin.firestore.Timestamp;
};

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
    'You must be a leader of this group to post announcements.',
  );
}

async function resolveAuthorBulletinStatus(
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

async function resolveOrgMemberIds(orgId: string): Promise<string[]> {
  const snap = await db
    .collection('organizations').doc(orgId)
    .collection('users')
    .where('approvalStatus', '==', 'approved')
    .get();
  return snap.docs.map((d) => d.id);
}

async function deliverBulletin(
  orgId: string,
  bulletinId: string,
): Promise<boolean> {
  const bulletinRef = db
    .collection('organizations').doc(orgId)
    .collection('bulletins').doc(bulletinId);

  const claimed = await db.runTransaction<BulletinData | null>(async (tx) => {
    const snap = await tx.get(bulletinRef);
    if (!snap.exists) return null;
    const data = snap.data() as BulletinData;

    if (data.status !== 'published') return null;
    if (data.deliveredAt) return null;

    tx.update(bulletinRef, {
      deliveredAt: admin.firestore.FieldValue.serverTimestamp(),
      publishedAt:
        data.publishedAt ?? admin.firestore.FieldValue.serverTimestamp(),
    });
    return data;
  });

  if (!claimed) return false;

  const title = claimed.title ?? 'New announcement';
  const body = claimed.body ?? '';
  let recipientIds = await resolveOrgMemberIds(orgId);

  const authorId = claimed.authorId;
  if (authorId && !recipientIds.includes(authorId)) {
    recipientIds = [...recipientIds, authorId];
  }

  if (recipientIds.length === 0) {
    logger.warn('deliverBulletin: no recipients — rolling back claim', {
      orgId,
      bulletinId,
    });
    await bulletinRef.update({
      deliveredAt: admin.firestore.FieldValue.delete(),
    });
    return false;
  }

  const notification: Record<string, unknown> = {
    type: 'bulletin',
    title,
    body,
    read: false,
    data: { bulletinId },
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

  const userDocs = await fetchByIds(
    db.collection('organizations').doc(orgId).collection('users'),
    recipientIds,
  );

  const tokenOwner = new Map<string, string>();
  const tokens: string[] = [];
  for (const u of userDocs) {
    const prefs = u['notificationPreferences'] as
      | Record<string, unknown>
      | undefined;
    if (prefs?.['bulletins'] === false) continue;
    const userTokens = (u['fcmTokens'] as string[] | undefined) ?? [];
    for (const t of userTokens) {
      tokens.push(t);
      tokenOwner.set(t, u.id);
    }
  }

  if (tokens.length === 0) {
    logger.info('deliverBulletin: no FCM tokens', { orgId, bulletinId });
    return true;
  }

  const messaging = admin.messaging();
  const staleByUser = new Map<string, string[]>();
  let successCount = 0;

  for (let i = 0; i < tokens.length; i += 500) {
    const chunk = tokens.slice(i, i + 500);
    const result = await messaging.sendEachForMulticast({
      tokens: chunk,
      notification: { title, body },
      data: { bulletinId, type: 'bulletin' },
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

  for (const [uid, stale] of staleByUser) {
    await db
      .collection('organizations').doc(orgId)
      .collection('users').doc(uid)
      .update({
        fcmTokens: admin.firestore.FieldValue.arrayRemove(...stale),
      });
  }

  logger.info('deliverBulletin completed', {
    orgId,
    bulletinId,
    recipientCount: recipientIds.length,
    pushSuccess: successCount,
  });
  return true;
}

/**
 * Creates an org-wide announcement for a verified group leader.
 */
export const createGroupLeaderAnnouncement = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const {
    orgId,
    title,
    body,
    groupId,
    groupLabel,
    expiresAt,
  } = (request.data ?? {}) as {
    orgId?: string;
    title?: string;
    body?: string;
    groupId?: string;
    groupLabel?: string;
    expiresAt?: string;
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
  const status = await resolveAuthorBulletinStatus(orgId, uid, tokenPerms);

  const userSnap = await db
    .collection('organizations').doc(orgId)
    .collection('users').doc(uid)
    .get();
  const authorName =
    (userSnap.data()?.['displayName'] as string | undefined) ?? null;

  const bulletinRef = db
    .collection('organizations').doc(orgId)
    .collection('bulletins').doc();

  const payload: Record<string, unknown> = {
    organizationId: orgId,
    title: trimmedTitle,
    body: trimmedBody,
    status,
    authorId: uid,
    sourceGroupId: groupId,
    sourceGroupName: groupLabel ?? null,
    isPinned: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  if (authorName) payload['authorName'] = authorName;
  if (status === 'published') {
    payload['publishedAt'] = admin.firestore.FieldValue.serverTimestamp();
  }
  if (expiresAt) {
    payload['expiresAt'] = admin.firestore.Timestamp.fromDate(
      new Date(expiresAt),
    );
  }

  await bulletinRef.set(payload);

  logger.info('createGroupLeaderAnnouncement completed', {
    orgId,
    bulletinId: bulletinRef.id,
    groupId,
    uid,
    status,
  });

  return {
    ok: true,
    bulletinId: bulletinRef.id,
    status,
  };
});

export const onBulletinPublished = onDocumentWritten(
  'organizations/{orgId}/bulletins/{bulletinId}',
  async (event) => {
    const after = event.data?.after.data() as BulletinData | undefined;
    if (!after) return;

    if (after.status !== 'published') return;
    if (after.deliveredAt) return;

    const { orgId, bulletinId } = event.params;
    await deliverBulletin(orgId, bulletinId);
  },
);
