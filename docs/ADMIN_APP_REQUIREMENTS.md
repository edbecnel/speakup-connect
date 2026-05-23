# Admin Mobile App Requirements — SpeakUp Connect

> This document defines the scope, roles, and feature requirements for the **SpeakUp Connect Admin Mobile App** — a separate Flutter app (or flavor) for elevated-role users (admins, teachers, moderators) on iOS and Android.

---

## Overview

The Admin Mobile App is a **companion app** to the main SpeakUp Connect user app. It is not a replacement for the full web admin portal — it is purpose-built for **real-time awareness and time-sensitive actions** that elevated-role users need to perform on the go.

The philosophy: **the web portal is the workbench; the mobile admin app is the pager.**

---

## Role Hierarchy

| Role | Description |
|---|---|
| **Global Super Admin** | Speakup Connect platform owner and designated global admins. Full access across all organizations. **Web portal only — no cross-org mobile access.** |
| **Org Admin** | Organization-level administrator (e.g., school principal, HR head). Full access within their org only. |
| **Moderator** | Trusted member who reviews and triages reports. Limited admin actions within their org. |
| **Teacher / Staff** | Can post bulletins, broadcast reminders to their groups, and view reports from their assigned groups. Report visibility is configurable per org. |
| **Group Leader** | Can post to their group's news board and send group-scoped announcements. |
| **Normal User** | Standard member. Uses the main SpeakUp Connect app only. |

> **Mobile Admin App is available to:** Org Admin, Moderator, Teacher/Staff, Group Leader — all scoped to a single organization.  
> **Global Super Admin** has no mobile admin access. Web portal only.

---

## Guiding Principle: What Stays Web-Only

The following features are **intentionally excluded from the mobile admin app** because they require large screens, complex data entry, or are low-urgency management tasks:

- Full report analytics and trend dashboards
- Roster import (CSV/PDF bulk upload)
- Organization settings and branding configuration
- Role and permission management
- Audit log review
- Billing and subscription management
- Multi-tenant / tenant onboarding (Super Admin only)
- Bulk message history and export

---

## Essential Mobile Admin Features

### 1. Bulletin Board — Post & Manage

**Who:** Org Admin, Teacher/Staff  
**Why on mobile:** Bulletins are often time-sensitive (e.g., class cancellation, emergency notice, schedule change). Waiting to get to a computer is not acceptable.

- Post a new bulletin (title, body, optional image, optional expiry date)
- Target audience: org-wide, specific group, specific role level
- Pin or unpin a bulletin
- Edit or delete own bulletins
- View bulletin read receipts (count only on mobile; full list on web)

---

### 2. Push Notification Center — Urgent Alerts

**Who:** All elevated roles  
**Why on mobile:** The primary reason the admin app exists. Admins must be reachable for urgent issues even when away from a computer.

- Receive FCM push notifications for:
  - New report submitted at **Critical** urgency (immediate, full-screen alert)
  - New report submitted at **Urgent** urgency (heads-up notification)
  - Report escalated by a moderator or auto-escalated by SLA timer
  - Anonymous tip submitted
  - New user flagged or blocked
  - System-level alerts (e.g., org storage nearing limit)
- Notification preferences per category (on/off, sound, vibration)
- In-app notification inbox with read/unread state
- Quick-action from notification: view report, acknowledge, escalate

---

### 3. Report Triage — View & Respond

**Who:** Org Admin, Moderator  
**Why on mobile:** Urgent reports (safety, bullying, emergency) cannot wait for a desktop session.

- View incoming reports queue — filterable by:
  - Urgency: **Critical**, **Urgent**, **Low Urgency**, **Manual Escalation**
  - Status: **New**, **In Progress**, **Resolved**, **Closed**
- View full report detail: description, category, urgency level, timestamp, attachments, reporter (or "Anonymous")
- Change report status: Acknowledge → In Progress → Resolved / Closed
- Override urgency level during triage (e.g., escalate Low Urgency → Urgent)
- Add an internal note (visible only to admins/moderators)
- Manually escalate report to a higher role
- **Not on mobile:** Bulk actions, report export, analytics

---

### 4. Broadcast Reminders & Announcements

**Who:** Org Admin, Teacher/Staff, Group Leader  
**Why on mobile:** Teachers need to send quick reminders to students (e.g., "Bring your PE uniform tomorrow") without opening a browser.

