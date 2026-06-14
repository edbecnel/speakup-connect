# Translation Helper (MVP)

Web workspace for org admins and translation moderators to manage UI translations before exporting ARB files into `lib/l10n/`. In-page help is built into `index.html` (expand **Translation workspace help** or click **Help** after sign-in).

**End-to-end workflow (canonical — start here):** [docs/INTERNATIONALIZATION.md §11](../docs/INTERNATIONALIZATION.md#11-end-to-end-workflow-canonical)  
**GitHub issue:** [#48](https://github.com/edbecnel/speakup-connect/issues/48)  
**Architecture:** [docs/INTERNATIONALIZATION.md §13](../docs/INTERNATIONALIZATION.md#13-translation-helper-tool)  
**In-app docs:** Help Center → **Administrator Guide** → **UI translations** → **Platform setup**

This README covers **setup commands and troubleshooting** only. The full translate → export → app release checklist lives in **INTERNATIONALIZATION.md §11**.

## What it does

1. **Import** `lib/l10n/app_en.arb` (English source keys) — platform `super_admin` only
2. **List / filter** strings by status, feature, screen, review, or search
3. **AI draft** single keys or all missing (`draftTranslation`, `batchDraftTranslations` Cloud Functions)
4. **Review** — edit target text, mark `in_review` or `approved`
5. **Export** downloadable `app_ceb.arb` / `app_fil.arb` JSON — org admin only
6. **Export CSV** / **Import CSV** — spreadsheet handoff for human translators (all workspace editors)
7. **`populate-csv-screens.js`** — refresh **`screen`** column in a reviewer CSV after `app_en.arb` changes (repo script; see §11 and Step 12)

Workflow data lives in Firestore: `languages/{locale}/strings/{stringKey}`.

### Setup checklist

| Step | What | Where |
|------|------|--------|
| 1 | Firebase CLI login | PowerShell |
| 2 | Deploy Cloud Functions (+ optional `functions/.env` for AI) | PowerShell |
| 3a | Download `scripts/service-account.json` | Firebase Console |
| 3b | Run `node scripts/seed_roles.js` | PowerShell |
| 3c | Assign translation moderator roles | Flutter app |
| 3d | Grant platform `super_admin` (import English only) | PowerShell + `assign_super_admin.js` |
| 4 | Create `firebase-config.js` | Local file |
| 5 | Start web server (`npx serve`) | PowerShell |
| 6–11 | Import, edit, export translations | Browser (+ app for role assign) |

---

## Step-by-step setup (from PowerShell)

Run these in order the **first time** you enable translation editing for an environment. Steps 1–4 are **one-time** per Firebase project. Step 5 is needed **each time** you open the web tool.

> **PowerShell vs browser:** Steps 1–5 use PowerShell only. Steps 6+ use a **browser** at http://localhost:5050. You sign in with the **same Firebase Auth email and password as the mobile app**, but the browser session is separate (signing into the app does not auto-sign you into the web tool).

### Sign-in credentials (read before Step 6)

This project uses **three different logins**. Do not mix them up:

| Used for | What you enter | Example |
|----------|----------------|---------|
| **Step 1** — `npx firebase-tools login` | Your **Google account** (deploy CLI) | Google account that owns the Firebase project |
| **Step 3a–3d, 3b** — Admin scripts | **Service account JSON** file path | `scripts\service-account.json` (not a password) |
| **Step 7** — Translation Helper web page | **Firebase Auth email + password** | Same as SpeakUp Connect **mobile app** login |

**Your web password is your Firebase Authentication password** (Email/Password provider) — the one you use in the Flutter app. It is **not**:

- Your Google password for `firebase-tools login` (unless you chose the same password everywhere)
- Your OpenAI key (`sk-…` — that goes in `functions/.env` only)
- Changed by `assign_super_admin.js` or `assign_admin.js` (those scripts only update roles/claims)

Forgot password? Firebase Console → **Authentication** → **Users** → select user → **Reset password**.

**Requirements:** [Node.js](https://nodejs.org/) (includes `npm` / `npx`). You can run from **any** folder in the repo; paths below are examples.

This project uses **`npx firebase-tools`** so you do not need a global `firebase` command on your PATH. If you prefer a global install: `npm install -g firebase-tools`, then you may use `firebase` instead of `npx firebase-tools`.

### Step 1 — Firebase CLI login (one-time per machine)

```powershell
npx firebase-tools login
```

A browser window opens to sign in with your Google account (Firebase/Google Cloud access to project `speakup-connect-891dd`).

Confirm the active project:

```powershell
cd D:\Dev\Speakup-Connect\functions
npx firebase-tools use speakup-connect-891dd
```

### Step 2 — Deploy translation Cloud Functions (one-time per deploy)

From the repo `functions/` folder. Choose **Option A** or **Option B** depending on whether you want AI draft.

#### Option A — Deploy without AI (manual edit/approve only)

```powershell
cd D:\Dev\Speakup-Connect\functions
npm run build
npx firebase-tools deploy --only functions:getTranslationWorkspaceAccess,functions:importTranslationSource,functions:importTranslationTargets,functions:listTranslationEntries,functions:saveTranslationEntry,functions:draftTranslation,functions:batchDraftTranslations,functions:exportTranslationArb
```

List, save, approve, and export work. **AI draft** and **Translate missing (AI)** return an error until you complete **Option B** (or **Option B follow-up** below).

#### Option B — Deploy with AI draft (recommended if you want AI)

Set the API key **before** deploy so AI works immediately after deploy:

```powershell
cd D:\Dev\Speakup-Connect\functions

# 1. Create .env from the example and add your OpenAI key
Copy-Item .env.example .env
# Edit .env → TRANSLATION_AI_API_KEY=sk-your-key-here
# Optional: TRANSLATION_AI_PROVIDER=openai  TRANSLATION_AI_MODEL=gpt-4o-mini

# 2. Build and deploy (deploy reads functions/.env)
npm run build
npx firebase-tools deploy --only functions:getTranslationWorkspaceAccess,functions:importTranslationSource,functions:importTranslationTargets,functions:listTranslationEntries,functions:saveTranslationEntry,functions:draftTranslation,functions:batchDraftTranslations,functions:exportTranslationArb
```

Do **not** commit `functions/.env`.

#### Option B follow-up — Already deployed without `.env`?

Add the key, then redeploy the AI callables (or run the full deploy command from Option B again):

```powershell
cd D:\Dev\Speakup-Connect\functions
Copy-Item .env.example .env
# Edit .env → TRANSLATION_AI_API_KEY=sk-your-key-here
npm run build
npx firebase-tools deploy --only functions:draftTranslation,functions:batchDraftTranslations
```

Re-run the deploy command whenever translation function code changes in git.

### Step 3 — Seed or update roles (one-time, or after permission changes)

This writes role definitions to Firestore so **`manageTranslations`** appears in **Roles & Permissions** in the app. Org admins can then assign **Translation moderator** to staff.

#### Do you need this step?

| Your goal | Need Step 3? |
|-----------|----------------|
| Test translation editing as **org admin** yourself | **Optional** — org admins already have translation access |
| Assign **Translation moderator** to other users | **Yes** — seed or manual Firestore edit |
| Refresh role catalog after adding new permissions in code | **Yes** — re-run seed (safe to run again) |

#### Step 3a — Download service account key (one-time per machine)

The seed script uses the Firebase **Admin SDK**. It does **not** use your `firebase login` session — it needs a JSON key file that is **not** in git.

1. Open Firebase Console → **Project settings** → **Service accounts**:  
   https://console.firebase.google.com/project/speakup-connect-891dd/settings/serviceaccounts/adminsdk

2. Click **Generate new private key** → confirm **Generate key**.

3. Save the downloaded JSON file to this exact path (use this file name exactly):

   ```
   D:\Dev\Speakup-Connect\scripts\service-account.json
   ```

4. **Do not commit** this file — it is listed in `.gitignore`. If it is ever exposed, revoke the key in Google Cloud Console and generate a new one.

If you see `ENOENT: no such file or directory, open '...\scripts\service-account.json'`, the file is missing or saved under a different name/path — repeat steps 1–3.

#### Step 3b — Run the seed script

```powershell
cd D:\Dev\Speakup-Connect
$env:GOOGLE_APPLICATION_CREDENTIALS = "scripts\service-account.json"
node scripts/seed_roles.js
```

**Expected output:**

```
✅  Seeded 6 roles into organizations/monhs-ph-001/roles

  • [SYSTEM] org-admin — Organization Admin
  • [SYSTEM] member — Member
  • [starter] guidance-counselor — Guidance Counselor
  ...
```

The script is **idempotent** — safe to re-run. It merges updates into existing role documents (including adding `manageTranslations` to **Organization Admin**).

#### Step 3c — Assign translation moderator (in Flutter app)

After seeding, org admins assign the capability in the app (not PowerShell):

1. **Settings → Admin Dashboard → Roles & Permissions**
2. Create or edit a role (e.g. *Cebuano Translator*)
3. Under **Administration**, enable **Translation moderator (edit UI strings)**
4. **Assign** the role to an approved member

The assignee must **sign out and sign back in** (app or web Translation Helper) so permissions refresh.

#### Alternative — Manual Firestore edit (no service account)

If you cannot create a service account key:

1. Open [Firestore](https://console.firebase.google.com/project/speakup-connect-891dd/firestore)
2. Navigate to `organizations` → `monhs-ph-001` → `roles` → `org-admin` (or another role document)
3. Edit the `capabilities` array — ensure it includes the string `manageTranslations`
4. Save

Then assign roles in the app as in **Step 3c**.

#### Step 3d — Grant platform super_admin (deployment lead, one-time)

Required only for **Import `app_en.arb`** in the web Translation Helper. Org admins can edit, approve, and export without this.

| Role | Import English? | How it is granted |
|------|-----------------|-------------------|
| Org admin | No | `assign_admin.js` or app enrollment |
| Platform `super_admin` | Yes | `assign_super_admin.js` (below) |

**Prerequisites:**

- Account already registered in the **mobile app** (Firebase Auth user exists).
- Firestore profile exists at `organizations/monhs-ph-001/users/{uid}` (joined MONHS).
- `scripts/service-account.json` in place (**Step 3a**).

**Run** (replace with your Firebase Auth email — same email as app login):

```powershell
cd D:\Dev\Speakup-Connect
$env:GOOGLE_APPLICATION_CREDENTIALS = "scripts\service-account.json"
node scripts/assign_super_admin.js your-firebase-auth-email@example.com
```

**What the script does:**

- Sets Firestore profile `role` to `super_admin`
- Sets JWT custom claim `role: super_admin` and full `permissions` list
- Creates org-admin role assignment if missing

**What the script does not do:** create the Auth user, set your password, or register you in the app.

**Expected output:**

```
Looking up user: your-firebase-auth-email@example.com
Found UID: xxxxxxxxxxxxxxxxxxxxxx

✅  "your-firebase-auth-email@example.com" is now platform super_admin for monhs-ph-001.
Sign out and sign back in on the Translation Helper web page and Flutter app.
You should see Import app_en.arb in the web Translation Helper.
```

**After running:**

1. Sign **out** on http://localhost:5050 (or close the tab).
2. Sign **in** again with your **app email + Firebase Auth password** (see **Sign-in credentials** above).
3. Confirm **Import `app_en.arb`** appears in the toolbar.

If Import still does not appear, hard-refresh the page or try a private browser window after sign-in.

### Step 4 — Web app config (one-time per machine)

This file lets the Translation Helper sign in with **Firebase Auth** in the browser. It is **not** where your OpenAI key goes — that stays in `functions/.env` (Step 2).

```powershell
cd D:\Dev\Speakup-Connect\tools\translation-helper
Copy-Item firebase-config.example.js firebase-config.js
```

#### Step 4a — Get Firebase web app values from the Console

1. Open **Project settings** (gear icon) → **General** tab:  
   https://console.firebase.google.com/project/speakup-connect-891dd/settings/general

2. Scroll to **Your apps**.

3. **If you already have a Web app** (`</>` icon):
   - Click the web app name.
   - Choose **Config** (not npm / CDN snippets).
   - You will see a `firebaseConfig` object like:
     ```javascript
     const firebaseConfig = {
       apiKey: "AIzaSy...",
       authDomain: "speakup-connect-891dd.firebaseapp.com",
       projectId: "speakup-connect-891dd",
       storageBucket: "speakup-connect-891dd.firebasestorage.app",
       messagingSenderId: "212080957929",
       appId: "1:212080957929:web:xxxxxxxx"
     };
     ```

4. **If there is no Web app yet:**
   - Click **Add app** → choose **Web** (`</>`).
   - Nickname: e.g. `Translation Helper` (any label is fine).
   - **Do not** enable Firebase Hosting unless you want it — not required for local `npx serve`.
   - Click **Register app** → copy the `firebaseConfig` values shown.

#### Step 4b — Paste values into `firebase-config.js`

Open `tools/translation-helper/firebase-config.js` and fill in **only** the placeholders. The example file already has correct values for this project except the two marked `YOUR_*`:

| Field in `firebase-config.js` | Copy from Firebase `firebaseConfig` | Example shape |
|-------------------------------|-------------------------------------|---------------|
| `apiKey` | `apiKey` | Starts with `AIzaSy…` (Firebase **Web API Key**) |
| `authDomain` | `authDomain` | Already `speakup-connect-891dd.firebaseapp.com` in the example |
| `projectId` | `projectId` | Already `speakup-connect-891dd` |
| `storageBucket` | `storageBucket` | Already set in the example |
| `messagingSenderId` | `messagingSenderId` | Already `212080957929` in the example |
| `appId` | `appId` | Starts with `1:212080957929:web:` |

**Common mistake:** putting your **OpenAI** key (`sk-…`) in `apiKey`. That field must be the Firebase **Web API Key** (`AIzaSy…`). OpenAI belongs only in `functions/.env` → `TRANSLATION_AI_API_KEY`.

Example after editing (use **your** values from the Console):

```javascript
window.FIREBASE_CONFIG = {
  apiKey: 'AIzaSy........................',
  authDomain: 'speakup-connect-891dd.firebaseapp.com',
  projectId: 'speakup-connect-891dd',
  storageBucket: 'speakup-connect-891dd.firebasestorage.app',
  messagingSenderId: '212080957929',
  appId: '1:212080957929:web:abcdef123456',
};

/** Required for org admins and translation moderators (not platform super_admin). */
window.ORGANIZATION_ID = 'monhs-ph-001';
```

#### Step 4c — Organization id

Keep `ORGANIZATION_ID` as your school tenant id (`monhs-ph-001` for MONHS). **Required** when signing in as org admin or translation moderator. Platform `super_admin` can leave it as-is.

**Enable Email/Password sign-in:** Firebase Console → **Build** → **Authentication** → **Sign-in method** → ensure **Email/Password** is enabled (same as the mobile app).

### Step 5 — Start the local web server (each session)

```powershell
cd D:\Dev\Speakup-Connect\tools\translation-helper
npx --yes serve -p 5050
```

Leave this terminal open. The tool is served at **http://localhost:5050**.

**Local Functions emulator (optional):** if you run `firebase emulators:start --only functions`, `app.js` auto-connects to `127.0.0.1:5001` when the page is loaded from localhost. Otherwise calls go to deployed Cloud Functions.

---

## Step-by-step usage (in the browser)

### Step 6 — Open the Translation Helper

Open **http://localhost:5050** in Chrome/Edge/Firefox (not the Flutter app). Ensure Step 5 (`npx serve`) is still running.

### Step 7 — Sign in on the web page

Enter your **Firebase Auth email and password** — the **same credentials as the SpeakUp Connect mobile app** (see **Sign-in credentials** at the top of this guide).

| Who | Access | Password |
|-----|--------|----------|
| Platform operator | JWT claim `role: super_admin` (**Step 3d**) | App Firebase Auth password |
| Org admin | Firestore profile `role: admin` for the org | App Firebase Auth password |
| Translation moderator | Role with `manageTranslations` | App Firebase Auth password |

The web tool uses a **separate browser session** from the mobile app. Signing into the app on your phone does not sign you into http://localhost:5050 — you must sign in on the web page too (same email/password).

If sign-in fails with *Access denied*, check Step 3 (roles seeded), confirm `ORGANIZATION_ID` in `firebase-config.js`, and sign out/in after role changes.

If you ran **Step 3d** but **Import `app_en.arb`** is missing, sign out and sign in again so the JWT picks up `super_admin`.

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

See **[INTERNATIONALIZATION.md §11 — Phase E–G](../docs/INTERNATIONALIZATION.md#phase-e--export-arb)** for export, `flutter gen-l10n`, hot restart, and commit.

1. Click **Export ARB**.
2. Save the JSON as `lib/l10n/app_ceb.arb` or `lib/l10n/app_fil.arb`.
3. Run `flutter gen-l10n`, hot restart the app, then commit ARB + generated Dart files.

### Step 12 — Human translator via Google Sheets (optional)

1. Click **Export CSV** for the target locale (or use `lib/l10n/ceb_translations.csv` / `fil` equivalent in the repo).
2. **Populate the `screen` column** (required after `app_en.arb` changes or new keys):

   ```powershell
   cd D:\Dev\Speakup-Connect
   node tools/translation-helper/populate-csv-screens.js lib/l10n/ceb_translations.csv
   ```

   This scans Dart usage under `lib/` and fills **`screen`** so reviewers know where each string appears. Re-run whenever English keys are added or moved. See [INTERNATIONALIZATION.md §11 — Populate screen column](../docs/INTERNATIONALIZATION.md#populate-screen-column-for-reviewer-csv).

3. Upload the CSV to Google Sheets (or Excel) and share with your translator.
4. Translator edits **`translation`**; optional **`notes`**, **`verified`**, **`status`**. Keep **`key`** and ICU placeholders (`{name}`, etc.) unchanged.
5. Download the sheet as CSV from Google Sheets.
6. Click **Import CSV** in the Translation Helper, confirm, then review imported rows (`screen` → Firestore `context`; `notes` / `verified` are session-only until re-import).
7. Approve strings in the workspace (or set `status` column to `approved` in the CSV before import).
8. Org admin: **Export ARB** when ready for release (Step 11).

**CSV columns:** `key`, `screen`, `english`, `translation`, `notes`, `verified`, `status` (last four optional except `translation` on import). Legacy four-column CSVs still work.

**Scripts:** `map-l10n-screens.js` (key → screen map), `populate-csv-screens.js` (updates a CSV file in place).

---

## Quick reference — who can do what

| Action | Translation moderator | Org admin | Platform super_admin |
|--------|----------------------|-----------|----------------------|
| Edit / Save / Approve | Yes | Yes | Yes |
| AI draft (single row) | Yes | Yes | Yes |
| Translate missing (AI batch) | No | Yes | Yes |
| Export CSV / Import CSV | Yes | Yes | Yes |
| Export ARB | No | Yes | Yes |
| Import `app_en.arb` | No | No | Yes |

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| `Secret Manager API... disabled` (403) on deploy | Pull latest code — translation functions use `functions/.env`, not Secret Manager. Redeploy after `git pull`. |
| `TRANSLATION_AI_API_KEY is not set` when using AI draft | Copy `functions/.env.example` → `functions/.env`, add your key, redeploy (see Step 2 Option B follow-up) |
| AI batch stops or fails with quota / 429 errors | OpenAI Platform prepaid balance is empty. Add credits at https://platform.openai.com/settings/organization/billing/overview (not ChatGPT Plus). Check usage at https://platform.openai.com/usage. Minimum top-up is typically $5. Enable auto-recharge in Billing settings for long batch jobs. |
| `firebase` / command not found | Use `npx firebase-tools` instead of `firebase` (see Step 1) |
| `ENOENT ... service-account.json` on seed | Complete **Step 3a** — download key and save as `scripts\service-account.json` |
| Access denied on web sign-in | Complete Step 3, set `ORGANIZATION_ID` in `firebase-config.js`, sign out/in after role assignment |
| No **Import `app_en.arb`** after Step 3d | Sign out/in on web tool; confirm `assign_super_admin.js` succeeded; use app Firebase Auth password |
| **Translate missing (AI)** seems to do nothing | Hard-refresh http://localhost:5050. Status now appears **below the toolbar** (green/red banner). Ensure `USE_FUNCTIONS_EMULATOR = false` in `firebase-config.js` unless the emulator is running. Redeploy functions if you see `TRANSLATION_AI_API_KEY is not set`. |
| `functions/internal` on **Refresh** | Hard-refresh http://localhost:5050 (Ctrl+Shift+R). Sign out/in so JWT picks up `super_admin`. Confirm `USE_FUNCTIONS_EMULATOR = false` in `firebase-config.js`. Open the tool at **http://localhost:5050** on the same machine running `npx serve` (not another device IP unless emulator is off). Redeploy `listTranslationEntries` and `getTranslationWorkspaceAccess` if logs show a server error. |
| `Missing firebase-config.js` or `YOUR_API_KEY` in browser | Complete Step 4 — use Firebase `apiKey` (`AIzaSy…`), not OpenAI (`sk-…`) |

---

## Security

- Put `TRANSLATION_AI_API_KEY` in `functions/.env` (gitignored) — not in the app or git.
- Callables require platform `super_admin`, org admin, or `manageTranslations`; org-scoped calls require `organizationId` in `firebase-config.js`.
- Do not commit `firebase-config.js`, `functions/.env`, or `scripts/service-account.json`.

## Related scripts

| Script | Purpose |
|--------|---------|
| `scripts/seed_roles.js` | Seed role definitions including `manageTranslations` |
| `scripts/assign_admin.js` | Grant org admin for a Firebase Auth email |
| `scripts/assign_super_admin.js` | Grant platform `super_admin` (Import English in web tool) |

## Related Cloud Functions

| Callable | Purpose |
|----------|---------|
| `getTranslationWorkspaceAccess` | Resolve allowed locales and capabilities for caller |
| `importTranslationSource` | Import English keys from ARB (super_admin) |
| `listTranslationEntries` | List/filter workflow entries |
| `saveTranslationEntry` | Save target text + status |
| `draftTranslation` | AI draft one key |
| `batchDraftTranslations` | AI draft missing keys (chunked) |
| `batchSaveAiDrafts` | Copy all `ai_draft` rows to `in_review` |
| `batchApproveSavedTranslations` | Approve all saved/in-review rows |
| `exportTranslationArb` | Generate ARB JSON for download |
| `importTranslationTargets` | Batch import target translations from CSV |
