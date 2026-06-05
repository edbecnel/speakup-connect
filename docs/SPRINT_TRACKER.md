# Sprint Tracker — SpeakUp Connect

> Last Updated: June 1, 2026  
> Current Sprint: **Sprint 10** (Reminders Feature)  
> Sprint Duration: 2 weeks

> **Development Velocity Note:** Development has significantly outpaced the original planned schedule. As of May 23, 2026 (day 5 of the project), the codebase covers work originally scoped for Sprints 1–6. Sprint numbering below reflects original plan order but completion dates reflect actual delivery dates.

---

## Active Sprint

### Sprint 10 — Reminders Feature
- **Status:** ✅ Implemented & deployed — backend (rules, indexes, functions) live on `speakup-connect-891dd`; pending on-device smoke test
- **Goal:** Build the full reminders feature — compose screen, broadcast delivery (push + in-app feed), optional approval workflow, and the `approveReminders` permission.
- **Scope decisions:** full scheduling (scheduled Cloud Function), robust per-user notification feed (read/unread), and full audience targeting (all / group / role).
- **Verification:** `flutter analyze` clean (no new errors/warnings); `functions` `npm run build` (tsc, strict) passes; deployed `firestore:rules`, `firestore:indexes`, and all functions (`onReminderPublished` asia-southeast1, `publishDueReminders` us-central1, plus existing functions).

#### 📋 Scope
- [x] Add `approveReminders` to `AppPermission` enum (+ `displayName`/`groupLabel`) + update `org-admin` seed role (`roles_provider.dart`)
- [x] Add `requireReminderApproval` boolean field to `organizations/{orgId}` document (entity + model + repository + admin Branding Settings toggle)
- [x] Firestore data model: `organizations/{orgId}/reminders/{id}` with `status: draft|pending|published|rejected`, `audienceType/audienceId/audienceLabel`, `scheduledAt`, `deliveredAt`, review fields
- [x] Build `ReminderEntity` + `ReminderModel` (domain + data layers)
- [x] Build reminder providers — `pendingRemindersProvider`, `myRemindersProvider`, compose-form notifier, submit notifier, review notifier
- [x] Build Compose Reminder screen — title, body, audience (all / group / role), schedule or send now
- [x] Submit flow: if `requireReminderApproval == true` AND user lacks `approveReminders` → save as `pending`; otherwise publish directly
- [x] Build Admin Approval Queue screen — list of `pending` reminders with approve/reject actions
- [x] Push notification on publish — Cloud Function `onReminderPublished` (FCM fan-out by audience + stale-token pruning)
- [x] Scheduled publisher — Cloud Function `publishDueReminders` (`every 5 minutes`) for future-scheduled reminders
- [x] In-app notification feed — per-user `notifications` subcollection written by the publish function; `AlertsScreen` with read/unread; registered `Routes.alerts`
- [x] Gate Compose button on `broadcastReminders` permission
- [x] Gate Approval Queue on `approveReminders` permission
- [x] Firestore security rules for `reminders` (broadcast/approve/pending flow) + per-user `notifications`
- [x] Composite indexes — `reminders` (status+createdAt, createdBy+createdAt) and collection-group (status+scheduledAt)

#### Done in this session
- [x] `flutter analyze` — clean (no new errors/warnings; only pre-existing info lints remain)
- [x] `functions` `npm run build` — passes under strict tsc
- [x] Deployed `firestore:rules` + `firestore:indexes`
- [x] Deployed all Cloud Functions (first 2nd-gen deploy on this project; required Eventarc/Pub-Sub/Cloud Run APIs auto-enabled, artifact cleanup policy set)

#### Follow-ups / known gaps
- [ ] On-device smoke test of the full flow (compose → approve → feed entry; scheduled publish)
- [ ] **Client FCM not wired up project-wide:** the app does not yet register `fcmTokens` or handle incoming messages, so push delivery is a no-op until that's built. The in-app notification feed works regardless. (Pre-existing gap — also affects the Sprint 7 status-change push.)
- [ ] Once client FCM is added, create the Android notification channels (`reminders`, `status_updates`) referenced by the push payloads.

---

## Completed Sprints

