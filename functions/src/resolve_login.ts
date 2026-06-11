import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import {
  normalizeContactEmail,
  normalizeStudentIdForAuth,
  studentAuthEmail,
  STUDENT_AUTH_EMAIL_DOMAIN,
} from './student_auth';

const db = admin.firestore();

/** Looks up a student ID from profile or roster contact email. */
async function findStudentIdByContactEmail(
  orgId: string,
  email: string,
): Promise<string | null> {
  const trimmed = email.trim();
  const lower = normalizeContactEmail(trimmed);
  const candidates = [...new Set([trimmed, lower])];

  for (const candidate of candidates) {
    const byProfile = await db
      .collection('organizations')
      .doc(orgId)
      .collection('users')
      .where('email', '==', candidate)
      .limit(1)
      .get();

    if (!byProfile.empty) {
      const studentId = byProfile.docs[0].data()['studentId'] as
        | string
        | undefined;
      if (studentId?.trim()) {
        return studentId.trim();
      }
    }
  }

  for (const candidate of candidates) {
    const byRoster = await db
      .collection('organizations')
      .doc(orgId)
      .collection('roster')
      .where('email', '==', candidate)
      .limit(1)
      .get();

    if (!byRoster.empty) {
      const data = byRoster.docs[0].data();
      const studentId =
        (data['studentId'] as string | undefined)?.trim() ||
        byRoster.docs[0].id;
      if (studentId) {
        return studentId;
      }
    }
  }

  return null;
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

  // Already a Firebase Auth email (including synthetic student accounts).
  if (lower.includes('@')) {
    if (
      lower.endsWith(STUDENT_AUTH_EMAIL_DOMAIN) ||
      lower.includes(`.${STUDENT_AUTH_EMAIL_DOMAIN}`)
    ) {
      return { email: lower };
    }

    const studentId = await findStudentIdByContactEmail(trimmedOrg, trimmed);
    if (studentId) {
      return { email: studentAuthEmail(trimmedOrg, studentId) };
    }

    // Real email/password account (not student-ID provisioned).
    return { email: trimmed };
  }

  // School-issued student ID (username).
  const rosterRef = db
    .collection('organizations')
    .doc(trimmedOrg)
    .collection('roster')
    .doc(trimmed);

  const rosterSnap = await rosterRef.get();
  if (rosterSnap.exists) {
    return { email: studentAuthEmail(trimmedOrg, trimmed) };
  }

  // Fallback: normalized synthetic email (handles casing / minor formatting).
  void normalizeStudentIdForAuth;
  return { email: studentAuthEmail(trimmedOrg, trimmed) };
});
