/**
 * Backfill per-user groupMemberships indexes from existing group member rosters.
 *
 * Usage:
 *   node scripts/backfill_group_memberships.js
 *
 * Requires GOOGLE_APPLICATION_CREDENTIALS or Application Default Credentials.
 */

const fs = require('fs');
const path = require('path');
const admin = require('../functions/node_modules/firebase-admin');

const PROJECT_ID = 'speakup-connect-891dd';
const ORG_ID = 'monhs-ph-001';

function initAdmin() {
  const envPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (envPath) {
    const resolved = path.isAbsolute(envPath)
      ? envPath
      : path.resolve(process.cwd(), envPath);
    if (!fs.existsSync(resolved)) {
      console.error(`❌  Missing credentials file: ${resolved}`);
      process.exit(1);
    }
  }

  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId: PROJECT_ID,
  });
}

async function main() {
  if (!admin.apps.length) {
    initAdmin();
  }

  const db = admin.firestore();
  const groupsSnap = await db
    .collection('organizations')
    .doc(ORG_ID)
    .collection('groups')
    .get();

  let synced = 0;
  const batchSize = 400;
  let batch = db.batch();
  let batchCount = 0;

  for (const groupDoc of groupsSnap.docs) {
    const groupData = groupDoc.data();
    const groupName = groupData.name ?? 'Group';
    const membersSnap = await groupDoc.ref.collection('members').get();

    for (const memberDoc of membersSnap.docs) {
      const memberData = memberDoc.data();
      const userId = memberDoc.id;
      const indexRef = db
        .collection('organizations')
        .doc(ORG_ID)
        .collection('users')
        .doc(userId)
        .collection('groupMemberships')
        .doc(groupDoc.id);

      const payload = {
        organizationId: ORG_ID,
        groupId: groupDoc.id,
        groupName,
        groupRole: memberData.groupRole ?? 'member',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };
      if (memberData.positionRoleId) {
        payload.positionRoleId = memberData.positionRoleId;
      }

      batch.set(indexRef, payload, { merge: true });
      batchCount++;
      synced++;

      if (batchCount >= batchSize) {
        await batch.commit();
        batch = db.batch();
        batchCount = 0;
      }
    }
  }

  if (batchCount > 0) {
    await batch.commit();
  }

  console.log(`\n✅  Backfilled ${synced} groupMembership index rows for ${ORG_ID}\n`);
}

main().catch((err) => {
  console.error('❌  Backfill failed:', err.message);
  process.exit(1);
});
