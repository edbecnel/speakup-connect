/**
 * Backfill languages/ceb/strings/* route from existing context.
 *
 * Usage (PowerShell):
 *   cd D:\Dev\Speakup-Connect
 *   $env:GOOGLE_APPLICATION_CREDENTIALS="scripts\service-account.json"
 *   node scripts/backfill_translation_routes_ceb.js --dry
 *   node scripts/backfill_translation_routes_ceb.js
 */

// Use firebase-admin from the functions package (matches other scripts)
const admin = require('../functions/node_modules/firebase-admin');
const fs = require('fs');
const path = require('path');

const PROJECT_ID = 'speakup-connect-891dd';
const ORG_ID = 'monhs-ph-001';
const LOCALE = 'ceb';

const DRY_RUN = process.argv.includes('--dry');
const MAX_WRITES_ARG = process.argv.find((a) => a.startsWith('--maxWrites='));
const MAX_WRITES = MAX_WRITES_ARG ? Number(MAX_WRITES_ARG.split('=')[1]) : Infinity;

function loadJson(relPathFromFunctionsSrc) {
    const filePath = path.join(__dirname, '..', 'functions', 'src', relPathFromFunctionsSrc);
    return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function normalizeName(name) {
    return String(name ?? '').trim().replace(/\s+/g, ' ');
}

function normalizeForRouteMatch(name) {
    return normalizeName(name)
        .replace(/\s+\(shared\)$/i, '')
        .replace(/\s+screen$/i, '')
        .toLowerCase();
}

function lookupAliasRoute(name, aliases) {
    const trimmed = normalizeName(name);
    if (aliases[trimmed]) return aliases[trimmed];
    const lower = trimmed.toLowerCase();
    for (const [label, route] of Object.entries(aliases)) {
        if (label.toLowerCase() === lower) return route;
    }
    return null;
}

function routeForScreenName(name, routes, aliases) {
    const assignableOnly = new Set(routes.map((r) => r.route));

    const tryName = (candidate) => {
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

    const segments = String(name ?? '')
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

async function main() {
    if (!admin.apps.length) {
        admin.initializeApp({ projectId: PROJECT_ID });
    }
    const db = admin.firestore();

    const routes = loadJson('data/assignable_routes.json'); // [{route,label}]
    const aliases = loadJson('data/screen_name_route_aliases.json'); // { "Admin Dashboard": "/admin", ... }

    const col = db.collection('languages').doc(LOCALE).collection('strings');
    const snap = await col.get();

    let scanned = 0;
    let updated = 0;
    let skippedWithRoute = 0;
    let skippedNoContext = 0;
    let skippedNoMatch = 0;

    let batch = db.batch();
    let ops = 0;
    let remainingWrites = Number.isFinite(MAX_WRITES) ? MAX_WRITES : Infinity;

    const flush = async () => {
        if (ops === 0) return;
        if (!DRY_RUN) await batch.commit();
        batch = db.batch();
        ops = 0;
    };

    for (const doc of snap.docs) {
        const key = doc.id;
        if (key.startsWith('@')) continue;

        scanned++;
        const data = doc.data();

        const existingRoute = typeof data.route === 'string' ? data.route.trim() : '';
        if (existingRoute) {
            skippedWithRoute++;
            continue;
        }

        const ctx = typeof data.context === 'string' ? data.context.trim() : '';
        if (!ctx) {
            skippedNoContext++;
            continue;
        }

        const computed = routeForScreenName(ctx, routes, aliases);
        if (!computed) {
            skippedNoMatch++;
            continue;
        }

        if (remainingWrites <= 0) break;
        remainingWrites--;

        batch.set(
            doc.ref,
            {
                route: computed,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                lastEditedByOrgId: ORG_ID,
            },
            { merge: true },
        );

        ops++;
        updated++;

        if (ops >= 450) {
            await flush();
        }
    }

    await flush();

    console.log(
        JSON.stringify(
            {
                ok: true,
                dryRun: DRY_RUN,
                locale: LOCALE,
                scanned,
                updated,
                skippedWithRoute,
                skippedNoContext,
                skippedNoMatch,
                maxWrites: Number.isFinite(MAX_WRITES) ? MAX_WRITES : null,
            },
            null,
            2,
        ),
    );
}

main().catch((e) => {
    console.error(e);
    process.exit(1);
});