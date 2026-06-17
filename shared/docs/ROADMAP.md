# Product Roadmap — SpeakUp Connect

---

## Overview

This roadmap tracks the evolution from MVP pilot to a full multi-tenant SaaS platform.

---

## Phase 1 — MVP (Pilot Deployment: MONHS)

**Target:** Misamis Oriental National High School (MONHS), Philippines  
**Originated by:** MONHS Student Council President  
**Goal:** Validate the core product loop — submit, track, resolve — in a real school environment.

### MVP Feature Set

- [x] Project documentation & architecture
- [ ] Flutter project scaffolding
- [ ] Firebase project setup (Auth, Firestore, Storage, FCM)
- [ ] Custom app name displayed on splash and throughout app (e.g., "SpeakUp MONHSIAN")
- [ ] Organization finder: students discover their school/org after installing the app
- [ ] Apply-to-join signup flow: student submits full name + school-issued ID for admin approval
- [ ] Admin roster management: import student names and IDs (CSV, text, Word, PDF, or paste)
- [ ] Splash / Welcome screen with org branding
- [ ] Login screen (school ID + password)
- [ ] Sign up screen with customizable community rules acceptance
- [ ] Community rules displayed at signup and on main page (admin-customizable)
- [ ] Google sign-in integration
- [ ] Home Dashboard with language selector dropdown
- [ ] Submit Concern — 3-step wizard (Details → Photos → Review)
- [ ] Anonymous vs. With Identity toggle on submit
- [ ] Report categories (configurable, MONHS defaults pre-loaded)
- [ ] Photo attachment (up to 3 photos per report)
- [ ] Report submission with reference number (format: `MONHS-2024-000001`)
- [ ] Confirmation screen with reference number
- [ ] My Reports screen (All / Submitted / In Progress / Resolved tabs)
- [ ] Report detail screen
- [ ] Push notifications on status change
- [ ] Admin dashboard (web-compatible)
- [ ] Admin: view all reports, filter by category/status
- [ ] Admin: update report status
- [ ] Admin: assign personnel
- [ ] Admin: add notes/replies
- [ ] Dark / Light theme support
- [ ] Offline support (cached report list)

### MVP Success Criteria

- App runs on Android without crashes
- At least 10 real reports submitted by students
- Admins can manage reports end-to-end
- Zero unauthorized data access incidents

---

## Phase 2 — Pilot Expansion & Communications

**Goal:** Polish the MONHS deployment, activate full communications features, and begin onboarding a second organization.

### Phase 2 Features

**Onboarding & Identity**
- [ ] Self-service organization onboarding flow
- [ ] Organization branding customization (colors, logo, tagline)
- [ ] Custom app name configuration (e.g., "SpeakUp MONHSIAN") stored in org config
- [ ] Configurable community rules (shown at signup and on home page)
- [ ] Student/member roster import: CSV, plain text, Word (.docx), PDF, or paste-in-window
- [ ] Admin review and approval of student signup applications
- [ ] Student find-my-school flow (search by org name, code, or region)

**Reporting Enhancements**
- [ ] Configurable report categories per org
- [ ] In-app report reply/feedback thread
- [ ] Anonymous report reference code (allows status tracking without identity)
- [ ] Admin: generate basic reports & analytics
- [ ] Admin: export report data (CSV)
- [ ] Password reset flow
- [ ] Account settings & profile management

**Groups & Organizations**
- [x] Admin-defined groups and organizations (e.g., Journalism Club, Chess Club, Drum & Lyre Corps)
- [x] Group member list management (admin/leader adds/removes members, club positions)
- [~] Group roles: leader, member — leaders send **group alerts**, manage roster; news/chat not yet built
- [ ] **Member photos:** admin-managed official school photo on user/roster record; member-chosen personal badge in Settings (defaults to official photo when present) — see [MASTER_TASK_LIST.md → Epic 2.3 Member photos](MASTER_TASK_LIST.md)
- [x] Groups visible on home dashboard and Settings (**My Groups & Clubs**)
- [ ] **Group membership requests** — join: per-group opt-in (`allowJoinRequests`, default closed); leave: `voluntary` or `request_required` (default); removal and denied-leave alerts ([GROUP_JOIN_REQUESTS.md](GROUP_JOIN_REQUESTS.md))

**Communications: Boards**
- [ ] Bulletin board — admin-only org-wide announcements
- [ ] News board — group/org leaders post news for their group
- [ ] Boards displayed on home dashboard
- [ ] Push notifications for new bulletin and news posts

**Communications: Reminders** *(Sprint 10)*
- [x] Reminder broadcasts by admin, role-authorized users, and **group leaders** (group-targeted alerts)
- [x] Broadcast audience: all members, specific group, or custom role
- [x] Reminders appear as push notification + in-app notification feed
- [x] Role-based permission: `broadcastReminders` (compose & send) + `approveReminders` / org admin (approve pending)
- [x] Org-level toggle: `requireReminderApproval` — non-approvers submit to pending queue (Organization Settings)
- [x] Admin approval queue with badge (`Reminder Approvals` in Settings, Admin Dashboard, Alerts)
- [x] Optional recipient responses — free text, checkboxes, multiple choice; **response required**; **lock after submit** for votes

**Messaging**
- [ ] Peer-to-peer direct messaging between members
- [ ] Group messaging for admin-defined groups
- [ ] Message read receipts
- [ ] In-app notification for new messages

