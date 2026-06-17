/**
 * Seed MONHS demo groups for client walkthroughs and group-targeted reminders.
 *
 * Groups created (idempotent — safe to re-run):
 *   • spj — Special Program in Journalism (SPJ)
 *   • drum-and-lyre-corps — Drum and Lyre Corps
 *   • sslg — Supreme Secondary Learner Government (SSLG)
 *
 * Usage (preferred — no service account needed):
 *   App → Settings → Groups & Clubs → "Seed Demo Groups" (empty list)
 *
 * Alternative (Node script):
 *   node shared/scripts/seed_groups.js
 *
 * Authentication for the Node script (same options as seed_categories.js):
 *   • Set GOOGLE_APPLICATION_CREDENTIALS to the full path of your existing
 *     service-account JSON key (wherever you saved it), OR
 *   • Leave unset and use Application Default Credentials if configured.
 *
 *   Do NOT point at shared\scripts\service-account.json unless that file exists.
 */

const fs = require('fs');
const path = require('path');
const admin = require('../functions/node_modules/firebase-admin');

const PROJECT_ID = 'speakup-connect-891dd';

function initAdmin() {
  const envPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (envPath) {
    const resolved = path.isAbsolute(envPath)
      ? envPath
      : path.resolve(process.cwd(), envPath);
    if (!fs.existsSync(resolved)) {
      console.error('❌  GOOGLE_APPLICATION_CREDENTIALS points to a missing file:\n');
      console.error(`   ${resolved}\n`);
      console.error('   If your key is saved elsewhere, set the full path, e.g.:');
      console.error(
        '   $env:GOOGLE_APPLICATION_CREDENTIALS = "C:\\path\\to\\your-key.json"',
      );
      console.error('   Or clear the variable and rely on Application Default Credentials:');
      console.error('   Remove-Item Env:\\GOOGLE_APPLICATION_CREDENTIALS -ErrorAction SilentlyContinue\n');
      process.exit(1);
    }
  }

  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId: PROJECT_ID,
  });
}

// ── Config ────────────────────────────────────────────────────────────────────
const ORG_ID = 'monhs-ph-001';
const CREATED_BY = 'seed-script';

// ── Demo Groups ───────────────────────────────────────────────────────────────
const GROUPS = [
  {
    id: 'spj',
    name: 'Special Program in Journalism (SPJ)',
    description:
      'Students participating in the Special Program in Journalism. ' +
      'This is a program cohort group.',
  },
  {
    id: 'drum-and-lyre-corps',
    name: 'Drum and Lyre Corps',
    description: 'Marching drum and lyre ensemble.',
  },
  {
    id: 'sslg',
    name: 'Supreme Secondary Learner Government (SSLG)',
    description:
      'Student government organization representing the secondary student body.',
    positionRoles: [
      { id: 'president', label: 'President', sortOrder: 0 },
      { id: 'vice-president', label: 'Vice President', sortOrder: 1 },
      { id: 'treasurer', label: 'Treasurer', sortOrder: 2 },
      { id: 'secretary', label: 'Secretary', sortOrder: 3 },
      { id: 'other', label: 'Other', sortOrder: 4 },
    ],
  },
];

// ── Main ───────────────────────────────────────────────────────────────────────

async function main() {
  if (!admin.apps.length) {
    initAdmin();
  }

  const db = admin.firestore();
  const groupsRef = db.collection('organizations').doc(ORG_ID).collection('groups');
  const now = admin.firestore.FieldValue.serverTimestamp();

  for (const group of GROUPS) {
    const docRef = groupsRef.doc(group.id);
    const snap = await docRef.get();

    const payload = {
      groupId: group.id,
      organizationId: ORG_ID,
      name: group.name,
      description: group.description,
      isActive: true,
      createdBy: CREATED_BY,
      updatedAt: now,
    };

    if (group.positionRoles) {
      payload.positionRoles = group.positionRoles;
    }

    if (!snap.exists) {
      payload.memberCount = 0;
      payload.createdAt = now;
      await docRef.set(payload);
    } else {
      // Preserve memberCount and createdAt; refresh name/description for demos.
      await docRef.set(payload, { merge: true });
    }
  }

  console.log(`\n✅  Seeded ${GROUPS.length} groups into organizations/${ORG_ID}/groups\n`);
  GROUPS.forEach((g) => console.log(`  • ${g.id} — ${g.name}`));
  console.log('');
}

main().catch((err) => {
  console.error('❌  Seed failed:', err.message);
  process.exit(1);
});