### Sprint 9 — RBAC Phase 2: Permission Enforcement + UX
- **Date/Time:** June 1, 2026
- **Status:** ✅ Complete
- **Commit:** `5f1c4f7` (Sprint 9) + `8997ccc` (bugfixes)

#### 📝 Done
- [x] Router guard: non-admin profiles redirected away from `/admin/*` routes
- [x] `manageRoles` permission gate on RolesManagementScreen FAB, `_RoleCard` edit/assign buttons, `_EmptyRolesPlaceholder` buttons
- [x] `manageReports` permission gate on AdminReportDetailScreen admin actions section
- [x] Fix Riverpod 3.x breaking change: `valueOrNull` → `asData?.value` in `permission_provider.dart`
- [x] Photo lightbox viewer (`showPhotoViewer`) added to both report detail screens (admin + user)
- [x] Category chip displayed in both report detail screen headers
- [x] `customCapabilitiesProvider` switched to `FutureProvider` + `get()` to surface Firestore errors
- [x] Deploy Firestore rules for `customCapabilities` collection (fixed permission-denied)
- [x] Fix capabilities screen: `ref.invalidate(customCapabilitiesProvider)` after create and delete
- [x] Add composite index `users(approvalStatus ASC, displayName ASC)` — fixes assign-role user list query
- [x] Add `scripts/assign_admin.js` bootstrap script for org-admin role assignment

---

### Sprint 8 — RBAC: Roles Management, Phase 1
- **Date/Time:** May 29, 2026
- **Status:** ✅ Complete
- **Commit:** `f1b2866`
- **GitHub Issues:** *(pending)*

#### 🚀 AI Context Prompt
> "We are implementing Sprint 8 — RBAC (Role-Based Access Control) for SpeakUp Connect. Stack: Flutter 3.44, Riverpod 3.x (NotifierProvider pattern), go_router, Firebase Firestore. Seed 6 default system/starter roles into `organizations/monhs-ph-001/roles`, build the Roles & Permissions management screen, and fix any layout issues. DefaultOrganizationId is `monhs-ph-001`."

#### 📝 Done
- [x] Add `SeedRoles` notifier + `seedRolesProvider` to `roles_provider.dart` — batch-writes 6 roles via `SetOptions(merge: true)`
- [x] Add in-app "Seed Default Roles" button to `_EmptyRolesPlaceholder` (follows `_SetupCategoriesCard` pattern)
- [x] Seed 6 roles to Firestore: `org-admin` (all 14 permissions, isSystemRole), `member` (isSystemRole, no caps), `guidance-counselor`, `discipline-officer`, `homeroom-teacher`, `club-adviser`
- [x] Fix `_RoleCard` layout crash — `AppButton.secondary` uses `minimumSize: Size(double.infinity, 52)` by default; added `minimumWidth: 80` to prevent infinite-width constraint inside `Row`
- [x] Fix global FAB shape — removed `shape: const CircleBorder()` from `FloatingActionButtonThemeData`; Flutter's defaults already give regular FABs a circle and `.extended` FABs a stadium shape
- [x] Add explicit `shape: const StadiumBorder()` to both `FloatingActionButton.extended` widgets (`roles_management_screen.dart`, `my_reports_screen.dart`)
- [x] Make `+N more` capability chip interactive — converted from `Chip` to `ActionChip`; tapping opens `AlertDialog` listing all capabilities for that role

#### 👁️ Stakeholder Demo Asset
- **Asset Type:** *(To be added)*
- **Location:** `./docs/demos/sprint-008-rbac-roles.mp4`
- **Stakeholder Note:** Admins can now view all defined roles (system and custom) in the Roles & Permissions screen, see each role's capability chips, tap "+N more" to reveal the full capability list in a dialog, and use the in-app seed button to bootstrap default roles for a new organisation.

---

## Completed Sprints

### Sprint 7 — Admin Dashboard Enhancements
- **Date/Time:** May 29, 2026
- **Status:** ✅ Complete
- **Commit:** `9ec4bcd`
- **GitHub Issues:** #43, #44, #45, #46

