# In-App Help — SpeakUp Connect

Help content is **organization-specific**. Each tenant (school, LGU, NGO, company, etc.) ships its own guides describing **local setup, UI options, and enabled functionality**.

Generic fallbacks live in [`_default/`](_default/) when an org has no custom bundle yet.
Reusable school starter docs live in [`templates/school/`](templates/school/).

---

## Directory layout

```
shared/docs/help/
├── README.md                 ← this file
├── _default/                 ← generic platform guides (fallback)
│   ├── MEMBER_GUIDE.md
│   └── ADMIN_GUIDE.md
├── templates/
│   └── school/               ← canonical school templates for new school onboarding
│       ├── README.md
│       ├── MEMBER_GUIDE.md
│       ├── ADMIN_GUIDE.md
│       └── *_TUTORIAL.md
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

**Reference example:** [orgs/monhs-ph-001/](orgs/monhs-ph-001/) — MONHS school deployment.

---

## How the app picks a guide

1. Resolve the signed-in user's `organizationId` (from profile, or `FlavorConfig.orgId` on client builds).
2. Load `assets/help/orgs/{organizationId}/{article}_guide.md` (or `{article}_guide_{locale}.md` when locale is not English).
3. If missing, fall back to `assets/help/_default/{article}_guide.md` (then localized `_default` name, then English).

Implementation: `lib/features/help/data/help_asset_resolver.dart`. Locale comes from `appLocaleProvider` (`en` → no suffix; `ceb` → `_ceb`).

**Phase 1b:** `*_ceb.md` files may duplicate English until native speakers translate them. Same for `app_ceb.arb` UI strings.

---

## Audience-based guides (not per RBAC role)

Within each organization, use **two guides** — not one file per custom role:

| Guide | Who sees it |
|-------|-------------|
| **Member Guide** | All approved members |
| **Administrator Guide** | Org admins, translation moderators (`manageTranslations`), and staff with Administration menu access |

Custom org roles (Club Adviser, Guidance Counselor, **Cebuano Translator**, etc.) are covered **by topic** inside the Admin Guide, tagged with required capabilities. Do not fork help per role name. **UI translation editing** is documented only in the Administrator Guide — not the Member Guide.

Add a third guide only for a clearly different audience (e.g. applicants before approval).

---

## Onboarding a new organization

1. Create `shared/docs/help/orgs/{organizationId}/`
2. If this is a school org, copy from `shared/docs/help/templates/school/`:
   - `MEMBER_GUIDE.md`
   - `ADMIN_GUIDE.md`
   - Optional tutorials for training (`*_TUTORIAL.md`)
3. For non-school orgs, copy from `_default/` and tailor terminology
4. Customize for org type and enabled features:
   - **School:** student ID login, roster, grades, clubs
   - **LGU / municipality:** citizen reports, bulletin workflows
   - **NGO / company:** adjust terminology; omit school-only sections
5. Copy guide files to `assets/help/orgs/{organizationId}/`
6. Register the asset folder in `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/help/_default/
       - assets/help/orgs/monhs-ph-001/
       - assets/help/orgs/{new-org-id}/
   ```
7. Client builds: pair help bundle with `FlavorConfig.orgId` — see [ONBOARDING_NEW_SCHOOL.md](../ONBOARDING_NEW_SCHOOL.md)

---

## In-app entry point

**Settings → Help & Support → Help Center**

Lists guides for the current organization. Subtitle shows the org display name when loaded from Firestore.

**App language:** members change UI language from the **globe dropdown at the top of Home** or **Settings → Appearance → Language**. Picker options always show **English** and **Bisaya / Cebuano** by native name. Help markdown loads `member_guide_ceb.md` (etc.) when that locale is active — see [INTERNATIONALIZATION.md](../INTERNATIONALIZATION.md).

---

## Keeping docs in sync

1. Edit `shared/docs/help/orgs/{orgId}/MEMBER_GUIDE.md` (or `_default/`)
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
| [templates/school/README.md](templates/school/README.md) | Canonical school help template source |
| [DATABASE_DESIGN.md](../DATABASE_DESIGN.md) | Data model reference |
| [RBAC_ARCHITECTURE.md](../RBAC_ARCHITECTURE.md) | Permissions |
| [CLIENT_BUILDS.md](../CLIENT_BUILDS.md) | Per-client APK/IPA and `orgId` |
| [ONBOARDING_NEW_SCHOOL.md](../ONBOARDING_NEW_SCHOOL.md) | New school checklist |
