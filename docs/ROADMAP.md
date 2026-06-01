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
- [ ] Admin-defined groups and organizations (e.g., Journalism Club, Chess Club, Drum & Lyre Corps)
- [ ] Group member list management (admin adds/removes members)
- [ ] Group roles: leader, member (group leader can post news and send group messages)
- [ ] Groups visible in user profile and home dashboard

**Communications: Boards**
- [ ] Bulletin board — admin-only org-wide announcements
- [ ] News board — group/org leaders post news for their group
- [ ] Boards displayed on home dashboard
- [ ] Push notifications for new bulletin and news posts

**Communications: Reminders** *(Sprint 10)*
- [ ] Reminder broadcasts by admin, teachers, or role-authorized users (e.g., club leader)
- [ ] Broadcast audience: all members, specific group, or custom role
- [ ] Reminders appear as push notification + in-app notification feed
- [ ] Role-based permission: `broadcastReminders` (compose & send) + `approveReminders` (approve pending)
- [ ] Org-level toggle: `requireReminderApproval` — when enabled, reminders from non-approvers go into a pending queue before publishing
- [ ] Admin approval queue screen for pending reminders

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
- [ ] Multi-language support: all UI string keys indexed to language database
- [ ] Language selector dropdown on home/main page
- [ ] English (default) + Filipino as first supported languages
- [ ] Admin can set org default language
- [ ] Language database: Firestore-backed or bundled JSON per language

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
