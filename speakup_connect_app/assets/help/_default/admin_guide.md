# Administrator Guide

This generic guide describes administration features that may be available in your organization. **Menus and capabilities vary by org type and assigned permissions.**

---

## Administration menu

If you have admin access, **Settings** shows an **Administration** section. Items appear based on your role and capabilities — you may not see every item listed here.

**Member tip:** students and parents can change app language from the **globe dropdown at the top of Home** or **Settings → Appearance → Language** (**English** / **Bisaya / Cebuano**). Point them there if they cannot read the current UI language.

Common areas:

| Area | Typical use |
|------|-------------|
| My Groups & Clubs | All members — view groups *you* belong to |
| Admin Dashboard | Review and manage submitted reports |
| Groups & Clubs *(Administration)* | Create groups and manage all org rosters |
| Join Applications | Approve new member sign-ups |
| Pending Approvals | Approve pending announcements and group alerts (when enabled) |
| Member Management | Block, unenroll, edit profiles, reset passwords, restore members |
| Roles | Assign staff capabilities |
| Translations | Edit and approve UI strings for org languages (`manageTranslations` or org admin) |

School-type organizations may also show **Student Roster** and **School Grades**.

---

## Reports

Users with report-triage permissions can open the **Admin Dashboard**, update report status, and add admin notes.

---

## Groups and clubs

**Members** see their own groups under **Home** or **Settings → My Groups & Clubs** (read-only).

**Staff with `manageGroupRoster`** (or org admins) use **Settings → Administration → Groups & Clubs** to create groups, add members, review **join/leave requests**, configure join/leave policies, and assign leader/member roles. Some organizations also support **custom club positions** (offices such as President or Secretary).

**Org admins** can **edit member profiles** (name, student ID, email, grade) and **reset passwords** from **Member Management**.

### Official school photos

Org admins and staff with **Student Roster** or **Member Management** access can upload each student’s **official school photo**. This is a **permanent faculty record** — students cannot change, delete, or overwrite it.

- **Settings → Member Management** → edit a member → **Official school photo**
- **Settings → Student Roster** (schools) → tap a student’s **avatar** on their row

When a student later adds a personal badge (if allowed), it is stored **separately** and only affects what they see in the app. The official school photo remains on file for admins.

### Allow personal profile photos

**Settings → Administration → Organization Settings** → **Allow personal profile photos**

- **OFF (default)** — students see the official school photo or initials; tapping the profile circle in Settings shows a message that uploads are disabled
- **ON** — students may add a personal photo in **Settings** (gallery or camera); it does not replace the official school record on file

**Group leaders** (roster role Leader) may manage their group's roster, post **school-wide announcements** on behalf of their club, and send **group alerts** from **My Groups & Clubs** without org-wide broadcast permission.

After adding a member to a group, they should see it under **My Groups & Clubs** within a few seconds.

---

## Announcements

**Home → Announcements** is the organization-wide bulletin board. Admins and staff with `postBulletinOrgWide` can publish directly; group leaders use **Post Announcement** and attribute the source club.

### Compose and edit

When posting or editing:

- Title and message
- **Schedule for later** — send at a chosen date and time instead of immediately
- Optional **expiration** (can count from the scheduled send)
- **Pin to top** — org admins only; pinned posts sort first
- Optional **image** (attach at compose or add/change/remove in **Edit**)
- Optional **Request a response** — free text, checkboxes, or multiple choice; **response required** and **allow changing responses** work the same as group alerts

Authors and admins can **Edit** or **Delete** from the announcement detail screen. Use **My announcements** (or the announcements list for authors) to manage posts — scheduled items show **Scheduled** and the send time until they go live.

Open **View responses** on a post that requested responses to see submitted answers.

When **Require approval before publishing** is enabled under **Organization Settings**, non-approver posts appear in **Pending Approvals** until an admin publishes them (approvers see any scheduled send time).

---

## Reminders (group alerts)

Authorized staff and group leaders can compose group-targeted alerts. Org admins may enable **Require approval before publishing** under **Organization Settings**; pending **announcements** and **alerts** appear under **Pending Approvals**.

Optional **Request a response** supports free text, checkboxes, and multiple choice, plus **response required** and **allow changing responses** (turn off for votes).

