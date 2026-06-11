import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

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
  allowResponseUpdates?: boolean;
  options?: ResponseOption[];
}

type BulletinData = {
  title?: string;
  body?: string;
  status?: string;
  authorId?: string;
  authorName?: string;
  sourceGroupId?: string | null;
  sourceGroupName?: string | null;
  deliveredAt?: admin.firestore.Timestamp;
  scheduledAt?: admin.firestore.Timestamp;
  expiresAt?: admin.firestore.Timestamp;
  publishedAt?: admin.firestore.Timestamp;
  responseConfig?: ResponseConfig;
  imageUrl?: string;
};

type RemovalReason = 'recalled' | 'expired';

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

async function getFeedCopiesForBulletin(
  orgId: string,
  bulletinId: string,
): Promise<admin.firestore.QueryDocumentSnapshot[]> {
  const notifSnap = await db
    .collectionGroup('notifications')
    .where('data.bulletinId', '==', bulletinId)
    .get();
  return notifSnap.docs.filter((d) => {
    const orgDoc = d.ref.parent.parent?.parent.parent;
    return orgDoc?.id === orgId;
  });
}

async function writeBulletinHistory(
  orgId: string,
  bulletinId: string,
  data: BulletinData,
  reason: RemovalReason,
  removedBy: string | null,
  feedCopiesAffected: number,
): Promise<void> {
  await db
    .collection('organizations').doc(orgId)
    .collection('notification_history')
    .add({
      organizationId: orgId,
      sourceType: 'bulletin',
      sourceId: bulletinId,
      bulletinId,
      title: data.title ?? '',
      body: data.body ?? '',
      type: 'bulletin',
      createdBy: data.authorId ?? null,
      createdByName: data.authorName ?? null,
      publishedAt: data.publishedAt ?? data.deliveredAt ?? null,
      expiresAt: data.expiresAt ?? null,
      removedAt: admin.firestore.FieldValue.serverTimestamp(),
      removalReason: reason,
      removedBy,
      feedCopiesAffected,
    });
}

