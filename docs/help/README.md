# In-App Help — SpeakUp Connect

Help content is **organization-specific**. Each tenant (school, LGU, NGO, company, etc.) ships its own guides describing **local setup, UI options, and enabled functionality**.

Generic fallbacks live in [`_default/`](_default/) when an org has no custom bundle yet.

---

## Directory layout

```
docs/help/
├── README.md                 ← this file
├── _default/                 ← generic platform guides (fallback)
│   ├── MEMBER_GUIDE.md
│   └── ADMIN_GUIDE.md
└── orgs/
    └── {organizationId}/     ← one folder per tenant
        ├── README.md         ← optional org notes
        ├── MEMBER_GUIDE.md
        └── ADMIN_GUIDE.md

assets/help/                  ← same structure, lowercase filenames for the app
├── _default/
│   ├── member_guide.md
│   └── admin_guide.md
└── orgs/
    └── {organizationId}/
        ├── member_guide.md
        └── admin_guide.md
```

**Pilot example:** [orgs/monhs-ph-001/](orgs/monhs-ph-001/) — MONHS school (student ID login, roster, SSLG, grades).

---

## How the app picks a guide

1. Resolve the signed-in user's `organizationId` (from profile, or `FlavorConfig.orgId` on client builds).
2. Load `assets/help/orgs/{organizationId}/{article}_guide.md`.
3. If missing, fall back to `assets/help/_default/{article}_guide.md`.

Implementation: `lib/features/help/data/help_asset_resolver.dart`.

---

## Audience-based guides (not per RBAC role)

Within each organization, use **two guides** — not one file per custom role:

| Guide | Who sees it |
|-------|-------------|
| **Member Guide** | All approved members |
| **Administrator Guide** | Org admins and staff with Administration menu access |

Custom org roles (Club Adviser, Guidance Counselor, etc.) are covered **by topic** inside the Admin Guide, tagged with required capabilities. Do not fork help per role name.

Add a third guide only for a clearly different audience (e.g. applicants before approval).

---

## Onboarding a new organization

1. Create `docs/help/orgs/{organizationId}/`
2. Copy `_default/` guides as a starting point
3. Customize for org type and enabled features:
   - **School:** student ID login, roster, grades, clubs
   - **LGU / municipality:** citizen reports, bulletin workflows
   - **NGO / company:** adjust terminology; omit school-only sections
4. Copy to `assets/help/orgs/{organizationId}/`
5. Register the asset folder in `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/help/_default/
       - assets/help/orgs/monhs-ph-001/
       - assets/help/orgs/{new-org-id}/
   ```
6. Client builds: pair help bundle with `FlavorConfig.orgId` — see [ONBOARDING_NEW_SCHOOL.md](../ONBOARDING_NEW_SCHOOL.md)

---

## In-app entry point

**Settings → Help & Support → Help Center**

Lists guides for the current organization. Subtitle shows the org display name when loaded from Firestore.

---

## Keeping docs in sync

1. Edit `docs/help/orgs/{orgId}/MEMBER_GUIDE.md` (or `_default/`)
2. Copy to `assets/help/orgs/{orgId}/member_guide.md`
3. Reload the app:
   - **Edited existing asset text** — hot restart is usually enough
   - **Moved/renamed asset paths or changed `pubspec.yaml` assets** — stop `flutter run` (Ctrl+C) and start a **full** `flutter run` (hot restart will error looking for deleted paths)

If you see `PathNotFoundException: assets/help/admin_guide.md`, the dev session is stale from before org-specific folders — run `flutter clean`, then **stop** `flutter run` (Ctrl+C) and start a full `flutter run` again (not hot restart alone).

Legacy shim files at `assets/help/member_guide.md` and `assets/help/admin_guide.md` (copies of `_default`) are kept so Flutter hot restart can sync assets; the app still loads `orgs/{orgId}/` via `HelpAssetResolver`.

---

## Related documentation

| Document | Use |
|----------|-----|
| [DATABASE_DESIGN.md](../DATABASE_DESIGN.md) | Data model reference |
| [RBAC_ARCHITECTURE.md](../RBAC_ARCHITECTURE.md) | Permissions |
| [CLIENT_BUILDS.md](../CLIENT_BUILDS.md) | Per-client APK/IPA and `orgId` |
| [ONBOARDING_NEW_SCHOOL.md](../ONBOARDING_NEW_SCHOOL.md) | New school checklist |
