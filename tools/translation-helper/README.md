# Translation Helper (MVP)

Web workspace for org admins and translation moderators to manage UI translations before exporting ARB files into `lib/l10n/`. In-page help is built into `index.html` (expand **Translation workspace help** or click **Help** after sign-in).
**GitHub issue:** [#48](https://github.com/edbecnel/speakup-connect/issues/48)  
**Design:** [docs/INTERNATIONALIZATION.md §12](../../docs/INTERNATIONALIZATION.md)

## What it does

1. **Import** `lib/l10n/app_en.arb` (English source keys)
2. **List / filter** strings by status, feature prefix, or search
3. **AI draft** single keys or all missing (`draftTranslation`, `batchDraftTranslations` Cloud Functions)
4. **Review** — edit target text, mark `in_review` or `approved`
5. **Export** downloadable `app_ceb.arb` / `app_fil.arb` JSON

Workflow data lives in Firestore: `languages/{locale}/strings/{stringKey}`.

## Prerequisites

- Firebase project `speakup-connect-891dd`
- Signed-in user with JWT custom claim **`role: super_admin`**, **org admin**, or **`manageTranslations`** permission
- Cloud Functions deployed (translation callables)
- For AI draft: secret `TRANSLATION_AI_API_KEY` set (OpenAI by default)

```powershell
cd functions
npx firebase-tools functions:secrets:set TRANSLATION_AI_API_KEY
# Optional params in functions/.env or Firebase params:
# TRANSLATION_AI_PROVIDER=openai
# TRANSLATION_AI_MODEL=gpt-4o-mini
```

Deploy translation functions:

```powershell
firebase deploy --only functions:importTranslationSource,functions:listTranslationEntries,functions:saveTranslationEntry,functions:draftTranslation,functions:batchDraftTranslations,functions:exportTranslationArb
```

## Run locally

1. Copy `firebase-config.example.js` → `firebase-config.js` and add your **Web app** config from Firebase Console. Set `ORGANIZATION_ID` for org admin / moderator sign-in (e.g. `monhs-ph-001`).
2. Serve the folder (any static server):

```powershell
cd tools/translation-helper
npx --yes serve -p 5050
```

3. Open http://localhost:5050 and sign in with a super-admin account.
4. For local Functions emulator, `app.js` auto-connects to `127.0.0.1:5001` when served from localhost.

## Typical operator flow

1. Select target locale (`ceb` or `fil`).
2. **Import** `app_en.arb` from the repo.
3. Click **Translate missing (AI)** — review drafts in the table.
4. Edit rows as needed → **Approve** when ready.
5. **Export ARB** → save as `lib/l10n/app_ceb.arb` (or `app_fil.arb`) and commit with human review.

## Security

- AI API key is **server-side only** (Firebase Secret Manager).
- Callables require platform `super_admin`, org admin, or `manageTranslations` permission; org-scoped actions require `organizationId` in config.
- Do not commit `firebase-config.js` if it contains sensitive keys (web API keys are public by design but keep config local).
## Related Cloud Functions

| Callable | Purpose |
|----------|---------|
| `getTranslationWorkspaceAccess` | Resolve allowed locales and capabilities for caller |
| `listTranslationEntries` | List/filter workflow entries |
| `saveTranslationEntry` | Save target text + status |
| `draftTranslation` | AI draft one key |
| `batchDraftTranslations` | AI draft missing keys (chunked) |
| `exportTranslationArb` | Generate ARB JSON for download |
