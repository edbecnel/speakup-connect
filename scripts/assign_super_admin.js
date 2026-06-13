/**
 * Grant platform super_admin to a Firebase Auth user by email.
 *
 * Sets Firestore profile role + JWT custom claim `role: super_admin` so
 * Translation Helper can import app_en.arb and other platform-only actions work.
 *
 * Usage:
 *   node scripts/assign_super_admin.js your-email@example.com
 *
 * Authentication (same as seed_roles.js / assign_admin.js):
 *   $env:GOOGLE_APPLICATION_CREDENTIALS = "scripts\service-account.json"
 *   node scripts/assign_super_admin.js your-email@example.com
 *
 * After running: sign out and sign back in (Flutter app + Translation Helper web).
 */

const admin = require('../functions/node_modules/firebase-admin');

const PROJECT_ID = 'speakup-connect-891dd';
const ORG_ID = 'monhs-ph-001';

/** Must match seed_roles.js / app_permission.dart */
const ALL_PERMISSIONS = [
  'viewAllReports',
  'viewGroupReports',
  'approveReport',
  'manageReports',
  'postBulletinOrgWide',
  'postBulletinToGroup',
  'broadcastReminders',
  'manageGroupRoster',
  'manageClassRoster',
  'approveApplications',
  'blockUsers',
  'manageOrganizationSettings',
  'manageRoles',
  'manageTranslations',
  'viewAuditLogs',
];

async function main() {
  const email = process.argv[2];
  if (!email) {
    console.error('Usage: node scripts/assign_super_admin.js your-email@example.com');
    process.exit(1);
  }

  admin.initializeApp({ projectId: PROJECT_ID });
  const db = admin.firestore();
  const auth = admin.auth();

  console.log(`Looking up user: ${email}`);
  let userRecord;
  try {
    userRecord = await auth.getUserByEmail(email);
  } catch (e) {
    console.error(
      `Could not find a user with email "${email}". Register in the app first, then re-run.`,
    );
    process.exit(1);
  }

  const uid = userRecord.uid;
  console.log(`Found UID: ${uid}`);

  const profileRef = db
    .collection('organizations')
    .doc(ORG_ID)
    .collection('users')
    .doc(uid);

  const profileSnap = await profileRef.get();
  if (!profileSnap.exists) {
    console.error(
      `No profile at organizations/${ORG_ID}/users/${uid}. ` +
        'Apply/join the org in the app first, or run assign_admin.js.',
    );
    process.exit(1);
  }

  // Ensure org-admin role assignment exists (full capability set for JWT permissions).
  const assignmentsRef = profileRef.collection('roleAssignments');
  const orgAdmin = await assignmentsRef.where('roleId', '==', 'org-admin').get();
  if (orgAdmin.empty) {
    await assignmentsRef.doc('bootstrap-super-admin').set({
      roleId: 'org-admin',
      scopeType: 'org',
      scopeId: null,
      assignedBy: uid,
      assignedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log('Created org-admin role assignment.');
  }

  await profileRef.set(
    {
      role: 'super_admin',
      organizationId: ORG_ID,
      approvalStatus: 'approved',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  const existingClaims =
    (userRecord.customClaims) ?? {};

  await auth.setCustomUserClaims(uid, {
    ...existingClaims,
    role: 'super_admin',
    orgId: ORG_ID,
    organizationId: ORG_ID,
    permissions: ALL_PERMISSIONS,
    tagScopes: [],
  });

  console.log(`\n✅  "${email}" is now platform super_admin for ${ORG_ID}.`);
  console.log('Sign out and sign back in on the Translation Helper web page and Flutter app.');
  console.log('You should see Import app_en.arb in the web Translation Helper.');
}

main().catch((err) => {
  console.error('❌  Failed:', err.message);
  process.exit(1);
});