#### 📝 Done
- [x] Quick stats header — total, submitted, in-progress, resolved counts above the filter bar
- [x] Search bar — title/reference number filter with clear button (`adminSearchQueryProvider`)
- [x] Assign report to admin — "Assign / Reassign" button on detail screen, `_AssignDialog` with admin user picker and search, assignee display in header card
- [x] Push notification on status change — `notifyReporterOnStatusChange` Cloud Function (v2 `onDocumentUpdated`), sends FCM to reporter when `status` changes, respects `notificationPreferences.statusUpdates`, prunes stale tokens

#### 👁️ Stakeholder Demo Asset
- **Asset Type:** *(To be added)*
- **Location:** `./docs/demos/sprint-007-admin-enhancements.mp4`
- **Stakeholder Note:** Admin dashboard now shows live report counts, supports search, allows assigning reports to admin staff, and automatically notifies reporters when their report status changes.

---

### Sprint 6 — Admin Dashboard
- **Date/Time:** May 23, 2026
- **GitHub Issues:** #22, #23, #24, #25, #26
- **Status:** ✅ Complete (core features)

**Goal:** Admin dashboard fully functional: view all org reports, filter by category and status, navigate to full report detail, update status with history, add internal admin notes.

**Sprint Period:** May 22–23, 2026 (accelerated delivery)

#### 🚀 AI Context Prompt
> "We are building the Admin Dashboard feature for SpeakUp Connect. Stack: Flutter 3.44, Riverpod 3.x (NotifierProvider pattern), go_router, Firebase Firestore. The admin can see all reports for their org, filter by category/status, tap a report to see the full detail, update the status (with history append), and add internal admin notes. DefaultOrganizationId is `monhs-ph-001`. Admin UID is `4kuMOm3BZDT9oZpALIDjCnPT8Gk1`."

#### 📝 Done
- [x] Build `AdminDashboardScreen` — tab bar (All / Submitted / In Review / Resolved / Closed), report list, tap-to-detail navigation
- [x] Build `AdminFilterBar` — horizontal multi-select category filter chips (empty set = All; tapping All clears all)
- [x] Apply `adminCategoryFilterProvider` client-side filter to report list
- [x] Build `AdminReportDetailScreen` — full report view: header card (title, ref, status badge, priority badge, submitter, timestamps), description, photo gallery, admin action buttons, notes thread, status history timeline
- [x] Build `_StatusUpdateDialog` — status dropdown + optional note field, calls `updateReportStatus()`
- [x] Build `_AddNoteDialog` — multi-line note entry, calls `addAdminNote()`, resolves author name from `userProfileProvider`
- [x] Wire `adminReportByIdProvider` (FutureProvider.family) for detail data loading
- [x] Auto-refresh detail screen after status update or note via `ref.invalidate(adminReportByIdProvider(reportId))`
- [x] Implement Firestore Security Rules with `isAdminOrAbove()` guard on all report admin operations
- [x] Implement admin role check: `UserProfileEntity.isAdmin` getter, settings screen admin link gating
- [x] Fix `Timestamp.now()` in `statusHistory` array (serverTimestamp() not allowed in arrays)
- [x] Fix launch color to brand navy `#002673`
- [x] Remove debug logging from settings screen
- [x] Seed report categories for `monhs-ph-001`

#### 👁️ Stakeholder Demo Asset
- **Asset Type:** *(To be added — screen recording of admin dashboard + detail + filter)*
- **Location:** `./docs/demos/sprint-006-admin-dashboard.mp4`
- **Stakeholder Note:** Admins can now fully manage submitted reports — view all, filter by category, update status with audit trail, and add internal notes. All Firestore access is secured by role-based rules.

#### Remaining Sprint 6 Items (deferred to next sprint)
- [ ] Admin dashboard search bar
- [ ] Quick stats header (total, pending, in-progress counts)
- [ ] Assign report to admin personnel
- [ ] Push notification to reporter on status change

---

## Upcoming Sprints

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

## How to Use This Tracker

Each sprint entry follows this format:

```
### Sprint [N] — [Title]
- **Date/Time:** YYYY-MM-DD
- **GitHub Issue(s):** #N, #N
- **Status:** 🔄 In Progress | ✅ Complete | 🚫 Blocked

#### 🚀 AI Context Prompt
> Paste the prompt used to start this sprint

#### 📝 Done
- [x] Completed task

#### 👁️ Stakeholder Demo Asset
- **Asset Type:** Screenshot / Screen Recording / APK build
```

