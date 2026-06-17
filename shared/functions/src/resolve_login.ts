import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions';
import * as admin from 'firebase-admin';
import {
  normalizeContactEmail,
  studentAuthEmail,
  STUDENT_AUTH_EMAIL_DOMAIN,
} from './student_auth';

const db = admin.firestore();

/** School-issued IDs must not look like contact emails. */
function isValidStudentId(studentId: string): boolean {
  const trimmed = studentId.trim();
  return trimmed.length > 0 && !trimmed.includes('@');
}

async function authEmailForUserId(userId: string): Promise<string | null> {
  try {
    const user = await admin.auth().getUser(userId);
    return user.email ?? null;
  } catch {
    return null;
  }
}

/**
 * Returns the Firebase Auth email for a registered member, if known.
 * Tries exact contact-email matches first (self-registered accounts).
 */
async function authEmailForContactEmail(email: string): Promise<string | null> {
  const trimmed = email.trim();
  const candidates = [...new Set([trimmed, normalizeContactEmail(trimmed)])];

  for (const candidate of candidates) {
    try {
      const user = await admin.auth().getUserByEmail(candidate);
      if (user.email) {
        return user.email;
      }
    } catch (err) {
      const code = (err as { code?: string }).code;
      if (code !== 'auth/user-not-found') {
        logger.warn('resolveLoginEmail: getUserByEmail failed', {
          candidate,
          err,
        });
      }
    }
  }

  return null;
}

/**
 * Looks up a roster student ID from a contact email.
 * Roster is authoritative; staff/admin profiles are ignored.
 */
async function findStudentIdByContactEmail(
  orgId: string,
  email: string,
): Promise<string | null> {
  const trimmed = email.trim();
  const lower = normalizeContactEmail(trimmed);
  const candidates = [...new Set([trimmed, lower])];

  for (const candidate of candidates) {
    const byRoster = await db
      .collection('organizations')
      .doc(orgId)
      .collection('roster')
      .where('email', '==', candidate)
      .limit(1)
      .get();

    if (!byRoster.empty) {
      const rosterId = byRoster.docs[0].id;
      if (isValidStudentId(rosterId)) {
        return rosterId;
      }
    }
  }

  for (const candidate of candidates) {
    const byProfile = await db
      .collection('organizations')
      .doc(orgId)
      .collection('users')
      .where('email', '==', candidate)
      .limit(1)
      .get();

    if (byProfile.empty) continue;

    const data = byProfile.docs[0].data();
    const role = (data['role'] as string | undefined) ?? 'user';
    if (role !== 'user') {
      continue;
    }

    const studentId = (data['studentId'] as string | undefined)?.trim();
    if (!studentId || !isValidStudentId(studentId)) {
      continue;
    }

    const rosterSnap = await db
      .collection('organizations')
      .doc(orgId)
      .collection('roster')
      .doc(studentId)
      .get();
    if (rosterSnap.exists) {
      return studentId;
    }
  }

  return null;
}

/** Finds a registered Firebase Auth UID for a school-issued student ID. */
async function findRegisteredUserIdByStudentId(
  orgId: string,
  studentId: string,
): Promise<string | null> {
  const trimmed = studentId.trim();

  const rosterSnap = await db
    .collection('organizations')
    .doc(orgId)
    .collection('roster')
    .doc(trimmed)
    .get();

  if (rosterSnap.exists) {
    const registered = rosterSnap.data()?.['registeredUserId'] as
      | string
      | undefined;
    if (registered) {
      return registered;
    }
  }

  const byStudentIdField = await db
    .collection('organizations')
    .doc(orgId)
    .collection('roster')
    .where('studentId', '==', trimmed)
    .limit(1)
    .get();

  if (!byStudentIdField.empty) {
    const registered = byStudentIdField.docs[0].data()['registeredUserId'] as
      | string
      | undefined;
    if (registered) {
      return registered;
    }
  }

  const byProfile = await db
    .collection('organizations')
    .doc(orgId)
    .collection('users')
    .where('studentId', '==', trimmed)
    .limit(1)
    .get();

  if (!byProfile.empty) {
    const data = byProfile.docs[0].data();
    const role = (data['role'] as string | undefined) ?? 'user';
    if (role === 'user') {
      return byProfile.docs[0].id;
    }
  }

  return null;
}

/**
 * Maps a student ID to the Firebase Auth email on the registered account,
 * or the synthetic student email when no account exists yet.
 */
async function resolveAuthEmailForStudentId(
  orgId: string,
  studentId: string,
): Promise<string> {
  const uid = await findRegisteredUserIdByStudentId(orgId, studentId);
  if (uid) {
    const email = await authEmailForUserId(uid);
    if (email) {
      return email;
    }
  }
  return studentAuthEmail(orgId, studentId);
}

/**
 * Maps a user-facing login identifier (email or school student ID) to the
 * Firebase Auth email used for email/password sign-in.
 *
 * Unauthenticated — used only to prepare sign-in; invalid credentials are
 * still rejected by Firebase Auth.
 */
export const resolveLoginEmail = onCall(async (request) => {
  const { orgId, identifier } = (request.data ?? {}) as {
    orgId?: string;
    identifier?: string;
  };

  if (!orgId?.trim()) {
    throw new HttpsError('invalid-argument', 'orgId is required.');
  }
  if (!identifier?.trim()) {
    throw new HttpsError('invalid-argument', 'identifier is required.');
  }

  const trimmedOrg = orgId.trim();
  const trimmed = identifier.trim();
  const lower = trimmed.toLowerCase();

  if (lower.includes('@')) {
    if (
      lower.endsWith(STUDENT_AUTH_EMAIL_DOMAIN) ||
      lower.includes(`.${STUDENT_AUTH_EMAIL_DOMAIN}`)
    ) {
      return { email: lower };
    }

    // Self-registered members and staff use their real Firebase Auth email.
    const existingAuthEmail = await authEmailForContactEmail(trimmed);
    if (existingAuthEmail) {
      return { email: existingAuthEmail };
    }

    const studentId = await findStudentIdByContactEmail(trimmedOrg, trimmed);
    if (studentId) {
      return {
        email: await resolveAuthEmailForStudentId(trimmedOrg, studentId),
      };
    }

    return { email: trimmed };
  }

  return {
    email: await resolveAuthEmailForStudentId(trimmedOrg, trimmed),
  };
});