async function archiveAndRemoveBulletin(
  orgId: string,
  bulletinId: string,
  reason: RemovalReason,
  removedBy: string | null,
): Promise<{ deletedNotifications: number }> {
  const bulletinRef = db
    .collection('organizations').doc(orgId)
    .collection('bulletins').doc(bulletinId);
  const snap = await bulletinRef.get();
  const data = (snap.data() ?? {}) as BulletinData;

  const toDelete = await getFeedCopiesForBulletin(orgId, bulletinId);

  if (snap.exists) {
    await writeBulletinHistory(
      orgId,
      bulletinId,
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
    await bulletinRef.delete();
  }

  return { deletedNotifications };
}

async function markUserBulletinNotificationsRead(
  orgId: string,
  uid: string,
  bulletinId: string,
): Promise<void> {
  try {
    const snap = await db
      .collection('organizations').doc(orgId)
      .collection('users').doc(uid)
      .collection('notifications')
      .where('data.bulletinId', '==', bulletinId)
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
    logger.warn('markUserBulletinNotificationsRead failed', {
      orgId,
      uid,
      bulletinId,
      err,
    });
  }
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
    if (data.scheduledAt && data.scheduledAt.toMillis() > Date.now()) {
      return null;
    }

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

  const responseConfig = claimed.responseConfig;
  const responseRequired =
    responseConfig?.enabled === true &&
    responseConfig?.responseRequired === true;
  const notificationData: Record<string, unknown> = { bulletinId };
  if (responseRequired) {
    notificationData.responseRequired = true;
  }

  const notification: Record<string, unknown> = {
    type: 'bulletin',
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

async function assertCanManageBulletin(
  orgId: string,
  data: BulletinData,
  uid: string,
  tokenIsAdmin: boolean,
): Promise<void> {
  if (data.authorId === uid) return;
  if (tokenIsAdmin) return;

  const userSnap = await db
    .collection('organizations').doc(orgId)
    .collection('users').doc(uid)
    .get();
  const role = userSnap.data()?.['role'] as string | undefined;
  const isProfileAdmin =
    role === 'admin' || role === 'super_admin' || role === 'owner';
  if (isProfileAdmin) return;

  throw new HttpsError(
    'permission-denied',
    'You do not have permission to manage this announcement.',
  );
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
    scheduledAt,
    responseConfig,
  } = (request.data ?? {}) as {
    orgId?: string;
    title?: string;
    body?: string;
    groupId?: string;
    groupLabel?: string;
    expiresAt?: string;
    scheduledAt?: string;
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

/**
 * Validates and stores a recipient's response to a published announcement.
 */
export const submitBulletinResponse = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const { orgId, bulletinId, text, selectedOptionIds, selectedOptionId } =
    (request.data ?? {}) as {
      orgId?: string;
      bulletinId?: string;
      text?: string;
      selectedOptionIds?: string[];
      selectedOptionId?: string;
    };
  if (!orgId || !bulletinId) {
    throw new HttpsError(
      'invalid-argument',
      'orgId and bulletinId are required.',
    );
  }

  const uid = request.auth.uid;
  const bulletinRef = db
    .collection('organizations').doc(orgId)
    .collection('bulletins').doc(bulletinId);
  const bulletinSnap = await bulletinRef.get();
  if (!bulletinSnap.exists) {
    throw new HttpsError('not-found', 'Announcement not found.');
  }

  const bulletin = bulletinSnap.data() as BulletinData;
  if (bulletin.status !== 'published') {
    throw new HttpsError(
      'failed-precondition',
      'This announcement is not accepting responses.',
    );
  }
  if (bulletin.expiresAt && bulletin.expiresAt.toMillis() <= Date.now()) {
    throw new HttpsError(
      'failed-precondition',
      'This announcement has expired.',
    );
  }

  const config = bulletin.responseConfig;
  if (!config?.enabled) {
    throw new HttpsError(
      'failed-precondition',
      'This announcement does not accept responses.',
    );
  }

  const allowResponseUpdates = config.allowResponseUpdates !== false;
  const existingResponseSnap = await bulletinRef
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
    bulletinId,
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

  await bulletinRef.collection('responses').doc(uid).set(payload, { merge: true });
  await markUserBulletinNotificationsRead(orgId, uid, bulletinId);

  logger.info('submitBulletinResponse completed', { orgId, bulletinId, uid });
  return { ok: true, bulletinId };
});

/**
 * Sets or clears the image URL on a bulletin (author or org admin).
 */
export const setBulletinImageUrl = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const { orgId, bulletinId, imageUrl, clearImageUrl } =
    (request.data ?? {}) as {
      orgId?: string;
      bulletinId?: string;
      imageUrl?: string;
      clearImageUrl?: boolean;
    };
  if (!orgId || !bulletinId) {
    throw new HttpsError(
      'invalid-argument',
      'orgId and bulletinId are required.',
    );
  }

  const uid = request.auth.uid;
  const token = request.auth.token as Record<string, unknown>;
  const role = token['role'] as string | undefined;
  const isAdmin =
    role === 'admin' || role === 'super_admin' || role === 'owner';

  const bulletinRef = db
    .collection('organizations').doc(orgId)
    .collection('bulletins').doc(bulletinId);
  const snap = await bulletinRef.get();
  if (!snap.exists) {
    throw new HttpsError('not-found', 'Announcement not found.');
  }

  const data = snap.data() as BulletinData;
  await assertCanManageBulletin(orgId, data, uid, isAdmin);

  const bulletinUpdate: Record<string, unknown> = {
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  if (clearImageUrl === true) {
    bulletinUpdate.imageUrl = admin.firestore.FieldValue.delete();
  } else {
    const trimmed = (imageUrl ?? '').trim();
    if (!trimmed) {
      throw new HttpsError('invalid-argument', 'imageUrl is required.');
    }
    bulletinUpdate.imageUrl = trimmed;
  }

  await bulletinRef.update(bulletinUpdate);

  logger.info('setBulletinImageUrl completed', { orgId, bulletinId, by: uid });
  return { ok: true, bulletinId };
});

/**
 * Updates an announcement's title/body and propagates to feed copies.
 */
export const updateBulletin = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const {
    orgId,
    bulletinId,
    title,
    body,
    expiresAt,
    clearExpiresAt,
    imageUrl,
    clearImageUrl,
    responseConfig,
    clearResponseConfig,
  } =
    (request.data ?? {}) as {
      orgId?: string;
      bulletinId?: string;
      title?: string;
      body?: string;
      expiresAt?: number;
      clearExpiresAt?: boolean;
      imageUrl?: string;
      clearImageUrl?: boolean;
      responseConfig?: ResponseConfig;
      clearResponseConfig?: boolean;
    };
  if (!orgId || !bulletinId) {
    throw new HttpsError(
      'invalid-argument',
      'orgId and bulletinId are required.',
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

  const bulletinRef = db
    .collection('organizations').doc(orgId)
    .collection('bulletins').doc(bulletinId);
  const snap = await bulletinRef.get();
  if (!snap.exists) {
    throw new HttpsError('not-found', 'Announcement not found.');
  }

  const data = snap.data() as BulletinData;
  await assertCanManageBulletin(orgId, data, uid, isAdmin);

  const bulletinUpdate: Record<string, unknown> = {
    title: trimmedTitle,
    body: trimmedBody,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
  if (clearExpiresAt) {
    bulletinUpdate.expiresAt = admin.firestore.FieldValue.delete();
  } else if (typeof expiresAt === 'number' && expiresAt > 0) {
    bulletinUpdate.expiresAt = admin.firestore.Timestamp.fromMillis(expiresAt);
  }
  if (clearImageUrl) {
    bulletinUpdate.imageUrl = admin.firestore.FieldValue.delete();
  } else if (typeof imageUrl === 'string' && imageUrl.trim()) {
    bulletinUpdate.imageUrl = imageUrl.trim();
  }
  if (clearResponseConfig === true) {
    bulletinUpdate.responseConfig = admin.firestore.FieldValue.delete();
  } else if (responseConfig?.enabled) {
    bulletinUpdate.responseConfig = responseConfig;
  }

  await bulletinRef.update(bulletinUpdate);

  let updatedNotifications = 0;
  try {
    const toUpdate = await getFeedCopiesForBulletin(orgId, bulletinId);
    const feedUpdate: Record<string, unknown> = {
      title: trimmedTitle,
      body: trimmedBody,
    };
    if (clearExpiresAt) {
      feedUpdate.expiresAt = admin.firestore.FieldValue.delete();
    } else if (typeof expiresAt === 'number' && expiresAt > 0) {
      feedUpdate.expiresAt = admin.firestore.Timestamp.fromMillis(expiresAt);
    }

    for (let i = 0; i < toUpdate.length; i += 450) {
      const batch = db.batch();
      const slice = toUpdate.slice(i, i + 450);
      for (const d of slice) {
        batch.update(d.ref, feedUpdate);
      }
      await batch.commit();
      updatedNotifications += slice.length;
    }
  } catch (err) {
    logger.warn('updateBulletin: feed sync skipped', {
      orgId,
      bulletinId,
      err: err instanceof Error ? err.message : String(err),
    });
  }

  logger.info('updateBulletin completed', {
    orgId,
    bulletinId,
    updatedNotifications,
    by: uid,
  });

  return { ok: true, updatedNotifications };
});

/**
 * Deletes an announcement and removes all delivered feed copies.
 */
export const deleteBulletin = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const { orgId, bulletinId } = (request.data ?? {}) as {
    orgId?: string;
    bulletinId?: string;
  };
  if (!orgId || !bulletinId) {
    throw new HttpsError(
      'invalid-argument',
      'orgId and bulletinId are required.',
    );
  }

  const uid = request.auth.uid;
  const token = request.auth.token as Record<string, unknown>;
  const role = token['role'] as string | undefined;
  const isAdmin =
    role === 'admin' || role === 'super_admin' || role === 'owner';

  const bulletinRef = db
    .collection('organizations').doc(orgId)
    .collection('bulletins').doc(bulletinId);
  const snap = await bulletinRef.get();
  if (!snap.exists) {
    throw new HttpsError('not-found', 'Announcement not found.');
  }

  const data = snap.data() as BulletinData;
  await assertCanManageBulletin(orgId, data, uid, isAdmin);

  const { deletedNotifications } = await archiveAndRemoveBulletin(
    orgId,
    bulletinId,
    'recalled',
    uid,
  );

  logger.info('deleteBulletin completed', {
    orgId,
    bulletinId,
    deletedNotifications,
    by: uid,
  });

  return { ok: true, deletedNotifications };
});

