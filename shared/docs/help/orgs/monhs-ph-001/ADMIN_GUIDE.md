# Administrator Guide — MONHS

> **Organization:** `monhs-ph-001` (Misamis Oriental National High School pilot)  
> This guide is **school-specific** — student roster, grades, SSLG demo groups, and student ID login apply to MONHS. Other tenants maintain separate guides under `shared/docs/help/orgs/{orgId}/`.

This guide is for MONHS administrators and staff with delegated capabilities (report triage, group management, reminders, etc.). Sections note which permissions are required.

---

## Administration menu

**Member tip:** students and parents can change app language from the **globe dropdown at the top of Home** or **Settings → Appearance → Language** (**English** / **Bisaya / Cebuano**).

Open **Settings**. If you have admin access, you will see an **Administration** section with some or all of:

| Item | Typical permission |
|------|-------------------|
| My Groups & Clubs | All members — groups *you* belong to (not admin-only) |
| Admin Dashboard | `viewAllReports` / `manageReports` or org admin |
| Groups & Clubs *(Administration)* | `manageGroupRoster` or org admin — manage *all* org groups |
| Join Applications | Org admin |
| Pending Approvals | Org admin or `approveReminders` — announcements and group alerts |
| Member Management | Org admin |
| Student Roster | Org admin (schools with grade levels) |
| School Grades | Org admin |
| Translations | Org admin or `manageTranslations` — edit UI strings for org languages |

If you only see some items, your role has partial capabilities — read the matching sections below.

---

## Join applications

**Requires:** Org admin

1. **Settings → Join Applications**
2. Review pending sign-ups (name, student ID, email)
3. **Approve** to enroll the member, or **Reject** with an optional reason

Approved members can sign in and use the app. Rejected applicants see the rejection reason.

---

## Member management

**Requires:** Org admin

**Settings → Member Management**

- View all enrolled members (filter by status, grade, search)
- Tap a member row or **⋮ → Edit profile…** to open the edit screen
- **Block** — temporarily or permanently restrict access
- **Unenroll** — remove from the organization
- **Unblock / Re-enroll** — restore access when appropriate
- **Assign grade** — set grade level (when school grades are enabled)

### Edit member profile

**Requires:** Org admin

From **Member Management**, tap a member or choose **Edit profile…**:

| Field | Notes |
|-------|--------|
| **Full name** | Display / roster name |
| **Student ID (username)** | Sign-in username; must be unique |
| **Contact email** | Optional; member can also edit their own in Settings |
| **Grade** | Synced to roster when grades are enabled |
| **Official school photo** | Tap the photo circle to upload or replace the student’s ID photo |

Members cannot edit their own student ID from the app.

### Official school photos

Org admins can upload each student’s **official school ID photo** on **Edit member profile** (photo at top of screen). Staff with roster access can also tap a student’s **avatar** on **Student Roster** to upload or replace the photo.

This is the **permanent school record** for faculty — students cannot change or overwrite it. If a student adds a personal badge later, it is stored separately (see below).

### Allow personal profile photos

**Settings → Administration → Organization Settings** → **Allow personal profile photos**

- **OFF (default)** — students see the official school photo or initials; tapping the profile circle in Settings shows that uploads are disabled
- **ON** — students may add a personal photo in **Settings** (gallery or camera); the official school photo remains on file for admins

### Reset member password

**Requires:** Org admin

From **Edit profile** or **Member Management → ⋮ → Reset password…**:

1. Enter a new password (or use shortcuts):
   - **Use username / student ID** — sets password to their student ID
   - **Generate 8-digit password** — random numeric password
2. Tap **Continue**, then confirm **Reset password**

Tell the member the new password securely. They sign in with **either** their student ID **or** contact email plus the new password.

> Email notification of password resets is planned for a future release.

Blocked users see an explanation screen and cannot use member features.

---

## Student roster and provisioning

**Requires:** Org admin (school/university org types with grades)

### School grades

**Settings → School Grades** — define which grade levels your school uses (e.g. Grade 7–12). Required before roster features are useful.

### Adding a student (admin provisioned)

**Settings → Student Roster → Add Student** (FAB)

1. **Full name** — display name in the app
2. **Student ID** — school-issued ID (minimum 6 characters, unique in the org)
3. **Email** — optional; if omitted, a synthetic login is created
4. **Grade** — required for schools

