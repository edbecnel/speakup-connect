# Translation Helper (MVP)

Web workspace for org admins and translation moderators to manage UI translations before exporting ARB files into `lib/l10n/`. In-page help is built into `index.html` (expand **Translation workspace help** or click **Help** after sign-in).

**GitHub issue:** [#48](https://github.com/edbecnel/speakup-connect/issues/48)  
**Design:** [docs/INTERNATIONALIZATION.md §12](../../docs/INTERNATIONALIZATION.md)  
**In-app docs:** Help Center → **Administrator Guide** → **UI translations** → **Platform setup**

## What it does

1. **Import** `lib/l10n/app_en.arb` (English source keys) — platform `super_admin` only
2. **List / filter** strings by status, feature prefix, or search
3. **AI draft** single keys or all missing (`draftTranslation`, `batchDraftTranslations` Cloud Functions)
4. **Review** — edit target text, mark `in_review` or `approved`
5. **Export** downloadable `app_ceb.arb` / `app_fil.arb` JSON — org admin only

Workflow data lives in Firestore: `languages/{locale}/strings/{stringKey}`.

---

## Step-by-step setup (from PowerShell)

Run these in order the **first time** you enable translation editing for an environment. Steps 1–4 are **one-time** per Firebase project. Steps 5–6 are needed **each time** you open the web tool.

> **PowerShell vs browser:** Steps 1–4 and 6 use PowerShell only — you do **not** sign into the Flutter app. Step 7+ use a **browser** at http://localhost:5050 with email/password (separate from the mobile app sign-in).

### Step 1 — Firebase CLI login (one-time per machine)

```powershell
firebase login
```

Confirm the active project:

```powershell
cd D:\Dev\Speakup-Connect\functions
firebase use speakup-connect-891dd
```

### Step 2 — Deploy translation Cloud Functions (one-time per deploy)

From the repo `functions/` folder:

```powershell
cd D:\Dev\Speakup-Connect\functions
firebase deploy --only functions:getTranslationWorkspaceAccess,functions:importTranslationSource,functions:listTranslationEntries,functions:saveTranslationEntry,functions:draftTranslation,functions:batchDraftTranslations,functions:exportTranslationArb
```

Re-run this command whenever translation function code changes in git.

### Step 3 — Seed or update roles (one-time, or after permission changes)

This adds **`manageTranslations`** to the capability catalog in Firestore so org admins can assign **Translation moderator** roles in the app.

**Authentication:** download a service account key (Firebase Console → Project settings → Service accounts → Generate new private key) and save as `scripts/service-account.json` (gitignored).

```powershell
cd D:\Dev\Speakup-Connect
$env:GOOGLE_APPLICATION_CREDENTIALS = "scripts\service-account.json"
node scripts/seed_roles.js
```

**Alternative:** add `manageTranslations` manually to a role document in Firestore under `organizations/{orgId}/roles/`.

After assigning a role to a user in the app, that user must **sign out and sign back in** (app or web) so permissions refresh.

### Step 4 — Optional: AI draft secret (one-time)

Skip if you only need manual edit/approve. Required for **AI draft** and **Translate missing (AI)** buttons.

```powershell
cd D:\Dev\Speakup-Connect\functions
npx firebase-tools functions:secrets:set TRANSLATION_AI_API_KEY
```

Optional env/params (see `functions/.env` or Firebase params):

- `TRANSLATION_AI_PROVIDER=openai`
- `TRANSLATION_AI_MODEL=gpt-4o-mini`

### Step 5 — Web app config (one-time per machine)

```powershell
cd D:\Dev\Speakup-Connect\tools\translation-helper
Copy-Item firebase-config.example.js firebase-config.js
```

Edit `firebase-config.js`:

1. Replace `YOUR_API_KEY` and `YOUR_WEB_APP_ID` with values from **Firebase Console → Project settings → Your apps → Web app** (create a web app if none exists).
2. Set `ORGANIZATION_ID` to your tenant id (e.g. `monhs-ph-001`). **Required** for org admin and translation moderator sign-in. Platform `super_admin` can omit or ignore it.

Do **not** commit `firebase-config.js`.

### Step 6 — Start the local web server (each session)

```powershell
cd D:\Dev\Speakup-Connect\tools\translation-helper
npx --yes serve -p 5050
```

Leave this terminal open. The tool is served at **http://localhost:5050**.

**Local Functions emulator (optional):** if you run `firebase emulators:start --only functions`, `app.js` auto-connects to `127.0.0.1:5001` when the page is loaded from localhost. Otherwise calls go to deployed Cloud Functions.

---

## Step-by-step usage (in the browser)

Open **http://localhost:5050** in Chrome/Edge/Firefox (not the Flutter app).

### Step 7 — Sign in on the web page

Enter **email + password** for a Firebase Auth account with translation access:

| Who | Access |
|-----|--------|
| Platform operator | Auth user with custom claim `role: super_admin` |
| Org admin | Firestore user profile with `role: admin` (or `owner`) for the org |
| Translation moderator | Role assignment including `manageTranslations` |

This sign-in is **only for the web Translation Helper**. It is not the same session as the mobile app, even if you use the same email.

If sign-in fails with *Access denied*, check Step 3 (roles seeded), confirm `ORGANIZATION_ID` in `firebase-config.js`, and sign out/in after role changes.

**Alternative:** skip the web tool and use **Settings → Administration → Translations** in the Flutter app (same permissions).

### Step 8 — Import English source (platform super_admin only)

1. Select target locale (`ceb` or `fil`).
2. Click **Import `app_en.arb`** and choose `D:\Dev\Speakup-Connect\lib\l10n\app_en.arb`.
3. Wait for the success message, then **Refresh**.

Org admins and translation moderators **cannot** import — they edit rows created by this step.

### Step 9 — Assign translation moderators (org admin, in Flutter app)

Optional. Org admins already have full translation access.

1. **Settings → Admin Dashboard → Roles & Permissions**
2. Create or edit a role → enable **Translation moderator (edit UI strings)**
3. **Assign** the role to an approved member

See Administrator Guide → **UI translations** in Help Center.

### Step 10 — Edit and approve translations

In the web tool (or in-app **Translations** screen):

1. Select **Target locale**.
2. Filter or **Search** for strings.
3. Edit the **Target** column; click **Save** (`in_review`) or **Approve** (`approved`).
4. Optional: **AI draft** on one row, or **Translate missing (AI)** for all missing (org admin only).
5. Keep placeholders like `{name}` exactly as in English.

### Step 11 — Export ARB (org admin only)

1. Click **Export ARB**.
2. Save the JSON as `lib/l10n/app_ceb.arb` or `lib/l10n/app_fil.arb`.
3. Commit with human review.

---

## Quick reference — who can do what

| Action | Translation moderator | Org admin | Platform super_admin |
|--------|----------------------|-----------|----------------------|
| Edit / Save / Approve | Yes | Yes | Yes |
| AI draft (single row) | Yes | Yes | Yes |
| Translate missing (AI batch) | No | Yes | Yes |
| Export ARB | No | Yes | Yes |
| Import `app_en.arb` | No | No | Yes |

---

## Security

- AI API key is **server-side only** (Firebase Secret Manager).
- Callables require platform `super_admin`, org admin, or `manageTranslations`; org-scoped calls require `organizationId` in `firebase-config.js`.
- Do not commit `firebase-config.js` or `scripts/service-account.json`.

## Related Cloud Functions

| Callable | Purpose |
|----------|---------|
| `getTranslationWorkspaceAccess` | Resolve allowed locales and capabilities for caller |
| `importTranslationSource` | Import English keys from ARB (super_admin) |
| `listTranslationEntries` | List/filter workflow entries |
| `saveTranslationEntry` | Save target text + status |
| `draftTranslation` | AI draft one key |
| `batchDraftTranslations` | AI draft missing keys (chunked) |
| `exportTranslationArb` | Generate ARB JSON for download |
