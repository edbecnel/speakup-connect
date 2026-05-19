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
- [ ] Splash / Welcome screen with org branding ("SpeakUp MONHS")
- [ ] Login screen (email/school ID + password)
- [ ] Sign up screen
- [ ] Google sign-in integration
- [ ] Home Dashboard (4-tile grid: Submit Concern, My Reports, Announcements, School Info)
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

## Phase 2 — Pilot Expansion

**Goal:** Polish the MONHS deployment and begin onboarding a second organization.

### Phase 2 Features

- [ ] Self-service organization onboarding flow
- [ ] Organization branding customization (colors, logo, tagline)
- [ ] Configurable report categories per org
- [ ] Announcements feature (push + in-app)
- [ ] School / Organization Information page
- [ ] Admin: generate basic reports & analytics
- [ ] Admin: export report data (CSV)
- [ ] In-app report reply/feedback thread
- [ ] Anonymous report reference code (allows status tracking without identity)
- [ ] Password reset flow
- [ ] Account settings & profile management
- [ ] Localization support (English + Filipino)
- [ ] Firebase App Check (anti-abuse)
- [ ] Rate limiting (max 5 reports per user per day)

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
- [ ] Multi-language support
- [ ] iOS App Store deployment
- [ ] Web app deployment (Flutter Web)
- [ ] Email notification delivery (in addition to push)
- [ ] Firestore Security Rules comprehensive audit
- [ ] GDPR/DPA compliance tooling
- [ ] Data retention automation
- [ ] Performance monitoring (Firebase Performance)
- [ ] Error tracking (Sentry or Firebase Crashlytics)

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
| M3: Auth flow working end-to-end | Sprint 3 | ⬜ Not Started |
| M4: Report submission working | Sprint 4 | ⬜ Not Started |
| M5: Admin dashboard working | Sprint 5 | ⬜ Not Started |
| M6: MONHS pilot internal launch | Sprint 6–7 | ⬜ Not Started |
| M7: MONHS pilot public launch | Sprint 8–10 | ⬜ Not Started |
| M8: Second organization onboarded | Post-pilot | ⬜ Not Started |
| M9: SaaS platform public launch | Phase 3 | ⬜ Not Started |

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
