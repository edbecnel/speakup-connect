/**
 * Seed default report categories for an organization.
 *
 * Usage:
 *   node shared/scripts/seed_categories.js
 *
 * Requirements:
 *   npm install firebase-admin   (run once in the project root or shared/scripts/)
 *
 * Authentication:
 *   Set GOOGLE_APPLICATION_CREDENTIALS to your service account JSON path, OR
 *   run `firebase login` and use the Firebase CLI's default credentials by
 *   setting FIREBASE_TOKEN / using the emulator.
 *
 *   Easiest for local dev:
 *     1. Go to Firebase Console → Project Settings → Service Accounts
 *     2. Generate a new private key → save as shared/scripts/service-account.json
 *     3. set GOOGLE_APPLICATION_CREDENTIALS=shared\scripts\service-account.json
 *     4. node shared/scripts/seed_categories.js
 */

const admin = require('firebase-admin');

// ── Config ────────────────────────────────────────────────────────────────────
// Change these to match your deployment.
const PROJECT_ID   = 'speakup-connect-891dd';
const ORG_ID       = 'monhs-ph-001'; // AppConfig.defaultOrganizationId

// ── Default Categories ────────────────────────────────────────────────────────
// These are generic school/community categories. Adjust labels, icons,
// and colors to match the client's preferences via the Admin Branding screen
// once the app is running.
const DEFAULT_CATEGORIES = [
  {
    categoryId:     'facility',
    label:          'Facility & Infrastructure',
    icon:           'build_outlined',
    color:          '#F59E0B',
    sortOrder:      1,
    isActive:       true,
    requiresPhoto:  false,
  },
  {
    categoryId:     'safety',
    label:          'Safety & Security',
    icon:           'security_outlined',
    color:          '#EF4444',
    sortOrder:      2,
    isActive:       true,
    requiresPhoto:  false,
  },
  {
    categoryId:     'academic',
    label:          'Academic Concern',
    icon:           'school_outlined',
    color:          '#3B82F6',
    sortOrder:      3,
    isActive:       true,
    requiresPhoto:  false,
  },
  {
    categoryId:     'bullying',
    label:          'Bullying & Harassment',
    icon:           'report_problem_outlined',
    color:          '#8B5CF6',
    sortOrder:      4,
    isActive:       true,
    requiresPhoto:  false,
  },
  {
    categoryId:     'sanitation',
    label:          'Sanitation & Cleanliness',
    icon:           'cleaning_services_outlined',
    color:          '#10B981',
    sortOrder:      5,
    isActive:       true,
    requiresPhoto:  true,
  },
  {
    categoryId:     'conduct',
    label:          'Staff / Teacher Conduct',
    icon:           'person_outlined',
    color:          '#F97316',
    sortOrder:      6,
    isActive:       true,
    requiresPhoto:  false,
  },
  {
    categoryId:     'administrative',
    label:          'Administrative',
    icon:           'admin_panel_settings_outlined',
    color:          '#6B7280',
    sortOrder:      7,
    isActive:       true,
    requiresPhoto:  false,
  },
  {
    categoryId:     'other',
    label:          'Other',
    icon:           'help_outline',
    color:          '#9CA3AF',
    sortOrder:      8,
    isActive:       true,
    requiresPhoto:  false,
  },
];

// ── Main ──────────────────────────────────────────────────────────────────────
async function main() {
  // Initialize Admin SDK using GOOGLE_APPLICATION_CREDENTIALS env var.
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId:  PROJECT_ID,
  });

  const db = admin.firestore();
  const categoriesRef = db
    .collection('organizations')
    .doc(ORG_ID)
    .collection('categories');

  // Check if categories already exist.
  const existing = await categoriesRef.limit(1).get();
  if (!existing.empty) {
    console.log(`Categories already exist for org "${ORG_ID}". Skipping seed.`);
    console.log('Delete existing documents first if you want to re-seed.');
    process.exit(0);
  }

  const batch = db.batch();
  for (const cat of DEFAULT_CATEGORIES) {
    const ref = categoriesRef.doc(cat.categoryId);
    batch.set(ref, cat);
  }

  await batch.commit();
  console.log(`✓ Seeded ${DEFAULT_CATEGORIES.length} categories for org "${ORG_ID}".`);
  process.exit(0);
}

main().catch((err) => {
  console.error('Seed failed:', err.message);
  process.exit(1);
});
