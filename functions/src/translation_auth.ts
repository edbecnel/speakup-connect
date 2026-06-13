import { CallableRequest, HttpsError } from 'firebase-functions/v2/https';

/** Platform operators only — not org admins. */
export function assertPlatformSuperAdmin(request: CallableRequest): string {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }
  const uid = request.auth.uid;
  const role = request.auth.token['role'] as string | undefined;
  if (role !== 'super_admin') {
    throw new HttpsError(
      'permission-denied',
      'Translation Helper requires platform super_admin access.',
    );
  }
  return uid;
}
