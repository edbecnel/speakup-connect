import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import {
  normalizeContactEmail,
  normalizeStudentIdForAuth,
  studentAuthEmail,
  STUDENT_AUTH_EMAIL_DOMAIN,
} from './student_auth';

const db = admin.firestore();

/** School-issued IDs must not look like contact emails. */
function isValidStudentId(studentId: string): boolean {
  const trimmed = studentId.trim();
  return trimmed.length > 0 && !trimmed.includes('@');
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

  // Roster contact email → roster document ID is the canonical student ID.
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

  // Registered student profile — never map staff/admin contact emails.
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

    // Real email/password account (admin, self-registered, etc.).
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