The student signs in with **student ID or contact email** and the password you set (initial default is often the student ID until reset). See the Member Guide.

### Bulk import

CSV/PDF bulk import is planned; use **Add Student** for pilot walkthroughs.

---

## Groups and clubs

### What members see (all users)

Students and staff view their own memberships under:

- **Home → My Groups & Clubs**
- **Settings → My Groups & Clubs**
- **Settings → Browse Groups & Clubs** — discover clubs and **request to join** when allowed

They see group name, Leader/Member role, and club position. Members can **request to join** open clubs or **leave** / **request to leave** depending on each group’s policy.

After you add someone to a group, tell them to check **My Groups & Clubs** or pull to refresh on **Home**.

### Managing all org groups (admins)

**Requires:** `manageGroupRoster` or org admin

**Settings → Administration → Groups & Clubs**

### Demo seed (MONHS pilot)

Use the **⋮ menu → Seed Demo Groups** to create:

- Special Program in Journalism (SPJ)
- Drum and Lyre Corps
- Supreme Secondary Learner Government (SSLG)

Safe to re-run; updates names/descriptions without wiping rosters.

### Create a group

1. **Groups & Clubs → Create Group**
2. Enter name and optional description
3. Optionally enable **Define club positions** and add offices (President, Treasurer, etc.)
4. Create — you are taken to the member roster

### Club positions (custom offices)

Groups can define **custom position labels** independent of Leader/Member permissions:

| Concept | Purpose |
|---------|---------|
| **Leader / Member** | Roster permission (who can help manage the group) |
| **Club position** | Display office (President, Secretary, Other, etc.) |

**Define positions:**

- When creating a group — toggle **Define club positions**
- On an existing group — **Edit Group** (admins and `manageGroupRoster` only) → **Define club positions**

**Assign positions:**

- **Add Members** — optional **Club position** dropdown
- Member **⋮ menu** on roster — **Assign position**

Members are sorted by position order, then name. SSLG seed includes default offices: President, Vice President, Treasurer, Secretary, Other.

### Manage roster

- **Add Members** — search approved org members, set Leader/Member and optional position
- **⋮ menu** on a member — change leader status, assign position, or remove (removed members get an **Alerts** notification)
- **Requests** — review **join** and **leave** requests (same screen group leaders use)

### Edit group settings

Open **Edit Group** from:

- **Administration → Groups & Clubs** — pencil icon on a row, or the card at the top of the roster after you open a group
- **My Groups & Clubs** — **Edit Group** on a group you lead

One screen covers:

- Group **name** and **description**
- **Allow join requests** and optional **join hint**
- **Leave policy** — voluntary leave vs approval required
- **Define club positions** (admins / `manageGroupRoster` only)
- **Group is active** (org admin only — inactive groups are hidden from browse)

Org admins can open any group under **Groups & Clubs** and use **Requests** even if not on the roster.

### Group leaders (student officers)

Members with **Leader** on a group roster (e.g. SSLG officers) can, for groups they lead:

- **Manage Members** and **Add Members** (add members, change roles/positions)
- **Requests** — approve/deny join and leave requests (badge when pending)
- **Edit Group** — name, description, join/leave policies (leaders cannot edit club position titles)
- **Send Alert** — group-targeted reminder from **My Groups & Clubs**
- **Sent Group Alerts** — review broadcasts they sent and **View responses**

Leaders do **not** need org-wide `broadcastReminders`; group alerts may still require **admin approval** if your org has that setting enabled.

---

## Admin dashboard (reports)

**Requires:** `viewAllReports` / `manageReports` or org admin

**Settings → Admin Dashboard**

- Review submitted reports
- Update status and add admin notes
- View photos and category
- Notify reporters when status changes (when configured)

---

## School-wide announcements

**Requires:** Org admin, `postBulletinOrgWide`, or group **Leader** (leaders post on behalf of a club)

Announcements are always **organization-wide** — every approved member can read them under **Home → Announcements**.

### Post an announcement (admin)

**Home → Announcements → Post** (or the compose action from the announcements screen)

- Title and message
- **Schedule for later** — send at a chosen date and time instead of immediately (expiration can count from the scheduled send)
- Optional **expiration**
- **Pin to top** — admins only; pinned posts sort first for all members
- Optional **image** — attach when composing or add/change/remove in **Edit**
- Optional **Request a response** — free text, checkboxes, or multiple choice; **response required** and **allow changing responses** (turn off for one-time polls)

