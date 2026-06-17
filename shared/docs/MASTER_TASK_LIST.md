# Master Task List — SpeakUp Connect

> This is the comprehensive task breakdown for the entire SpeakUp Connect project.  
> Organized by Phase → Epic → Task.  
> Use this for long-term sprint planning.

---

## How to Use This List

- Each task is assigned to a **Phase** and **Epic**
- Tasks are marked with checkboxes: `[ ]` not started, `[~]` in progress, `[x]` complete
- Add assignee and sprint number in brackets when scheduling: `[Sprint 2] [Dev A]`
- See [shared/docs/SPRINT_TRACKER.md](shared/docs/SPRINT_TRACKER.md) for the current active sprint breakdown

---

## High-Priority Backlog

> **Next product pillars** after current pilot hardening. Architecture docs where noted.

| # | Initiative | Epic | Architecture | GitHub |
|---|------------|------|--------------|--------|
| 1 | **Multi-language support** — Phase 1 + 1b ✅; Translation Helper + real `ceb`/`fil` + feature extraction ⏳ | [2.5](#epic-25--multi-language-support) | [INTERNATIONALIZATION.md](INTERNATIONALIZATION.md) | [#48–#53](https://github.com/edbecnel/speakup-connect/issues?q=is%3Aissue+is%3Aopen+label%3Aepic%3A2.5) |
| 2 | **Peer-to-peer and group messaging** | [2.10](#epic-210--peer-to-peer-messaging), [2.11](#epic-211--group-messaging) | TBD — `DATABASE_DESIGN.md` § directMessages / messages | [#55](https://github.com/edbecnel/speakup-connect/issues/55) |
| 3 | **Parent accounts and login** | [2.13](#epic-213--parent-accounts) | TBD | [#56](https://github.com/edbecnel/speakup-connect/issues/56) |

Suggested implementation order: **i18n → messaging → parents** (messaging is independent; parents may link to student profiles and alerts).

---

## Phase 1 — Foundation & MVP

### Epic 1.1 — Project Documentation

- [x] Create README.md
- [x] Create shared/docs/PROJECT_OVERVIEW.md
- [x] Create shared/docs/ARCHITECTURE.md
- [x] Create shared/docs/FOLDER_STRUCTURE.md
- [x] Create shared/docs/DATABASE_DESIGN.md
- [x] Create shared/docs/SECURITY_AND_PRIVACY.md
- [x] Create shared/docs/ROADMAP.md
- [x] Create shared/docs/SPRINT_TRACKER.md
- [x] Create shared/docs/MASTER_TASK_LIST.md
- [x] Create shared/docs/CODING_STANDARDS.md
- [x] Create shared/docs/AI_DEVELOPMENT_WORKFLOW.md
- [x] Create shared/docs/RBAC_ARCHITECTURE.md
- [ ] Create shared/docs/WIREFRAMES.md (annotated wireframe notes)
- [ ] Create shared/docs/API_CONTRACTS.md (Firestore read/write contract docs)
- [ ] Create shared/docs/TESTING_STRATEGY.md

---

### Epic 1.2 — Flutter Project Setup

**Frontend**
- [ ] Initialize Flutter project with package name `com.speakupconnect.app`
- [ ] Configure pubspec.yaml (all dependencies)
- [ ] Configure analysis_options.yaml (strict linting rules)
- [ ] Create full folder structure matching shared/docs/FOLDER_STRUCTURE.md
- [ ] Create `.gitignore` (Flutter + Firebase rules)
- [ ] Verify project compiles and runs on Android emulator
- [ ] Configure build flavors: `development`, `staging`, `production`
- [ ] Set up `assets/` directory with placeholder images/fonts
- [ ] Create app launcher icon placeholder

**DevOps**
- [ ] Initialize Git repository
- [ ] Create initial commit with scaffolded structure
- [ ] Create GitHub/GitLab repository
- [ ] Set up branch strategy: `main`, `develop`, `feature/*`
- [ ] Add `.github/PULL_REQUEST_TEMPLATE.md`

---

### Epic 1.3 — Core Layer

**Theme System**
- [ ] Create `app_colors.dart` — base color palette (org-agnostic defaults)
- [ ] Create `app_typography.dart` — TextTheme with Google Fonts
- [ ] Create `app_theme.dart` — ThemeData factory (light + dark)
- [ ] Implement dynamic theme from org config (primary/secondary colors)
- [ ] Verify dark mode on Android

**Router**
- [ ] Create `route_constants.dart` — all named route paths as constants
- [ ] Create `app_router.dart` — GoRouter configuration
- [ ] Implement auth guard (redirect to login if not authenticated)
- [ ] Implement admin guard (redirect if not admin role)
- [ ] Implement org-loading guard (redirect if org config not loaded)
- [ ] Test all named routes navigate correctly

**Constants & Utilities**
- [ ] Create `app_constants.dart` — app-wide constants
- [ ] Create `validators.dart` — email, password, required field validators
- [ ] Create `date_formatter.dart` — date display helpers
- [ ] Create `context_extensions.dart` — theme/screen size helpers
- [ ] Create `string_extensions.dart` — capitalization, truncation helpers

**Errors**
- [ ] Create `app_exception.dart` — typed exception classes
- [ ] Create `failure.dart` — sealed Failure class for domain errors

---

### Epic 1.4 — Configuration Layer

- [ ] Create `app_config.dart` — compile-time constants (app name, version)
- [ ] Create `env_config.dart` — environment selector
- [ ] Create `firebase_options.dart` placeholder (replaced by FlutterFire CLI)
- [ ] Document environment setup process

---

### Epic 1.5 — Shared Widgets

- [ ] Create `app_button.dart` — primary, secondary, text button variants
- [ ] Create `app_text_field.dart` — styled input with label/error/icon support
- [ ] Create `app_loading_indicator.dart` — centered CircularProgressIndicator
- [ ] Create `app_error_widget.dart` — error message + retry button
- [ ] Create `app_empty_state.dart` — empty list illustration + message
- [x] Create `app_avatar.dart` — user/org avatar with fallback initials; **official photo** + **personal badge** (`avatarUrl` → `officialPhotoUrl` → initials) per [DATABASE_DESIGN.md](DATABASE_DESIGN.md)
- [ ] Write widget tests for all shared widgets

---

### Epic 1.6 — Organization Feature

**Domain**
- [ ] Create `OrganizationConfigEntity`
- [ ] Create `OrganizationRepository` abstract interface
- [ ] Create `LoadOrganizationConfigUseCase`

**Data**
- [ ] Create `OrganizationConfigModel` (with `fromJson`/`toJson`)
- [ ] Create `OrganizationRemoteDataSource` (Firestore reads)
- [ ] Create `OrganizationRepositoryImpl`

**Presentation**
- [ ] Create `organizationConfigProvider` (AsyncNotifier loading org config)
- [ ] Apply org colors to theme dynamically
- [ ] Apply org display name to app bar and splash screen
- [ ] Cache org config in memory for session

**Testing**
- [ ] Unit test: `LoadOrganizationConfigUseCase`
- [ ] Unit test: `OrganizationRepositoryImpl` (mock datasource)

---

### Epic 1.7 — Authentication Feature

**Domain**
- [ ] Create `UserEntity`
- [ ] Create `AuthRepository` abstract interface
- [ ] Create `SignInWithEmailUseCase`
- [ ] Create `SignUpWithEmailUseCase`
- [ ] Create `SignInAnonymouslyUseCase`
- [ ] Create `SignOutUseCase`
- [ ] Create `GetCurrentUserUseCase`

**Data**
- [ ] Create `UserModel` (with `fromJson`/`toJson`)
- [ ] Create `AuthRemoteDataSource` (FirebaseAuth calls)
- [ ] Create `AuthRepositoryImpl`
- [ ] Create `UserRemoteDataSource` (Firestore user profile reads/writes)

**Presentation — Providers**
- [ ] Create `authStateProvider` (StreamProvider watching FirebaseAuth state)
- [ ] Create `currentUserProvider` (derived from auth state)
- [ ] Create `authNotifierProvider` (AsyncNotifier for sign-in/sign-up operations)

**Presentation — Screens**
- [ ] Build `SplashScreen`
  - [ ] Display org logo (from config)
  - [ ] Display org name dynamically (e.g., "SpeakUp MONHS")
  - [ ] Display tagline dynamically (from org config)
  - [ ] "Get Started" button
  - [ ] "Learn More" text link
  - [ ] Auto-redirect if already logged in
- [ ] Build `LoginScreen`
  - [ ] Login / Sign Up tab switcher
  - [ ] Email / School ID input field
  - [ ] Password input with show/hide toggle
  - [ ] "Forgot Password?" link
  - [ ] Login button
  - [ ] "Continue with Google" button (placeholder Sprint 2, active Sprint 3)
  - [ ] Terms & Privacy Policy footer
  - [ ] Error handling (wrong password, user not found)
- [ ] Build `RegisterScreen`
  - [ ] Full name field
  - [ ] Email / School ID field
  - [ ] Password + confirm password
  - [ ] Terms acceptance checkbox
  - [ ] Submit button
  - [ ] Validation and error handling
- [ ] Build `ForgotPasswordScreen`
  - [ ] Email input
  - [ ] "Send Reset Link" button
  - [ ] Success confirmation state

**Presentation — Widgets**
- [ ] Create `AuthTextField` — styled text field for auth forms
- [ ] Create `AuthFormWrapper` — card wrapper for login/register forms

**Firestore**
- [ ] Create user profile document on first sign-up
- [ ] Update `lastLoginAt` on each successful sign-in
- [ ] Store FCM token on sign-in

**Testing**
- [ ] Unit test: `SignInWithEmailUseCase`
- [ ] Unit test: `SignUpWithEmailUseCase`
- [ ] Unit test: `SignInAnonymouslyUseCase`
- [ ] Unit test: `AuthRepositoryImpl` (mock datasource)
- [ ] Widget test: `LoginScreen`
- [ ] Widget test: `RegisterScreen`

---

### Epic 1.8 — Home Dashboard Feature

**Presentation — Screens**
- [ ] Build `HomeDashboardScreen`
  - [ ] App bar: hamburger menu, "Home" title, notification bell
  - [ ] Welcome card: "Welcome, {name}! How can we help make our {orgType} better?"
  - [ ] 2×2 feature tile grid
    - [ ] Submit Concern tile
    - [ ] My Reports tile
    - [ ] Announcements tile (placeholder)
    - [ ] Organization Information tile (placeholder)
  - [ ] Bottom navigation bar: Home | My Reports | + (FAB) | Alerts | Profile

**Presentation — Widgets**
- [ ] Create `DashboardTile` — icon + label tile widget
- [ ] Create `WelcomeCard` — org-branded greeting card
- [ ] Create `AppBottomNavBar` — persistent bottom navigation

**Testing**
- [ ] Widget test: `HomeDashboardScreen`
- [ ] Widget test: `DashboardTile`

---

### Epic 1.9 — Report Submission Feature

**Domain**
- [ ] Create `ReportEntity`
- [ ] Create `ReportCategoryEntity`
- [ ] Create `ReportRepository` abstract interface
- [ ] Create `SubmitReportUseCase`
- [ ] Create `GenerateReportReferenceUseCase`
- [ ] Create `GetReportCategoriesUseCase`
- [ ] Create `UploadReportPhotosUseCase`

**Data**
- [ ] Create `ReportModel` (with `fromJson`/`toJson`)
- [ ] Create `ReportCategoryModel`
- [ ] Create `ReportRemoteDataSource` (Firestore writes + Storage uploads)
- [ ] Create `ReportRepositoryImpl`
- [ ] Implement atomic reference number counter (Firestore transaction)

**Presentation — Providers**
- [ ] Create `reportCategoriesProvider` (FutureProvider loading org categories)
- [ ] Create `submitReportNotifierProvider` (AsyncNotifier for multi-step form state)
- [ ] Create `reportPhotosProvider` (StateNotifier for photo picker state)

**Presentation — Screens**
- [ ] Build `SubmitReportScreen` (3-step wizard host)
  - [ ] 3-step progress indicator
  - [ ] Step navigation (Next/Back/Submit)
  - [ ] Form state preserved across steps
- [ ] Build `SubmitReportStep1` (Details)
  - [ ] "Report as" toggle: Anonymous | With Identity
  - [ ] Category dropdown (loaded from org config)
  - [ ] Title text field
  - [ ] Description text area
  - [ ] Character count for description
  - [ ] Validation before proceeding to step 2
- [ ] Build `SubmitReportStep2` (Photos)
  - [ ] Up to 3 photo slots with + add buttons
  - [ ] Camera and gallery picker
  - [ ] Photo preview with remove option
  - [ ] "Optional" label
- [ ] Build `SubmitReportStep3` (Review)
  - [ ] Summary of all entered details
  - [ ] Photo thumbnails
  - [ ] "Back" and "Submit" buttons
  - [ ] Loading state on submit
- [ ] Build `ReportConfirmationScreen`
  - [ ] Success checkmark animation
  - [ ] "Thank You!" heading
  - [ ] Reference number display (e.g., `MONHS-2026-000001`)
  - [ ] "Go to My Reports" button

**Presentation — Widgets**
- [ ] Create `CategoryDropdown` — org-category picker
- [ ] Create `PhotoPickerWidget` — 3-slot photo picker
- [ ] Create `ReportReviewSummary` — step 3 summary card
- [ ] Create `StepProgressIndicator` — 1→2→3 progress widget
- [ ] Create `AnonymousToggle` — Anonymous | With Identity segmented control; hidden entirely when category `anonymityMode` is `identified`; unchanged when `open`; hidden when `voluntary_contact` (report is always anonymous, opt-in offered post-submit)
- [ ] Show `identifiedNotice` banner on report form when `anonymityMode` is `identified`
- [ ] Build post-submit `VoluntaryContactSheet` — shown after anonymous submit when `anonymityMode` is `voluntary_contact`; stores opt-in as a separate `counselorContactRequests/{requestId}` document not linked to the report

**Firebase**
- [ ] Configure Firebase Storage rules for photo uploads
- [ ] Compress images before upload (max 1MB per photo)
- [ ] Generate download URLs and store in report document
- [ ] Implement Firestore transaction for atomic reference number increment

**Testing**
- [ ] Unit test: `SubmitReportUseCase`
- [ ] Unit test: `GenerateReportReferenceUseCase`
- [ ] Unit test: `ReportRepositoryImpl` (mock datasource)
- [ ] Widget test: `SubmitReportStep1`
- [ ] Widget test: `PhotoPickerWidget`
- [ ] Integration test: full submit flow

---

### Epic 1.10 — My Reports & Report Details Feature

**Domain**
- [ ] Create `GetMyReportsUseCase`
- [ ] Create `WatchMyReportsUseCase` (real-time stream)
- [ ] Create `GetReportDetailsUseCase`

**Data**
- [ ] Create `ReportRemoteDataSource.watchMyReports()` (Firestore stream)
- [ ] Create `ReportRemoteDataSource.getReportById()`

**Presentation — Providers**
- [ ] Create `myReportsProvider` (StreamProvider for real-time updates)
- [ ] Create `reportDetailProvider` (FutureProvider by reportId)
- [ ] Create `reportStatusFilterProvider` (StateProvider for tab filtering)

**Presentation — Screens**
- [ ] Build `MyReportsScreen`
  - [ ] Tab bar: All | Submitted | In Progress | Resolved
  - [ ] Filtered report list per tab
  - [ ] Pull-to-refresh
  - [ ] Empty state per tab
  - [ ] Pagination
- [ ] Build `ReportDetailsScreen`
  - [ ] Full report title, description, category
  - [ ] Report status with history timeline
  - [ ] Photo viewer
  - [ ] Reference number display
  - [ ] Submission date

**Presentation — Widgets**
- [ ] Create `ReportCard` — list item card (ref number, title, status, date)
- [ ] Create `ReportStatusBadge` — color-coded status chip
- [ ] Create `StatusTimeline` — vertical status history list

**Testing**
- [ ] Unit test: `GetMyReportsUseCase`
- [ ] Widget test: `MyReportsScreen`
- [ ] Widget test: `ReportCard`

---

### Epic 1.11 — Admin Dashboard Feature

**Domain**
- [ ] Create `AdminEntity` *(using `ReportEntity` directly — separate entity deferred)*
- [ ] Create `AdminRepository` abstract interface *(admin ops added to `ReportRepository`)*
- [x] Create `GetAllReportsUseCase` (admin: all org reports) — via `allReportsProvider`
- [x] Create `UpdateReportStatusUseCase` — `updateReportStatus()` in report provider
- [x] Create `AddAdminNoteUseCase` — `addAdminNote()` in report provider
- [ ] Create `AssignReportUseCase`

**Data**
- [ ] Create `AdminModel` *(deferred — using ReportModel)*
- [x] Create `AdminRemoteDataSource` — admin methods added to `ReportRepositoryImpl`
- [ ] Create `AdminRepositoryImpl` *(deferred — merged into ReportRepositoryImpl)*

**Presentation — Providers**
- [x] Create `allReportsProvider` (StreamProvider for all org reports)
- [x] Create `adminCategoryFilterProvider` (NotifierProvider — multi-select Set<String>)
- [x] Create `adminReportByIdProvider` (FutureProvider.family for detail screen)

**Presentation — Screens**
- [x] Build `AdminDashboardScreen`
  - [x] Filter bar (by category — multi-select chips)
  - [x] Filter by status (tab bar: All / Submitted / In Review / Resolved / Closed)
  - [ ] Search bar
  - [x] Report list (all org reports, tap to navigate to detail)
  - [ ] Quick stats header (total, pending, in-progress)
- [x] Build `AdminReportDetailScreen`
  - [x] Full report view (title, ref number, status badge, priority badge, submitter, description)
  - [x] Photo gallery (horizontal scroll, full-screen tap)
  - [x] Status update control (`_StatusUpdateDialog`)
  - [ ] Assign to dropdown
  - [x] Notes/reply thread (`_AdminNoteCard` list + `_AddNoteDialog`)
  - [x] Status history timeline

**Presentation — Widgets**
- [x] Create `AdminReportCard` — tappable card navigating to detail screen
- [x] Create `StatusUpdateDialog` — modal with status dropdown + optional note
- [x] Create `AdminFilterBar` — horizontal multi-select filter chips
- [x] Create `AdminNoteCard` + `AddNoteDialog` — notes thread UI

**Firestore**
- [x] Implement admin status update (with `statusHistory` append)
- [x] Implement admin note creation
- [ ] Implement assign report to admin user

**Push Notifications**
- [ ] Send FCM notification to admin topic on new report
- [ ] Send FCM notification to reporter on status change (if not anonymous)

**Testing**
- [ ] Unit test: `UpdateReportStatusUseCase`
- [ ] Unit test: `AddAdminNoteUseCase`
- [ ] Widget test: `AdminDashboardScreen`

---

### Epic 1.12 — Notifications Feature

- [ ] Configure Firebase Cloud Messaging in Flutter
- [ ] Request notification permission on first launch (Android 13+)
- [ ] Save FCM token to user profile in Firestore
- [ ] Handle FCM token refresh (update Firestore)
- [ ] Handle foreground notifications (in-app banner)
- [ ] Handle background notification taps (navigate to correct screen)
- [ ] Build `AlertsScreen` — list of received notifications
- [ ] Admin: subscribe to org admin topic on login
- [ ] Admin: unsubscribe from topic on logout

---

### Epic 1.13 — Settings & Profile Feature

- [ ] Build `SettingsScreen`
  - [ ] Theme toggle (dark/light)
  - [ ] Notification preferences
  - [ ] Language selector dropdown (switches app language)
  - [ ] About section (app version, organization info)
  - [ ] Sign out button
- [ ] Build `ProfileScreen`
  - [ ] Display name
  - [ ] Email / School ID
  - [ ] Change password link
  - [ ] Account info
  - [ ] Groups membership list
- [ ] Implement theme persistence (SharedPreferences)
- [ ] Implement language preference persistence (SharedPreferences + Firestore sync)

---

## Phase 2 — Pilot Expansion & Communications

### Epic 2.1 — Organization Onboarding

> **Design:** [SCHOOL_ONBOARDING_AND_SUBSCRIPTIONS.md](SCHOOL_ONBOARDING_AND_SUBSCRIPTIONS.md) — self-serve wizard, pay at end, `pending_payment` → `active`

- [ ] In-app **Register your school** wizard (pricing shown first; branding, join policy, admin link)
- [ ] `submitSchoolOnboarding` Cloud Function — auto Phase A (`organizations/{orgId}`, seed roles/categories, admin profile)
- [ ] `onboardingRequests/{requestId}` collection + realtime status in initiating app
- [ ] `subscriptionStatus` on org doc (`pending_payment` \| `active` \| …); gate directory + student join on `active`
- [ ] PayMongo / Stripe checkout (web) + webhook → activate org + in-app notification to admin
- [ ] Sandbox mode before payment (admin configures; students blocked)
- [ ] Super-admin manual activate (invoice / pilot override)
- [ ] Platform notification on new org registration (optional fraud review)
- [ ] Custom app name (`appCustomName`) / display name in wizard (e.g., "MONHS")

### Epic 2.2 — Branding Customization

- [ ] In-app branding config editor (admin)
- [ ] Logo upload via Firebase Storage
- [ ] Dynamic app theme from org config
- [ ] Custom tagline per org
- [ ] Configurable category management UI

### Epic 2.3 — Organization Finder & Apply-to-Join Flow

**Organization Discovery**
- [ ] Build `FindSchoolScreen` — search for organizations by name, code, or region
- [ ] Firestore query: search `organizations` collection by `displayName` or `appCustomName`
- [ ] Display org card: logo, name, city/region, type
- [ ] "Apply to Join" button on org card

**Apply-to-Join Signup**
- [ ] Build `ApplyToJoinScreen` — full name + school-issued ID input
- [ ] Validate `studentId` against org `roster` collection on submission
- [ ] Create user with `approvalStatus: 'pending'` if roster match found
- [ ] Admin notification: new signup application pending review
- [ ] Build `PendingApprovalScreen` — shown after apply, explains next steps
- [ ] Admin: view and approve/reject pending applications
- [ ] Notify user on approval or rejection (push + in-app)

**Roster Management**
- [ ] Build `RosterManagementScreen` (admin)
- [ ] Import roster from CSV file (parse name + ID columns)
- [ ] Import roster from plain text (line-by-line or tab-separated)
- [ ] Import roster from Word (.docx) file
- [ ] Import roster from PDF file
- [ ] Import roster by pasting into a text window (auto-parse)
- [ ] Show import preview before confirming
- [ ] Bulk write roster entries to Firestore `roster` subcollection
- [ ] Admin: view, search, and remove roster entries
- [ ] Mark roster entry `isRegistered: true` when user completes signup
- [x] Admin: reset member password (`resetOrgMemberPassword` Cloud Function + in-app dialog)
- [ ] **Future (blocked on email infrastructure) — password reset via email link (preferred):**
  - [ ] When admin requests a member password reset and `profile.email` is set, email a secure, time-limited reset link (Firebase Auth action link or signed custom token)
  - [ ] Link target: web reset-password page **or** app deep link (`/reset-password?token=…`) that lands on an in-app screen to enter and confirm a new password
  - [ ] Invalidate link after use or expiry; audit `passwordResetAt` / `passwordResetBy` on profile
  - [ ] Hook: new callable or extend `resetOrgMemberPassword` in `shared/functions/src/reset_org_member_password.ts`
- [ ] **Future (email infrastructure) — interim fallback:** Email member that an admin changed their password and include the new value only if link-based self-service reset is not shipped yet (less secure; avoid long term)

**Member photos (official + personal badge)** *(complete — June 5, 2026)*
- [x] **Official photo (admin-controlled)** — `officialPhotoUrl` on user profile + `roster/{studentId}`:
  - [x] Upload/replace/remove via **Edit Member** and **Student Roster** (tap avatar)
  - [x] Who may manage: org admin / system admin and anyone with **`manageClassRoster`**, **`blockUsers`**
  - [x] Students and regular members **cannot** change the official photo (rules + callables)
  - [x] Store in Firebase Storage (`users/{userId}/official/…`, `roster/{studentId}/official/…`)
- [x] **Personal badge / avatar (member-controlled)** — `avatarUrl` on user profile:
  - [x] **Settings → Profile header:** tap the circular badge to pick/upload a personal image (when `allowMemberProfilePhotos` is ON)
  - [x] Org admin toggle: **Organization Settings → Allow personal profile photos** (default OFF)
  - [x] Members may change their own `avatarUrl` only; never `officialPhotoUrl`; personal upload does not overwrite school record
  - [x] **Display priority:** `avatarUrl` → `officialPhotoUrl` → initials (`app_avatar.dart`)
- [x] Cloud Functions: `uploadMemberAvatar` (server-side upload for members — avoids client Storage/App Check 403), `setMemberAvatarUrl`, `setOfficialPhotoUrl` — deployed to `speakup-connect-891dd`
- [x] Firestore Security Rules: block self-writes to `officialPhotoUrl`; `allowMemberProfilePhotos` org toggle
- [x] Firebase Storage rules: `avatar/` (self) vs `official/` (admin/roster manager) paths
- [x] `allowMemberProfilePhotos` cached in `OrgConfigCacheService`; Settings profile circle always tappable (snackbar when disabled)
- [x] Help guides: member Settings photo + admin official school photo (`assets/help/`, `shared/docs/help/`)
- [x] On-device smoke test: member personal upload on Android (MONHS pilot)
- [ ] Optional later: bulk official-photo import with roster CSV; photo on group roster cards; Firebase App Check for client Storage uploads

### Epic 2.4 — Community Rules

- [ ] Create `communityRules` Firestore collection per org
- [ ] Seed default rules on org creation
- [ ] Build `CommunityRulesScreen` (admin) — create, edit, reorder, delete rules
- [ ] Display rules on `RegisterScreen` / apply-to-join form (with checkbox acceptance)
- [ ] Display rules on home page / info section
- [ ] Enforce `communityRulesEnabled` flag from org config

### Epic 2.5 — Multi-Language Support

> **Status:** `[~]` In progress — **Phase 1 + 1b shipped** (June 2026, commit `ee38c77`); next: Translation Helper MVP → real Cebuano copy → Tagalog → feature extraction → Firestore sync  
> **Architecture:** [INTERNATIONALIZATION.md](INTERNATIONALIZATION.md) — US English (`en_US`) home language; **`ceb`** first regional add-on; **`fil` (Tagalog)** second platform language; **Translation Helper** for scale.  
> **GitHub:** [#48](https://github.com/edbecnel/speakup-connect/issues/48) Translation Helper · [#49](https://github.com/edbecnel/speakup-connect/issues/49) Cebuano · [#50](https://github.com/edbecnel/speakup-connect/issues/50) Tagalog · [#51](https://github.com/edbecnel/speakup-connect/issues/51) feature extraction · [#52](https://github.com/edbecnel/speakup-connect/issues/52) validators/CI · [#53](https://github.com/edbecnel/speakup-connect/issues/53) Firestore sync

**Infrastructure (Phase 1)**
- [x] Add `flutter_localizations`; configure `l10n.yaml` and `flutter: generate: true`
- [x] Create `speakup_connect_app/lib/l10n/app_en.arb` (US English template) and `app_ceb.arb` (English placeholders)
- [ ] Create `lib/l10n/app_fil.arb` (scaffold — copy English until Translation Helper export)
- [x] Implement `appLocaleProvider` + `SharedPreferences` cold-start cache (`lib/core/l10n/locale_provider.dart`)
- [ ] Implement `locale_resolution.dart` — full chain: user `preferredLanguage` → org `defaultLanguage` → device locale → `en_US`
- [x] Wire `MaterialApp` `localizationsDelegates`, `supportedLocales`, `locale` (`lib/app.dart`)
- [x] `context.l10n` extension (`lib/core/l10n/app_localizations_extension.dart`)

**String migration**
- [x] Define key conventions (see INTERNATIONALIZATION.md §6)
- [x] Phase 1 extraction → `app_en.arb`: **auth** (login, splash), **home**, **settings**, **help hub**
- [ ] Phase 2 extraction — by feature area (hardcoded UI → `app_en.arb`):
  - [ ] **Auth:** register, apply-to-join
  - [ ] **Reports:** submit flow, my reports, report details, confirmation
  - [ ] **Admin:** roster, approval queue, branding, grades, add/edit member, enrolled users, admin report detail
  - [x] **Groups:** browse, create, edit, my groups, members, membership requests (`groups*` ARB keys; Cebuano via Translation Helper)
  - [ ] **Announcements:** compose, detail, my announcements, responses, edit dialog
  - [ ] **Reminders:** compose, responses, expiration/response config widgets
  - [ ] **Roles:** management, assign, editor, user assignments
  - [ ] **Notifications / alerts** inbox and snackbars
  - [ ] **Settings:** change password and any remaining settings sub-screens
- [ ] Migrate `lib/core/utils/validators.dart` messages to l10n keys (pass `AppLocalizations` or `BuildContext`)
- [ ] Audit `intl` date/number formatting — pass active locale, not hardcoded `en_US` (INTERNATIONALIZATION.md §13)
- [ ] CI: fail build if `app_ceb.arb` or `app_fil.arb` missing keys from `app_en.arb`
- [ ] CI or custom lint: ban new hardcoded user-facing strings in `lib/features/**/presentation/`
- [x] Add hardcoded UI string audit tooling for extraction workflow (`find-hardcoded-ui-strings.js`, allowlist, route-alias generator, and catalog mapping updates in Translation Helper)

**Translation Helper tool** (see INTERNATIONALIZATION.md §12)
- [x] MVP: web or admin UI — import `app_en.arb`, list all keys with US English source
- [x] Per-target-language editor with status: `missing` \| `ai_draft` \| `in_review` \| `approved`
- [x] Export approved strings to `app_ceb.arb` / `app_fil.arb` (and future ARB files)
- [x] `draftTranslation` + `batchDraftTranslations` Cloud Functions — AI first draft via **model API**; **human approval required** before export
- [ ] Store **`TRANSLATION_AI_API_KEY`** in Firebase Secret Manager (`functions:secrets:set`); never in app or git
- [x] Env/params: `TRANSLATION_AI_PROVIDER`, `TRANSLATION_AI_MODEL`; provider HTTP client in `shared/functions/src/translation_ai.ts`
- [x] Prompt template: preserve ICU placeholders; post-validate `{name}` / plurals; `ai_draft_failed` on mismatch
- [x] Auth: platform `super_admin`, org admin, or **`manageTranslations`** permission (assignable via Roles)
- [ ] Translation Helper: **Translate missing (AI)** + per-row re-draft; no direct browser → provider calls
- [x] Filter/search by feature, missing keys, review status
- [x] In-app Translation Workspace (`/admin/translations`) for org admins and translation moderators
- [x] In-app translation mode — browse app, EN/target toggle, session review → Firestore; admin-configurable badges per app screen (Screen names)
- [x] Screen names registry — CRUD, route assignment, string `context`, Translation badges toggle (app + web)
- [x] Expand `TranslationAnchor` instrumentation to more screens in code
- [x] Translation screens summary view + summary UX improvements (layout, loading/error handling, sorting, collapsible actions in app/web tooling)
- [ ] Phase 2: Firestore-backed workflow (`languages/{code}/strings` + export job)

**Cebuano (Bisaya) — 1st add-on**
- [x] Scaffold `app_ceb.arb` + add `ceb` to `supportedAppLanguageCodes` and `kLanguageNativeLabels`
- [x] Locale-aware help resolver + `member_guide_ceb.md` in `assets/help/` (`_default` + MONHS org copy; English placeholders)
- [x] Sync `shared/docs/help/` member guides with language UI (keep in sync when editing help)
- [ ] Translate phase-1 keys via Translation Helper → real Cebuano in `app_ceb.arb` (native speaker review)
- [ ] Replace English placeholder content in `member_guide_ceb.md` (assets + docs)
- [ ] Widget tests with `Locale('ceb')` on auth + home (layout smoke)

**Tagalog — 2nd language**
- [ ] Add `app_fil.arb` + `fil` to `supportedAppLanguageCodes` and `kLanguageNativeLabels` (`Tagalog`)
- [ ] Add `member_guide_fil.md` under `assets/help/` (+ MONHS org copy) and `shared/docs/help/`
- [ ] Translate phase-1 keys via Translation Helper → `app_fil.arb` (native speaker review)
- [ ] Widget tests with `Locale('fil')` on auth + home (layout smoke)

**Presentation & org config**
- [x] Language picker — Settings → Appearance → Language (`showLanguagePickerSheet`)
- [x] Language picker — Home dashboard (`LanguageSelectorDropdown` at top of scroll)
- [x] Picker option labels via `kLanguageNativeLabels` only — **not** ARB (INTERNATIONALIZATION.md §6.1)
- [ ] Sync `preferredLanguage` to `users/{uid}` on change (read on sign-in; write on picker change)
- [ ] `supportedLocalesForOrgProvider` — filter pickers by org `supportedLanguages`
- [ ] Admin: org `defaultLanguage` + `supportedLanguages` in branding settings UI

**Cloud Functions & push (phase 2)**
- [ ] Localized push notification titles/bodies — functions i18n map or template per locale (INTERNATIONALIZATION.md §7)

**Firestore overlay (phase 2 — optional)**
- [ ] Seed `languages/en`, `languages/ceb`, `languages/fil` metadata in Firestore
- [ ] Super-admin / Translation Helper hot-reload overlay on bundled ARB

**Testing**
- [ ] `locale_resolution_test.dart` — resolution order unit tests
- [ ] Widget/golden tests for longer Cebuano/Tagalog strings on key screens (optional goldens)

### Epic 2.6 — Groups & Clubs

**Domain**
- [x] Create `GroupEntity`
- [x] Create `GroupMemberEntity`
- [x] Create `GroupRepository` abstract interface
- [x] Create `CreateGroupUseCase`
- [x] Create `AddGroupMemberUseCase`
- [x] Create `GetGroupsUseCase`
- [x] Create `GetMyGroupsUseCase`

**Data**
- [x] Create `GroupModel` (with `fromJson`/`toJson`)
- [x] Create `GroupMemberModel`
- [x] Create `GroupRemoteDataSource`
- [x] Create `GroupRepositoryImpl`
- [x] Per-user `groupMemberships` index + `syncMyGroupMemberships` / `syncUserGroupMembershipIndex` Cloud Functions

**Presentation**
- [x] Build `GroupsListScreen` — all org groups, searchable
- [ ] Build `GroupDetailScreen` — group info, member list, news posts, group chat
- [x] Build `CreateGroupScreen` (admin) — name, description, custom club positions
- [x] Build `GroupMembersScreen` (admin/leader) — add/remove members, assign leader & club position
- [x] Build `AddGroupMembersScreen` — search, role/position assignment, scroll-safe layout
- [x] Build `MyGroupsScreen` — member view; **View Members** vs **Manage Members** by role; leader actions
- [x] Build `EditGroupScreen` — unified group settings (name, description, policies, club positions, active flag)
- [x] `updateGroup` in repository + datasource; sync `groupName` on membership indexes when renamed
- [x] Show user's groups on home dashboard (`MyGroupsHomeSection`) and Settings
- [x] Group role badge: leader vs. member; club position display

**Group leaders** *(subset of roster + reminders)*
- [x] Leaders can view group roster, add members, change leader/member role and club position
- [x] Leaders can compose **group alerts** to groups they lead (`createGroupLeaderReminder` callable)
- [x] Leaders can view **Sent Group Alerts** and **View responses** for their broadcasts
- [x] `My Groups` index auto-repair on stream attach (roster → `users/{uid}/groupMemberships`)

**Testing**
- [ ] Unit test: `CreateGroupUseCase`
- [ ] Unit test: `GroupRepositoryImpl`
- [ ] Widget test: `GroupsListScreen`

### Epic 2.6.1 — Group Membership Requests (Join & Leave) *(planned)*

> **GitHub:** [#47](https://github.com/edbecnel/speakup-connect/issues/47) · **Milestone:** Sprint 13  
> Design: [GROUP_JOIN_REQUESTS.md](GROUP_JOIN_REQUESTS.md). Join: default **closed** (`allowJoinRequests`). Leave: default **request required** (`memberLeavePolicy`). Admins and group leaders configure both per group.

**Domain**
- [ ] Add `allowJoinRequests`, `joinRequestHint`, `memberLeavePolicy` to `GroupEntity` / `GroupModel`
- [ ] Create `GroupJoinRequestEntity`, `GroupLeaveRequestEntity` (`status`: pending | approved | rejected | withdrawn)
- [ ] Extend `GroupRepository`: join + leave submit, withdraw, list pending, review
- [ ] Use cases: submit/review/withdraw join; voluntary leave; submit/review/withdraw leave

**Data**
- [ ] `GroupJoinRequestModel`, `GroupLeaveRequestModel` + Firestore codecs
- [ ] Datasource methods for `joinRequests` and `leaveRequests` subcollections
- [ ] Denormalize `organizationId`, `groupId`, `groupName` on request docs for admin queue queries

**Cloud Functions — join**
- [ ] `submitGroupJoinRequest` — approved member; `allowJoinRequests`; not on roster; idempotent pending check
- [ ] `reviewGroupJoinRequest` — admin / `manageGroupRoster` / leader; approve adds member + sync index
- [ ] `withdrawGroupJoinRequest` — requester cancels pending join request

**Cloud Functions — leave**
- [ ] `voluntaryLeaveGroup` — member; `memberLeavePolicy == voluntary`; block sole leader
- [ ] `submitGroupLeaveRequest` — member; `request_required`; required reason (20–500 chars)
- [ ] `reviewGroupLeaveRequest` — approve removes member; deny **requires** `rejectionReason`
- [ ] `withdrawGroupLeaveRequest` — requester cancels pending leave request
- [ ] Enhance `removeGroupMember` (or server wrapper) — notify removed member; cancel pending leave request

**Cloud Functions — counts**
- [ ] Optional: maintain `pendingJoinRequestCount`, `pendingLeaveRequestCount` on group doc

**Security**
- [ ] Firestore rules: `joinRequests` / `leaveRequests` read for requester, leader, admin; writes via callables only
- [x] Extend `onlyGroupLeaderGroupUpdate()` for `name`, `description`, `allowJoinRequests`, `joinRequestHint`, `memberLeavePolicy`
- [ ] Route roster deletes through callables so removal notifications always fire
- [ ] Composite / collection-group indexes for pending join and leave queues

**Presentation — settings & admin**
- [ ] **Allow join requests** toggle on `CreateGroupScreen` (default OFF)
- [ ] **Member leave policy** selector: Leave anytime | Must request to leave (default request)
- [x] **Edit Group** screen — join toggle, leave policy, hint, name, description (admin + `manageGroupRoster` + leader; leaders cannot edit position lists or active flag)
- [x] Badge on admin `GroupsListScreen` for pending join + leave counts (subtitle + requests icon)

**Presentation — members (join)**
- [ ] `BrowseGroupsScreen` — status: Member | Pending | Request to join | Invitation only
- [ ] `GroupJoinRequestSheet` — optional message
- [ ] Entry points: Home, Settings (near My Groups)

**Presentation — members (leave)**
- [ ] `MyGroupsScreen`: **Leave group** when `voluntary`; **Request to leave** when `request_required`
- [ ] `GroupLeaveRequestSheet` — required reason form (20–500 chars); show **Leave pending** state
- [ ] Confirmation dialog for voluntary leave

**Presentation — review queue**
- [ ] `GroupMembershipRequestsScreen` — **Join** and **Leave** tabs; approve / reject (deny leave requires reason)
- [ ] Leader badges on `MyGroupsScreen` / `GroupMembersScreen`
- [ ] Optional: cross-group aggregate screen for admins

**Notifications (in-app alert + push)**
- [ ] New join / leave request → leaders + roster admins
- [ ] Join approved / rejected → requester
- [ ] Leave approved → requester
- [ ] Leave **denied** → requester with **rejection reason in alert body**
- [ ] **Removed** by admin/leader → removed member (automated alert)
- [ ] Optional: voluntary leave → notify leaders

**Routes & providers**
- [x] `Routes.browseGroups`, `Routes.editGroupPath(groupId)`, `Routes.groupMembershipRequestsPath(groupId)`
- [ ] `canReviewGroupMembershipRequestsProvider`, pending join/leave providers, `groupMembershipPolicyProvider`

**Documentation & help**
- [ ] Update `MEMBER_GUIDE` / `ADMIN_GUIDE` — join policies, leave policies, removal/denial alerts
- [ ] Sync `assets/help/`

**Testing**
- [ ] Unit tests: join/leave use cases, policy guards, sole-leader block
- [ ] Rules / emulator: closed join, voluntary leave, leave request deny with reason
- [ ] Widget tests: browse status chips; leave vs request-to-leave buttons
- [ ] On-device: SSLG (`request_required` leave); Drum and Lyre (`voluntary`); removal alert; denied leave shows reason

### Epic 2.7 — Organization-Wide Announcements *(Bulletin Board)*

**Domain**
- [x] Create `BulletinEntity` (+ `responseConfig`, `imageUrl`)
- [x] Create `BulletinRepository` abstract interface
- [x] Post / watch / update / delete via repository + providers

**Data**
- [x] Create `BulletinModel`
- [x] Create `BulletinRepositoryImpl` (+ `BulletinResponseRepository`)
- [x] Cloud Functions: `createGroupLeaderAnnouncement`, `onBulletinPublished`, `publishDueBulletins`, `submitBulletinResponse`, `updateBulletin`, `deleteBulletin`, `setBulletinImageUrl`

**Presentation**
- [x] `AnnouncementsScreen` — org-wide list; pinned first
- [x] `AnnouncementDetailScreen` — full content, image, response form
- [x] `ComposeAnnouncementScreen` — title, body, schedule for later, pin, expiry, image, request-a-response
- [x] `EditAnnouncementDialog` — edit title/body/expiry/image/response settings
- [x] `MyAnnouncementsScreen` — author manage + view responses
- [x] Group leaders: **Post Announcement** from My Groups; approval queue when enabled
- [x] Alerts integration — attention badges for pending responses
- [x] Firestore rules + indexes for bulletin responses and author updates

**Home & auth (June 2026)**
- [x] Home dashboard: **Quick Actions** above **My Groups & Clubs** (collapsed by default)
- [x] `resolveLoginEmail` — student ID / contact email for members; real email for admin/staff (no synthetic student-email mapping for non-members)
- [x] In-app + `shared/docs/help` guides updated for sign-in, home, announcements (incl. schedule for later, June 2026)

**Testing**
- [ ] Unit test: bulletin submit / update flows
- [ ] Widget test: `AnnouncementsScreen`, `EditAnnouncementDialog`

### Epic 2.8 — News Board

**Domain**
- [ ] Create `NewsPostEntity`
- [ ] Create `NewsPostRepository` abstract interface
- [ ] Create `PostNewsUseCase` (requires `canPostNews` permission)
- [ ] Create `GetNewsFeedUseCase`

**Data**
- [ ] Create `NewsPostModel`
- [ ] Create `NewsPostRemoteDataSource`
- [ ] Create `NewsPostRepositoryImpl`

**Presentation**
- [ ] Build `NewsBoardScreen` — combined feed of org-wide and group news posts
- [ ] Build `NewsPostDetailScreen` — full post content
- [ ] Build `CreateNewsPostScreen` (group leader / role-authorized user) — title, body, group, visibility
- [ ] Filter feed: All / My Groups / Org-Wide
- [ ] Push notification to group members on new group post

**Testing**
- [ ] Unit test: `PostNewsUseCase`
- [ ] Widget test: `NewsBoardScreen`

### Epic 2.9 — Reminders *(Sprint 10)*

**Permissions**
- [x] Add `approveReminders` to `AppPermission` enum (group: Reminders)
- [ ] Update `org-admin` seed role in `SeedRoles` notifier to include `approveReminders`
- [ ] Update `seed_roles.js` script to include `approveReminders` in org-admin

**Org Settings**
- [x] Add `requireReminderApproval` boolean field to `organizations/{orgId}` document (default: `false`)
- [x] Admin toggle UI — **Organization Settings → Reminder Approval** with server-verified save

**Domain**
- [x] Create `ReminderEntity` — id, title, body, audience, status (draft/pending/published/rejected), authorId, createdAt, publishedAt
- [x] Create `ReminderRepository` abstract interface
- [x] Submit/approve/reject logic in `reminder_provider` (replaces separate use-case classes)
- [x] Pending queue stream (`pendingRemindersProvider`)

**Data**
- [x] Create `ReminderModel` with `fromFirestore` / `toFirestore`
- [x] Create `ReminderRepositoryImpl` (+ `createGroupLeaderReminder` callable for student leaders)
- [x] Firestore path: `organizations/{orgId}/reminders/{reminderId}`
- [x] Firestore security rules: `broadcastReminders` to create, `approveReminders`/admins to approve/reject, group leaders via callable

**Presentation**
- [x] Build `ComposeReminderScreen` — title, body, audience selector (all org / specific group / specific role)
- [x] Submit logic: if `requireReminderApproval && !canPublishDirectly` → `pending`; else `published` (leaders via `createGroupLeaderReminder`)
- [x] Build `MyBroadcastsScreen` — sent reminders, edit/recall, view responses
- [x] Build `ReminderApprovalQueueScreen` — approve/reject; org admins + `approveReminders` holders
- [x] Pending count badges — Admin Dashboard, Settings, Alerts app bar
- [x] Gate Compose button on `canComposeRemindersProvider` (org broadcasters + group leaders)
- [x] Reminders appear in user in-app notification feed on publish
- [x] Push notification delivered to audience on publish (Cloud Functions `onReminderPublished`, `publishDueReminders`)

**Indexes**
- [x] Add composite index: `reminders(status ASC, createdAt DESC)` to `firestore.indexes.json`

**Testing**
- [ ] Unit test: reminder submit / approve flows
- [ ] Unit test: `ApproveReminderUseCase` (or provider equivalent)

### Epic 2.9.1 — Reminder Enhancements *(Sprint 12)*

Optional expiration, notification history, broadcast management, full-screen detail, and recipient responses.

**Expiration & auto-cleanup**
- [x] Add `expiresAt` field to reminder documents and delivered feed copies
- [x] Compose UI: optional expiration via **date & time** or **hours + minutes** duration (`ExpirationPickerSection`)
- [x] Edit broadcast: update or clear `expiresAt` via `updateReminder` Cloud Function
- [x] Scheduled Cloud Function `expireReminders` — archives expired broadcasts and removes feed copies
- [x] Client filters expired items from Alerts feed (synthetic broadcasts + feed entries)

**Notification history**
- [x] Collection `organizations/{orgId}/notification_history/{historyId}` — server-written archive
- [x] Archive on recall (`recalled`), expiration (`expired`), personal dismiss (`user_dismissed`), clear-all (`cleared_all`)
- [x] Callables `dismissNotification`, `clearNotificationFeed` — archive before delete
- [x] `NotificationHistoryScreen` — author/admin read access via Firestore rules
- [x] Firestore composite index: `notification_history(createdBy ASC, removedAt DESC)`
- [x] Bulk notification dismissal from Alerts inbox (multi-select state + batch dismiss action wired through repository/callables)

**Broadcast management UX**
- [x] Callable `updateReminder` — author/admin edit title, body, expiration; propagates to feed copies
- [x] Callable `recallReminder` — author/admin/approver global delete with history archive
- [x] `EditReminderDialog`, edit/delete from Alerts and My Broadcasts (owner + org admin)
- [x] `BroadcastDetailScreen` — full-screen reminder view with back button, expiration display

**Recipient responses** *(optional per broadcast)*
- [x] `responseConfig` on reminder document — `enabled`, `responseRequired`, `type`, `maxTextLength`, `options[]`, `allowAdditionalText`, `allowResponseUpdates`
- [x] Response types: `free_text` (character limit), `checkbox` (multi-select), `multiple_choice` (single-select)
- [x] Compose UI: `ResponseConfigSection` — response type, options, **response required**, **allow changing responses**
- [x] Checkbox options: minimum **one** option row; recipients may submit with **none checked** (valid “none of the above” answer)
- [x] **Allow changing responses** — when off, answers lock after first submit (votes/polls); server + UI enforced
- [x] Subcollection `organizations/{orgId}/reminders/{reminderId}/responses/{userId}` — one response per recipient
- [x] Callable `submitReminderResponse` — validates response against config; upserts per-user doc; rejects locked updates
- [x] `ReminderResponseForm` on `BroadcastDetailScreen` — submit/update or read-only locked view
- [x] `ReminderResponsesScreen` — author/admin/group leader view all responses
- [x] Firestore rules: author/admin read all responses; recipient read own; writes server-only

**Delivery & approval hardening**
- [x] `resolveReminderRecipients` — roster + `groupMemberships` union; author always receives copy
- [x] Roll back `deliveredAt` when zero recipients; `retryReminderDelivery` callable
- [x] Pending reminders query without `orderBy` (avoids missing `createdAt` on server timestamps)
- [x] Org admins see approval queue without separate `approveReminders` grant

**Indexes**
- [x] Collection-group index: `reminders(status ASC, expiresAt ASC)` for expiration job
- [x] Collection-group index: `groupMemberships(organizationId, groupId)` for delivery

**Testing**
- [ ] On-device: compose with each response type → recipient submits → author views responses
- [ ] On-device: expiration via duration and date/time; verify auto-removal and history entry
- [ ] On-device: locked checkbox vote — submit, verify no update when `allowResponseUpdates` is off
- [ ] Unit test: `ReminderResponseConfig` validation
- [ ] Widget test: `ResponseConfigSection`, `ReminderResponseForm`

### Epic 2.10 — Peer-to-Peer Messaging

> **Priority:** High — see [High-Priority Backlog](#high-priority-backlog). Group chat: [Epic 2.11](#epic-211--group-messaging).

**Domain**
- [ ] Create `DirectMessageThreadEntity`
- [ ] Create `MessageEntity`
- [ ] Create `DirectMessageRepository` abstract interface
- [ ] Create `SendDirectMessageUseCase`
- [ ] Create `GetDirectThreadsUseCase`
- [ ] Create `WatchDirectThreadUseCase` (real-time stream)

**Data**
- [ ] Create `DirectMessageThreadModel`
- [ ] Create `MessageModel`
- [ ] Create `DirectMessageRemoteDataSource`
- [ ] Create `DirectMessageRepositoryImpl`
- [ ] Deterministic thread ID generation (`sorted([uidA, uidB]).join('_')`)

**Presentation**
- [ ] Build `MessagesInboxScreen` — list of DM threads, sorted by `lastMessageAt`
- [ ] Build `DirectMessageChatScreen` — real-time chat UI for a thread
- [ ] Compose new message: user picker (org member search)
- [ ] Message bubble UI (sent/received alignment, timestamp)
- [ ] Read receipts display
- [ ] Unread message badge on inbox icon
- [ ] Push notification for new DM

**Testing**
- [ ] Unit test: `SendDirectMessageUseCase`
- [ ] Widget test: `DirectMessageChatScreen`

### Epic 2.11 — Group Messaging

> **Priority:** High — see [High-Priority Backlog](#high-priority-backlog). Ship after or parallel to Epic 2.10; shared inbox UX recommended.

**Domain**
- [ ] Create `GroupMessageThreadEntity`
- [ ] Create `GroupMessageRepository` abstract interface
- [ ] Create `SendGroupMessageUseCase`
- [ ] Create `WatchGroupMessagesUseCase` (real-time stream)

**Data**
- [ ] Create `GroupMessageModel`
- [ ] Create `GroupMessageRemoteDataSource`
- [ ] Create `GroupMessageRepositoryImpl`

**Presentation**
- [ ] Build `GroupChatScreen` — real-time group chat (accessible from `GroupDetailScreen`)
- [ ] Group name and avatar in chat header
- [ ] Member list accessible from chat
- [ ] Push notification for new group message (to group members)

**Testing**
- [ ] Unit test: `SendGroupMessageUseCase`
- [ ] Widget test: `GroupChatScreen`

### Epic 2.13 — Parent Accounts

> **Priority:** High — see [High-Priority Backlog](#high-priority-backlog). Architecture doc TBD (links student roster, alerts, consent). Depends partly on org join flow ([Epic 2.3](MASTER_TASK_LIST.md#epic-23--organization-finder--apply-to-join-flow)).

**Product**
- [ ] Define parent role vs member/student (RBAC: `parent` system role or scoped capability)
- [ ] Parent sign-up / login flow (email + password; not student-ID synthetic auth)
- [ ] Link parent account to one or more students (`parentLinks` or `students/{id}/guardians`)
- [ ] Admin: invite parent, approve link requests, unlink
- [ ] Parent dashboard: linked students, school alerts/announcements visibility (read-only scope TBD)
- [ ] Optional: parent receives copies of student reminder/alert types (org policy flag)
- [ ] Consent / terms acknowledgment for parent accounts ([SECURITY_AND_PRIVACY.md](SECURITY_AND_PRIVACY.md))
- [ ] Firestore rules: parent reads only linked student data permitted by policy

**Data**
- [ ] Schema: `organizations/{orgId}/parentLinks/{linkId}` or nested on student profile
- [ ] Fields: `parentUserId`, `studentUserId`, `studentId`, `relationship`, `status`, `approvedBy`
- [ ] Cloud Function: `linkParentToStudent`, `approveParentLink`

**Presentation**
- [ ] `ParentRegisterScreen` / link-existing-account flow
- [ ] `ParentHomeScreen` or parent mode on Home when role is parent
- [ ] Admin: **Parent links** management on member edit / roster
- [ ] Settings: manage linked children

**Notifications**
- [ ] Push + in-app when parent link approved
- [ ] Parent notification preferences (separate from student)

**Documentation**
- [ ] Help guides: parent login and linking (`assets/help/` + `shared/docs/help/`)
- [ ] Architecture doc `PARENT_ACCOUNTS.md` before implementation

---

### Epic 2.12 — Role-Based Permissions

> Architecture fully designed. See **[shared/docs/RBAC_ARCHITECTURE.md](RBAC_ARCHITECTURE.md)** for the two-tier RBAC model, `AppPermission` enum design, custom capabilities, and enforcement strategy.

- [x] Define `AppPermission` enum in `lib/core/permissions/app_permission.dart`
- [ ] Create `roles` Firestore collection per org — seed default system roles (`org-admin`, `member`)
- [ ] Create `customCapabilities` Firestore collection per org — seed with org-specific defaults
- [x] Build `PermissionProvider` (Riverpod) — resolves effective capabilities from role assignments + custom cap registry
- [x] Implement Firebase Auth Custom Claims Cloud Function (`syncCustomClaims`, `refreshMyPermissions`)
- [x] Build `RolesManagementScreen` (admin) — list, edit, delete roles
- [x] Build `RoleEditorScreen` (admin) — create/edit role with capability checklist
- [x] Build `AssignRoleScreen` (admin) — assign custom roles to users with scope
- [x] Build `CapabilitiesScreen` (admin) — view built-ins, create/delete custom capability aliases
- [x] Enforce permissions via Firestore Security Rules (using Custom Claims) — `roleAssignments`, `roles`, `customCapabilities`, `classes`, `counselorContactRequests`
- [ ] Enforce remaining permission gates in Security Rules:
  - `broadcastReminders` — reminders collection write
  - `postBulletinToGroup` / `postBulletinOrgWide` — bulletins / newsPosts write
  - `manageGroupRoster` — groups subcollection write
  - `blockUsers` — blockedUsers collection write

### Epic 2.13 — Abuse Blocking & Moderation

- [ ] Create `blockedUsers` Firestore collection per org
- [ ] Build `BlockUserDialog` — reason, block type (permanent / temporary + duration)
- [ ] Build `BlockedUsersScreen` (admin) — view, unblock, manage all blocks
- [ ] Enforce block on login: blocked users get a "your account has been restricted" screen
- [ ] Anonymous user block: device fingerprint or IP hash stored in `targetIdentifier`
- [ ] Block expiry: Firebase scheduled function to auto-unblock when `expiresAt` passes
- [ ] Report-a-message feature: users can flag messages for admin review

### Epic 2.14 — Announcements (Original)

- [ ] Announcement Firestore collection schema
- [ ] Admin: create/publish announcement
- [ ] User: view announcements list
- [ ] Push notification for new announcements

### Epic 2.15 — Anonymous Report Reference Code

- [ ] Generate random 8-character reference code on anonymous submit
- [ ] Store code locally (SharedPreferences or encrypted storage)
- [ ] "Track by reference code" lookup screen
- [ ] Status retrieval by code (without auth)

### Epic 2.16 — Analytics & Reporting (Admin)

- [ ] Admin: report counts by category
- [ ] Admin: report counts by status
- [ ] Admin: average resolution time
- [ ] Admin: export reports to CSV
- [ ] Admin: date range filtering

### Epic 2.17 — Admin Activity Audit Log

> Schema fully designed. See **[shared/docs/DATABASE_DESIGN.md → audit_log](DATABASE_DESIGN.md)** for the event taxonomy, document schema, and implementation strategy.

- [ ] Create `audit_log` Cloud Function write helper (shared utility for all triggers)
- [ ] Trigger: `config/main` write → `config.branding_updated`
- [ ] Trigger: `categories/{id}` write → `config.category_created/updated/deleted`
- [ ] Trigger: `roles/{id}` write → `roles.role_created/updated/deleted`
- [ ] Trigger: `customCapabilities/{id}` write → `roles.capability_created/deleted`
- [ ] Extend `syncCustomClaims` trigger → also write `roles.assignment_added/removed` to `audit_log`
- [ ] Trigger: `users/{id}` approval status change → `users.application_approved/rejected`
- [ ] Trigger: `blockedUsers/{id}` write → `users.user_blocked/unblocked`
- [ ] Build `AuditLogScreen` (admin, web-only) — paginated timeline view with `resourceType` + `actorId` filters
- [ ] Firestore Security Rules: `audit_log` readable only by `viewAuditLogs` permission; **no client writes**
- [ ] Add `audit_log` composite indexes to `firestore.indexes.json`

---

## Phase 3 — Multi-Tenant SaaS

### Epic 3.1 — SaaS Infrastructure

- [ ] Platform admin dashboard (web)
- [ ] Organization management CRUD
- [ ] Subscription tier management
- [ ] Billing integration (Stripe or PayMongo)
- [ ] Platform-level audit log

### Epic 3.2 — iOS & Web Deployment

- [ ] iOS App Store setup and provisioning
- [ ] Flutter Web build configuration
- [ ] Platform-specific permission handling (iOS)
- [ ] App Store listing assets

### Epic 3.3 — Compliance & Data Privacy

- [ ] GDPR right to erasure implementation
- [ ] DPA (Philippines) compliance checklist
- [ ] Data retention automation (Firebase scheduled functions)
- [ ] Privacy policy & terms of service screens
- [ ] Consent management

### Epic 3.4 — Advanced Language Support

> Builds on [Translation Helper](INTERNATIONALIZATION.md#12-translation-helper-tool) (Epic 2.5). Cebuano + Tagalog ship in 2.5.

- [x] Translation Helper: in-context preview (MVP — in-app translation mode; expand badge coverage)
- [x] Translation Helper: completion dashboard (% approved per locale) — shipped as translation screens summary views and summary refinements in app/web tooling
- [ ] Community / contractor interpreter accounts (language-scoped)
- [ ] Additional language packs via same pipeline (Hiligaynon, Ilocano, Spanish, …)
- [ ] Org-level language enablement (subset of platform languages)

### Epic 3.5 — Advanced Messaging

- [ ] Media attachments in DM and group messages (images)
- [ ] Message deletion (sender can retract)
- [ ] Message reactions (emoji)
- [ ] Threaded replies in news posts and bulletins

---

## Phase 4 — Enterprise

### Epic 4.1 — API & Integrations

- [ ] REST API design (OpenAPI spec)
- [ ] Firebase Functions API implementation
- [ ] API key management
- [ ] Webhook delivery system
- [ ] SCIM user provisioning (replaces CSV import for large enterprises)

### Epic 4.2 — Advanced Features

- [ ] AI content screening (spam/inappropriate content detection)
- [ ] SMS notification delivery
- [ ] QR code report trigger
- [ ] Video attachment support
- [ ] Public transparency portal

---

## Testing Tasks (All Phases)

- [ ] Set up Flutter test project structure
- [ ] Unit tests: all use cases
- [ ] Unit tests: all repository implementations (mocked datasources)
- [ ] Widget tests: all screens
- [ ] Widget tests: all shared widgets
- [ ] Integration tests: auth flow
- [ ] Integration tests: report submission flow
- [ ] Integration tests: admin management flow
- [ ] Performance tests: report list with 500+ items
- [ ] Security tests: Firestore rules (Firebase emulator)
- [ ] End-to-end tests (Flutter integration test framework)

---

## Security Tasks (All Phases)

- [ ] Write Firestore Security Rules (see shared/docs/DATABASE_DESIGN.md outline)
- [ ] Write Firebase Storage Security Rules
- [ ] Deploy and test rules against Firebase emulator
- [ ] Penetration test: unauthorized cross-org data access
- [ ] Review all user inputs for XSS-equivalent risks
- [ ] Enable Firebase App Check (production)
- [ ] Review and rotate Firebase project API keys quarterly
- [ ] Enable Google Cloud audit logging

---

## Deployment Tasks

- [ ] Create Firebase project: `speakupconnect-dev`
- [ ] Create Firebase project: `speakupconnect-pilot-monhs`
- [ ] Create Firebase project: `speakupconnect-production`
- [ ] Configure Firestore indexes
- [ ] Configure Firestore Security Rules
- [ ] Configure Storage Security Rules
- [ ] Configure FCM topics and permissions
- [ ] Set up CI/CD pipeline (GitHub Actions)
- [ ] Android Play Store account setup
- [ ] App bundle signing configuration
- [ ] Internal test track on Play Store
- [ ] Production release on Play Store

---

## Tech Debt & Housekeeping

> Items identified during development that don't fit an active sprint epic but must not be forgotten.  
> Linked to GitHub issues where applicable.

### Android / Native

- [ ] Fix launch background color mismatch — `android/app/src/main/res/values/colors.xml` has `#2563EB` (old blue); should be `#002673` (current primary navy) so the native splash matches the app theme

### Dart / Flutter

- [ ] Remove debug logging from `lib/features/settings/presentation/screens/settings_screen.dart` (profile debug `print` statements added in commit `17f6fdb`)
- [x] Repository split complete: app code moved to `speakup_connect_app/`, shared assets/docs/functions/scripts to `shared/`, and tooling/web artifacts to `speakup_connect_web/` (follow-up config/generated path updates landed)

### Data / Firebase

- [ ] Seed default report categories for MONHS org — navigate to Admin Dashboard → Branding Settings → "Add Default Categories" while logged in as admin (`monhs-ph-001`)
