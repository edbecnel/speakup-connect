# Master Task List — SpeakUp Connect

> This is the comprehensive task breakdown for the entire SpeakUp Connect project.  
> Organized by Phase → Epic → Task.  
> Use this for long-term sprint planning.

---

## How to Use This List

- Each task is assigned to a **Phase** and **Epic**
- Tasks are marked with checkboxes: `[ ]` not started, `[~]` in progress, `[x]` complete
- Add assignee and sprint number in brackets when scheduling: `[Sprint 2] [Dev A]`
- See [docs/SPRINT_TRACKER.md](docs/SPRINT_TRACKER.md) for the current active sprint breakdown

---

## Phase 1 — Foundation & MVP

### Epic 1.1 — Project Documentation

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
- [ ] Create docs/WIREFRAMES.md (annotated wireframe notes)
- [ ] Create docs/API_CONTRACTS.md (Firestore read/write contract docs)
- [ ] Create docs/TESTING_STRATEGY.md

---

### Epic 1.2 — Flutter Project Setup

**Frontend**
- [ ] Initialize Flutter project with package name `com.speakupconnect.app`
- [ ] Configure pubspec.yaml (all dependencies)
- [ ] Configure analysis_options.yaml (strict linting rules)
- [ ] Create full folder structure matching docs/FOLDER_STRUCTURE.md
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
- [ ] Create `app_avatar.dart` — user/org avatar with fallback initials
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
- [ ] Create `AnonymousToggle` — Anonymous | With Identity segmented control

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
- [ ] Create `AdminEntity`
- [ ] Create `AdminRepository` abstract interface
- [ ] Create `GetAllReportsUseCase` (admin: all org reports)
- [ ] Create `UpdateReportStatusUseCase`
- [ ] Create `AddAdminNoteUseCase`
- [ ] Create `AssignReportUseCase`

**Data**
- [ ] Create `AdminModel`
- [ ] Create `AdminRemoteDataSource` (Firestore reads for all org reports)
- [ ] Create `AdminRepositoryImpl`

**Presentation — Providers**
- [ ] Create `adminReportsProvider` (StreamProvider for all org reports)
- [ ] Create `adminFilterProvider` (StateNotifier for category/status filters)
- [ ] Create `adminNotifierProvider` (AsyncNotifier for status updates/notes)

**Presentation — Screens**
- [ ] Build `AdminDashboardScreen`
  - [ ] Filter bar (by category, by status)
  - [ ] Search bar
  - [ ] Report list (all org reports)
  - [ ] Quick stats header (total, pending, in-progress)
- [ ] Build `AdminReportDetailScreen`
  - [ ] Full report view
  - [ ] Status update control
  - [ ] Assign to dropdown
  - [ ] Notes/reply thread
  - [ ] Status history

**Presentation — Widgets**
- [ ] Create `AdminReportCard` — admin-view report card (with action buttons)
- [ ] Create `StatusUpdateDialog` — modal for changing report status
- [ ] Create `AdminFilterBar` — horizontal filter chips
- [ ] Create `AdminNoteThread` — admin notes list + add note input

**Firestore**
- [ ] Implement admin status update (with `statusHistory` append)
- [ ] Implement admin note creation
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
  - [ ] Language selection (placeholder)
  - [ ] About section (app version, organization info)
  - [ ] Sign out button
- [ ] Build `ProfileScreen`
  - [ ] Display name
  - [ ] Email
  - [ ] Change password link
  - [ ] Account info
- [ ] Implement theme persistence (SharedPreferences)

---

## Phase 2 — Pilot Expansion

### Epic 2.1 — Organization Onboarding

- [ ] Build organization self-registration web form
- [ ] Firebase function to create organization document
- [ ] Admin notification on new org registration
- [ ] Organization activation workflow

### Epic 2.2 — Branding Customization

- [ ] In-app branding config editor (admin)
- [ ] Logo upload via Firebase Storage
- [ ] Dynamic app theme from org config
- [ ] Custom tagline per org
- [ ] Configurable category management UI

### Epic 2.3 — Announcements

- [ ] Announcement Firestore collection schema
- [ ] Admin: create/publish announcement
- [ ] User: view announcements list
- [ ] Push notification for new announcements

### Epic 2.4 — Anonymous Report Reference Code

- [ ] Generate random 8-character reference code on anonymous submit
- [ ] Store code locally (SharedPreferences or encrypted storage)
- [ ] "Track by reference code" lookup screen
- [ ] Status retrieval by code (without auth)

### Epic 2.5 — Analytics & Reporting (Admin)

- [ ] Admin: report counts by category
- [ ] Admin: report counts by status
- [ ] Admin: average resolution time
- [ ] Admin: export reports to CSV
- [ ] Admin: date range filtering

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

---

## Phase 4 — Enterprise

### Epic 4.1 — API & Integrations

- [ ] REST API design (OpenAPI spec)
- [ ] Firebase Functions API implementation
- [ ] API key management
- [ ] Webhook delivery system
- [ ] SCIM user provisioning

### Epic 4.2 — Advanced Features

- [ ] AI content screening (spam detection)
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

- [ ] Write Firestore Security Rules (see docs/DATABASE_DESIGN.md outline)
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
