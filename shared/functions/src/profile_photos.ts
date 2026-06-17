import { randomUUID } from 'crypto';

import { onCall, HttpsError } from 'firebase-functions/v2/https';

import { logger } from 'firebase-functions';

import * as admin from 'firebase-admin';

import { assertOrgAdminCaller } from './update_org_member';



const db = admin.firestore();



const MAX_AVATAR_BYTES = 5 * 1024 * 1024;

const ALLOWED_IMAGE_TYPES = new Set([

  'image/jpeg',

  'image/png',

  'image/webp',

  'image/gif',

]);



async function resolveUserPermissions(

  orgId: string,

  userId: string,

): Promise<string[]> {

  const assignmentsSnap = await db

    .collection('organizations')

    .doc(orgId)

    .collection('users')

    .doc(userId)

    .collection('roleAssignments')

    .get();



  if (assignmentsSnap.empty) return [];



  const roleIds = [

    ...new Set(

      assignmentsSnap.docs

        .map((d) => d.data()['roleId'] as string | undefined)

        .filter((id): id is string => Boolean(id)),

    ),

  ];



  const rolesRef = db.collection('organizations').doc(orgId).collection('roles');

  const roleSnaps = await Promise.all(roleIds.map((id) => rolesRef.doc(id).get()));

  const permissions = new Set<string>();



  for (const snap of roleSnaps) {

    if (!snap.exists) continue;

    for (const cap of (snap.data()?.['capabilities'] as string[] | undefined) ??

      []) {

      if (cap) permissions.add(cap);

    }

  }



  return Array.from(permissions);

}



async function assertCanManageOfficialPhotos(

  uid: string,

  orgId: string,

  token: Record<string, unknown>,

): Promise<void> {

  try {

    await assertOrgAdminCaller(uid, orgId, token);

    return;

  } catch {

    // Fall through to delegated permissions.

  }



  const claimed = (token['permissions'] as string[] | undefined) ?? [];

  if (

    claimed.includes('manageClassRoster') ||

    claimed.includes('blockUsers')

  ) {

    return;

  }



  const resolved = await resolveUserPermissions(orgId, uid);

  if (

    resolved.includes('manageClassRoster') ||

    resolved.includes('blockUsers')

  ) {

    return;

  }



  throw new HttpsError(

    'permission-denied',

    'Only roster or member managers can update official photos.',

  );

}



function applyPhotoUrlUpdate(

  clear: boolean,

  imageUrl: string | undefined,

): Record<string, unknown> {

  const update: Record<string, unknown> = {

    updatedAt: admin.firestore.FieldValue.serverTimestamp(),

  };

  if (clear) {

    update.officialPhotoUrl = admin.firestore.FieldValue.delete();

  } else {

    const trimmed = (imageUrl ?? '').trim();

    if (!trimmed) {

      throw new HttpsError('invalid-argument', 'imageUrl is required.');

    }

    update.officialPhotoUrl = trimmed;

  }

  return update;

}



function extensionForContentType(contentType: string): string {

  switch (contentType) {

    case 'image/png':

      return 'png';

    case 'image/webp':

      return 'webp';

    case 'image/gif':

      return 'gif';

    default:

      return 'jpg';

  }

}



function buildStorageDownloadUrl(

  bucketName: string,

  storagePath: string,

  downloadToken: string,

): string {

  return `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodeURIComponent(storagePath)}?alt=media&token=${downloadToken}`;

}



/**

 * Validates that the signed-in user may update their personal avatar in [orgId].

 * Profile doc path is authoritative; organizationId field may be absent on legacy rows.

 */

async function assertMemberAvatarUploadAllowed(

  uid: string,

  orgId: string,

): Promise<admin.firestore.DocumentReference> {

  const userRef = db

    .collection('organizations')

    .doc(orgId)

    .collection('users')

    .doc(uid);

  const snap = await userRef.get();

  if (!snap.exists) {

    throw new HttpsError('not-found', 'Profile not found.');

  }



  const profile = snap.data() ?? {};

  const profileOrgId = profile['organizationId'] as string | undefined;

  if (profileOrgId && profileOrgId !== orgId) {

    throw new HttpsError(

      'permission-denied',

      'Profile does not belong to this organization.',

    );

  }

  if (profile['approvalStatus'] !== 'approved') {

    throw new HttpsError(

      'permission-denied',

      'Only approved members can update profile photos.',

    );

  }



  const orgSnap = await db.collection('organizations').doc(orgId).get();

  if (orgSnap.data()?.['allowMemberProfilePhotos'] !== true) {

    throw new HttpsError(

      'permission-denied',

      'Personal profile photos are disabled. Ask an administrator to enable '

        + '“Allow personal profile photos” under Organization Settings.',

    );

  }



  return userRef;

}



/**

 * Uploads a member personal badge via Admin SDK (bypasses client Storage rules

 * and App Check) and writes avatarUrl on the profile.

 */

