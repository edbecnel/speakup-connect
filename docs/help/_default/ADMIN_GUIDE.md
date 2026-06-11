# Administrator Guide

This generic guide describes administration features that may be available in your organization. **Menus and capabilities vary by org type and assigned permissions.**

> Client organizations (schools, LGUs, NGOs, etc.) should ship **org-specific help** under `docs/help/orgs/{orgId}/` with local workflows, UI options, and enabled features.

---

## Administration menu

If you have admin access, **Settings** shows an **Administration** section. Items appear based on your role and capabilities — you may not see every item listed here.

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

## Org-specific documentation

When onboarding a new tenant, add tailored guides at:

`docs/help/orgs/{organizationId}/MEMBER_GUIDE.md`  
`docs/help/orgs/{organizationId}/ADMIN_GUIDE.md`

Copy the same files to `assets/help/orgs/{organizationId}/` for in-app viewing.
