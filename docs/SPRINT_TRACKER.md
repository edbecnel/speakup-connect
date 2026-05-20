# Sprint Tracker — SpeakUp Connect

> Last Updated: May 20, 2026  
> Current Sprint: **Sprint 1**  
> Sprint Duration: 2 weeks

> **Requirements Expansion (May 20, 2026 — Sheenaia):** SpeakUp Connect is now a full community communications platform, not only an issue-reporting tool. Added: admin-defined groups/clubs, peer-to-peer and group messaging, news board, bulletin board, broadcast reminders, multi-language support with home-page language selector, apply-to-join signup with school-ID verification, student roster import (CSV / text / Word / PDF / paste), customizable community rules, abuse blocking (temp + permanent), role-based permissions, and custom org app name (e.g., "SpeakUp MONHSIAN"). All docs updated: PROJECT_OVERVIEW, ROADMAP, DATABASE_DESIGN, MASTER_TASK_LIST.

---

## How to Use This Tracker

Each sprint entry follows this format:

```
### Sprint [N] — [Title]
- **Date/Time:** YYYY-MM-DD (X-hour block)
- **GitHub Issue(s):** #N, #N
- **Status:** 🔄 In Progress | ✅ Complete | 🚫 Blocked

#### 🚀 AI Context Prompt
> Paste the prompt used to start this sprint with GitHub Copilot / Cursor

#### 📝 Done
- [x] Completed task

#### 👁️ Stakeholder Demo Asset
- **Asset Type:** Screenshot / Screen Recording / APK build
- **Location:** ./docs/demos/sprint-NNN-[slug].png
- **Stakeholder Note:** What this delivers from the roadmap perspective
```

---

## Active Sprint

### Sprint 1 — Foundation & Architecture
- **Date/Time:** May 19, 2026 (ongoing)
- **GitHub Issues:** #1, #2, #3, #4, #5, #7, #8, #9, #10
- **Status:** 🔄 In Progress

**Goal:** Complete all project documentation, scaffold the Flutter project, and establish the folder architecture. No Firebase integration yet — just structure and placeholder code that compiles and runs.

**Sprint Period:** May 19, 2026 → June 2, 2026

#### 🚀 AI Context Prompt
> "Act as a senior Flutter architect. We are working on SpeakUp Connect — a multi-tenant community reporting app. We are on Sprint 1 (Foundation & Architecture). The stack is Flutter + Dart, Riverpod 2.x, go_router, Firebase, and Material Design 3. Refer to docs/ARCHITECTURE.md for design decisions and docs/FOLDER_STRUCTURE.md for conventions. Current task: [paste task title from GitHub Issue]."

#### 👁️ Stakeholder Demo Asset
- **Asset Type:** *(To be added on sprint completion — screenshot of running app on emulator)*
- **Location:** `./docs/demos/sprint-001-scaffold.png`
- **Stakeholder Note:** Delivers the foundational architecture and documentation for the MONHS pilot project, establishing the multi-tenant SaaS structure from day one.

#### Sprint 1 Tasks

**Documentation**
- [x] Create README.md
- [x] Create docs/PROJECT_OVERVIEW.md
- [x] Create docs/ARCHITECTURE.md
- [x] Create docs/FOLDER_STRUCTURE.md
- [x] Create docs/DATABASE_DESIGN.md
- [x] Create docs/SECURITY_AND_PRIVACY.md
- [x] Create docs/ROADMAP.md
- [x] Create docs/SPRINT_TRACKER.md
- [x] Create docs/MASTER_TASK_LIST.md
- [x] Create docs/CODING_STANDARDS.md
- [x] Create docs/AI_DEVELOPMENT_WORKFLOW.md

**Flutter Project Setup**
- [ ] Initialize Flutter project (`flutter create`)
- [ ] Configure pubspec.yaml with all required dependencies
- [ ] Configure analysis_options.yaml (strict linting)
- [ ] Create folder structure (all feature directories)
- [ ] Verify project compiles and runs on Android emulator

