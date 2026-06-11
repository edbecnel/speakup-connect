import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions';
import * as admin from 'firebase-admin';
import {
  assertStudentPasswordLength,
  normalizeContactEmail,
  studentAuthEmail,
  STUDENT_AUTH_EMAIL_DOMAIN,
} from './student_auth';

const db = admin.firestore();

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
    .collection('organizations')
    .doc(orgId)
    .collection('users')
    .doc(uid)
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
    'Only organization admins can update member profiles.',
  );
}

function isSyntheticStudentAuthEmail(email: string | undefined): boolean {
  return !!email && email.includes(STUDENT_AUTH_EMAIL_DOMAIN);
}

/**
 * Updates an org member's profile, roster row, and (when applicable) Firebase Auth.
 * Org admin only. Does not modify role or permissions.
 */
export const updateOrgMember = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const { orgId, userId, updates } = (request.data ?? {}) as {
    orgId?: string;
    userId?: string;
    updates?: {
      fullName?: string;
      studentId?: string | null;
      email?: string | null;
      gradeLevel?: number | null;
    };
  };

  if (!orgId || !userId) {
    throw new HttpsError('invalid-argument', 'orgId and userId are required.');
  }
  if (!updates || typeof updates !== 'object') {
    throw new HttpsError('invalid-argument', 'updates object is required.');
  }

  const actorUid = request.auth.uid;
  const token = request.auth.token as Record<string, unknown>;
  await assertOrgAdminCaller(actorUid, orgId, token);

  const userRef = db
    .collection('organizations')
    .doc(orgId)
    .collection('users')
    .doc(userId);
  const profileSnap = await userRef.get();
  if (!profileSnap.exists) {
    throw new HttpsError('not-found', 'Member profile not found.');
  }

  const profile = profileSnap.data() ?? {};
  const oldStudentId = (profile['studentId'] as string | undefined)?.trim() ?? '';
  const now = admin.firestore.FieldValue.serverTimestamp();
  const profileUpdate: Record<string, unknown> = { updatedAt: now };
  const authUpdate: admin.auth.UpdateRequest = {};

  if (updates.fullName !== undefined) {
    const trimmedName = (updates.fullName ?? '').trim();
    if (!trimmedName) {
      throw new HttpsError('invalid-argument', 'Full name cannot be empty.');
    }
    profileUpdate['fullName'] = trimmedName;
    profileUpdate['displayName'] = trimmedName;
    authUpdate.displayName = trimmedName;
  }

  if (updates.gradeLevel !== undefined) {
    if (updates.gradeLevel != null && updates.gradeLevel <= 0) {
      throw new HttpsError('invalid-argument', 'Invalid grade level.');
    }
    if (updates.gradeLevel == null) {
      profileUpdate['gradeLevel'] = admin.firestore.FieldValue.delete();
    } else {
      profileUpdate['gradeLevel'] = updates.gradeLevel;
    }
  }

  if (updates.email !== undefined) {
    const trimmedEmail = (updates.email ?? '').trim();
    if (trimmedEmail && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(trimmedEmail)) {
      throw new HttpsError('invalid-argument', 'Invalid email address.');
    }
    if (trimmedEmail) {
      profileUpdate['email'] = normalizeContactEmail(trimmedEmail);
    } else {
      profileUpdate['email'] = admin.firestore.FieldValue.delete();
    }
  }

  let newStudentId = oldStudentId;
  if (updates.studentId !== undefined) {
    const trimmedId = (updates.studentId ?? '').trim();
    if (trimmedId) {
      try {
        assertStudentPasswordLength(trimmedId);
      } catch (err) {
        throw new HttpsError(
          'invalid-argument',
          err instanceof Error ? err.message : 'Invalid student ID.',
        );
      }
      if (!/^[a-zA-Z0-9-]+$/.test(trimmedId)) {
        throw new HttpsError(
          'invalid-argument',
          'Student ID may only contain letters, numbers, and hyphens.',
        );
      }
      newStudentId = trimmedId;
      profileUpdate['studentId'] = trimmedId;
    } else {
      profileUpdate['studentId'] = admin.firestore.FieldValue.delete();
      newStudentId = '';
    }
  }

  const batch = db.batch();
  let rosterEmail: string | undefined;
  let rosterFullName: string | undefined;
  let rosterGrade: string | undefined;

  if (updates.email !== undefined) {
    const trimmedEmail = (updates.email ?? '').trim();
    rosterEmail = trimmedEmail ? normalizeContactEmail(trimmedEmail) : undefined;
  }
  if (updates.fullName !== undefined) {
    rosterFullName = (updates.fullName ?? '').trim();
  }
  if (updates.gradeLevel !== undefined && updates.gradeLevel != null) {
    rosterGrade = `Grade ${updates.gradeLevel}`;
  }

  // Student ID change: migrate roster doc + synthetic Auth email.
  if (
    updates.studentId !== undefined &&
    newStudentId !== oldStudentId &&
    newStudentId
  ) {
    const newRosterRef = db
      .collection('organizations')
      .doc(orgId)
      .collection('roster')
      .doc(newStudentId);
    const existingNew = await newRosterRef.get();
    const existingUid = existingNew.data()?.['registeredUserId'] as
      | string
      | undefined;
    if (
      existingNew.exists &&
      existingUid &&
      existingUid !== userId
    ) {
      throw new HttpsError(
        'already-exists',
        'Another member already uses this student ID.',
      );
    }

    if (oldStudentId) {
      const oldRosterRef = db
        .collection('organizations')
        .doc(orgId)
        .collection('roster')
        .doc(oldStudentId);
      const oldRosterSnap = await oldRosterRef.get();
      if (oldRosterSnap.exists) {
        const migrated: Record<string, unknown> = {
          ...(oldRosterSnap.data() ?? {}),
          studentId: newStudentId,
          registeredUserId: userId,
          isRegistered: true,
          updatedAt: now,
        };
        if (rosterFullName) migrated['fullName'] = rosterFullName;
        if (rosterEmail !== undefined) {
          migrated['email'] = rosterEmail ?? admin.firestore.FieldValue.delete();
        }
        if (rosterGrade) migrated['grade'] = rosterGrade;
        batch.set(newRosterRef, migrated, { merge: true });
        batch.delete(oldRosterRef);
      } else {
        batch.set(
          newRosterRef,
          {
            studentId: newStudentId,
            fullName:
              rosterFullName ??
              (profile['fullName'] as string | undefined) ??
              'Member',
            grade:
              rosterGrade ??
              (profile['gradeLevel'] != null
                ? `Grade ${profile['gradeLevel']}`
                : 'Grade'),
            isRegistered: true,
            registeredUserId: userId,
            updatedAt: now,
            ...(rosterEmail ? { email: rosterEmail } : {}),
          },
          { merge: true },
        );
      }
    } else {
      batch.set(
        newRosterRef,
        {
          studentId: newStudentId,
          fullName:
            rosterFullName ??
            (profile['fullName'] as string | undefined) ??
            'Member',
          grade:
            rosterGrade ??
            (profile['gradeLevel'] != null
              ? `Grade ${profile['gradeLevel']}`
              : 'Grade'),
          isRegistered: true,
          registeredUserId: userId,
          updatedAt: now,
          ...(rosterEmail ? { email: rosterEmail } : {}),
        },
        { merge: true },
      );
    }

    try {
      const authUser = await admin.auth().getUser(userId);
      if (isSyntheticStudentAuthEmail(authUser.email)) {
        authUpdate.email = studentAuthEmail(orgId, newStudentId);
      }
    } catch (err) {
      logger.warn('updateOrgMember: could not load auth user', { userId, err });
    }
  } else if (oldStudentId) {
    const rosterRef = db
      .collection('organizations')
      .doc(orgId)
      .collection('roster')
      .doc(oldStudentId);
    const rosterUpdate: Record<string, unknown> = { updatedAt: now };
    if (rosterFullName) rosterUpdate['fullName'] = rosterFullName;
    if (rosterEmail !== undefined) {
      rosterUpdate['email'] = rosterEmail ?? admin.firestore.FieldValue.delete();
    }
    if (rosterGrade) rosterUpdate['grade'] = rosterGrade;
    if (Object.keys(rosterUpdate).length > 1) {
      batch.set(rosterRef, rosterUpdate, { merge: true });
    }
  }

  batch.update(userRef, profileUpdate);

  // Keep group roster display names in sync when the name changes.
  if (rosterFullName) {
    const membershipsSnap = await userRef.collection('groupMemberships').get();
    for (const indexDoc of membershipsSnap.docs) {
      const groupId = indexDoc.id;
      const memberRef = db
        .collection('organizations')
        .doc(orgId)
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .doc(userId);
      batch.set(
        memberRef,
        { displayName: rosterFullName, updatedAt: now },
        { merge: true },
      );
    }
  }

  await batch.commit();

  if (Object.keys(authUpdate).length > 0) {
    try {
      await admin.auth().updateUser(userId, authUpdate);
    } catch (err) {
      logger.error('updateOrgMember: auth update failed', { userId, err });
      throw new HttpsError(
        'internal',
        'Profile saved but login email could not be updated. Contact support.',
      );
    }
  }

  logger.info('updateOrgMember completed', {
    orgId,
    userId,
    by: actorUid,
    fields: Object.keys(updates),
  });

  return { ok: true, userId, studentId: newStudentId || null };
});
