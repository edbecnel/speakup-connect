import { CallableRequest, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

const db = admin.firestore();

const DEFAULT_ORG_TRANSLATION_LOCALES = ['ceb', 'fil'];

export interface TranslationAccess {
  uid: string;
  isPlatformSuperAdmin: boolean;
  organizationId: string | null;
  /** `null` means all locales (platform super-admin). */
  allowedLocales: string[] | null;
  canImportSource: boolean;
  canExportArb: boolean;
  canBatchAi: boolean;
}

async function loadUserProfile(orgId: string, uid: string) {
  const snap = await db
    .collection('organizations')
    .doc(orgId)
    .collection('users')
    .doc(uid)
    .get();
  return { snap, data: snap.data() ?? {} };
}

async function isOrgAdmin(orgId: string, uid: string, token: Record<string, unknown>) {
  const role = token['role'] as string | undefined;
  const tokenOrg =
    (token['organizationId'] as string | undefined) ??
    (token['orgId'] as string | undefined);
  if (
    tokenOrg === orgId &&
    (role === 'admin' || role === 'super_admin' || role === 'owner')
  ) {
    return true;
  }
  const { data } = await loadUserProfile(orgId, uid);
  const profileRole = data['role'] as string | undefined;
  return (
    data['organizationId'] === orgId &&
    data['approvalStatus'] === 'approved' &&
    (profileRole === 'admin' ||
      profileRole === 'super_admin' ||
      profileRole === 'owner')
  );
}

function tokenPermissions(token: Record<string, unknown>): string[] {
  return (token['permissions'] as string[] | undefined) ?? [];
}

function profilePermissions(data: Record<string, unknown>): string[] {
  return (data['permissions'] as string[] | undefined) ?? [];
}

async function hasManageTranslationsPermission(
  orgId: string,
  uid: string,
  token: Record<string, unknown>,
): Promise<boolean> {
  if (tokenPermissions(token).includes('manageTranslations')) {
    return true;
  }
  const { data } = await loadUserProfile(orgId, uid);
  return profilePermissions(data).includes('manageTranslations');
}

async function orgTranslationLocales(orgId: string): Promise<string[]> {
  const orgSnap = await db.collection('organizations').doc(orgId).get();
  const raw = orgSnap.data()?.['supportedLanguages'];
  if (Array.isArray(raw) && raw.length > 0) {
    return raw.filter(
      (code): code is string =>
        typeof code === 'string' && code.length > 0 && code !== 'en',
    );
  }
  return [...DEFAULT_ORG_TRANSLATION_LOCALES];
}

function assertLocaleAllowed(access: TranslationAccess, targetLocale?: string) {
  if (!targetLocale || access.allowedLocales === null) {
    return;
  }
  if (!access.allowedLocales.includes(targetLocale)) {
    throw new HttpsError(
      'permission-denied',
      `Locale "${targetLocale}" is not enabled for your organization.`,
    );
  }
}

/**
 * Resolves who may use Translation Helper callables.
 *
 * - Platform `super_admin`: all locales; import/export/batch AI.
 * - Org admin: org `supportedLanguages` (excluding en); export + batch AI.
 * - `manageTranslations` permission: same locale scope; edit + single AI draft.
 */
export async function resolveTranslationAccess(
  request: CallableRequest,
  options?: {
    targetLocale?: string;
    requireImport?: boolean;
    requireExport?: boolean;
    requireBatchAi?: boolean;
  },
): Promise<TranslationAccess> {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const uid = request.auth.uid;
  const token = request.auth.token as Record<string, unknown>;
  const jwtRole = token['role'] as string | undefined;

  if (jwtRole === 'super_admin') {
    const access: TranslationAccess = {
      uid,
      isPlatformSuperAdmin: true,
      organizationId: null,
      allowedLocales: null,
      canImportSource: true,
      canExportArb: true,
      canBatchAi: true,
    };
    return access;
  }

  const organizationId = request.data?.['organizationId'] as string | undefined;
  if (!organizationId) {
    throw new HttpsError(
      'invalid-argument',
      'organizationId is required for org translation access.',
    );
  }

  const { data: profile } = await loadUserProfile(organizationId, uid);
  if (
    profile['organizationId'] !== organizationId ||
    profile['approvalStatus'] !== 'approved'
  ) {
    throw new HttpsError(
      'permission-denied',
      'Only approved organization members can manage translations.',
    );
  }

  const admin = await isOrgAdmin(organizationId, uid, token);
  const moderator = await hasManageTranslationsPermission(
    organizationId,
    uid,
    token,
  );

  if (!admin && !moderator) {
    throw new HttpsError(
      'permission-denied',
      'Translation access requires org admin or manageTranslations permission.',
    );
  }

  const allowedLocales = await orgTranslationLocales(organizationId);
  const access: TranslationAccess = {
    uid,
    isPlatformSuperAdmin: false,
    organizationId,
    allowedLocales,
    canImportSource: false,
    canExportArb: admin,
    canBatchAi: admin,
  };

  assertLocaleAllowed(access, options?.targetLocale);

  if (options?.requireImport && !access.canImportSource) {
    throw new HttpsError(
      'permission-denied',
      'Importing English source keys requires platform super_admin.',
    );
  }
  if (options?.requireExport && !access.canExportArb) {
    throw new HttpsError(
      'permission-denied',
      'Exporting ARB files requires org admin access.',
    );
  }
  if (options?.requireBatchAi && !access.canBatchAi) {
    throw new HttpsError(
      'permission-denied',
      'Batch AI translation requires org admin access.',
    );
  }

  return access;
}

/** @deprecated Use resolveTranslationAccess — kept for platform-only utilities. */
export function assertPlatformSuperAdmin(request: CallableRequest): string {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }
  const role = request.auth.token['role'] as string | undefined;
  if (role !== 'super_admin') {
    throw new HttpsError(
      'permission-denied',
      'This action requires platform super_admin access.',
    );
  }
  return request.auth.uid;
}
