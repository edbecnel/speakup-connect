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
| Reminder Approvals | Approve pending group/org alerts (when enabled) |
| Member Management | Block, unenroll, or restore members |
| Roles | Assign staff capabilities |

School-type organizations may also show **Student Roster** and **School Grades**.

---

## Reports

Users with report-triage permissions can open the **Admin Dashboard**, update report status, and add admin notes.

---

## Groups and clubs

**Members** see their own groups under **Home** or **Settings → My Groups & Clubs** (read-only).

**Staff with `manageGroupRoster`** (or org admins) use **Settings → Administration → Groups & Clubs** to create groups, add members, and assign leader/member roles. Some organizations also support **custom club positions** (offices such as President or Secretary).

**Group leaders** (roster role Leader) may manage their group's roster and send **group alerts** from **My Groups & Clubs** without org-wide broadcast permission.

After adding a member to a group, they should see it under **My Groups & Clubs** within a few seconds.

---

## Reminders

Authorized staff and group leaders can compose reminders (audience varies by role). Org admins may enable **Require approval before publishing** under **Organization Settings**; pending items appear under **Reminder Approvals**.

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
