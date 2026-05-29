/**
 * Seed system roles and MONHS starter roles for an organization.
 *
 * System roles (org-admin, member) are created with isSystemRole: true and
 * cannot be deleted via the admin UI. They are idempotent — safe to re-run.
 *
 * Usage:
 *   node scripts/seed_roles.js
 *
 * Authentication (same as seed_categories.js):
 *   1. Firebase Console → Project Settings → Service Accounts → Generate key
 *   2. Save as scripts/service-account.json
 *   3. set GOOGLE_APPLICATION_CREDENTIALS=scripts\service-account.json
 *   4. node scripts/seed_roles.js
 */

// Use firebase-admin from the functions package (avoids a separate install)
const admin = require('../functions/node_modules/firebase-admin');

// ── Config ────────────────────────────────────────────────────────────────────
const PROJECT_ID = 'speakup-connect-891dd';
const ORG_ID     = 'monhs-ph-001';

// ── All AppPermission keys (must match lib/core/permissions/app_permission.dart)
const ALL_PERMISSIONS = [
  // Reports
  'viewAllReports',
  'viewGroupReports',
  'approveReport',
  'manageReports',
  // Bulletins & News
  'postBulletinOrgWide',
  'postBulletinToGroup',
  // Reminders
  'broadcastReminders',
  // Roster & Users
  'manageGroupRoster',
  'manageClassRoster',
  'approveApplications',
  'blockUsers',
  // Org Administration
  'manageOrganizationSettings',
  'manageRoles',
  'viewAuditLogs',
];

// ── Role Definitions ──────────────────────────────────────────────────────────
//
// System roles use a fixed document ID and isSystemRole: true.
// Starter roles are non-system and can be edited or deleted via the admin UI.
//
const ROLES = [
  // ── System roles (cannot be deleted) ──────────────────────────────────────
  {
    id: 'org-admin',
    displayName: 'Organization Admin',
    description: 'Full administrative access to all organization features.',
    isSystemRole: true,
    capabilities: ALL_PERMISSIONS,
    customCapabilities: [],
  },
  {
    id: 'member',
    displayName: 'Member',
    description: 'Standard member. Can submit reports and view their own submissions.',
    isSystemRole: true,
    capabilities: [],
    customCapabilities: [],
  },

  // ── MONHS starter roles (editable, not system) ─────────────────────────────
  {
    id: 'guidance-counselor',
    displayName: 'Guidance Counselor',
    description: 'Reviews and closes guidance referral reports. Can post to group boards.',
    isSystemRole: false,
    capabilities: [
      'viewGroupReports',
      'approveReport',
      'postBulletinToGroup',
    ],
    customCapabilities: [],
  },
  {
    id: 'discipline-officer',
    displayName: 'Discipline Officer',
    description: 'Manages discipline-related reports. Can update status and add notes.',
    isSystemRole: false,
    capabilities: [
      'viewGroupReports',
      'approveReport',
      'manageReports',
      'blockUsers',
    ],
    customCapabilities: [],
  },
  {
    id: 'homeroom-teacher',
    displayName: 'Homeroom Teacher',
    description: 'Views reports from their assigned class/section. Manages class roster.',
    isSystemRole: false,
    capabilities: [
      'viewGroupReports',
      'manageClassRoster',
    ],
    customCapabilities: [],
  },
  {
    id: 'club-adviser',
    displayName: 'Club / Org Adviser',
    description: 'Manages extracurricular group roster. Can post to group bulletin board.',
    isSystemRole: false,
    capabilities: [
      'manageGroupRoster',
      'postBulletinToGroup',
      'broadcastReminders',
    ],
    customCapabilities: [],
  },
];

// ── Main ───────────────────────────────────────────────────────────────────────

async function main() {
  // Initialise Admin SDK (uses GOOGLE_APPLICATION_CREDENTIALS env var)
  if (!admin.apps.length) {
    admin.initializeApp({ projectId: PROJECT_ID });
  }

  const db = admin.firestore();
  const rolesRef = db
    .collection('organizations')
    .doc(ORG_ID)
    .collection('roles');

  const now = admin.firestore.FieldValue.serverTimestamp();
  const batch = db.batch();

  for (const role of ROLES) {
    const { id, ...data } = role;
    const docRef = rolesRef.doc(id);
    // merge: true so re-running only updates changed fields, preserving
    // any admin edits made after the initial seed.
    batch.set(
      docRef,
      { ...data, updatedAt: now },
      { merge: true },
    );
    // On first write, also set createdAt (merge won't overwrite existing value
    // because we use set with merge — but createdAt needs special handling).
    // We use a second conditional set only when the doc doesn't exist yet.
  }

  await batch.commit();

  // Set createdAt only on documents that don't yet have it
  for (const role of ROLES) {
    const docRef = rolesRef.doc(role.id);
    const snap = await docRef.get();
    if (snap.exists && !snap.data().createdAt) {
      await docRef.update({ createdAt: now });
    } else if (!snap.exists) {
      await docRef.set({ createdAt: now }, { merge: true });
    }
  }

  console.log(`\n✅  Seeded ${ROLES.length} roles into organizations/${ORG_ID}/roles\n`);
  ROLES.forEach(r =>
    console.log(`  • [${r.isSystemRole ? 'SYSTEM' : 'starter'}] ${r.id} — ${r.displayName}`)
  );
  console.log('');
}

main().catch(err => {
  console.error('❌  Seed failed:', err.message);
  process.exit(1);
});