- Compose and send a broadcast message to:
  - Entire organization
  - A specific group or class
  - A specific role level (e.g., all students)
- Schedule a broadcast for a future time (simple date/time picker)
- View sent broadcast history (last 30 days)
- **Not on mobile:** Broadcast templates, recurring schedules, full history search

---

### 5. Direct Messaging — Admin-Initiated

**Who:** All elevated roles  
**Why on mobile:** Admins may need to reach a specific user directly (e.g., follow up on a report, contact a student's parent representative).

- Initiate a direct message to any member of the org
- View and continue existing admin DM threads
- Shared with the main user app's messaging system (same inbox)
- Admin badge/indicator visible to the recipient (so they know it is an official message)

---

### 6. Group & Club Management — Lightweight

**Who:** Org Admin, Group Leader  
**Why on mobile:** Quick actions only — no bulk operations.

- View list of groups/clubs in the org
- Add or remove a single member from a group
- Post to a group's news board
- **Not on mobile:** Create/delete groups, bulk member import, group settings

---

### 7. User Flag & Block Actions

**Who:** Org Admin, Moderator  
**Why on mobile:** If a moderator receives an urgent report of abuse, they need to act immediately.

- View flagged users
- Temporarily suspend a user account (with reason and duration)
- Lift a suspension
- Permanently block a user (requires Org Admin role)
- **Not on mobile:** Full user profile management, role changes, account deletion

---

### 8. Dashboard — At-a-Glance Summary

**Who:** Org Admin  
**Why on mobile:** A quick health check without needing the full web dashboard.

- Today's report count by status (New / In Progress / Resolved)
- Count of unresolved urgent/critical reports
- Active bulletins count
- Pending user applications count (apply-to-join queue)
- Last sync timestamp
- **Not on mobile:** Charts, trend graphs, exportable data

---

### 9. Apply-to-Join Approval Queue

**Who:** Org Admin  
**Why on mobile:** New student applications need timely approval so members are not left waiting.

- View pending membership applications
- View applicant details (name, submitted ID, timestamp)
- Approve or reject with an optional message
- **Not on mobile:** Bulk approve, roster cross-reference tools

---

## Feature Comparison Matrix

| Feature | Mobile Admin App | Web Admin Portal |
|---|:---:|:---:|
| Post bulletins | ✅ | ✅ |
| Manage bulletin history | Basic | Full |
| Push notification alerts | ✅ | ✅ (browser) |
| Report triage (view + status change) | ✅ | ✅ |
| Report analytics & trends | ❌ | ✅ |
| Broadcast reminders | ✅ | ✅ |
| Broadcast templates & scheduling | Basic | Full |
| Direct messaging | ✅ | ✅ |
| Group membership (single actions) | ✅ | ✅ |
| Bulk group operations | ❌ | ✅ |
| User flag & suspend | ✅ | ✅ |
| Full user management | ❌ | ✅ |
| Apply-to-join approval | ✅ | ✅ |
| Roster import | ❌ | ✅ |
| Org settings & branding | ❌ | ✅ |
| Role & permission management | ❌ | ✅ |
| Audit logs | ❌ | ✅ |
| Billing & subscription | ❌ | ✅ |
| At-a-glance dashboard | ✅ (summary only) | ✅ (full) |

---

## Implementation Notes

### Delivery: Flavor or Separate App?

**Recommendation: Flutter Build Flavor**

Use a `admin` build flavor within the existing `Speakup-Connect` Flutter project rather than a separate repository. This means:

- Shared codebase for auth, Firebase services, messaging, and theming
- Admin-only features are gated by role checks, not separate builds
- A single Firebase project serves both apps
- Admin flavor can have a distinct app icon color/badge (e.g., a shield or different accent) to distinguish it visually
- Deployed as a **separate app listing** on the App Store and Play Store: "SpeakUp Connect — Admin"

### Authentication & Role Enforcement

- Same Firebase Auth as the user app
- On login, the user's Firestore role document is checked
- If role is `normal_user`, the admin app shows an "Access Denied" screen and signs out
- All elevated actions are enforced server-side via Firestore Security Rules — the app UI is a convenience layer only

### Report Urgency Levels and Escalation SLAs

Four urgency levels apply to all reports (decided May 21, 2026):

| Level | FCM Priority | Notification Style | Acknowledgement SLA | Auto-Escalation |
|---|---|---|---|---|
| **Critical** | `high` | Full-screen intent (Android), critical alert (iOS) | 15 minutes | ✅ Always fires |
| **Urgent** | `high` | Heads-up notification | 30 minutes | ✅ Always fires |
| **Low Urgency** | `normal` | Silent badge update | 60 minutes | ⚙️ Configurable per org (default: off) |
| **Manual Escalation** | `normal` | Silent badge update | None | ❌ Never — admin escalates manually |

> Escalation fires to the next role up (e.g., Moderator → Org Admin) if no one has **acknowledged** the report within the SLA window.  
> The reporter selects urgency when submitting. Admins can override urgency during triage.  
> Safety/emergency report categories always default to **Critical** regardless of reporter selection.

### FCM Priority for Other Events

- Bulletins and broadcasts: `normal` priority, silent badge update
- Apply-to-join pending: `normal` priority, badge only
- System alerts: `high` priority, heads-up notification

---

## Resolved Decisions (May 21, 2026)

All open questions answered. Sprint planning for the admin app flavor can proceed.

---

### 1. Super Admin Scope — "Organization" Definition

**Decision:** An organization is a single client entity (one school, one municipality, one company). The mobile admin app is strictly org-scoped.

- **Org Admin** has full access within their own organization and cannot see or act on any other org's data.
- **Global Super Admin** (Speakup Connect platform owner and designated platform-level admins) manages all organizations but operates **exclusively from the web portal**. No cross-org mobile access.
- All roles in the mobile admin app operate within a single org context — the org they belong to.

---

### 2. Teacher Report Visibility

**Decision:** By default, teachers see only reports submitted within their assigned groups. This is configurable per org.

- **Default:** Teacher sees reports scoped to their assigned groups/classes only.
- **Configurable:** An Org Admin can grant a teacher expanded visibility (e.g., all org reports) via org settings on the web portal. This is a per-org, per-teacher permission.
- Enforced server-side via Firestore Security Rules — the mobile app reflects what the server permits.

---

### 3. Bulletin Read Receipts on Mobile

**Decision:** Count only on mobile (e.g., "34 of 120 have read this"). The full per-user read receipt list is web-portal-only.

---

### 4. School ID Photo in Apply-to-Join

**Decision:** Yes — display the uploaded school ID photo in the mobile approval queue. Admins need to verify applicant identity on-the-go without switching to a browser.

---

### 5. Report Urgency Levels and Escalation SLAs

**Decision:** Four urgency levels with distinct SLAs. See the *Report Urgency Levels and Escalation SLAs* table in Implementation Notes above for the full spec.

| Level | SLA | Auto-Escalation |
|---|---|---|
| Critical | 15 min | Always |
| Urgent | 30 min | Always |
| Low Urgency | 60 min | Configurable per org (default: off) |
| Manual Escalation | None | Never |

Safety/emergency report categories always default to **Critical**.  
Admins can override urgency during triage. Reporters set urgency at submission time.

---

## Open Questions — Awaiting MONHS Feedback

> These questions must be resolved before Epic 2.12 (Role-Based Permissions) can be sprint-planned.

### Q1 — Teacher / Staff Role Granularity (May 23, 2026)

The current role hierarchy lists a single **Teacher / Staff** role, but real-world use at MONHS may require more granular distinctions. A "Teacher Admin" sub-role has been identified that would be class-scoped rather than org-wide:

- Post bulletins **only to their own class/group** (not org-wide)
- Manage the student roster **for their own class only**
- Cannot access other classes' data or org-level settings

**Questions for MONHS:**
1. How many distinct elevated roles exist in practice? (e.g., Subject Teacher, Homeroom Teacher, Department Head, Guidance Counselor, School Admin)
2. Should a Homeroom Teacher's class-scoped access differ from a Subject Teacher's?
3. Can a teacher belong to multiple classes simultaneously (co-teacher / advisory split)?
4. Who at MONHS has authority to assign/revoke teacher-level roles — Org Admin only, or also a Department Head?
5. Are there any roles that should have read-only visibility into org-wide data without any write access?
6. Should the concept of "groups" (clubs, etc.) and "classes" be unified or kept as separate constructs in the data model?

**Impact:** The answers will determine whether Teacher/Staff remains one role with scoped permissions, or splits into multiple distinct roles. This directly affects the Firestore data model, Security Rules, and Epic 2.12 task breakdown.