### Edit, delete, and responses

Authors and admins can **Edit** or **Delete** from the announcement detail screen. **Edit** updates title, body, expiration, image, and response settings — tap **Save** after changing the image.

Use **My announcements** (or the author list on the announcements screen) to manage your posts. Scheduled posts show **Scheduled** and the send time until they go live. When a post requested responses, open **View responses** to read submitted answers.

### Group leaders

Leaders use **My Groups & Clubs → Post Announcement** and select which club they represent. Good for recruitment drives and club news that should reach the whole school, not just the group roster.

### Approval

When **Require approval before publishing** is **ON** (see below), leader and staff announcements go to **Pending Approvals** until an approver publishes them. Approvers see a scheduled send time when one was set. The same setting applies to **group alerts**.

---

## Reminders and broadcasts (group alerts)

**Requires:** `broadcastReminders`, group **Leader** role, and/or `approveReminders` / org admin (varies by action)

### Organization Settings — content approval

**Settings → Administration → Organization Settings** (org admin)

- **Require approval before publishing** — when **ON**, **announcements** and **group alerts** from non-approvers go to **Pending Approvals** until an admin approves
- The toggle shows **Currently ON / OFF** and is verified on the server after you save

### Compose a group alert

**Alerts → compose (FAB)** or **Compose Reminder** (org broadcasters)

Group leaders: **My Groups & Clubs → Send Alert** on a group they lead

- Title and body
- **Audience** — all members, specific **groups**, or **roles** (leaders: their group only)
- Optional expiration
- Optional **Request a response**:
  - **Free text**, **Checkboxes**, or **Multiple choice**
  - **Response required** — recipients must respond before dismissing
  - **Allow changing responses** — turn **OFF** for votes/polls (answers lock after submit)
  - Checkbox alerts support a **single option** (e.g. “I will attend”); recipients may leave it unchecked

### Approval queue

When **Require approval** is enabled, pending **announcements** and **group alerts** appear in:

- **Settings → Pending Approvals** (badge count)
- **Admin Dashboard** toolbar (checklist icon)
- **Alerts** app bar (checklist icon)

Org **admins** can approve/reject even without a separate `approveReminders` grant.

### My Broadcasts / Sent Group Alerts

Authors and admins: **Alerts → My broadcasts**. Group leaders: **Sent Group Alerts**.

Edit/recall where allowed, and open **View responses** for polls and forms.

---

## Roles and permissions

**Requires:** `manageRoles` or org admin

Custom org roles (Guidance Counselor, Club Adviser, etc.) bundle **capabilities** such as `manageGroupRoster` or `viewAllReports`. Assign roles to users under **Roles** management (admin settings area).

See [RBAC_ARCHITECTURE.md](../RBAC_ARCHITECTURE.md) for the full permission list. You do not need a separate help file per role — assign capabilities and point staff to the relevant sections of this guide.

---

## UI translations

MONHS supports **English** and **Bisaya / Cebuano** in the app UI (with **Tagalog** planned). English is the source language. Updating Cebuano labels and messages is an **administration** task — not covered in the Member Guide.

> **Member tip:** students only pick which language *they* see via **Home → globe icon** or **Settings → Appearance → Language**.

### Assign translation moderators

**Requires:** org admin (or staff with `manageRoles`)

Org admins always have translation access. To delegate to a teacher, SSLG officer, or parent volunteer who speaks Cebuano (or another enabled language):

1. **Settings → Admin Dashboard** → toolbar **Roles & Permissions**
2. **Create Role** or edit an existing role (for example *Cebuano Translator*).
3. Under **Administration**, enable **Translation moderator (edit UI strings)** (`manageTranslations`).
4. Save the role, then **Assign** it to the staff member (they must be an approved MONHS member).

They will see **Settings → Administration → Translations** without gaining other admin menus.

### Edit and approve UI strings

**Requires:** org admin **or** `manageTranslations`

1. **Settings → Administration → Translations**
2. Choose **Bisaya / Cebuano** (or another enabled language).
3. Search by English text or key name.
4. For each string, enter the Cebuano translation, then **Save** or **Approve** when ready. Use **AI draft** for a suggested first pass — always review before approving.
5. Keep placeholders like `{name}` unchanged.