**Core Layer**
- [ ] Create `lib/core/theme/app_colors.dart`
- [ ] Create `lib/core/theme/app_typography.dart`
- [ ] Create `lib/core/theme/app_theme.dart`
- [ ] Create `lib/core/constants/app_constants.dart`
- [ ] Create `lib/core/constants/route_constants.dart`
- [ ] Create `lib/core/errors/app_exception.dart`
- [ ] Create `lib/core/errors/failure.dart`
- [ ] Create `lib/core/router/app_router.dart` (placeholder routes)
- [ ] Create `lib/core/utils/validators.dart`
- [ ] Create `lib/core/extensions/context_extensions.dart`

**Config Layer**
- [ ] Create `lib/config/app_config.dart`
- [ ] Create `lib/config/env_config.dart`
- [ ] Create `lib/config/firebase_options.dart` (placeholder)

**Shared Layer**
- [ ] Create `lib/shared/widgets/app_button.dart`
- [ ] Create `lib/shared/widgets/app_text_field.dart`
- [ ] Create `lib/shared/widgets/app_loading_indicator.dart`
- [ ] Create `lib/shared/widgets/app_error_widget.dart`
- [ ] Create `lib/shared/widgets/app_empty_state.dart`
- [ ] Create `lib/shared/models/pagination_model.dart`

**Models & Entities (Domain)**
- [ ] Create `OrganizationConfigEntity`
- [ ] Create `UserEntity`
- [ ] Create `ReportEntity`
- [ ] Create `ReportCategoryEntity`

**Entry Point**
- [ ] Create `lib/main.dart`
- [ ] Create `lib/app.dart`

**Sprint 1 Definition of Done:**
- All documentation files created
- Flutter project compiles without errors
- App launches to splash screen on Android emulator
- Folder structure matches `docs/FOLDER_STRUCTURE.md`

---

## Sprint 2 — Authentication Flow

**Goal:** Implement full authentication: splash → login → register → home. Firebase Auth integrated. Route guards working.

**Sprint Period:** June 3, 2026 → June 16, 2026

#### Sprint 2 Preview Tasks

- [ ] Set up Firebase project for MONHS pilot
- [ ] Run FlutterFire CLI (`flutterfire configure`)
- [ ] Initialize Firebase in `main.dart`
- [ ] Implement `AuthRemoteDataSource` (email/password + anonymous)
- [ ] Implement `AuthRepository` and `AuthRepositoryImpl`
- [ ] Implement `SignInWithEmailUseCase`
- [ ] Implement `SignUpWithEmailUseCase`
- [ ] Implement `SignInAnonymouslyUseCase`
- [ ] Implement `SignOutUseCase`
- [ ] Implement `authStateProvider` (StreamProvider)
- [ ] Build Splash Screen (with org logo + tagline)
- [ ] Build Login Screen (email/School ID + password, Google sign-in placeholder)
- [ ] Build Register Screen
- [ ] Implement route guards (redirect unauthenticated users)
- [ ] Load organization config from Firestore on login
- [ ] Write unit tests for auth use cases

---

## Sprint 3 — Home Dashboard & Navigation

**Goal:** Home dashboard UI complete. Bottom navigation working. Organization branding applied dynamically.

**Sprint Period:** June 17, 2026 → June 30, 2026

#### Sprint 3 Preview Tasks

- [ ] Build Home Dashboard screen (4-tile grid)
- [ ] Build bottom navigation bar (Home, My Reports, +, Alerts, Profile)
- [ ] Apply dynamic org branding (name, colors from org config)
- [ ] Build Settings screen skeleton
- [ ] Build Profile screen skeleton
- [ ] Implement announcements tile (placeholder)
- [ ] Implement school information tile (placeholder)
- [ ] Responsive layout for different screen sizes

---

## Sprint 4 — Report Submission (3-Step Wizard)

**Goal:** Full report submission flow working end-to-end. Anonymous and identified submission. Photo upload. Reference number generated.

**Sprint Period:** July 1, 2026 → July 14, 2026

#### Sprint 4 Preview Tasks