export const uploadMemberAvatar = onCall(async (request) => {

  if (!request.auth) {

    throw new HttpsError('unauthenticated', 'Sign in required.');

  }



  const { orgId, imageBase64, contentType } = (request.data ?? {}) as {

    orgId?: string;

    imageBase64?: string;

    contentType?: string;

  };

  if (!orgId) {

    throw new HttpsError('invalid-argument', 'orgId is required.');

  }

  if (!imageBase64?.trim()) {

    throw new HttpsError('invalid-argument', 'imageBase64 is required.');

  }



  let buffer: Buffer;

  try {

    buffer = Buffer.from(imageBase64, 'base64');

  } catch {

    throw new HttpsError('invalid-argument', 'imageBase64 is not valid base64.');

  }

  if (buffer.length === 0) {

    throw new HttpsError('invalid-argument', 'Image data is empty.');

  }

  if (buffer.length > MAX_AVATAR_BYTES) {

    throw new HttpsError(

      'invalid-argument',

      'Image is too large. Use a photo under 5 MB.',

    );

  }



  const normalizedType = (contentType ?? 'image/jpeg').trim().toLowerCase();

  const resolvedType = ALLOWED_IMAGE_TYPES.has(normalizedType)

    ? normalizedType

    : 'image/jpeg';



  const uid = request.auth.uid;

  const userRef = await assertMemberAvatarUploadAllowed(uid, orgId);



  const ext = extensionForContentType(resolvedType);

  const fileName = `${Date.now()}_${randomUUID().slice(0, 8)}.${ext}`;

  const storagePath = `organizations/${orgId}/users/${uid}/avatar/${fileName}`;

  const downloadToken = randomUUID();

  const bucket = admin.storage().bucket();



  await bucket.file(storagePath).save(buffer, {

    metadata: {

      contentType: resolvedType,

      metadata: {

        firebaseStorageDownloadTokens: downloadToken,

      },

    },

  });



  const imageUrl = buildStorageDownloadUrl(

    bucket.name,

    storagePath,

    downloadToken,

  );



  await userRef.update({

    avatarUrl: imageUrl,

    updatedAt: admin.firestore.FieldValue.serverTimestamp(),

  });



  logger.info('uploadMemberAvatar completed', { orgId, uid, storagePath });

  return { ok: true, imageUrl };

});



/**

 * Sets or clears the signed-in member's personal profile badge URL.

 */

export const setMemberAvatarUrl = onCall(async (request) => {

  if (!request.auth) {

    throw new HttpsError('unauthenticated', 'Sign in required.');

  }



  const { orgId, imageUrl, clearImageUrl } = (request.data ?? {}) as {

    orgId?: string;

    imageUrl?: string;

    clearImageUrl?: boolean;

  };

  if (!orgId) {

    throw new HttpsError('invalid-argument', 'orgId is required.');

  }



  const uid = request.auth.uid;

  const userRef = await assertMemberAvatarUploadAllowed(uid, orgId);



  const update: Record<string, unknown> = {

    updatedAt: admin.firestore.FieldValue.serverTimestamp(),

  };

  if (clearImageUrl === true) {

    update.avatarUrl = admin.firestore.FieldValue.delete();

  } else {

    const trimmed = (imageUrl ?? '').trim();

    if (!trimmed) {

      throw new HttpsError('invalid-argument', 'imageUrl is required.');

    }

    update.avatarUrl = trimmed;

  }



  await userRef.update(update);

  logger.info('setMemberAvatarUrl completed', { orgId, uid });

  return { ok: true };

});



/**

 * Sets or clears a student's official school photo on roster and linked profile.

 */

export const setOfficialPhotoUrl = onCall(async (request) => {

  if (!request.auth) {

    throw new HttpsError('unauthenticated', 'Sign in required.');

  }



  const { orgId, studentId, userId, imageUrl, clearImageUrl } =

    (request.data ?? {}) as {

      orgId?: string;

      studentId?: string;

      userId?: string;

      imageUrl?: string;

      clearImageUrl?: boolean;

    };



  if (!orgId) {

    throw new HttpsError('invalid-argument', 'orgId is required.');

  }

  if (!studentId && !userId) {

    throw new HttpsError(

      'invalid-argument',

      'studentId or userId is required.',

    );

  }



  const uid = request.auth.uid;

  const token = request.auth.token as Record<string, unknown>;

  await assertCanManageOfficialPhotos(uid, orgId, token);



  const clear = clearImageUrl === true;

  const photoUpdate = applyPhotoUrlUpdate(clear, imageUrl);



  let resolvedStudentId = studentId?.trim();

  let resolvedUserId = userId?.trim();



  if (resolvedStudentId) {

    const rosterRef = db

      .collection('organizations')

      .doc(orgId)

      .collection('roster')

      .doc(resolvedStudentId);

    const rosterSnap = await rosterRef.get();

    if (rosterSnap.exists) {

      await rosterRef.set(photoUpdate, { merge: true });

      const registered = rosterSnap.data()?.['registeredUserId'] as

        | string

        | undefined;

      if (registered && !resolvedUserId) {

        resolvedUserId = registered;

      }

    } else if (!resolvedUserId) {

      throw new HttpsError('not-found', 'Roster student not found.');

    }

  }



  if (!resolvedStudentId && resolvedUserId) {

    const profileSnap = await db

      .collection('organizations')

      .doc(orgId)

      .collection('users')

      .doc(resolvedUserId)

      .get();

    if (!profileSnap.exists) {

      throw new HttpsError('not-found', 'Member profile not found.');

    }

    resolvedStudentId = profileSnap.data()?.['studentId'] as string | undefined;

  }



  if (resolvedUserId) {

    await db

      .collection('organizations')

      .doc(orgId)

      .collection('users')

      .doc(resolvedUserId)

      .update(photoUpdate);

  }



  if (resolvedStudentId && !studentId) {

    const rosterRef = db

      .collection('organizations')

      .doc(orgId)

      .collection('roster')

      .doc(resolvedStudentId);

    if ((await rosterRef.get()).exists) {

      await rosterRef.set(photoUpdate, { merge: true });

    }

  }



  logger.info('setOfficialPhotoUrl completed', {

    orgId,

    studentId: resolvedStudentId,

    userId: resolvedUserId,

    by: uid,

  });

  return { ok: true };

});


