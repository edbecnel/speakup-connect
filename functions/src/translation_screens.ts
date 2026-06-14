import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';
import { resolveTranslationAccess } from './translation_auth';

const db = admin.firestore();

interface AssignableRoute {
  route: string;
  label: string;
}

interface TranslationScreenDoc {
  name: string;
  assignedRoute: string | null;
  badgeEnabled: boolean;
  createdAt: admin.firestore.Timestamp;
  updatedAt: admin.firestore.Timestamp;
  lastEditedBy: string;
}

let assignableRoutesCache: AssignableRoute[] | null = null;

function loadAssignableRoutes(): AssignableRoute[] {
  if (assignableRoutesCache) return assignableRoutesCache;
  const filePath = path.join(__dirname, 'data', 'assignable_routes.json');
  const raw = fs.readFileSync(filePath, 'utf8');
  assignableRoutesCache = JSON.parse(raw) as AssignableRoute[];
  return assignableRoutesCache;
}

function assignableRouteSet(): Set<string> {
  return new Set(loadAssignableRoutes().map((r) => r.route));
}

function screensRef(orgId: string) {
  return db
    .collection('organizations')
    .doc(orgId)
    .collection('translationScreens');
}

function normalizeName(name: string): string {
  return name.trim().replace(/\s+/g, ' ');
}

function screenForClient(id: string, data: TranslationScreenDoc) {
  const routes = loadAssignableRoutes();
  const routeMeta = data.assignedRoute
    ? routes.find((r) => r.route === data.assignedRoute)
    : undefined;
  return {
    screenId: id,
    name: data.name,
    assignedRoute: data.assignedRoute,
    assignedRouteLabel: routeMeta?.label ?? null,
    badgeEnabled: data.badgeEnabled === true,
    updatedAt: data.updatedAt?.toMillis?.() ?? null,
  };
}

async function assertUniqueName(
  orgId: string,
  name: string,
  excludeId?: string,
) {
  const snap = await screensRef(orgId).get();
  const normalized = normalizeName(name).toLowerCase();
  for (const doc of snap.docs) {
    if (excludeId && doc.id === excludeId) continue;
    const existing = (doc.data()['name'] as string | undefined) ?? '';
    if (normalizeName(existing).toLowerCase() === normalized) {
      throw new HttpsError(
        'already-exists',
        `A screen name "${existing}" already exists.`,
      );
    }
  }
}

async function findRouteConflict(
  orgId: string,
  route: string,
  excludeId?: string,
) {
  const snap = await screensRef(orgId)
    .where('assignedRoute', '==', route)
    .limit(1)
    .get();
  if (snap.empty) return null;
  const doc = snap.docs[0];
  if (excludeId && doc.id === excludeId) return null;
  return doc;
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
  return ['ceb', 'fil'];
}

async function renameStringContexts(
  orgId: string,
  oldName: string,
  newName: string,
) {
  const locales = await orgTranslationLocales(orgId);
  let updated = 0;

  for (const locale of locales) {
    const snap = await db
      .collection('languages')
      .doc(locale)
      .collection('strings')
      .where('context', '==', oldName)
      .get();

    if (snap.empty) continue;

    let batch = db.batch();
    let ops = 0;

    for (const doc of snap.docs) {
      batch.set(
        doc.ref,
        {
          context: newName,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          lastEditedByOrgId: orgId,
        },
        { merge: true },
      );
      ops++;
      updated++;
      if (ops >= 450) {
        await batch.commit();
        batch = db.batch();
        ops = 0;
      }
    }
    if (ops > 0) await batch.commit();
  }

  return updated;
}

export const listTranslationScreens = onCall(async (request) => {
  const access = await resolveTranslationAccess(request, {});
  if (!access.organizationId) {
    throw new HttpsError(
      'permission-denied',
      'Screen name management requires organization context.',
    );
  }

  const snap = await screensRef(access.organizationId)
    .orderBy('name')
    .get();

  const screens = snap.docs.map((doc) =>
    screenForClient(doc.id, doc.data() as TranslationScreenDoc),
  );

  return {
    screens,
    assignableRoutes: loadAssignableRoutes(),
  };
});

export const createTranslationScreen = onCall(async (request) => {
  const access = await resolveTranslationAccess(request, {});
  if (!access.organizationId) {
    throw new HttpsError(
      'permission-denied',
      'Screen name management requires organization context.',
    );
  }

  const rawName = request.data?.['name'] as string | undefined;
  const name = normalizeName(rawName ?? '');
  if (!name) {
    throw new HttpsError('invalid-argument', 'Screen name is required.');
  }

  await assertUniqueName(access.organizationId, name);

  const now = admin.firestore.Timestamp.now();
  const ref = screensRef(access.organizationId).doc();
  const data: TranslationScreenDoc = {
    name,
    assignedRoute: null,
    badgeEnabled: false,
    createdAt: now,
    updatedAt: now,
    lastEditedBy: access.uid,
  };
  await ref.set(data);

  logger.info('createTranslationScreen', {
    orgId: access.organizationId,
    screenId: ref.id,
    name,
  });

  return { ok: true, screen: screenForClient(ref.id, data) };
});

