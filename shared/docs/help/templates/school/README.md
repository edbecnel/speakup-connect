# School Help Templates

Reusable documentation templates for any school tenant onboarding to SpeakUp Connect.

Use these files as the canonical source when preparing help docs for a new school org.

| File | Purpose |
|---|---|
| `MEMBER_GUIDE.md` | Feature reference for approved members (students/staff) |
| `ADMIN_GUIDE.md` | Feature reference for school admins and delegated staff |
| `MEMBER_TUTORIAL.md` | Optional step-by-step onboarding for first-time members |
| `ADMIN_TUTORIAL.md` | Step-by-step onboarding for first-time administrators |

## Reference vs tutorial

- `*_GUIDE.md` = feature-based lookup/reference during daily operations.
- `*_TUTORIAL.md` = beginner learning flow, completed in sequence.

Do not merge both modes into one file. Keep reference guides and tutorials separate.

## New school onboarding flow

1. Copy templates to org docs:
   - `shared/docs/help/orgs/{organizationId}/MEMBER_GUIDE.md`
   - `shared/docs/help/orgs/{organizationId}/ADMIN_GUIDE.md`
   - Optional: `*_TUTORIAL.md` files for internal training docs
2. Replace placeholders (`{organizationId}`, `{School Name}`, role labels) with tenant values.
3. Keep feature coverage accurate for that tenant:
   - remove unsupported sections
   - keep school-only sections only when enabled (student ID login, roster, grades)
4. Copy app-served guide files to bundled assets:
   - `assets/help/orgs/{organizationId}/member_guide.md`
   - `assets/help/orgs/{organizationId}/admin_guide.md`
5. Register the new assets path in `speakup_connect_app/pubspec.yaml`.
6. Smoke-test in app: **Settings -> Help Center**.

## Seeding source

These templates were seeded from the MONHS school help docs and generalized for reuse.

- MONHS reference docs remain available at `shared/docs/help/orgs/monhs-ph-001/`.
- Keep MONHS examples labeled as examples when reusing content for other schools.
