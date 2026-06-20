# Administrator Guide - School Template

> **Organization:** `{organizationId}` (`{School Name}`)  
> This is the reusable school template. Copy this file to `shared/docs/help/orgs/{organizationId}/ADMIN_GUIDE.md` and tailor sections to enabled features.

This guide is for school administrators and delegated staff with administration capabilities.

---

## Administration menu

Open **Settings**. If you have admin access, you will see an **Administration** section with some or all of:

| Item | Typical permission |
|---|---|
| My Groups & Clubs | All members - groups you belong to |
| Admin Dashboard | `viewAllReports` / `manageReports` or org admin |
| Groups & Clubs *(Administration)* | `manageGroupRoster` or org admin |
| Join Applications | Org admin |
| Pending Approvals | Org admin or `approveReminders` |
| Member Management | Org admin |
| Student Roster | Org admin (schools with grade levels) |
| School Grades | Org admin (schools with grade levels) |
| Translations | Org admin or `manageTranslations` |

If you only see some items, your role has partial capabilities.

---

## Join applications

**Requires:** Org admin

1. **Settings -> Join Applications**
2. Review pending sign-ups
3. **Approve** to enroll the member, or **Reject** with optional reason

Approved members can sign in and use the app. Rejected applicants see rejection reason text.

---

## Member management

**Requires:** Org admin

**Settings -> Member Management**

- View enrolled members (filter by status/search)
- Edit profile details
- Block/unblock access
- Unenroll/re-enroll members
- Assign grade (if school grades are enabled)

### Edit member profile

**Requires:** Org admin

| Field | Notes |
|---|---|
| Full name | Display / roster name |
| Student ID (username) | School sign-in username; unique in org |
| Contact email | Optional sign-in/contact email |
| Grade | Used when grade-level workflows are enabled |
| Official school photo | Permanent school record photo uploaded by staff |

Members cannot edit their own student ID from the app.

### Personal profile photos

**Settings -> Administration -> Organization Settings -> Allow personal profile photos**

- **OFF (default)** - members see official photo or initials
- **ON** - members can upload a personal photo in Settings

Official school photos remain separate from personal photos.

### Reset member password

**Requires:** Org admin

From **Edit profile** or **Member Management -> menu -> Reset password**:

1. Enter a new password (or use approved shortcuts)
2. Confirm reset
3. Share credentials securely

Members can sign in with either student ID or contact email using the same password.

---

## Student roster and provisioning

**Requires:** Org admin (school org type with grades)

### School grades

**Settings -> School Grades** - define grade levels before roster-heavy operations.

### Add a student

**Settings -> Student Roster -> Add Student**

1. Full name
2. Student ID (minimum length and unique in org)
3. Optional contact email
4. Grade

### Bulk import

If CSV/PDF import is not enabled in your deployment, use manual add flow.

---

## Groups and clubs

### Member-facing entry points

Members can access:

- **Home -> My Groups & Clubs**
- **Settings -> My Groups & Clubs**
- **Settings -> Browse Groups & Clubs**

### Admin group management

**Requires:** `manageGroupRoster` or org admin  
**Path:** **Settings -> Administration -> Groups & Clubs**

Use this area to:

- create groups
- edit group metadata and join/leave policies
- manage roster and leadership role
- review join/leave requests
- assign club positions

### Leader vs club position

| Concept | Purpose |
|---|---|
| Leader / Member | Permission level in roster |
| Club position | Display office label (President, Secretary, etc.) |

These are independent. A member can have a position label without leader privileges.

### Demo data (optional)

If your tenant uses demo data scripts/seeding, label these clearly as examples and avoid presenting them as production policy.

---

## Admin dashboard (reports)

**Requires:** `viewAllReports` / `manageReports` or org admin  
**Path:** **Settings -> Admin Dashboard**

- Review submitted reports
- Update statuses and notes
- View attachments and categories
- Trigger/confirm reporter notification behavior when configured

---

## Announcements (organization-wide)

**Requires:** Org admin, `postBulletinOrgWide`, or delegated leader/staff permissions

Announcements are organization-wide and visible to approved members under **Home -> Announcements**.

Core actions:

- compose title/body
- optional scheduling
- optional expiration
- optional image
- optional response request (free text, checkbox, multiple choice)
- edit/delete where allowed

When approval gating is ON, non-approver content goes to **Pending Approvals**.

---

## Group alerts and approval workflow

**Requires:** `broadcastReminders`, group Leader role, and/or `approveReminders` or org admin

**Organization setting:** **Require approval before publishing**

- Applies to announcements and group alerts from non-approvers
- Pending items appear in **Settings -> Pending Approvals**

Response configuration options:

- response required
- allow changing responses
- response type: free text / checkboxes / multiple choice

---

## Roles and permissions

**Requires:** `manageRoles` or org admin

Use roles to bundle capabilities (for example `manageGroupRoster`, `manageTranslations`, `viewAllReports`).

See `shared/docs/RBAC_ARCHITECTURE.md` for full capability definitions.

---

## UI translations

**Requires:** org admin or `manageTranslations`

Use **Settings -> Administration -> Translations** to:

- edit and approve localized strings
- run AI draft where configured
- export ARB where available

Keep placeholders unchanged (for example `{name}`).

### Assign translation moderators

Grant `manageTranslations` via **Roles & Permissions** to delegated staff who should edit UI translations.

### Translation mode and screen badges

If translation mode is enabled in your deployment:

- configure screen names and badge visibility
- use in-context editing for faster review

For web tooling details, refer to `speakup_connect_web/tools/translation-helper/README.md`.

---

## Support

- For tenant policy/process questions: follow school administration channels.
- For platform issues: contact your SpeakUp Connect deployment lead.

---

## Template completion checklist

Before publishing this as org-specific help:

- [ ] Replace `{organizationId}` and `{School Name}`
- [ ] Remove sections for disabled features
- [ ] Label school-specific examples clearly
- [ ] Copy final guide to `assets/help/orgs/{organizationId}/admin_guide.md`
- [ ] Confirm Help Center rendering in app