Org admins may also run **Translate missing (AI)** for a whole language and **Export ARB (copy JSON)** when approved strings are ready for an app release. Translation moderators edit and approve individual strings only.

### Manage screen names and translation badges

**Requires:** org admin **or** `manageTranslations`

Configure which MONHS app screens show in-context edit badges during translation mode.

**Mobile app:** **Settings → Administration → Translations** → app bar **list icon** → **Screen names**

**Web:** Translation Helper → **Screen names** tab (`ORGANIZATION_ID = monhs-ph-001`)

1. Add screen names (for example *Home*, *Login*, *Settings*).
2. Assign each name to the matching app route.
3. Enable **Translation badges** on routes where translators should tap globe badges in translation mode.
4. Optionally set **Screen name** on each translation row for filtering in the web tool.

One screen name per route. Unassign before reusing a name on another screen.

### Browse app in translation mode (in-context)

**Requires:** org admin **or** `manageTranslations`

Best for MONHS Cebuano translators who need to see English labels **in place** on real screens before writing Bisaya. Enable **Translation badges** under **Screen names** for each route first.

1. **Settings → Administration → Translations** → choose **Bisaya / Cebuano**.
2. Tap **Browse app in translation mode**.
3. Banner toggle: **English** (read meaning) ↔ **Bisaya / Cebuano** (preview translation).
4. On badge-enabled screens, tap the **globe badge** on a labeled string → edit → **Save** (session queue).
5. **Review** → **Save edits to Firestore**.

Edits sync to the web **Translation Helper** (`speakup_connect_web/tools/translation-helper/`, `ORGANIZATION_ID = monhs-ph-001`) after **Refresh**. Export ARB when ready for a new app build. Where badges are off, use the list workspace or web tool; the preview language toggle still works on all screens.

### Platform setup (deployment lead only)

**Audience:** SpeakUp Connect **deployment lead or developer** — not MONHS org admins. Complete once per Firebase environment before the in-app **Translations** workspace works for MONHS.

1. **Deploy translation Cloud Functions** (from the repo `shared/functions/` folder):

   ```powershell
   npx firebase-tools deploy --only functions:getTranslationWorkspaceAccess,functions:importTranslationSource,functions:listTranslationEntries,functions:saveTranslationEntry,functions:draftTranslation,functions:batchDraftTranslations,functions:exportTranslationArb
   ```

2. **Seed or update roles** for organization `monhs-ph-001` so **`manageTranslations`** is in the capability catalog:

   ```powershell
   node shared/scripts/seed_roles.js
   ```

   Or add `manageTranslations` manually in Firestore. MONHS org admins assign it via **Roles & Permissions**. Users must **sign out and sign back in** after permissions change.

3. **Optional — AI draft:** set Firebase secret `TRANSLATION_AI_API_KEY`. Manual edit and approve work without it.

4. **Import English source (platform `super_admin` only):** web **Translation Helper** at `speakup_connect_web/tools/translation-helper/` — import `speakup_connect_app/lib/l10n/app_en.arb`. Set `ORGANIZATION_ID = 'monhs-ph-001'` in `firebase-config.js`.

5. See `speakup_connect_web/tools/translation-helper/README.md` and [INTERNATIONALIZATION.md](../../INTERNATIONALIZATION.md) §12 for full operator docs.

After setup, MONHS org admins assign Cebuano translators and manage editing in the app.

---

## Response-required alerts (summary)

When composing a reminder with responses enabled:

1. Turn on **Request a response**
2. Choose response type and options
3. Turn on **Response required** if students must answer before dismissing
4. For votes, turn **Allow changing responses** **OFF**
5. Publish (or submit for approval if your org requires it)

Students see the alert until they submit a response. **Clear all** on the alerts feed leaves required items in place.

**Checkbox tip:** One checkbox is enough for yes/no style questions. An unchecked box is a valid answer (e.g. “not attending”).

---

## Scripts and data (technical)

For developers or admins with Firebase access:

- `shared/scripts/seed_groups.js` — seed SPJ, Drum and Lyre, SSLG (SSLG includes default position roles)
- In-app **Seed Demo Groups** — same data without a service account key

Firestore fields: `positionRoles` on group documents, `positionRoleId` on member documents — see [DATABASE_DESIGN.md](../DATABASE_DESIGN.md).

---

## Support

For platform issues, contact your SpeakUp Connect deployment lead. For school policy questions, follow your institution's existing channels.
