# Sprint Tracker — SpeakUp Connect

> Last Updated: June 20, 2026  
> Current Sprint: **Sprint 13** (Group Membership Requests) — implementation in progress (reliability hardening shipped)  
> Last completed: **Sprint 15** (i18n Phase 1 + 1b) — June 2026  
> Sprint Duration: 2 weeks  
> **GitHub Issues synced:** June 13, 2026 — closed stale MVP issues (#1–#21 except #13); filed #47–#56 for active work

---

## High-Priority Backlog (queued)

| Order | Initiative | Design doc | Epic | GitHub |
|-------|------------|------------|------|--------|
| 1 | Multi-language — Phase 1 + 1b ✅; **next:** Translation Helper MVP, real Cebuano, Tagalog, feature extraction, Firestore sync | [INTERNATIONALIZATION.md](INTERNATIONALIZATION.md) | 2.5 | #48–#53 |
| 2 | Peer-to-peer + group messaging | TBD | 2.10, 2.11 | #55 |
| 3 | Parent accounts and login | TBD | 2.13 | #56 |

Suggested next sprint after Sprint 13 closure: **Sprint 16 — i18n Phase 2** ([#48](https://github.com/edbecnel/speakup-connect/issues/48) Translation Helper, [#49](https://github.com/edbecnel/speakup-connect/issues/49) real Cebuano, [#51](https://github.com/edbecnel/speakup-connect/issues/51) feature extraction, [#52](https://github.com/edbecnel/speakup-connect/issues/52) validators/CI). Tagalog ([#50](https://github.com/edbecnel/speakup-connect/issues/50)) and Firestore language sync ([#53](https://github.com/edbecnel/speakup-connect/issues/53)) can follow in Sprint 17+.

> **Development Velocity Note:** Development has significantly outpaced the original planned schedule. As of May 23, 2026 (day 5 of the project), the codebase covers work originally scoped for Sprints 1–6. Sprint numbering below reflects original plan order but completion dates reflect actual delivery dates.

---

## Active Sprint

### Sprint 13 — Group Membership Requests (Join & Leave) *(Epic 2.6.1)*
- **Status:** 📋 Design complete — implementation not started
- **GitHub Issues:** [#47](https://github.com/edbecnel/speakup-connect/issues/47)
- **Milestone:** Sprint 13 — Group Membership Requests
- **Goal:** Join: members **request to join** when `allowJoinRequests` is on (default off). Leave: `voluntary` (leave anytime) or `request_required` (reason form + approval, default). Alerts when **removed** or **leave denied** (with reason).
- **Design:** [GROUP_JOIN_REQUESTS.md](GROUP_JOIN_REQUESTS.md)
- **Source epic:** [MASTER_TASK_LIST.md → Epic 2.6.1](MASTER_TASK_LIST.md)

#### 🚀 AI Context Prompt
> "Implement Sprint 13 per `shared/docs/GROUP_JOIN_REQUESTS.md`. Join: `allowJoinRequests`, `joinRequests/{userId}`, browse + review. Leave: `memberLeavePolicy` (`voluntary` | `request_required`), `leaveRequests/{userId}`, Leave group vs Request to leave UI. Callables for submit/review/voluntary leave; enhance removal to notify member. Denied leave alerts must include rejection reason."

#### 📋 Scope (ship order)
- [ ] Schema + join/leave entities + repository
- [ ] Cloud Functions + Firestore rules + indexes
- [ ] Admin/leader policy toggles (join + leave) on create/edit group
- [ ] `BrowseGroupsScreen` + join request sheet
- [ ] `MyGroupsScreen` leave / request-to-leave + reason form
- [ ] `GroupMembershipRequestsScreen` (Join | Leave tabs) + badges
- [ ] Membership notifications (removed, leave denied with reason) + help guides

#### 🧹 Fixes (June 16, 2026)
- [x] Approve join request is **idempotent** when requester is already on roster (stale pending request)
- [x] Browse list waits for memberships to load before showing **Request to Join** (prevents leader/member false negatives)
- [x] Requests screen surfaces **real backend error messages** instead of only “Action failed”

#### 🔎 Needs confirmation
- [ ] Sprint 13 core flow completion status still needs human confirmation (commit range shows reliability hardening only; checklist items for full join/leave workflow remain intentionally unchecked)

#### 🚫 Out of scope
- Instant self-join without approval
- Class/homeroom enrollment
- Replacing SSLG election workflow

#### MONHS validation
- [ ] SSLG: join closed; leave `request_required`; officer cannot leave without approval
- [ ] Drum and Lyre: open join requests; `voluntary` leave
- [ ] Admin removes member → student receives alert
- [ ] Denied leave request → student alert shows reason

---

### Delivered June 5, 2026 — Profile photos (Sprint 14)
- [x] `avatarUrl` / `officialPhotoUrl` on user profile; `officialPhotoUrl` on roster
- [x] Admin official photo: **Edit Member** + **Student Roster** (tap avatar)
- [x] Member personal badge: **Settings** profile circle (gallery/camera/remove)
- [x] `allowMemberProfilePhotos` org toggle (default OFF); cached in offline org config
- [x] Cloud Functions: `uploadMemberAvatar` (server upload — avoids client Storage/App Check 403), `setMemberAvatarUrl`, `setOfficialPhotoUrl`
- [x] Storage + Firestore rules; `onMemberApproved` syncs JWT claims for membership
- [x] Deployed to `speakup-connect-891dd`; member upload smoke-tested on Android

---

### Delivered June 2026 — i18n Phase 1 + 1b (Sprint 15) *(Epic 2.5)*
- **Commits:** `41877a1`, `ee38c77`
- **Design:** [INTERNATIONALIZATION.md](INTERNATIONALIZATION.md)
- **GitHub Issues:** *(shipped before issue sync — track Phase 2 in #48–#53)*
- [x] `l10n.yaml`, `flutter_localizations`, `flutter: generate: true`
- [x] `app_en.arb` (source) + `app_ceb.arb` (English placeholders); `AppLocalizations` + `context.l10n`
- [x] `appLocaleProvider` + `SharedPreferences` cold-start cache
- [x] `MaterialApp` wired with `localizationsDelegates`, `supportedLocales`, `locale`
- [x] Phase-1 string extraction: auth (login, splash), home, settings, help hub
- [x] `kLanguageNativeLabels` — picker options **not** in ARB (§6.1)
- [x] Home `LanguageSelectorDropdown` + Settings `showLanguagePickerSheet`
- [x] `HelpAssetResolver` + `member_guide_ceb.md` assets (`_default` + MONHS; English placeholders)
- [x] `shared/docs/help/` synced with language UI; CODING_STANDARDS.md requires new UI text → `app_en.arb`

#### 📋 Remaining (Epic 2.5 — see MASTER_TASK_LIST)
- [x] Translation Helper MVP + AI draft callables — [#48](https://github.com/edbecnel/speakup-connect/issues/48)
- [ ] Real Cebuano copy in `app_ceb.arb` + `member_guide_ceb.md` — [#49](https://github.com/edbecnel/speakup-connect/issues/49)
- [ ] `app_fil.arb` + Tagalog help + `kLanguageNativeLabels` — [#50](https://github.com/edbecnel/speakup-connect/issues/50)
- [ ] Feature extraction (reports, admin, groups, announcements, reminders, roles, …) — [#51](https://github.com/edbecnel/speakup-connect/issues/51)
- [ ] `validators.dart` → l10n; CI ARB key parity — [#52](https://github.com/edbecnel/speakup-connect/issues/52)
- [ ] `locale_resolution.dart`; `preferredLanguage` Firestore sync; org language admin — [#53](https://github.com/edbecnel/speakup-connect/issues/53)

#### ✅ Follow-up delivered June 15–16, 2026 (post Sprint 15)
- **Commits:** `536a150`, `b8fc709`, `27bef8b`, `f24eafa`, `1ebe5c8`, `540aec9`, `471bbc9`, `ed927e0`, `a1c2b07`, `753240e`
- [x] Translation hardcoded-string extraction tooling landed (scanner + allowlist + route alias generator + catalog hardening)
- [x] Translation screens summary shipped and iterated (layout, sorting, loading/error handling, collapsible summary actions)
- [x] Translation Workspace and Translation Mode UX refined (shell/widget/workspace improvements)
- [ ] Needs confirmation: whether current extraction pass is complete enough to close all Epic 2.5 Phase-2 per-feature checklist rows (commit evidence shows broad progress but not guaranteed full completion across every screen)

---

### Delivered June 16, 2026 — Alerts bulk dismissal UX
- **Commit:** `327ee74`
- [x] Multi-select alert state and bulk dismiss action added to Alerts UI
- [x] Notification repository/provider flow updated to support batched dismiss operations
- [x] Localization strings updated for bulk-dismiss interactions

---

### Delivered June 17, 2026 — Repository restructuring + workspace conventions
- **Commits:** `bc08cd0`, `c9be73e`, `2e06d03`
- [x] Repository reorganized into `shared/`, `speakup_connect_app/`, and `speakup_connect_web/`
- [x] Follow-up path/config/generated-file alignment completed after move (including helper tooling package lock updates)
- [x] Icon assets relocated to new app/web structure and stale old-root copies removed
- [ ] Needs confirmation: whether any external automation scripts/CI references outside this repo still point to pre-restructure paths

---

### Delivered June 20, 2026 — School help canonicalization refactor
- [x] Moved school help source-of-truth to `shared/docs/help/school/` (`README.md`, guides, tutorials, tutorial QA docs)
- [x] Updated Help Center model to resolve `org -> school -> _default` assets without requiring per-org school duplication
- [x] Added in-app school tutorial articles and user-facing labels (Member/Administrator Guide and Tutorial)
- [x] Updated onboarding/help docs to point to canonical school source and optional org overrides only

---

### Delivered June 11, 2026 — Announcement scheduling
- **Deploy tracking:** [#54](https://github.com/edbecnel/speakup-connect/issues/54) — production Cloud Functions + indexes still needed
- [x] **Schedule for later** on **Post Announcement** (parity with Compose Reminder)
- [x] `scheduledAt` on bulletins; `publishDueBulletins` scheduled Cloud Function
- [x] Expiration relative to scheduled send; **My announcements** shows scheduled status/time
- [x] Help guides + `DATABASE_DESIGN.md` updated

---

### Delivered June 5, 2026 — Announcements parity & login fix
- **Commits:** `8c894ed`, `abc351d`
- [x] Announcements: optional image, request-a-response, edit/delete, `submitBulletinResponse` / `updateBulletin` / `setBulletinImageUrl` deployed
- [x] `resolveLoginEmail` — admin/staff sign in with real email; students with ID or contact email
- [x] Home: Quick Actions first; **My Groups & Clubs** collapsed by default
- [x] Help guides synced (`assets/help/`, `shared/docs/help/`)

---

### Sprint 15 — i18n Phase 1 + 1b *(Epic 2.5)* — ✅ Complete
- **Date/Time:** June 2026
- **Commits:** `41877a1`, `ee38c77`
- **Goal:** gen-l10n foundation, Phase-1 English extraction, Cebuano scaffold, Home + Settings language pickers, locale-aware help.
- **Design:** [INTERNATIONALIZATION.md](INTERNATIONALIZATION.md)
- See **Delivered June 2026 — i18n Phase 1 + 1b** above for scope checklist and remaining Epic 2.5 tasks.

---

### Sprint 14 — Profile Photos *(Epic 2.3 — Member photos)* — ✅ Complete
- **Goal:** Members upload a personal profile photo in Settings; admins upload each student’s official school photo (roster + member edit).
- **Source epic:** [MASTER_TASK_LIST.md → Epic 2.3 Member photos](MASTER_TASK_LIST.md)
- See **Delivered June 5, 2026 — Profile photos** above for scope checklist.

---

### Sprint 11 — Groups & Clubs *(client demo priority)*
- **Status:** ✅ Complete — commit `828738e` and follow-ups
- **Goal:** Stand up org groups end-to-end so admins can create clubs, manage rosters, assign club positions, and members see their groups — unlocking the **group audience** path in Compose Reminder and a credible client demo narrative (e.g. broadcast to Journalism Club).
- **Source epic:** [MASTER_TASK_LIST.md → Epic 2.6](MASTER_TASK_LIST.md)

#### 🚀 AI Context Prompt
> "We are implementing Sprint 11 — Groups & Clubs for SpeakUp Connect. Stack: Flutter 3.44, Riverpod 3.x, go_router, Firebase Firestore. Build the groups feature per Epic 2.6 and `shared/docs/DATABASE_DESIGN.md` (`organizations/{orgId}/groups/{groupId}` + `members` subcollection). Default org: `monhs-ph-001`. Mirror RBAC patterns from classes (`manageGroupRoster` in rules). Compose Reminder already consumes `audienceGroupsProvider` — wire real group CRUD so group-targeted reminders work in-app."

#### 📋 Scope (demo-critical — ship first)
- [x] Domain: `GroupEntity`, `GroupMemberEntity`, `GroupRepository`, `CreateGroupUseCase`, `AddGroupMemberUseCase`, `GetGroupsUseCase`, `GetMyGroupsUseCase`
- [x] Data: `GroupModel`, `GroupMemberModel`, `GroupRemoteDataSource`, `GroupRepositoryImpl`
- [x] Providers: `orgGroupsProvider`, `myGroupsProvider`, `groupMembersProvider` (+ action notifiers)
- [x] Admin `GroupsListScreen` — searchable list of org groups; entry from Settings (admin section)
- [x] Admin `CreateGroupScreen` — name, description, optional club position definitions
- [x] Admin `GroupMembersScreen` — view roster, add member (user search), remove member, assign `leader` vs `member`, assign club position
- [x] `EditGroupPositionRolesScreen` — customize offices (President, Treasurer, etc.) per group
- [x] `positionRoles` on group docs + `positionRoleId` on member docs; SSLG seed defaults
- [x] In-app **Seed Demo Groups** + `shared/scripts/seed_groups.js` (SPJ, Drum and Lyre Corps, SSLG)
- [x] Firestore rules: gate `groups` / `members` writes on `manageGroupRoster` (keep `isAdminOrAbove` as fallback), matching `classes` pattern
- [x] **Student roster:** `AddStudentScreen`, `provisionStudent` Cloud Function, student ID login (ID as password)
- [x] **Response required** on reminders — recipients must respond before dismissing
- [x] In-app help: per-org Member + Admin guides (`shared/docs/help/orgs/{orgId}/`, `assets/help/`, Settings → Help Center; `_default` fallback)
- [ ] Verify Compose Reminder **group audience** picker populates and publishes → members appear in Alerts feed (on-device smoke test)

#### 📋 Scope (stretch — if time remains)
- [ ] `GroupDetailScreen` — group info + member list (no chat/news yet)
- [x] `MyGroupsScreen` — read-only list with role and club position (Settings + Home)
- [x] Home dashboard section for "My Groups & Clubs"
- [ ] Unit test: `CreateGroupUseCase`; widget test: `GroupsListScreen`

#### 🚫 Explicitly out of scope (later sprints)
- Group chat (Epic 2.11)
- News board posts per group (Epic 2.8)
- Bulk member import
- Classes / homeroom management (separate `classes/` collection — not started in app)

#### 👁️ Stakeholder Demo Asset
- **Asset Type:** Screen recording
- **Location:** `./shared/docs/demos/sprint-011-groups.mp4`
- **Stakeholder Note:** Admin creates SPJ / Drum and Lyre / SSLG groups, adds student members; admin broadcasts a reminder to SPJ and recipients see it in Alerts.

#### Next up
- **Sprint 13 — Group Membership Requests (Epic 2.6.1):** join + leave policies — see [GROUP_JOIN_REQUESTS.md](GROUP_JOIN_REQUESTS.md).

---

### Sprint 12 — Reminder Enhancements *(Epic 2.9.1)*
- **Status:** ✅ Complete — deployed to `speakup-connect-891dd`
- **Goal:** Expiration, notification history, broadcast edit/recall, full-screen detail, and optional recipient responses on reminders.
- **Source epic:** [MASTER_TASK_LIST.md → Epic 2.9.1](MASTER_TASK_LIST.md)

#### 📝 Done
- [x] Optional `expiresAt` — date/time picker or hours+minutes duration on compose; `expireReminders` scheduled job
- [x] `notification_history` archive — expired, recalled, dismissed, cleared; history screen for author/admin
- [x] Edit/recall broadcasts — `updateReminder`, `recallReminder` callables; owner + org admin UI
- [x] `BroadcastDetailScreen` — tap reminder for full-screen view with expiration and back navigation
- [x] Optional recipient responses — free text (char limit), checkboxes, multiple choice; `submitReminderResponse` callable
- [x] `ReminderResponsesScreen` — author/admin views aggregated responses per broadcast
- [x] Deployed: `firestore:rules`, `expireReminders`, `dismissNotification`, `clearNotificationFeed`, `submitReminderResponse`

#### Deferred follow-ups
- [ ] On-device smoke test: each response type end-to-end; expiration + history verification
- [ ] Unit/widget tests for response config and forms

#### 👁️ Stakeholder Demo Asset
- **Asset Type:** Screen recording
- **Location:** `./shared/docs/demos/sprint-012-reminder-responses.mp4`
- **Stakeholder Note:** Admin composes a reminder requesting checkbox responses; members open the alert full-screen and submit; admin reviews responses from My Broadcasts.

---

## Completed Sprints

### Sprint 10 — Reminders Feature
- **Date/Time:** June 1, 2026 (implemented); closed June 8, 2026
- **Status:** ✅ Complete — core scope shipped & deployed; follow-ups deferred (see below)
- **Goal:** Full reminders feature — compose, broadcast delivery (push + in-app feed), optional approval workflow, `approveReminders` permission.
- **Verification:** `flutter analyze` clean; `functions` `npm run build` passes; deployed `firestore:rules`, `firestore:indexes`, and Cloud Functions on `speakup-connect-891dd`.

#### 📝 Done
- [x] All Sprint 10 scope items (see git history / `lib/features/reminders/`)
- [x] `onReminderPublished` + `publishDueReminders` Cloud Functions live
- [x] In-app Alerts feed + approval queue + compose screen with all / group / role audience

#### Deferred follow-ups
- [ ] On-device smoke test: compose → approve → feed entry; scheduled publish *(can run anytime)*
- [ ] **Group audience demo** — in progress via Sprint 11
- [ ] **Client FCM (Epic 1.12)** — next after Groups *(was Sprint 12; reminder enhancements took Sprint 12 slot — FCM becomes Sprint 13)*

---

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
- [x] Add `shared/scripts/assign_admin.js` bootstrap script for org-admin role assignment

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
- **Location:** `./shared/docs/demos/sprint-008-rbac-roles.mp4`
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
- **Location:** `./shared/docs/demos/sprint-007-admin-enhancements.mp4`
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
- **Location:** `./shared/docs/demos/sprint-006-admin-dashboard.mp4`
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
- **Location:** ./shared/docs/demos/sprint-NNN-[slug].png
- **Stakeholder Note:** What this delivers from the roadmap perspective
```

### Sprint 13 — Client FCM & Push Notifications *(planned — after Sprint 11)*
- **Status:** 📋 Planned
- **Goal:** Wire `firebase_messaging` on Android so users receive system notifications when the app is backgrounded or closed. Unblocks push delivery for reminders, report status updates, and future broadcasts.
- **Source epic:** [MASTER_TASK_LIST.md → Epic 1.12](MASTER_TASK_LIST.md)
- **Prerequisite:** Sprint 11 Groups complete (demo flow: group reminder → verify push on member device). Server Cloud Functions already call `admin.messaging()` when `users/{uid}.fcmTokens` is populated.

#### 📋 Scope
- [ ] `FcmService` (or `core/notifications/`) — init `FirebaseMessaging`, request permission (Android 13+)
- [ ] On login / app start: get token, `arrayUnion` into `organizations/{orgId}/users/{uid}.fcmTokens`
- [ ] On token refresh: update Firestore; on logout: `arrayRemove` current device token
- [ ] Android notification channels: `reminders`, `status_updates` (IDs already referenced in Cloud Function payloads)
- [ ] Foreground: in-app banner or local notification when message received while app open
- [ ] Background / terminated: tap navigates to `Routes.alerts` or report detail via `data.type` + `reminderId` / `reportId`
- [ ] Respect `notificationPreferences` (`reminders`, `statusUpdates`) before showing local UI (server already skips push when opted out)
- [ ] On-device test: publish group reminder → notification appears in shade without opening app; tap opens Alerts

#### 🚫 Out of scope (defer)
- iOS APNs setup
- Admin FCM topic subscribe/unsubscribe (master list item — evaluate if still needed vs per-user tokens)
- Epic 1.11 new-report admin topic push

#### 👁️ Stakeholder Demo Asset
- **Asset Type:** Screen recording (phone locked → notification arrives → tap → Alerts)
- **Location:** `./shared/docs/demos/sprint-012-fcm-push.mp4`

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
- **Location:** ./shared/docs/demos/sprint-NNN-[slug].png
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