---

## Completed Sprints

### Sprint 1–5 — Foundation through My Reports (✅ Completed)
- **Date/Time:** May 19–22, 2026
- **GitHub Issues:** #1–#21
- **Status:** ✅ Complete

All foundational work delivered ahead of schedule in the first few days of development: project setup, pubspec, linting, folder structure, theme system, router with auth/admin guards, Firebase integration (Auth, Firestore, Storage, Messaging), org config, authentication flow, home dashboard, report submission wizard with photo upload, My Reports screen, report detail screen, reference number generation, Firestore security rules, categories seeded for `monhs-ph-001`.

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

### Session Log — May 23, 2026 (Branding, Splash, Native Spinner)
- **Date/Time:** May 23, 2026
- **GitHub Issues:** #TBD (tech debt items to be filed)
- **Status:** ✅ Committed — 4 commits pushed to `origin/master` (HEAD = `225a92b`)

#### 📝 Done
- [x] `app_theme.dart` — added `chipTheme`, `switchTheme`, `checkboxTheme`, `radioTheme` so selected state uses `colorScheme.secondary` (#F5DC0F gold) with `colorScheme.onSecondary` for content
- [x] `MainActivity.kt` — moved native `ProgressBar` from `onStart()` to `onCreate()` so spinner appears immediately at app launch (~1s before Flutter engine); removed in `onFlutterUiDisplayed()`
- [x] `splash_screen.dart` — 700ms minimum timer; `_LoadingScreen` (full blue #2563EB Scaffold + white `CircularProgressIndicator`) while loading; `_SplashContent` (branded: logo, "SpeakUp {orgName}", tagline, "Get Started") after
- [x] `app_router.dart` — `_AuthStateListenable` holds off ALL go_router redirects for 5 seconds from app start; ensures authenticated users see splash before redirect to home

#### Known Limitations from This Session
- Launch background color still `#2563EB` (old blue) in `colors.xml` — should be `#002673`. Tracked as tech debt.
- Splash experience (~4s combined blue + spinner) is acceptable but not ideal. Proper fix needs Android SplashScreen API (blocked — see Blocked Items).

#### 👁️ Stakeholder Demo Asset
- **Asset Type:** Device test on Samsung Galaxy S9 (SM-G960U, API 29)
- **Result:** Blue screen ~4s, spinner ~0.5s, branded splash OK. Accepted as interim state.
- **Stakeholder Note:** Branding now fully applied — gold secondary color on all selection widgets; loading experience shows school branding before navigating to home.

---

*(Sprint 1 in progress — session log entries above represent work completed within Sprint 1 scope and beyond)*

---

## Blocked Items

| # | Item | Reason | Notes |
|---|---|---|---|
| 1 | Splash loading experience (timing) | `FlutterSurfaceView` composites independently — native `ProgressBar` doesn't reliably overlay Flutter surface on all devices | Needs Android 12+ SplashScreen API (`androidx.core:core-splashscreen`) or dedicated pre-Flutter Activity. **Do NOT retry** `Handler.postDelayed` or removing `_LoadingScreen` — both failed. |
| 2 | Seed default categories | Needs manual admin action | Admin Dashboard → Branding Settings → "Add Default Categories" for `monhs-ph-001` |

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
| May 20, 2026 | SpeakUp Connect is now a full community communications platform | Added groups, messaging, news board, multi-language, apply-to-join, roster import, etc. |
| May 23, 2026 | 5-second router splash lock via `_AuthStateListenable` | Ensures authenticated users see branded splash (~4s) before auto-redirect to home |
| May 23, 2026 | `_LoadingScreen` approach for pre-content state | Full blue Scaffold matching native launch background — avoids white flash between native and Flutter |
| May 23, 2026 | Native spinner in `onCreate()` not `onStart()` | `onStart()` fires after Flutter engine starts on some devices — `onCreate()` guarantees it appears at cold start |
| May 23, 2026 | Do NOT use `Handler.postDelayed` for splash timing | `FlutterSurfaceView` composites independently; native views don't reliably overlay Flutter surface on S9 (API 29) |