export const onBulletinPublished = onDocumentWritten(
  'organizations/{orgId}/bulletins/{bulletinId}',
  async (event) => {
    const after = event.data?.after.data() as BulletinData | undefined;
    if (!after) return;

    if (after.status !== 'published') return;
    if (after.deliveredAt) return;
    if (after.scheduledAt && after.scheduledAt.toMillis() > Date.now()) {
      return;
    }

    const { orgId, bulletinId } = event.params;
    await deliverBulletin(orgId, bulletinId);
  },
);

/**
 * Runs every 5 minutes and delivers published announcements whose
 * scheduledAt time has arrived but which have not yet been delivered.
 */
export const publishDueBulletins = onSchedule('every 5 minutes', async () => {
  const now = admin.firestore.Timestamp.now();
  const dueSnap = await db
    .collectionGroup('bulletins')
    .where('status', '==', 'published')
    .where('scheduledAt', '<=', now)
    .get();

  let delivered = 0;
  for (const doc of dueSnap.docs) {
    const data = doc.data() as BulletinData;
    if (data.deliveredAt) continue;

    const orgDoc = doc.ref.parent.parent;
    if (!orgDoc) continue;
    const ok = await deliverBulletin(orgDoc.id, doc.id);
    if (ok) delivered++;
  }

  logger.info('publishDueBulletins completed', {
    candidates: dueSnap.size,
    delivered,
  });
});
