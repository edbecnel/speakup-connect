# Project Overview — SpeakUp Connect

---

## Platform Description

SpeakUp Connect is a **multi-tenant community reporting and communications platform** that bridges the gap between community members and their organization's leadership. It is more than an issue-reporting tool — it is a **full community communications hub** for schools, organizations, and institutions.

The platform provides:

**Reporting & Safety**
- Report safety concerns, incidents, and hazards
- Submit complaints and grievances
- Make suggestions and improvement requests
- Flag bullying, harassment, or misconduct
- Request maintenance or facilities support
- Submit anonymous tips when personal safety may be at risk

**Communications & Community**
- Peer-to-peer direct messaging between members
- Group messaging for admin-defined groups and organizations
- News board where school groups and organizations post updates
- Bulletin board for organization-wide admin announcements
- Student/member reminders broadcast by teachers, admins, or role-authorized users
- Admin-defined groups and clubs (e.g., Journalism Club, Chess Club, Drum and Lyre Corps) with customizable club positions (President, Treasurer, etc.)
- In-app Help Center with **per-organization** member and administrator guides (each tenant ships its own markdown; generic `_default` fallback for new orgs)

**Organization & Administration**
- Custom app name per organization (e.g., "SpeakUp MONHSIAN")
- Student/member roster management — admin can provision students with school ID login; bulk import (CSV, text, Word, PDF) planned
- Apply-to-join signup flow: students find their school and apply using their name and school-issued ID
- Multi-language support with per-user language selection
- Customizable community rules displayed at signup and on the main page
- Abuse blocking for both anonymous and authenticated users (temporary or permanent)
- Role-based permissions for broadcasting, moderation, and group management

At its core, SpeakUp Connect is built on the belief that **every voice matters** — and that communities become stronger when people have accessible, trustworthy, and structured ways to be heard and to communicate.

---

## Platform Vision

> **"Give every community member a safe, structured voice — regardless of their organization."**

SpeakUp Connect is not a product built for one school or one municipality. It is a **SaaS platform** designed to serve any organization that needs structured community communication.

---

## Target Organizations

The platform is designed to serve:

| Organization Type | Example Use Cases |
|---|---|
| **Schools / High Schools** | Bullying reports, safety incidents, facility requests |
| **Universities** | Campus safety, harassment reporting, maintenance |
| **Local Government Units (LGUs)** | Citizen concerns, public safety, infrastructure issues |
| **NGOs** | Community feedback, beneficiary concerns, incident tracking |
| **Churches / Religious Organizations** | Community welfare, event feedback, safety concerns |
| **Corporations / Companies** | HR concerns, safety incidents, whistleblowing |
| **Condominiums / HOAs** | Maintenance requests, neighbor concerns, security issues |

---

## Pilot Deployment

The **initial pilot deployment** is for a high school in the Philippines.

### Pilot Goals

- Validate the core report submission and tracking workflow
- Test the admin dashboard and report management system
- Validate Firebase performance and data isolation
- Gather feedback from students, teachers, and administrators
- Identify UX improvements before broader deployment
- Establish a reference implementation for multi-tenant onboarding

### Pilot Scope

The pilot will implement:
- Student report submission (authenticated + anonymous)
- Admin report management dashboard
- Core report categories (Safety, Bullying, Maintenance, etc.)
- Status tracking (Submitted → Resolved)
- Push notification alerts for admins
- Basic admin user management

---

## Multi-Tenant SaaS Vision

SpeakUp Connect is architected as a **multi-tenant SaaS platform** from day one.

### What Multi-Tenancy Means

- Each organization ("tenant") has a unique `organizationId`
- All data is scoped and isolated per organization
- Organizations can customize:
  - Branding (logo, colors, name)
  - Custom app name (e.g., "SpeakUp MONHSIAN")
  - Report categories
  - User roles and admin assignments
  - Notification settings
  - Privacy and moderation policies
  - Community rules (customizable, shown at signup and on main page)
  - Default language and supported languages
  - Student/member roster (importable from CSV, text, Word, PDF)

### Future SaaS Features

- Organization self-registration and onboarding
- Subscription billing integration
- Custom domain support
- Organization analytics dashboard
- API access for enterprise integrations
- White-label branding options

---

## Target Users

### End Users (Community Members)

- Students, residents, employees, congregation members
- Apply to join their organization using their full name and organization-issued ID
- Can submit reports (authenticated or anonymous)
- Can track the status of their own reports
- Can send and receive direct messages and participate in group messaging
- Receive notifications on status updates and broadcasts
- Can change their display language via a language selector on the home page

### Role-Authorized Users

- Users granted specific permissions by an admin (e.g., club leader, journalism editor)
- Can broadcast reminders and post news to the groups they manage
- Permissions are defined per role and assigned by administrators

### Administrators

- Teachers, staff, government officers, community managers
- Can view and manage all reports for their organization
- Can update report status, assign personnel, add notes
- Can define student groups and organizations with member lists
- Can post bulletin board announcements (org-wide)
- Can broadcast reminders to all members or specific groups
- Can import student/member rosters from CSV, text, Word, or PDF files
- Can manage user roles and permissions
- Can block abusive users (temporarily or permanently)
- Receive push notifications for new reports
- Cannot access data from other organizations

### Super Administrators (Platform Level)

- SpeakUp Connect platform operators
- Can manage organizations and subscription tiers
- System-level monitoring and maintenance
- Not visible to end users

---

## Key Differentiators

1. **Privacy-First Design** — Anonymous reporting is a first-class feature, not an afterthought
2. **Multi-Tenant from Day One** — No rearchitecting needed for scaling
3. **Mobile-First** — Built in Flutter for cross-platform native performance
4. **Configurable Per Organization** — Categories, branding, custom app name, rules, and roles adapt to each organization
5. **Designed for Minors** — Special considerations for student privacy, safety, and abuse prevention
6. **Audit-Ready** — Built with audit logging and compliance in mind
7. **Full Communications Hub** — Not just reporting: direct messaging, group messaging, news board, bulletin board, and reminders
8. **Multi-Language** — All UI strings are indexed to a language database; users can switch languages from the home page
9. **Controlled Onboarding** — Students find and apply to join their organization; signup requires admin-issued ID verification
10. **Role-Based Broadcasting** — Reminders and news posts are controlled by role permissions, not just admin status

---

## Success Metrics

### Pilot Success (High School Deployment)

- At least 50% of students aware of and able to use the platform
- At least 10 reports submitted in first month
- Admin response time under 48 hours per report
- Zero unauthorized data access incidents
- Positive feedback from administrators on usability
- At least 3 active groups/clubs using the news board or group messaging

### Platform Success (Long-Term)

- 10+ organizations onboarded within 12 months
- 95%+ uptime SLA
- Sub-3-second report submission
- Successful anonymous report delivery rate > 99%
- Active daily use of messaging and bulletin features
- At least 3 supported languages at public launch