- [ ] Build Submit Concern Step 1 (Details: category, title, description, anonymous toggle)
- [ ] Build Submit Concern Step 2 (Photos: up to 3 photos)
- [ ] Build Submit Concern Step 3 (Review summary)
- [ ] Build Confirmation screen with reference number
- [ ] Implement photo picker and Firebase Storage upload
- [ ] Implement report submission to Firestore
- [ ] Implement reference number generation (`{ORG_CODE}-{YEAR}-{SEQUENCE}`)
- [ ] Implement anonymous report flow (Firebase anonymous auth)
- [ ] Push notification to admins on new report
- [ ] Form validation and error handling

---

## Sprint 5 — My Reports & Report Details

**Goal:** Users can track their submitted reports. Status badges. Tab filtering.

**Sprint Period:** July 15, 2026 → July 28, 2026

#### Sprint 5 Preview Tasks

- [ ] Build My Reports screen (All / Submitted / In Progress / Resolved tabs)
- [ ] Build Report Details screen
- [ ] Implement Firestore real-time listener for report status changes
- [ ] Status badge component (color-coded)
- [ ] In-app notifications / alerts screen
- [ ] Pull-to-refresh
- [ ] Pagination (cursor-based)

---

## Sprint 6 — Admin Dashboard

**Goal:** Admins can view, filter, and manage all reports. Status updates. Notes.

**Sprint Period:** July 29, 2026 → August 11, 2026

#### Sprint 6 Preview Tasks

- [ ] Build Admin Dashboard screen
- [ ] Admin report list with filter bar (by category, status)
- [ ] Admin report detail view (full report + admin notes)
- [ ] Status update dialog
- [ ] Add note/reply to report
- [ ] Assign report to personnel
- [ ] Admin push notification setup

---

## Sprint 7 — MONHS Pilot Launch Preparation

**Goal:** Internal testing, bug fixes, and soft launch to MONHS student council.

**Sprint Period:** August 12, 2026 → August 25, 2026

#### Sprint 7 Preview Tasks

- [ ] Comprehensive testing (Android devices)
- [ ] Load MONHS-specific categories
- [ ] Configure MONHS branding in Firebase
- [ ] Firebase Security Rules audit
- [ ] Performance testing
- [ ] Bug fixes from internal testing
- [ ] Create admin accounts for MONHS staff
- [ ] Onboarding documentation for MONHS admins
- [ ] Soft launch to student council for feedback

---

## Completed Sprints

> Completed sprint entries are moved here from the Active Sprint section.
> Each entry should include the AI Context Prompt used, all completed tasks, and a Stakeholder Demo Asset.

### [Sprint Log Entry Template]

```markdown
### Sprint [N] — [Title]
- **Date/Time:** YYYY-MM-DD (X-hour block)
- **GitHub Issues:** #N
- **Status:** ✅ Complete

#### 🚀 AI Context Prompt
> "Act as a senior Flutter engineer. We are on Sprint [N] of SpeakUp Connect..."

#### 📝 Done
- [x] Task 1
- [x] Task 2

#### 👁️ Stakeholder Demo Asset
- **Asset Type:** Screenshot / Screen Recording / APK
- **Location:** ./docs/demos/sprint-NNN-[slug].png
- **Stakeholder Note:** What was delivered and why it matters.
```

---

*(No sprints completed yet — Sprint 1 in progress)*

---

## Blocked Items

*(None currently)*

---

## Notes & Decisions Log

| Date | Decision | Reason |
|---|---|---|
| May 19, 2026 | Use Riverpod 2.x for state management | Best-in-class for Flutter, good DI support |
| May 19, 2026 | Use go_router for navigation | Official Flutter routing package, supports route guards |
| May 19, 2026 | Feature-based folder structure | Scales better than layer-based for long-term SaaS |
| May 19, 2026 | Reference number format: `{ORG_CODE}-{YEAR}-{SEQ}` | Based on wireframe (MONHS-2024-000123) |
| May 19, 2026 | 3-step report submission wizard | Based on wireframe: Details → Photos → Review |
| May 19, 2026 | MONHS as first pilot | Originated by MONHS Student Council President |
