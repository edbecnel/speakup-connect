# Security & Privacy — SpeakUp Connect

---

## Overview

SpeakUp Connect is designed with privacy and security as foundational principles, not afterthoughts. Because the platform may be used by **minors** (students in schools), and involves **sensitive reports** (bullying, harassment, safety incidents), the security model must be robust and auditable.

---

## Anonymous Reporting Design

### Why Anonymous Reporting Is Critical

In school and community environments, individuals may fear retaliation for reporting. If reporters believe their identity will be revealed, they will not report — leaving problems unaddressed. Anonymous reporting is therefore a **safety mechanism**, not a loophole.

### How Anonymous Reporting Works

1. When a user selects "Submit Anonymously," the app calls `FirebaseAuth.signInAnonymously()`
2. Firebase creates a temporary anonymous auth session
3. The report document is created with:
   - `isAnonymous: true`
   - `submittedBy: null`
   - `submitterDisplayName: null`
4. The anonymous Firebase Auth UID is **not stored** in the report document
5. The anonymous session is signed out after report submission

### What Is NOT Collected for Anonymous Reports

- User display name
- Email address
- Firebase Auth UID linked to any profile
- Device fingerprint
- IP address (Firebase does not expose this to the client)

### Anonymous Report Limitations

- Anonymous reporters cannot track the status of their report (unless they save a locally-generated report reference code)
- Anonymous reporters cannot receive push notifications
- Admins cannot identify or contact the reporter

### Future Enhancement: Report Reference Code

Generate a locally-stored random code that allows the reporter to retrieve status updates without being identifiable. This will be implemented in a future sprint.

---

## Authentication Security

### Password Requirements

- Minimum 8 characters
- Firebase Authentication enforces basic email validation
- Future: Enforce complexity requirements via custom validation

### Session Management

- Firebase ID tokens expire after 1 hour and are auto-refreshed
- Sessions are invalidated on password change
- Sign-out clears all local auth state and cached Firestore data

### Account Lockout

Firebase Authentication automatically handles brute-force protection via rate limiting.

### Sensitive Data in Transit

All Firebase SDK communication uses TLS/HTTPS. No custom HTTP endpoints are used that could bypass this.

---

## Role-Based Access Control (RBAC)

### Role Definitions

| Role | Who | Capabilities |
|---|---|---|
| `anonymous` | Unidentified users | Submit reports only (with anonymous auth) |
| `user` | Registered community members | Submit reports, view own reports, update profile, receive notifications |
| `admin` | Organization administrators | View all reports, update status, add notes, assign personnel, manage categories |
| `super_admin` | Organization owner/IT | Manage organization settings, manage admin users, view audit logs |
| `platform_admin` | SpeakUp Connect team | Manage organizations, platform-level monitoring (never accesses org data) |
| `teacher` *(planned)* | Class-level staff | Post bulletins and manage roster scoped to their own class/group only — **exact capabilities TBD pending MONHS feedback** |

> **⚠ Role definitions are not final.** The Teacher/Staff role in particular may split into multiple granular roles (e.g., Homeroom Teacher, Subject Teacher, Department Head) depending on MONHS requirements. Do not implement Epic 2.12 until open questions in `ADMIN_APP_REQUIREMENTS.md → Open Questions — Awaiting MONHS Feedback` are resolved.

### How Roles Are Enforced

Roles are enforced at **two levels**:

1. **App Level** — Riverpod providers check the user's role before displaying admin UI
2. **Firestore Security Rules Level** — Rules validate role on every read/write operation (server-side enforcement)

App-level checks are for UX only. Security Rule enforcement is the actual security boundary.

### Custom Claims (Future)

For performance, roles will be stored as Firebase Auth custom claims in a future sprint. This avoids a Firestore read on every security rule evaluation.

---

## Firestore Security

### Core Principles

1. **No public access** — All read/write requires authentication
2. **Org scoping** — Every rule validates `organizationId` matches the authenticated user's org
3. **Minimum privilege** — Users can only access what they explicitly need
4. **Append-only audit trails** — `statusHistory` in reports cannot be modified or deleted

