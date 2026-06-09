# Administrator Guide

This generic guide describes administration features that may be available in your organization. **Menus and capabilities vary by org type and assigned permissions.**

> Client organizations (schools, LGUs, NGOs, etc.) should ship **org-specific help** under `docs/help/orgs/{orgId}/` with local workflows, UI options, and enabled features.

---

## Administration menu

If you have admin access, **Settings** shows an **Administration** section. Items appear based on your role and capabilities — you may not see every item listed here.

Common areas:

| Area | Typical use |
|------|-------------|
| Admin Dashboard | Review and manage submitted reports |
| Groups & Clubs | Create groups and manage rosters |
| Join Applications | Approve new member sign-ups |
| Member Management | Block, unenroll, or restore members |
| Roles | Assign staff capabilities |

School-type organizations may also show **Student Roster** and **School Grades**.

---

## Reports

Users with report-triage permissions can open the **Admin Dashboard**, update report status, and add admin notes.

---

## Groups and clubs

Users with group roster permissions can create groups, add members, and assign leader/member roles. Some organizations also support **custom club positions** (offices such as President or Secretary).

---

## Reminders

Authorized staff can compose reminders to all members, specific groups, or roles. Optional recipient responses and **response required** settings may be available depending on org configuration.

---

## Roles and permissions

Org admins can define roles and assign capabilities to staff. See [RBAC_ARCHITECTURE.md](../../RBAC_ARCHITECTURE.md) for the platform permission list.

---

## Org-specific documentation

When onboarding a new tenant, add tailored guides at:

`docs/help/orgs/{organizationId}/MEMBER_GUIDE.md`  
`docs/help/orgs/{organizationId}/ADMIN_GUIDE.md`

Copy the same files to `assets/help/orgs/{organizationId}/` for in-app viewing.