---

## Roles and permissions

Org admins can define roles and assign capabilities to staff. See [RBAC_ARCHITECTURE.md](../../RBAC_ARCHITECTURE.md) for the platform permission list.

---

## UI translations

The app can show more than one **UI language** (for example **English**, **Bisaya / Cebuano**, and **Tagalog**). **English** is the source language for all labels and messages. Keeping other languages accurate is an **administration** task for org admins and delegated **translation moderators** — not something regular members do from the Member Guide.

> **Member tip:** students and parents only choose which language *they* see via **Home → globe icon** or **Settings → Appearance → Language**. That is separate from the translation workspace below.

### Assign translation moderators

**Requires:** org admin (or staff with `manageRoles`)

Org admins always have full translation access. To let a teacher, parent volunteer, or staff member edit translations without full admin rights:

1. Open **Settings → Admin Dashboard** → toolbar **Roles & Permissions** (org admin path), or open **Roles & Permissions** directly if your role includes it.
2. **Create Role** or edit an existing role (for example *Bisaya Translator*).
3. Under **Administration**, enable **Translation moderator (edit UI strings)** (`manageTranslations`).
4. Save the role.
5. On the role card, tap **Assign** (or open **Assignments**), search for the user, and confirm the assignment.

The person must be an **approved** organization member. After assignment, they see **Settings → Administration → Translations** but not other admin-only items (unless they have other capabilities).

You can combine `manageTranslations` with other capabilities on the same role if needed.

### Edit and approve UI strings

**Requires:** org admin **or** `manageTranslations` (translation moderator)

1. **Settings → Administration → Translations**
2. Select the **target language** (only languages enabled for your organization are listed).
3. Use **Search** to find a string by key name or English text.
4. For each row:
   - Read the **English source** shown above the field.
   - Type or edit the translation. Keep placeholders such as `{name}` exactly as they appear in English.
   - **Save** — stores your edit as *in review*.
   - **Approve** — marks the string final and ready for export.
   - **AI draft** — optional machine-generated suggestion for that row; always review before approving.
5. The status chip shows progress: `missing`, `ai_draft`, `in_review`, or `approved`.

**Org admins only** (translation moderators do not see these):

- **Translate missing (AI)** — batch AI drafts for all missing strings in the selected language.
- **Export ARB (copy JSON)** — copy approved strings as ARB JSON for app release builds.

Platform operators import the English source key list. School staff focus on reviewing, correcting, and approving target-language text.

### Manage screen names and translation badges

**Requires:** org admin **or** `manageTranslations`

Use this to name app screens, tag translation strings for filtering, and control **where in-context edit badges appear** during translation mode.

**Mobile app:** **Settings → Administration → Translations** → app bar **list icon** → **Screen names**

**Web:** Translation Helper → **Screen names** tab (`speakup_connect_web/tools/translation-helper/`)

| Task | Action |
|------|--------|
| Add a screen name | Enter a name → **Add screen name** |
| Rename | Edit the name → **Save** (updates string labels that used the old name) |
| Assign to an app screen | In **Assign to app screen**, pick a screen name for each route |
| Unassign | **(unassigned)** in the dropdown, or **Unassign route** on the catalog row |
| Enable edit badges | Turn on **Translation badges** for an assigned route — globe badges appear on that screen in translation mode |
| Tag a string | In the translation list (app or web), set **Screen name** on each row |

**Rules:** One screen name per app route at a time. A name already assigned elsewhere must be unassigned before reuse. Badges only appear on routes where **Translation badges** is on **and** the string is wrapped for translation in app code (currently Home, Settings, Login key strings).

### Browse app in translation mode (in-context)

**Requires:** org admin **or** `manageTranslations`

Use this when translators need to see **where** a label appears on a real screen, not only in a searchable list.

1. **Settings → Administration → Translations**
2. Select the **target language** (for example **Bisaya / Cebuano**).
3. Tap **Browse app in translation mode**.
4. A banner appears at the top. The app opens in **English** first so you can read source meaning in context.
5. Use the banner toggle **English | Bisaya / Cebuano** to preview the target language.
6. On screens where **Translation badges** are enabled (see **Manage screen names and translation badges** above), tap the **globe badge** beside a label:
   - Read **English (source)** in the sheet.
   - Edit **Translation**; optionally enable **Approve**.
   - Tap **Save** — queued in your **session** (not on the server yet).
