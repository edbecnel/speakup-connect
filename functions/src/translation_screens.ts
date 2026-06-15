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
let screenNameRouteAliasesCache: Record<string, string> | null = null;

function loadAssignableRoutes(): AssignableRoute[] {
  if (assignableRoutesCache) return assignableRoutesCache;
  const filePath = path.join(__dirname, 'data', 'assignable_routes.json');
  const raw = fs.readFileSync(filePath, 'utf8');
  assignableRoutesCache = JSON.parse(raw) as AssignableRoute[];
  return assignableRoutesCache;
}

function loadScreenNameRouteAliases(): Record<string, string> {
  if (screenNameRouteAliasesCache) return screenNameRouteAliasesCache;
  const filePath = path.join(__dirname, 'data', 'screen_name_route_aliases.json');
  const raw = fs.readFileSync(filePath, 'utf8');
  screenNameRouteAliasesCache = JSON.parse(raw) as Record<string, string>;
  return screenNameRouteAliasesCache;
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
        `A screen name "${existing}" already exists on another catalog entry.`,
        { conflictingScreenId: doc.id, conflictingScreenName: existing },
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

function normalizeForRouteMatch(name: string): string {
  return normalizeName(name)
    .replace(/\s+\(shared\)$/i, '')
    .replace(/\s+screen$/i, '')
    .toLowerCase();
}

function lookupAliasRoute(
  name: string,
  aliases: Record<string, string>,
): string | null {
  const trimmed = normalizeName(name);
  if (aliases[trimmed]) return aliases[trimmed];
  const lower = trimmed.toLowerCase();
  for (const [label, route] of Object.entries(aliases)) {
    if (label.toLowerCase() === lower) return route;
  }
  return null;
}

function routeForScreenName(name: string): string | null {
  const routes = loadAssignableRoutes();
  const aliases = loadScreenNameRouteAliases();
  const assignableOnly = new Set(routes.map((r) => r.route));

  const tryName = (candidate: string): string | null => {
    const aliasRoute = lookupAliasRoute(candidate, aliases);
    if (aliasRoute && assignableOnly.has(aliasRoute)) return aliasRoute;

    const norm = normalizeForRouteMatch(candidate);
    for (const r of routes) {
      if (normalizeForRouteMatch(r.label) === norm) return r.route;
    }
    return null;
  };

  const direct = tryName(name);
  if (direct) return direct;

  const segments = name
    .split(/\s*\/\s*/)
    .map((s) => s.trim())
    .filter(Boolean);
  for (const segment of segments) {
    const route = tryName(segment);
    if (route) return route;
  }

  for (const segment of segments) {
    const stripped = segment.replace(/^[^(]+\(shared\)\s*/i, '').trim();
    if (stripped) {
      const route = tryName(stripped);
      if (route) return route;
    }
  }

  return null;
}

function nameSegments(name: string): string[] {
  return name
    .split(/\s*\/\s*/)
    .map((s) => normalizeName(s).toLowerCase())
    .filter(Boolean);
}

function isSegmentOfScreenName(shortName: string, longName: string): boolean {
  const short = normalizeName(shortName).toLowerCase();
  if (normalizeName(longName).toLowerCase() === short) return false;
  return nameSegments(longName).includes(short);
}

function shareSameRouteAlias(nameA: string, nameB: string): boolean {
  const routeA = routeForScreenName(nameA);
  const routeB = routeForScreenName(nameB);
  return routeA != null && routeA === routeB;
}

function isRedundantSegmentCatalogName(
  name: string,
  otherNames: string[],
): boolean {
  const route = routeForScreenName(name);
  if (!route) return false;
  for (const other of otherNames) {
    if (normalizeName(other).toLowerCase() === normalizeName(name).toLowerCase()) {
      continue;
    }
    if (isSegmentOfScreenName(name, other) && shareSameRouteAlias(name, other)) {
      return true;
    }
  }
  return false;
}

async function dedupeRedundantSegmentScreens(
  orgId: string,
): Promise<{ removed: number }> {
  const snap = await screensRef(orgId).get();
  const docs = snap.docs.map((doc) => ({
    id: doc.id,
    data: doc.data() as TranslationScreenDoc,
  }));

  const toDelete = new Set<string>();
  for (const short of docs) {
    if (short.data.assignedRoute) continue;
    for (const long of docs) {
      if (short.id === long.id) continue;
      if (
        isSegmentOfScreenName(short.data.name, long.data.name) &&
        shareSameRouteAlias(short.data.name, long.data.name)
      ) {
        toDelete.add(short.id);
        break;
      }
    }
  }

  if (toDelete.size === 0) return { removed: 0 };

  let batch = db.batch();
  let ops = 0;
  for (const id of toDelete) {
    batch.delete(screensRef(orgId).doc(id));
    ops++;
    if (ops >= 450) {
      await batch.commit();
      batch = db.batch();
      ops = 0;
    }
  }
  if (ops > 0) await batch.commit();

  logger.info('dedupeRedundantSegmentScreens', { orgId, removed: toDelete.size });
  return { removed: toDelete.size };
}

async function backfillRouteAssignments(
  orgId: string,
  uid: string,
): Promise<{ routesAssigned: number }> {
  const snap = await screensRef(orgId).get();
  const assignedRoutes = new Set<string>();
  for (const doc of snap.docs) {
    const route = doc.data()['assignedRoute'] as string | null | undefined;
    if (typeof route === 'string' && route.length > 0) {
      assignedRoutes.add(route);
    }
  }

  let routesAssigned = 0;
  let batch = db.batch();
  let ops = 0;

  for (const doc of snap.docs) {
    const data = doc.data() as TranslationScreenDoc;
    if (data.assignedRoute) continue;

    const route = routeForScreenName(data.name);
    if (!route || assignedRoutes.has(route)) continue;

    batch.update(doc.ref, {
      assignedRoute: route,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      lastEditedBy: uid,
    });
    assignedRoutes.add(route);
    routesAssigned++;
    ops++;
    if (ops >= 450) {
      await batch.commit();
      batch = db.batch();
      ops = 0;
    }
  }

  if (ops > 0) await batch.commit();

  if (routesAssigned > 0) {
    logger.info('backfillRouteAssignments', { orgId, routesAssigned });
  }

  return { routesAssigned };
}

async function collectDistinctStringContexts(orgId: string): Promise<string[]> {
  const locales = await orgTranslationLocales(orgId);
  const names = new Set<string>();

  for (const locale of locales) {
    const snap = await db
      .collection('languages')
      .doc(locale)
      .collection('strings')
      .get();
    for (const doc of snap.docs) {
      const ctx = doc.data()['context'];
      if (typeof ctx === 'string' && ctx.trim()) {
        names.add(normalizeName(ctx));
      }
    }
  }

  return [...names].sort((a, b) => a.localeCompare(b));
}

async function seedScreensFromStringContexts(
  orgId: string,
  uid: string,
  options?: { assignRoutes?: boolean },
): Promise<{
  created: number;
  routesAssigned: number;
  contextCount: number;
  deduped: number;
}> {
  const existingSnap = await screensRef(orgId).get();
  const existingDocNames = existingSnap.docs.map(
    (doc) => normalizeName((doc.data()['name'] as string | undefined) ?? ''),
  );
  const existingNames = new Set(
    existingDocNames.map((name) => name.toLowerCase()),
  );
  const assignedRoutes = new Set(
    existingSnap.docs
      .map((doc) => doc.data()['assignedRoute'] as string | null | undefined)
      .filter((route): route is string => typeof route === 'string' && route.length > 0),
  );

  const contextNames = await collectDistinctStringContexts(orgId);
  const assignRoutes = options?.assignRoutes !== false;
  const now = admin.firestore.Timestamp.now();
  let created = 0;
  let routesAssigned = 0;

  let batch = db.batch();
  let ops = 0;

  const catalogNameUniverse = [...existingDocNames, ...contextNames];
  for (const name of contextNames) {
    if (existingNames.has(name.toLowerCase())) continue;
    if (
      isRedundantSegmentCatalogName(
        name,
        catalogNameUniverse.filter(
          (other) => normalizeName(other).toLowerCase() !== name.toLowerCase(),
        ),
      )
    ) {
      continue;
    }

    let assignedRoute: string | null = null;
    if (assignRoutes) {
      const route = routeForScreenName(name);
      if (route && !assignedRoutes.has(route)) {
        assignedRoute = route;
        assignedRoutes.add(route);
        routesAssigned++;
      }
    }

    const ref = screensRef(orgId).doc();
    const data: TranslationScreenDoc = {
      name,
      assignedRoute,
      badgeEnabled: false,
      createdAt: now,
      updatedAt: now,
      lastEditedBy: uid,
    };
    batch.set(ref, data);
    existingNames.add(name.toLowerCase());
    created++;
    ops++;
    if (ops >= 450) {
      await batch.commit();
      batch = db.batch();
      ops = 0;
    }
  }

  if (ops > 0) await batch.commit();

  const backfill = await backfillRouteAssignments(orgId, uid);
  routesAssigned += backfill.routesAssigned;

  const dedupe = await dedupeRedundantSegmentScreens(orgId);

  logger.info('seedScreensFromStringContexts', {
    orgId,
    contextCount: contextNames.length,
    created,
    routesAssigned,
    deduped: dedupe.removed,
  });

  return {
    created,
    routesAssigned,
    contextCount: contextNames.length,
    deduped: dedupe.removed,
  };
}

function resolveScreenOrganizationId(
  access: Awaited<ReturnType<typeof resolveTranslationAccess>>,
  request: { data?: Record<string, unknown> },
): string {
  if (access.organizationId) return access.organizationId;
  const requested = request.data?.['organizationId'];
  if (
    access.isPlatformSuperAdmin &&
    typeof requested === 'string' &&
    requested.trim()
  ) {
    return requested.trim();
  }
  throw new HttpsError(
    'permission-denied',
    'Screen name management requires organization context. Set ORGANIZATION_ID in firebase-config.js (web) or pass organizationId.',
  );
}

export const listTranslationScreens = onCall(async (request) => {
  const access = await resolveTranslationAccess(request, {});
  const organizationId = resolveScreenOrganizationId(access, request);

  let snap = await screensRef(organizationId).orderBy('name').get();
  let seededFromContexts: {
    created: number;
    routesAssigned: number;
    contextCount: number;
  } | null = null;
  let routesBackfilled = 0;

  if (snap.empty) {
    seededFromContexts = await seedScreensFromStringContexts(
      organizationId,
      access.uid,
    );
    routesBackfilled = seededFromContexts.routesAssigned;
    if (seededFromContexts.created > 0) {
      snap = await screensRef(organizationId).orderBy('name').get();
    }
  }

  const screens = snap.docs.map((doc) =>
    screenForClient(doc.id, doc.data() as TranslationScreenDoc),
  );

  return {
    screens,
    assignableRoutes: loadAssignableRoutes(),
    seededFromContexts,
    routesBackfilled,
  };
});

export const seedTranslationScreensFromContexts = onCall(async (request) => {
  const access = await resolveTranslationAccess(request, {});
  const organizationId = resolveScreenOrganizationId(access, request);

  const assignRoutes = request.data?.['assignRoutes'] !== false;
  const result = await seedScreensFromStringContexts(
    organizationId,
    access.uid,
    { assignRoutes },
  );

  const snap = await screensRef(organizationId).orderBy('name').get();
  const screens = snap.docs.map((doc) =>
    screenForClient(doc.id, doc.data() as TranslationScreenDoc),
  );

  return {
    ok: true,
    ...result,
    screens,
    assignableRoutes: loadAssignableRoutes(),
  };
});

export const createTranslationScreen = onCall(async (request) => {
  const access = await resolveTranslationAccess(request, {});
  const organizationId = resolveScreenOrganizationId(access, request);

  const rawName = request.data?.['name'] as string | undefined;
  const name = normalizeName(rawName ?? '');
  if (!name) {
    throw new HttpsError('invalid-argument', 'Screen name is required.');
  }

  await assertUniqueName(organizationId, name);

  const now = admin.firestore.Timestamp.now();
  const ref = screensRef(organizationId).doc();
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
    orgId: organizationId,
    screenId: ref.id,
    name,
  });

  return { ok: true, screen: screenForClient(ref.id, data) };
});

export const updateTranslationScreen = onCall(async (request) => {
  const access = await resolveTranslationAccess(request, {});
  const organizationId = resolveScreenOrganizationId(access, request);

  const screenId = request.data?.['screenId'] as string | undefined;
  if (!screenId) {
    throw new HttpsError('invalid-argument', 'screenId is required.');
  }

  const ref = screensRef(organizationId).doc(screenId);
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
      await assertUniqueName(organizationId, name, screenId);
      patch['name'] = name;
      contextsRenamed = await renameStringContexts(
        organizationId,
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
        organizationId,
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
    orgId: organizationId,
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
  const organizationId = resolveScreenOrganizationId(access, request);

  const screenId = request.data?.['screenId'] as string | undefined;
  if (!screenId) {
    throw new HttpsError('invalid-argument', 'screenId is required.');
  }

  const ref = screensRef(organizationId).doc(screenId);
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
    orgId: organizationId,
    screenId,
    name: data.name,
  });

  return { ok: true };
});