**Moderation & Safety**
- [ ] Abuse blocking: block anonymous or authenticated users permanently or for a set period
- [ ] Admin block management interface
- [ ] Report-a-message / report-a-post feature
- [ ] Firebase App Check (anti-abuse)
- [ ] Rate limiting (max 5 reports per user per day)

**Localization**
- [~] Multi-language support: Flutter gen-l10n + ARB bundles (see [INTERNATIONALIZATION.md](INTERNATIONALIZATION.md)) — **Phase 1 + 1b shipped** (June 2026)
- [x] **US English (`en_US`)** home language — `app_en.arb`, `appLocaleProvider`, `MaterialApp` wiring
- [~] **Cebuano (`ceb`)** regional (MONHS) — `app_ceb.arb` + help resolver scaffold; **real translations pending**
- [ ] **Tagalog (`fil`)** second language — `app_fil.arb` not yet created
- [ ] **Translation Helper** tool — list + in-context views, **AI model API** initial draft (server-side API token), human approval, ARB export
- [x] Language selector in Settings + Home (`kLanguageNativeLabels`; Tagalog option when `fil` ships)
- [ ] Admin can set org `defaultLanguage` + `supportedLanguages`
- [ ] `preferredLanguage` Firestore sync on user profile
- [ ] Language database: Firestore overlay (optional phase 2) — bundled ARB is v1 source of truth

**Announcements**
- [ ] School / Organization Information page
- [ ] Announcements feature (push + in-app)

---

## Phase 3 — Multi-Tenant Production Release

**Goal:** Launch SpeakUp Connect as a publicly available SaaS platform.

### Phase 3 Features

- [ ] Organization self-registration portal (web)
- [ ] Subscription billing (Stripe or PayMongo for Philippines)
- [ ] Platform admin dashboard (manages all organizations)
- [ ] Custom domain support per organization
- [ ] White-label app icon per organization (build flavors)
- [ ] Advanced analytics dashboard for admins
- [ ] SLA tracking (response time goals per organization)
- [ ] Additional language packs (beyond English + Filipino)
- [ ] Community-contributed language translations
- [ ] iOS App Store deployment
- [ ] Web app deployment (Flutter Web)
- [ ] Email notification delivery (in addition to push)
  - [ ] **Member password-reset link (preferred)** — when an org admin triggers a reset for a member with a contact email on file, send an email with a secure, time-limited link. The link opens either (a) a web reset-password page or (b) a deep link into the app login/reset flow where the member enters and confirms their new password (do not email plaintext passwords)
  - [ ] **Admin-set password email (interim fallback)** — optional notification after `resetOrgMemberPassword` if link-based reset is not yet available; include only if product policy allows emailing admin-chosen passwords
- [ ] Firestore Security Rules comprehensive audit
- [ ] GDPR/DPA compliance tooling
- [ ] Data retention automation
- [ ] Performance monitoring (Firebase Performance)
- [ ] Error tracking (Sentry or Firebase Crashlytics)
- [ ] Advanced group features: sub-groups, event posts, file sharing
- [ ] Messaging: media attachments (images) in direct and group messages
- [ ] Automated abuse detection (spam/inappropriate content screening)

---

## Phase 4 — Enterprise & Long-Term Expansion

**Goal:** Enterprise integrations and advanced platform capabilities.

### Phase 4 Features

- [ ] REST API for enterprise integrations
- [ ] Webhook support for third-party tools
- [ ] AI-powered content screening (spam/inappropriate content detection)
- [ ] SMS notification delivery
- [ ] Multi-admin hierarchy (department-level admins)
- [ ] Public report portal (optional, for transparency)
- [ ] Moderation workflow for sensitive reports
- [ ] SCIM user provisioning (for large org directory sync)
- [ ] Audit log export for compliance
- [ ] Custom report workflows per category
- [ ] In-app video attachments
- [ ] QR code report submission (physical locations trigger report form)

---

## Milestones

| Milestone | Target | Status |
|---|---|---|
| M1: Documentation & Architecture Complete | Sprint 1 | 🟡 In Progress |
| M2: Flutter scaffold with navigation | Sprint 2 | ⬜ Not Started |
| M3: Auth flow + org finder + apply-to-join | Sprint 3 | ⬜ Not Started |
| M4: Report submission working | Sprint 4 | ⬜ Not Started |
| M5: Admin dashboard + roster import | Sprint 5 | ⬜ Not Started |
| M6: Bulletin board + news board + reminders | Sprint 6 | ⬜ Not Started |
| M7: Messaging (P2P + group) + groups | Sprint 7 | ⬜ Not Started |
| M8: MONHS pilot internal launch | Sprint 8–9 | ⬜ Not Started |
| M9: MONHS pilot public launch | Sprint 10–12 | ⬜ Not Started |
| M10: Second organization onboarded | Post-pilot | ⬜ Not Started |
| M11: SaaS platform public launch | Phase 3 | ⬜ Not Started |

---

## Reference Number Format

Reports use a human-readable reference number format:

```
{ORG_CODE}-{YEAR}-{SEQUENCE}
```

Examples:
- `MONHS-2024-000123` — MONHS, year 2024, report #123
- `MANILA-LGU-2025-000001` — Manila LGU, year 2025, first report

The `ORG_CODE` is defined per organization and stored in the organization config. The sequence counter is maintained in Firestore as an atomic counter per organization per year.
