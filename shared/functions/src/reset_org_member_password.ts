import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions';
import * as admin from 'firebase-admin';

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
    'Only organization admins can reset member passwords.',
  );
}

function isPrivilegedRole(role: string | undefined): boolean {
  return role === 'admin' || role === 'super_admin' || role === 'owner';
}

/**
 * Sets a new Firebase Auth password for an org member.
 * Org admin only. Cannot reset your own password or another admin's.
 */
export const resetOrgMemberPassword = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const { orgId, userId, newPassword } = (request.data ?? {}) as {
    orgId?: string;
    userId?: string;
    newPassword?: string;
  };

  if (!orgId || !userId) {
    throw new HttpsError('invalid-argument', 'orgId and userId are required.');
  }

  const trimmedPassword = (newPassword ?? '').trim();
  if (!trimmedPassword) {
    throw new HttpsError('invalid-argument', 'newPassword is required.');
  }
  if (trimmedPassword.length < 6) {
    throw new HttpsError(
      'invalid-argument',
      'Password must be at least 6 characters.',
    );
  }

  const actorUid = request.auth.uid;
  if (actorUid === userId) {
    throw new HttpsError(
      'permission-denied',
      'Use account settings to change your own password.',
    );
  }

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
  const targetRole = profile['role'] as string | undefined;
  if (isPrivilegedRole(targetRole)) {
    throw new HttpsError(
      'permission-denied',
      'Cannot reset passwords for admin accounts.',
    );
  }

  try {
    await admin.auth().getUser(userId);
  } catch {
    throw new HttpsError('not-found', 'Login account not found for this member.');
  }

  try {
    await admin.auth().updateUser(userId, { password: trimmedPassword });
  } catch (err) {
    logger.error('resetOrgMemberPassword: auth update failed', {
      userId,
      err,
    });
    throw new HttpsError('internal', 'Could not update password. Try again.');
  }

  const now = admin.firestore.FieldValue.serverTimestamp();
  await userRef.set(
    {
      passwordResetAt: now,
      passwordResetBy: actorUid,
      updatedAt: now,
    },
    { merge: true },
  );

  // TODO(email): When transactional email is enabled, prefer emailing a secure
  // reset link to profile.email (if set) so the member can open a web page or
  // in-app deep link and set/confirm their own password — do not email plaintext
  // passwords long term. See docs/ROADMAP.md → Email notification delivery and
  // docs/MASTER_TASK_LIST.md → Epic 2.3 Roster Management.

  logger.info('resetOrgMemberPassword completed', {
    orgId,
    userId,
    by: actorUid,
  });

  return { ok: true, userId };
});
