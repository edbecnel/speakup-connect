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

- [ ] Build organization self-registration web form
- [ ] Firebase function to create organization document
- [ ] Admin notification on new org registration
- [ ] Organization activation workflow
- [ ] Custom app name (`appCustomName`) configuration in org setup wizard (e.g., "SpeakUp MONHSIAN")

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

### Epic 2.4 — Community Rules

- [ ] Create `communityRules` Firestore collection per org
- [ ] Seed default rules on org creation
- [ ] Build `CommunityRulesScreen` (admin) — create, edit, reorder, delete rules
- [ ] Display rules on `RegisterScreen` / apply-to-join form (with checkbox acceptance)
- [ ] Display rules on home page / info section
- [ ] Enforce `communityRulesEnabled` flag from org config

### Epic 2.5 — Multi-Language Support

**Data Layer**
- [ ] Create `languages` top-level Firestore collection
- [ ] Seed `en` (English) language document and string entries
- [ ] Seed `fil` (Filipino) language document and string entries
- [ ] Define string key conventions (e.g., `home.welcomeMessage`, `auth.loginButton`)
- [ ] Implement all English UI strings via string keys (no hardcoded text)

**Presentation**
- [ ] Language selector dropdown on home/main page
- [ ] Language selector in Settings screen
- [ ] Write selected language to `users/{id}.preferredLanguage` in Firestore
- [ ] Persist language selection locally (SharedPreferences)
- [ ] Build `LanguageProvider` (Riverpod) — loads and serves string values
- [ ] Fallback to `en` when a key is missing in selected language
- [ ] Admin: set org default language in org config

**Asset Bundling**
- [ ] Bundle English + Filipino strings as JSON assets for offline use
- [ ] Implement hot-reload of language strings from Firestore (without app update)

### Epic 2.6 — Groups & Clubs

**Domain**
- [ ] Create `GroupEntity`
- [ ] Create `GroupMemberEntity`
- [ ] Create `GroupRepository` abstract interface
- [ ] Create `CreateGroupUseCase`
- [ ] Create `AddGroupMemberUseCase`
- [ ] Create `GetGroupsUseCase`
- [ ] Create `GetMyGroupsUseCase`

**Data**
- [ ] Create `GroupModel` (with `fromJson`/`toJson`)
- [ ] Create `GroupMemberModel`
- [ ] Create `GroupRemoteDataSource`
- [ ] Create `GroupRepositoryImpl`

**Presentation**
- [ ] Build `GroupsListScreen` — all org groups, searchable
- [ ] Build `GroupDetailScreen` — group info, member list, news posts, group chat
- [ ] Build `CreateGroupScreen` (admin) — name, description, avatar
- [ ] Build `GroupMembersScreen` (admin/leader) — add/remove members, assign leader
- [ ] Show user's groups on home dashboard and profile
- [ ] Group role badge: leader vs. member

**Testing**
- [ ] Unit test: `CreateGroupUseCase`
- [ ] Unit test: `GroupRepositoryImpl`
- [ ] Widget test: `GroupsListScreen`

### Epic 2.7 — Bulletin Board

**Domain**
- [ ] Create `BulletinEntity`
- [ ] Create `BulletinRepository` abstract interface
- [ ] Create `PostBulletinUseCase`
- [ ] Create `GetBulletinsUseCase`

**Data**
- [ ] Create `BulletinModel`
- [ ] Create `BulletinRemoteDataSource`
- [ ] Create `BulletinRepositoryImpl`

**Presentation**
- [ ] Build `BulletinBoardScreen` — paginated list of org-wide bulletins
- [ ] Build `BulletinDetailScreen` — full bulletin content
- [ ] Build `PostBulletinScreen` (admin) — title, body, pin toggle, expiry date
- [ ] Pinned bulletins shown at top
- [ ] Push notification to all members on new bulletin
- [ ] Show bulletin count badge on home dashboard

**Testing**
- [ ] Unit test: `PostBulletinUseCase`
- [ ] Widget test: `BulletinBoardScreen`

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

### Epic 2.9 — Reminders

**Domain**
- [ ] Create `ReminderEntity`
- [ ] Create `ReminderRepository` abstract interface
- [ ] Create `BroadcastReminderUseCase` (requires `canBroadcastReminders` permission)
- [ ] Create `GetRemindersUseCase`

**Data**
- [ ] Create `ReminderModel`
- [ ] Create `ReminderRemoteDataSource`
- [ ] Create `ReminderRepositoryImpl`

**Presentation**
- [ ] Build `SendReminderScreen` — title, body, audience selector (all / group / role)
- [ ] Audience picker: all org, specific group, or role
- [ ] Build `RemindersHistoryScreen` — list of sent reminders (sender view)
- [ ] Reminders appear in user notification feed
- [ ] Push notification delivered to audience on broadcast
- [ ] Enforce `canBroadcastReminders` permission via Firestore Security Rules

**Testing**
- [ ] Unit test: `BroadcastReminderUseCase`

### Epic 2.10 — Peer-to-Peer Messaging

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

### Epic 2.12 — Role-Based Permissions

- [ ] Create `roles` Firestore collection per org
- [ ] Seed default roles on org creation (e.g., "Club Leader", "Teacher")
- [ ] Build `RolesManagementScreen` (admin) — create, edit, delete roles and permission sets
- [ ] Build `AssignRoleScreen` (admin) — assign custom roles to users
- [ ] `PermissionProvider` (Riverpod) — checks user's effective permissions
- [ ] Enforce permissions via Firestore Security Rules:
  - `canBroadcastReminders` — reminders collection write
  - `canPostNews` — newsPosts collection write
  - `canManageGroup` — groups subcollection write
  - `canBlockUsers` — blockedUsers collection write

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

- [ ] Community-contributed language translation workflow
- [ ] Admin-side language string editor
- [ ] Language completion dashboard (per-language % complete)
- [ ] Add additional language packs (Spanish, Cebuano, etc.)

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

---

## Tech Debt & Housekeeping

> Items identified during development that don't fit an active sprint epic but must not be forgotten.  
> Linked to GitHub issues where applicable.

### Android / Native

- [ ] Fix launch background color mismatch — `android/app/src/main/res/values/colors.xml` has `#2563EB` (old blue); should be `#002673` (current primary navy) so the native splash matches the app theme

### Dart / Flutter

- [ ] Remove debug logging from `lib/features/settings/presentation/screens/settings_screen.dart` (profile debug `print` statements added in commit `17f6fdb`)

### Data / Firebase

- [ ] Seed default report categories for MONHS org — navigate to Admin Dashboard → Branding Settings → "Add Default Categories" while logged in as admin (`monhs-ph-001`)