### Sensitive Fields

The following fields are admin-only and enforced by Security Rules:

- `adminNotes` — Cannot be read by non-admin users
- `assignedTo` — Cannot be set by non-admin users
- `statusHistory` — Cannot be written directly (written only via admin update function)
- `priority` — Can only be set by admins

### Input Validation in Security Rules

Security Rules validate incoming data structure:
- Title: non-empty string, max 200 chars
- Description: non-empty string, max 1000 chars
- Category: must exist in the organization's categories collection
- `isAnonymous`: boolean, cannot be changed after creation

---

## Firebase Storage Security

All uploaded files (report photos) are stored at:
```
organizations/{organizationId}/reports/{reportId}/{filename}
```

Storage Rules enforce:
- Only authenticated users of the organization can upload
- Maximum file size: 10 MB per file
- Allowed MIME types: `image/jpeg`, `image/png`, `image/webp`
- Only organization admins can download report photos (regular users can view their own)
- Uploaded files cannot be deleted by regular users (admin only)

---

## Student & Minor Privacy Considerations

Because the platform is deployed in schools and may be used by students under 18:

### Data Minimization

- Only collect the minimum necessary personal information
- Display names are optional; users can use initials or aliases
- No birth dates, addresses, or sensitive demographic data collected

### Parental Consent Considerations

- Organizations using the platform for minors must obtain appropriate consent per local law (e.g., RA 10173 - Data Privacy Act of the Philippines)
- The platform provides configurable consent/terms acknowledgment screens

### Data Retention

- Student data should not be retained indefinitely
- Default retention: 2 years for resolved reports
- Account data: deleted 90 days after account closure
- Configurable per organization to comply with local regulations

### Third-Party Data Sharing

- No user data is shared with third parties
- Firebase (Google) processes data as a data processor under Google's DPA
- No analytics SDKs that fingerprint users (no Crashlytics, no Google Analytics in MVP)

---

## Anti-Spam & Moderation Planning

### Current Protections

- Firebase Authentication rate-limiting prevents mass account creation
- App-level rate limiting: maximum 5 report submissions per user per day
- Admin review required before report status changes to "In Progress"

### Future Protections (Post-MVP)

- Configurable spam detection keywords per organization
- Admin moderation queue before reports are visible
- Report flagging by other users (for non-anonymous reports)
- AI-powered content screening (optional)
- Rate limiting via Firebase App Check

---

## Audit Logging

### What Is Logged

Every report status change creates an immutable entry in `statusHistory`:
- Previous status
- New status
- Who made the change (admin UID + display name)
- Timestamp
- Optional note

### What Is NOT Logged (to protect privacy)

- The identity of anonymous reporters
- Failed login attempts (managed by Firebase)
- Admin report view events (future enhancement)

### Future: Admin Activity Log

A separate `audit_log` subcollection will be added to track:
- Admin logins
- Configuration changes
- User management actions
- Report deletions (if deletion is ever enabled)

---

## Security Incident Response

### Suspected Data Breach

1. Immediately revoke all Firebase Auth tokens via Firebase Console
2. Disable the affected organization's Firestore access
3. Review Firestore audit logs in Google Cloud Console
4. Notify affected organization within 72 hours (per GDPR/DPA requirements)

### Security Vulnerability Disclosure

Report security vulnerabilities to: `security@speakupconnect.app` (to be configured)

---

## Compliance Considerations

### Philippines — Data Privacy Act (RA 10173)

- Personal data collection requires consent and a stated purpose
- Data subjects have the right to access, correct, and delete their data
- A Data Protection Officer (DPO) must be designated
- Report data breaches to the National Privacy Commission within 72 hours

### GDPR (Future — EU Deployment)

- Lawful basis for processing must be documented
- Right to erasure ("right to be forgotten") must be implemented
- Data processing agreements required with Firebase/Google

### COPPA (Future — US Deployment)

- Additional protections required for users under 13
- Parental consent mechanism required