export const updateTranslationScreen = onCall(async (request) => {
  const access = await resolveTranslationAccess(request, {});
  if (!access.organizationId) {
    throw new HttpsError(
      'permission-denied',
      'Screen name management requires organization context.',
    );
  }

  const screenId = request.data?.['screenId'] as string | undefined;
  if (!screenId) {
    throw new HttpsError('invalid-argument', 'screenId is required.');
  }

  const ref = screensRef(access.organizationId).doc(screenId);
  const existing = await ref.get();
  if (!existing.exists) {
    throw new HttpsError('not-found', 'Screen name not found.');
  }

  const data = existing.data() as TranslationScreenDoc;
  const patch: Record<string, unknown> = {
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    lastEditedBy: access.uid,
  };

  let contextsRenamed = 0;

  if (request.data?.['name'] !== undefined) {
    const name = normalizeName(String(request.data['name'] ?? ''));
    if (!name) {
      throw new HttpsError('invalid-argument', 'Screen name cannot be empty.');
    }
    if (name !== data.name) {
      await assertUniqueName(access.organizationId, name, screenId);
      patch['name'] = name;
      contextsRenamed = await renameStringContexts(
        access.organizationId,
        data.name,
        name,
      );
    }
  }

  if (request.data?.['assignedRoute'] !== undefined) {
    const assignedRouteRaw = request.data['assignedRoute'];
    if (assignedRouteRaw === null || assignedRouteRaw === '') {
      patch['assignedRoute'] = null;
      patch['badgeEnabled'] = false;
    } else if (typeof assignedRouteRaw === 'string') {
      const assignedRoute = assignedRouteRaw.trim();
      if (!assignableRouteSet().has(assignedRoute)) {
        throw new HttpsError(
          'invalid-argument',
          `Unknown app route: ${assignedRoute}`,
        );
      }
      const conflict = await findRouteConflict(
        access.organizationId,
        assignedRoute,
        screenId,
      );
      if (conflict) {
        const conflictName =
          (conflict.data()?.['name'] as string | undefined) ?? conflict.id;
        throw new HttpsError(
          'failed-precondition',
          `Route is already assigned to screen name "${conflictName}". Unassign it there first.`,
        );
      }
      patch['assignedRoute'] = assignedRoute;
    } else {
      throw new HttpsError('invalid-argument', 'assignedRoute must be a string or null.');
    }
  }

  if (request.data?.['badgeEnabled'] !== undefined) {
    const badgeEnabled = request.data['badgeEnabled'] === true;
    const nextRoute =
      (patch['assignedRoute'] as string | null | undefined) ??
      data.assignedRoute;
    if (badgeEnabled && !nextRoute) {
      throw new HttpsError(
        'failed-precondition',
        'Assign this screen name to an app route before enabling translation badges.',
      );
    }
    patch['badgeEnabled'] = badgeEnabled;
  }

  await ref.set(patch, { merge: true });
  const updated = await ref.get();
  const updatedData = updated.data() as TranslationScreenDoc;

  logger.info('updateTranslationScreen', {
    orgId: access.organizationId,
    screenId,
    contextsRenamed,
  });

  return {
    ok: true,
    screen: screenForClient(screenId, updatedData),
    contextsRenamed,
  };
});

export const deleteTranslationScreen = onCall(async (request) => {
  const access = await resolveTranslationAccess(request, {});
  if (!access.organizationId) {
    throw new HttpsError(
      'permission-denied',
      'Screen name management requires organization context.',
    );
  }

  const screenId = request.data?.['screenId'] as string | undefined;
  if (!screenId) {
    throw new HttpsError('invalid-argument', 'screenId is required.');
  }

  const ref = screensRef(access.organizationId).doc(screenId);
  const existing = await ref.get();
  if (!existing.exists) {
    throw new HttpsError('not-found', 'Screen name not found.');
  }

  const data = existing.data() as TranslationScreenDoc;
  if (data.assignedRoute) {
    const routes = loadAssignableRoutes();
    const routeMeta = routes.find((r) => r.route === data.assignedRoute);
    throw new HttpsError(
      'failed-precondition',
      `Unassign "${data.name}" from ${routeMeta?.label ?? data.assignedRoute} before deleting.`,
    );
  }

  await ref.delete();

  logger.info('deleteTranslationScreen', {
    orgId: access.organizationId,
    screenId,
    name: data.name,
  });

  return { ok: true };
});
