/**
 * Assign the org-admin role to a user by email address.
 *
 * Usage:
 *   node shared/scripts/assign_admin.js your-email@example.com
 *
 * Authentication (same as seed_roles.js):
 *   1. Firebase Console → Project Settings → Service Accounts → Generate new key
 *   2. Save the file as shared/scripts/service-account.json
 *   3. set GOOGLE_APPLICATION_CREDENTIALS=shared\scripts\service-account.json
 *   4. node shared/scripts/assign_admin.js your-email@example.com
 */

const admin = require('../functions/node_modules/firebase-admin');

const PROJECT_ID = 'speakup-connect-891dd';
const ORG_ID     = 'monhs-ph-001';

async function main() {
  const email = process.argv[2];
  if (!email) {
    console.error('Usage: node shared/scripts/assign_admin.js your-email@example.com');
    process.exit(1);
  }

  admin.initializeApp({ projectId: PROJECT_ID });
  const db   = admin.firestore();
  const auth = admin.auth();

  // Look up the UID from the email address.
  console.log(`Looking up user: ${email}`);
  let userRecord;
  try {
    userRecord = await auth.getUserByEmail(email);
  } catch (e) {
    console.error(`Could not find a user with email "${email}". Check the spelling and try again.`);
    process.exit(1);
  }

  const uid = userRecord.uid;
  console.log(`Found UID: ${uid}`);

  // Check if an org-admin assignment already exists.
  const assignmentsRef = db
    .collection('organizations').doc(ORG_ID)
    .collection('users').doc(uid)
    .collection('roleAssignments');

  const existing = await assignmentsRef.where('roleId', '==', 'org-admin').get();
  if (!existing.empty) {
    console.log('User already has the org-admin role assigned. Nothing to do.');
    process.exit(0);
  }

  // Create the assignment.
  await assignmentsRef.doc('bootstrap-admin').set({
    roleId:     'org-admin',
    scopeType:  'org',
    scopeId:    null,
    assignedBy: uid,
    assignedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Keep the profile role in sync so router/admin UI gates match Firestore rules.
  const profileRef = db
    .collection('organizations').doc(ORG_ID)
    .collection('users').doc(uid);
  await profileRef.set(
    {
      role: 'admin',
      organizationId: ORG_ID,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  console.log(`\nDone! "${email}" is now an org-admin for ${ORG_ID}.`);
  console.log('Hot-restart the app and the Create Role button will appear.');
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
