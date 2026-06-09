# Administrator Guide — MONHS

> **Organization:** `monhs-ph-001` (Misamis Oriental National High School pilot)  
> This guide is **school-specific** — student roster, grades, SSLG demo groups, and student ID login apply to MONHS. Other tenants maintain separate guides under `docs/help/orgs/{orgId}/`.

This guide is for MONHS administrators and staff with delegated capabilities (report triage, group management, reminders, etc.). Sections note which permissions are required.

---

## Administration menu

Open **Settings**. If you have admin access, you will see an **Administration** section with some or all of:

| Item | Typical permission |
|------|-------------------|
| My Groups & Clubs | All members — groups *you* belong to (not admin-only) |
| Admin Dashboard | `viewAllReports` / `manageReports` or org admin |
| Groups & Clubs *(Administration)* | `manageGroupRoster` or org admin — manage *all* org groups |
| Join Applications | Org admin |
| Reminder Approvals | Org admin or `approveReminders` |
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

### What members see (all users)

Students and staff view their own memberships under:

- **Home → My Groups & Clubs**
- **Settings → My Groups & Clubs**

They see group name, Leader/Member role, and club position. They do **not** manage rosters from these screens.

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
- On an existing group — open the roster → **badge icon** → edit positions

**Assign positions:**

- **Add Members** — optional **Club position** dropdown
- Member **⋮ menu** on roster — **Assign position**

Members are sorted by position order, then name. SSLG seed includes default offices: President, Vice President, Treasurer, Secretary, Other.

### Manage roster

- **Add Members** — search approved org members, set Leader/Member and optional position
- **⋮ menu** on a member — change leader status, assign position, or remove

### Group leaders (student officers)

Members with **Leader** on a group roster (e.g. SSLG officers) can, for groups they lead:

- **View Members** and **Manage Members** (add members, change roles/positions)
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

## Reminders and broadcasts

**Requires:** `broadcastReminders`, group **Leader** role, and/or `approveReminders` / org admin (varies by action)

### Organization Settings — reminder approval

**Settings → Administration → Organization Settings** (org admin)

- **Require approval before publishing** — when **ON**, reminders from group leaders and other non-approvers go to **Reminder Approvals** until an admin approves
- The toggle shows **Currently ON / OFF** and is verified on the server after you save

### Compose a reminder

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

When **Require approval** is enabled, pending alerts appear in:

- **Settings → Reminder Approvals** (badge count)
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

- `scripts/seed_groups.js` — seed SPJ, Drum and Lyre, SSLG (SSLG includes default position roles)
- In-app **Seed Demo Groups** — same data without a service account key

Firestore fields: `positionRoles` on group documents, `positionRoleId` on member documents — see [DATABASE_DESIGN.md](../DATABASE_DESIGN.md).

---

## Support

For platform issues, contact your SpeakUp Connect deployment lead. For school policy questions, follow your institution's existing channels.
