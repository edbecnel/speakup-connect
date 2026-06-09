# Administrator Guide — MONHS

> **Organization:** `monhs-ph-001` (Misamis Oriental National High School pilot)  
> This guide is **school-specific** — student roster, grades, SSLG demo groups, and student ID login apply to MONHS. Other tenants maintain separate guides under `docs/help/orgs/{orgId}/`.

This guide is for MONHS administrators and staff with delegated capabilities (report triage, group management, reminders, etc.). Sections note which permissions are required.

---

## Administration menu

Open **Settings**. If you have admin access, you will see an **Administration** section with some or all of:

| Item | Typical permission |
|------|-------------------|
| Admin Dashboard | `viewAllReports` / `manageReports` or org admin |
| Groups & Clubs | `manageGroupRoster` or org admin |
| Join Applications | Org admin |
| Member Management | Org admin |
| Student Roster | Org admin (schools with grade levels) |
| School Grades | Org admin |

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

- View all enrolled members
- **Block** — temporarily or permanently restrict access
- **Unenroll** — remove from the organization
- **Unblock / Re-enroll** — restore access when appropriate

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

The student signs in with **student ID as both username and password** (see Member Guide).

### Bulk import

CSV/PDF bulk import is planned; use **Add Student** for pilot walkthroughs.

---

## Groups and clubs

**Requires:** `manageGroupRoster` or org admin

**Settings → Groups & Clubs**

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
- On an existing group — open the roster → **badge icon** → edit positions

**Assign positions:**

- **Add Members** — optional **Club position** dropdown
- Member **⋮ menu** on roster — **Assign position**

Members are sorted by position order, then name. SSLG seed includes default offices: President, Vice President, Treasurer, Secretary, Other.

### Manage roster

- **Add Members** — search approved org members, set Leader/Member and optional position
- **⋮ menu** on a member — change leader status, assign position, or remove

---

## Admin dashboard (reports)

**Requires:** `viewAllReports` / `manageReports` or org admin

**Settings → Admin Dashboard**

- Review submitted reports
- Update status and add admin notes
- View photos and category
- Notify reporters when status changes (when configured)

---

## Reminders and broadcasts

**Requires:** `broadcastReminders` and/or `approveReminders` (varies by org)

### Compose a reminder

**Alerts → compose (FAB)** or **Compose Reminder**

- Title and body
- **Audience** — all members, specific **groups**, or **roles**
- Optional expiration
- Optional **responses** (text, checkboxes, multiple choice)
- **Response required** — recipients must respond before dismissing the alert

### Approval queue

If your org requires approval, drafts appear in the **approval queue** for authorized approvers.

### My Broadcasts

Authors and admins can view sent broadcasts, edit/recall where allowed, and review **aggregated responses**.

---

## Roles and permissions

**Requires:** `manageRoles` or org admin

Custom org roles (Guidance Counselor, Club Adviser, etc.) bundle **capabilities** such as `manageGroupRoster` or `viewAllReports`. Assign roles to users under **Roles** management (admin settings area).

See [RBAC_ARCHITECTURE.md](../RBAC_ARCHITECTURE.md) for the full permission list. You do not need a separate help file per role — assign capabilities and point staff to the relevant sections of this guide.

---

## Response-required alerts (summary)

When composing a reminder with responses enabled:

1. Turn on **Allow responses**
2. Turn on **Response required** if students must answer before dismissing
3. Publish (or submit for approval)

Students see the alert until they submit a response. **Clear all** on the alerts feed leaves required items in place.

---

## Scripts and data (technical)

For developers or admins with Firebase access:

- `scripts/seed_groups.js` — seed SPJ, Drum and Lyre, SSLG (SSLG includes default position roles)
- In-app **Seed Demo Groups** — same data without a service account key

Firestore fields: `positionRoles` on group documents, `positionRoleId` on member documents — see [DATABASE_DESIGN.md](../DATABASE_DESIGN.md).

---

## Support

For platform issues, contact your SpeakUp Connect deployment lead. For school policy questions, follow your institution's existing channels.
