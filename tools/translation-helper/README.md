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

### Setup checklist

| Step | What | Where |
|------|------|--------|
| 1 | Firebase CLI login | PowerShell |
| 2 | Deploy Cloud Functions (+ optional `functions/.env` for AI) | PowerShell |
| 3a | Download `scripts/service-account.json` | Firebase Console |
| 3b | Run `node scripts/seed_roles.js` | PowerShell |
| 3c | Assign translation moderator roles | Flutter app |
| 4 | Create `firebase-config.js` | Local file |
| 5 | Start web server (`npx serve`) | PowerShell |
| 6–11 | Import, edit, export translations | Browser (+ app for role assign) |

---

## Step-by-step setup (from PowerShell)

Run these in order the **first time** you enable translation editing for an environment. Steps 1–4 are **one-time** per Firebase project. Step 5 is needed **each time** you open the web tool.

> **PowerShell vs browser:** Steps 1–5 use PowerShell only — you do **not** sign into the Flutter app. Steps 6+ use a **browser** at http://localhost:5050 with email/password (separate from the mobile app sign-in).

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
npx firebase-tools deploy --only functions:getTranslationWorkspaceAccess,functions:importTranslationSource,functions:listTranslationEntries,functions:saveTranslationEntry,functions:draftTranslation,functions:batchDraftTranslations,functions:exportTranslationArb
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
npx firebase-tools deploy --only functions:getTranslationWorkspaceAccess,functions:importTranslationSource,functions:listTranslationEntries,functions:saveTranslationEntry,functions:draftTranslation,functions:batchDraftTranslations,functions:exportTranslationArb
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

### Step 4 — Web app config (one-time per machine)

```powershell
cd D:\Dev\Speakup-Connect\tools\translation-helper
Copy-Item firebase-config.example.js firebase-config.js
```

Edit `firebase-config.js`:

1. Replace `YOUR_API_KEY` and `YOUR_WEB_APP_ID` with values from **Firebase Console → Project settings → Your apps → Web app** (create a web app if none exists).
2. Set `ORGANIZATION_ID` to your tenant id (e.g. `monhs-ph-001`). **Required** for org admin and translation moderator sign-in. Platform `super_admin` can omit or ignore it.

Do **not** commit `firebase-config.js`.

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

## Troubleshooting

| Error | Fix |
|-------|-----|
| `Secret Manager API... disabled` (403) on deploy | Pull latest code — translation functions use `functions/.env`, not Secret Manager. Redeploy after `git pull`. |
| `TRANSLATION_AI_API_KEY is not set` when using AI draft | Copy `functions/.env.example` → `functions/.env`, add your key, redeploy (see Step 2 Option B follow-up) |
| `firebase` / command not found | Use `npx firebase-tools` instead of `firebase` (see Step 1) |
| `ENOENT ... service-account.json` on seed | Complete **Step 3a** — download key and save as `scripts\service-account.json` |
| Access denied on web sign-in | Complete Step 3, set `ORGANIZATION_ID` in `firebase-config.js`, sign out/in after role assignment |

---

## Security

- Put `TRANSLATION_AI_API_KEY` in `functions/.env` (gitignored) — not in the app or git.
- Callables require platform `super_admin`, org admin, or `manageTranslations`; org-scoped calls require `organizationId` in `firebase-config.js`.
- Do not commit `firebase-config.js`, `functions/.env`, or `scripts/service-account.json`.

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