7. Tap **Review** in the banner when done.
8. On the review screen, tap **Save N edits to Firestore**.

**Where edits go:** Firestore `languages/{locale}/strings/{key}` as `in_review` or `approved`. They appear in the web **Translation Helper** after **Refresh**. To ship in the installed app, an org admin still **exports ARB** and releases a new build (see [INTERNATIONALIZATION.md §11](../../INTERNATIONALIZATION.md#11-end-to-end-workflow-canonical) Phase E–G).

**Coverage:** Badge visibility is configured per app screen under **Screen names**. The language preview toggle still works on all screens; use the list workspace or web tool where badges are off.

**Tips:** Exit with **X** on the banner (you are prompted if the session has unsaved edits). Edits use the same Firestore data as the list workspace and web tool.

### Platform setup (deployment lead only)

**Audience:** SpeakUp Connect **deployment lead or developer** — not school org admins. Complete once per Firebase environment before the in-app **Translations** workspace and web Translation Helper will work.

1. **Deploy translation Cloud Functions** (from the repo `shared/functions/` folder):

   ```powershell
   npx firebase-tools deploy --only functions:getTranslationWorkspaceAccess,functions:importTranslationSource,functions:listTranslationEntries,functions:saveTranslationEntry,functions:draftTranslation,functions:batchDraftTranslations,functions:exportTranslationArb
   ```

2. **Seed or update roles** so **`manageTranslations`** appears in the capability catalog:

   ```powershell
   node shared/scripts/seed_roles.js
   ```

   Alternatively, add `manageTranslations` manually to role documents in Firestore. Org admins then assign it through **Roles & Permissions** (see above). Users must **sign out and sign back in** after permissions change.

3. **Optional — AI draft:** set Firebase secret `TRANSLATION_AI_API_KEY` for OpenAI (or configured provider). Manual edit and approve work without it; AI buttons fail until the secret is set.

   **OpenAI API credits (if you run out during batch translation):** AI draft and **Translate missing (AI)** use the key in `shared/functions/.env` (`TRANSLATION_AI_API_KEY`). That key bills against **OpenAI Platform** prepaid balance — **not** a ChatGPT Plus subscription ([chatgpt.com](https://chatgpt.com) and [platform.openai.com](https://platform.openai.com) are billed separately).

   | Resource | URL |
   |----------|-----|
   | Add credits / billing overview | https://platform.openai.com/settings/organization/billing/overview |
   | Usage (spend and tokens) | https://platform.openai.com/usage |
   | API keys | https://platform.openai.com/api-keys |

   To top up: sign in at [platform.openai.com](https://platform.openai.com) → **Settings → Billing** → add a payment method if needed → **Add to balance** / **Buy credits** (minimum is typically **$5**). Consider **auto-recharge** and a **monthly spending limit** so large batch runs do not stop mid-job. If balance is zero, AI callables fail (often `429` or `insufficient_quota` in Firebase logs); manual edit, save, and approve still work.

4. **Import English source (platform `super_admin` only):** use the web **Translation Helper** (`speakup_connect_web/tools/translation-helper/`) or call `importTranslationSource` — upload `speakup_connect_app/lib/l10n/app_en.arb` so target-language rows exist before moderators edit.

5. **Web Translation Helper config:** copy `firebase-config.example.js` → `firebase-config.js`, add the Firebase web app config, and set `ORGANIZATION_ID` for the tenant (e.g. `monhs-ph-001`).

Full operator documentation: `speakup_connect_web/tools/translation-helper/README.md` and [INTERNATIONALIZATION.md](../../INTERNATIONALIZATION.md) §12.

After setup, school org admins assign translation moderators and handle day-to-day editing in the app.

---

## Local policy notes

If your organization has local workflows not covered here, record them in school onboarding SOPs and admin operations notes. Keep Help Center canonical content under `shared/docs/help/school/` and `assets/help/school/`, with `_default` as fallback.
