# Database Design — SpeakUp Connect

---

## Overview

SpeakUp Connect uses **Cloud Firestore** as its primary database. All data is structured as NoSQL documents organized in a way that enforces **complete data isolation between organizations (tenants)**.

---

## Multi-Tenant Isolation Strategy

Every document in Firestore is scoped under an organization:

```
organizations/{organizationId}/...
```

This means:
- A user in Organization A cannot access data in Organization B — even if they share the same Firebase Auth UID
- Firestore Security Rules enforce this at the database level
- All app-level queries include `organizationId` as a required parameter
- There are no cross-organization collection queries

---

## Top-Level Collections

```
Firestore Root
│
├── organizations/           # Top-level organization registry
│   └── {organizationId}/
│       ├── [organization document]
│       ├── config/          # Organization settings (subcollection)
│       ├── reports/         # Reports for this organization
│       ├── categories/      # Report categories
│       ├── users/           # User profiles scoped to this org
│       ├── admins/          # Admin records for this org
│       ├── roster/          # Imported student/member ID registry
│       ├── roles/           # Custom roles and permission sets
│       ├── classes/         # Academic classes/sections (Grade 7-A, etc.)
│       │   └── {classId}/
│       │       ├── [class document]
│       │       └── members/     # Class enrollment records
│       ├── groups/          # Extracurricular groups/clubs/organizations
│       │   └── {groupId}/
│       │       ├── [group document]
│       │       └── members/     # Group membership records
│       ├── bulletins/       # Admin-posted org-wide bulletin board posts
│       ├── newsPosts/       # Group/org news board posts
│       ├── reminders/       # Broadcast reminders sent to members
│       │   └── {reminderId}/
│       │       └── responses/   # Per-recipient optional responses
│       ├── notification_history/  # Archived expired/recalled/dismissed notifications
│       ├── messages/        # Group chat messages (per group sub-collection)
│       ├── directMessages/  # Peer-to-peer message threads
│       ├── blockedUsers/    # Abuse block records
        ├── communityRules/  # Customizable signup/community rules
        └── audit_log/       # Immutable admin activity log (append-only)
│
├── languages/               # Global language string database
│   └── {languageCode}/      # e.g. "en", "fil", "es"
│       └── strings/         # Key-value string entries
│
└── platform/                # Platform-level (super-admin only)
    └── stats/               # Aggregate statistics (no PII)
```

---

## Collection Schemas

### `organizations/{organizationId}` — Organization Document

```json
{
  "organizationId": "string (unique, URL-safe)",
  "displayName": "string",
  "appCustomName": "string (e.g. 'SpeakUp MONHSIAN' — shown on splash and throughout the app)",
  "type": "school | lgu | ngo | church | university | corporation | other",
  "country": "string",
  "region": "string (optional)",
  "city": "string (optional)",
  "logoUrl": "string | null",
  "primaryColor": "string (hex, e.g. '#1976D2')",
  "secondaryColor": "string (hex)",
  "contactEmail": "string",
  "isActive": "boolean",
  "allowAnonymousReports": "boolean",
  "defaultLanguage": "string (language code, e.g. 'en')",
  "supportedLanguages": ["string (language codes)"],
  "signupRequiresApproval": "boolean (true = apply-to-join; false = open signup)",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp",
  "subscriptionTier": "free | pilot | standard | enterprise",
  "subscriptionExpiresAt": "Timestamp | null"
}
```

**Field Notes:**
- `organizationId` is set as the Firestore document ID — use a short, URL-safe identifier (e.g., `ph-manila-highschool-001`)
- `appCustomName` is the white-labeled name displayed in the app (e.g., "SpeakUp MONHSIAN")
- `primaryColor` / `secondaryColor` drive the app theme for this organization
- `allowAnonymousReports` can be toggled per organization
- `defaultLanguage` sets the org-wide default; individual users can override in their profile
- `signupRequiresApproval: true` enables the apply-to-join flow where students submit name + school ID for admin review

---

### `organizations/{organizationId}/config/{configId}` — Organization Config

A single document per organization (use `configId = "main"`).

```json
{
  "welcomeMessage": "string (displayed on home screen)",
  "privacyPolicyUrl": "string | null",
  "termsOfServiceUrl": "string | null",
  "supportEmail": "string | null",
  "maxPhotosPerReport": "number (default: 3)",
  "maxReportDescriptionLength": "number (default: 1000)",
  "requirePhotoForCategories": ["safety", "maintenance"],
  "customFields": [],
  "notificationSettings": {
    "notifyAdminsOnNewReport": "boolean",
    "notifyUsersOnStatusChange": "boolean",
    "adminNotificationEmail": "string | null"
  },
  "communityRulesEnabled": "boolean (true = show rules at signup and on home page)",
  "updatedAt": "Timestamp"
}
```

---

### `organizations/{organizationId}/categories/{categoryId}` — Report Categories

```json
{
  "categoryId": "string",
  "label": "string (display name, e.g. 'Safety')",
  "icon": "string (Material icon name, e.g. 'shield')",
  "color": "string (hex, optional)",
  "isActive": "boolean",
  "requiresPhoto": "boolean",
  "requiresLocation": "boolean",
  "sortOrder": "number",
  "anonymityMode": "open | identified | voluntary_contact",
  "identifiedNotice": "string | null",
  "createdAt": "Timestamp"
}
```

#### `anonymityMode` — Per-Category Anonymous Reporting Behaviour

Configured by the org admin per category. Controls how the report submission form handles reporter identity.

| Value | Behaviour | Use case |
|---|---|---|
| `open` | Reporter freely chooses Anonymous or Identified. Default for most categories. | Bullying, Harassment, Safety, Suggestions |
| `identified` | Anonymous option is hidden. Reporter must submit with their identity. A notice is shown explaining why. | Guidance referrals where counselor needs to follow up in person |
| `voluntary_contact` | Report is genuinely anonymous. After submission, reporter is offered an optional private opt-in to be contacted by the assigned counselor. The opt-in is stored separately and is not linked to the report document. | Mental health, personal concerns where trust is critical but counselor follow-up is beneficial |

`identifiedNotice` — Optional custom message shown on the form when `anonymityMode` is `identified`. If null, the app displays a default message: *"Your name will be shared with the assigned counselor so they can support you directly."*

**Design rationale:** Option 2 (fake anonymity — counselor can unmask) was explicitly rejected because it destroys reporter trust when the counselor initiates contact. Students will share that the anonymous option is not genuine, causing the entire reporting system to lose credibility. Only `open` and `identified` and `voluntary_contact` are valid modes.

**Default Categories (created at organization setup):**

| categoryId | label | icon | anonymityMode |
|---|---|---|---|
| `safety` | Safety | `shield` | `open` |
| `bullying` | Bullying | `person_off` | `open` |
| `maintenance` | Maintenance | `build` | `open` |
| `facilities` | Facilities | `business` | `open` |
| `harassment` | Harassment | `report` | `open` |
| `suggestions` | Suggestions | `lightbulb` | `open` |
| `cleanliness` | Cleanliness | `cleaning_services` | `open` |
| `security` | Security | `security` | `open` |
| `other` | Other | `more_horiz` | `open` |

---

### `organizations/{organizationId}/reports/{reportId}` — Reports

This is the core document of the platform.

```json
{
  "reportId": "string (auto-generated)",
  "organizationId": "string (denormalized for security rule validation)",
  "title": "string",
  "description": "string",
  "categoryId": "string (references categories collection)",
  "status": "submitted | under_review | in_progress | resolved | closed",
  "priority": "critical | urgent | low | manual",
  "isAnonymous": "boolean",
  "submittedBy": "string | null (Firebase Auth UID, null if anonymous)",
  "submitterDisplayName": "string | null",
  "photoUrls": ["string"],
  "location": {
    "label": "string | null",
    "latitude": "number | null",
    "longitude": "number | null"
  },
  "assignedTo": "string | null (admin UID)",
  "adminNotes": [
    {
      "noteId": "string",
      "authorId": "string",
      "authorName": "string",
      "content": "string",
      "createdAt": "Timestamp"
    }
  ],
  "statusHistory": [
    {
      "fromStatus": "string | null",
      "toStatus": "string",
      "changedBy": "string (admin UID)",
      "changedAt": "Timestamp",
      "note": "string | null"
    }
  ],
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp",
  "resolvedAt": "Timestamp | null"
}
```

**Field Notes:**
- `isAnonymous: true` means `submittedBy` and `submitterDisplayName` are `null`
- `statusHistory` is append-only — never delete entries
- `adminNotes` are visible to admins only (enforced by Security Rules)
- `photoUrls` contain Firebase Storage download URLs

---

### `organizations/{organizationId}/users/{userId}` — User Profiles

```json
{
  "userId": "string (Firebase Auth UID)",
  "organizationId": "string (denormalized)",
  "displayName": "string",
  "fullName": "string",
  "studentId": "string | null (school/org-issued ID number)",
  "email": "string | null",
  "preferredLanguage": "string (language code, e.g. 'en'; overrides org default)",
  "role": "user | admin | super_admin",
  "customRoles": ["string (roleIds granted by admin)"],
  "approvalStatus": "pending | approved | rejected (for apply-to-join orgs)",
  "isActive": "boolean",
  "fcmTokens": ["string"],
  "notificationPreferences": {
    "statusUpdates": "boolean",
    "adminAlerts": "boolean",
    "messages": "boolean",
    "bulletins": "boolean",
    "reminders": "boolean"
  },
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp",
  "lastLoginAt": "Timestamp"
}
```

**Field Notes:**
- `userId` is set as the Firestore document ID
- `studentId` matches the value in the `roster` collection for approval verification
- `fcmTokens` is an array to support multiple devices per user
- `preferredLanguage` overrides the org-level `defaultLanguage` for this user
- `approvalStatus` is only relevant when the org has `signupRequiresApproval: true`
- FCM tokens are added/updated on each app launch

---

### `organizations/{organizationId}/admins/{adminId}` — Admin Records

```json
{
  "adminId": "string (Firebase Auth UID)",
  "organizationId": "string",
  "displayName": "string",
  "email": "string",
  "role": "admin | super_admin",
  "assignedCategories": ["string (categoryIds)"],
  "canManageAdmins": "boolean",
  "canExportData": "boolean",
  "isActive": "boolean",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

---

### `organizations/{organizationId}/roster/{studentId}` — Student/Member Roster

Pre-loaded registry of valid student names and IDs used for apply-to-join signup verification.

```json
{
  "studentId": "string (school/org-issued ID, used as document ID)",
  "fullName": "string",
  "email": "string | null (optional, may be pre-filled at import)",
  "grade": "string | null (optional)",
  "section": "string | null (optional)",
  "isRegistered": "boolean (true once a user account has been created with this ID)",
  "registeredUserId": "string | null (Firebase Auth UID after signup)",
  "importedAt": "Timestamp",
  "importSource": "csv | text | docx | pdf | manual"
}
```

**Field Notes:**
- The document ID is the `studentId` (school-issued) for fast lookup at signup
- `isRegistered` is set to `true` when a user signs up with this ID to prevent duplicate accounts
- Roster entries can be imported in bulk from CSV, plain text, Word (.docx), PDF, or pasted into a text window

---

### `organizations/{organizationId}/roles/{roleId}` — Custom Roles

> Full role model and capability design: see **[RBAC_ARCHITECTURE.md](RBAC_ARCHITECTURE.md)**.

```json
{
  "id": "string (e.g. 'guidance-counselor')",
  "displayName": "string (e.g. 'Guidance Counselor')",
  "description": "string | null",
  "isSystemRole": "boolean (system roles cannot be deleted)",
  "capabilities": ["string (AppPermission enum values, e.g. 'viewGroupReports', 'approveReport')"],
  "customCapabilities": ["string (IDs referencing customCapabilities collection)"],
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

---

### `organizations/{organizationId}/customCapabilities/{capId}` — Custom Capability Aliases

> Org-defined human-readable capability names backed by pre-built actions from the app catalog. See [RBAC_ARCHITECTURE.md → Custom Capabilities](RBAC_ARCHITECTURE.md).

```json
{
  "id": "string (e.g. 'cc_review-guidance-referral')",
  "displayName": "string (e.g. 'Review Guidance Referral')",
  "description": "string | null",
  "resolvedAction": "string (AppPermission enum value this resolves to)",
  "tagScope": "string | null (content tag this capability is pre-scoped to)",
  "usedInRoles": ["string (roleIds that include this capability)"],
  "createdBy": "string (userId)",
  "createdAt": "Timestamp"
}
```
```

---

### `organizations/{organizationId}/classes/{classId}` — Academic Classes

Academic units (sections/homerooms). Separate from extracurricular groups. Role assignment `scopeType: "class"` targets these.

```json
{
  "classId": "string",
  "organizationId": "string (denormalized)",
  "name": "string (e.g. 'Grade 7 — Section A', '10-Rizal')",
  "gradeLevel": "number (e.g. 7, 8, 9, 10)",
  "academicYear": "string (e.g. '2025-2026')",
  "homeroomTeacherId": "string | null (userId of assigned homeroom teacher)",
  "isActive": "boolean",
  "studentCount": "number (denormalized for display)",
  "createdBy": "string (admin UID)",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

#### `organizations/{organizationId}/classes/{classId}/members/{userId}` — Class Enrollment

```json
{
  "userId": "string (Firebase Auth UID)",
  "displayName": "string (denormalized for display)",
  "classRole": "student | teacher",
  "enrolledAt": "Timestamp",
  "addedBy": "string (admin UID)"
}
```

---

### `organizations/{organizationId}/groups/{groupId}` — Groups & Clubs

Extracurricular units (clubs, organizations, corps). Separate from academic classes. Role assignment `scopeType: "group"` targets these.

```json
{
  "groupId": "string",
  "organizationId": "string (denormalized)",
  "name": "string (e.g. 'Special Program in Journalism (SPJ)', 'Drum and Lyre Corps', 'SSLG')",
  "description": "string | null",
  "avatarUrl": "string | null",
  "positionRoles": [
    {
      "id": "string (stable slug, e.g. president)",
      "label": "string (e.g. President)",
      "sortOrder": "number"
    }
  ],
  "isActive": "boolean",
  "memberCount": "number (denormalized for display)",
  "createdBy": "string (admin UID)",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

#### `organizations/{organizationId}/groups/{groupId}/members/{userId}` — Group Members

```json
{
  "userId": "string (Firebase Auth UID)",
  "displayName": "string (denormalized for display)",
  "groupRole": "leader | member",
  "positionRoleId": "string | null (references positionRoles[].id when defined)",
  "joinedAt": "Timestamp",
  "addedBy": "string (admin or leader UID)"
}
```

---

### `organizations/{organizationId}/bulletins/{bulletinId}` — Bulletin Board

Org-wide announcements posted by admins. Visible to all members.

```json
{
  "bulletinId": "string",
  "organizationId": "string (denormalized)",
  "title": "string",
  "body": "string",
  "authorId": "string (admin UID)",
  "authorName": "string",
  "isPinned": "boolean",
  "attachmentUrls": ["string"],
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp",
  "expiresAt": "Timestamp | null"
}
```

---

### `organizations/{organizationId}/newsPosts/{postId}` — News Board

Posts by groups/clubs. Visible to all org members or group members depending on `visibility`.

```json
{
  "postId": "string",
  "organizationId": "string (denormalized)",
  "groupId": "string | null (null if posted by an admin without a group)",
  "groupName": "string | null (denormalized)",
  "title": "string",
  "body": "string",
  "authorId": "string (user UID)",
  "authorName": "string",
  "visibility": "org_wide | group_only",
  "attachmentUrls": ["string"],
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

---

### `organizations/{organizationId}/reminders/{reminderId}` — Broadcast Reminders

```json
{
  "organizationId": "string (denormalized)",
  "title": "string",
  "body": "string",
  "status": "draft | pending | published | rejected",
  "createdBy": "string (user UID)",
  "createdByName": "string | null",
  "audienceType": "all | group | role",
  "audienceId": "string | null",
  "audienceLabel": "string | null",
  "scheduledAt": "Timestamp | null",
  "expiresAt": "Timestamp | null (auto-remove when reached)",
  "publishedAt": "Timestamp | null",
  "deliveredAt": "Timestamp | null",
  "reviewedBy": "string | null",
  "reviewedByName": "string | null",
  "reviewedAt": "Timestamp | null",
  "rejectionReason": "string | null",
  "responseConfig": {
    "enabled": "boolean",
    "type": "free_text | checkbox | multiple_choice",
    "maxTextLength": "number (free_text only, default 500)",
    "options": [
      { "id": "string (UUID)", "label": "string" }
    ]
  },
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

**Permission Note:** Holders of `broadcastReminders` may create reminders; `approveReminders` or admins approve/reject pending items. Delivery and expiration are server-side (Cloud Functions).

**Response config:** Optional. When `responseConfig.enabled` is true, recipients submit one response per user via the `submitReminderResponse` callable until `expiresAt` (if set).

---

### `organizations/{organizationId}/reminders/{reminderId}/responses/{userId}` — Reminder Responses

One document per recipient per reminder (document ID = recipient UID).

```json
{
  "organizationId": "string",
  "reminderId": "string",
  "userId": "string (same as document ID)",
  "userDisplayName": "string | null",
  "responseType": "free_text | checkbox | multiple_choice",
  "text": "string | null (free_text)",
  "selectedOptionIds": ["string"] ,
  "selectedOptionId": "string | null (multiple_choice)",
  "submittedAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

**Permission Note:** Recipients write via `submitReminderResponse` (Admin SDK). Author and org admins may read all responses; recipients may read their own.

---

### `organizations/{organizationId}/notification_history/{historyId}` — Notification Archive

Server-written when a notification or broadcast is removed (expired, recalled, dismissed, or cleared).

```json
{
  "organizationId": "string",
  "sourceType": "reminder | notification",
  "sourceId": "string",
  "reminderId": "string | null",
  "userId": "string | null (per-user dismissals)",
  "title": "string",
  "body": "string",
  "type": "reminder | status_update | general",
  "audienceType": "string | null",
  "audienceLabel": "string | null",
  "createdBy": "string | null",
  "createdByName": "string | null",
  "publishedAt": "Timestamp | null",
  "expiresAt": "Timestamp | null",
  "removedAt": "Timestamp",
  "removalReason": "expired | recalled | user_dismissed | cleared_all",
  "removedBy": "string | null",
  "feedCopiesAffected": "number | null"
}
```

**Permission Note:** Client writes disabled. Admins read all; broadcast authors read by `createdBy`; users read entries where `userId` matches.

---

### `organizations/{organizationId}/messages/{threadId}` — Group Chat Messages

Group messages are stored as subcollections under a thread document.

```json
// Thread document (organizations/{orgId}/messages/{threadId})
{
  "threadId": "string",
  "groupId": "string (references groups collection)",
  "organizationId": "string",
  "lastMessage": "string (preview of most recent message)",
  "lastMessageAt": "Timestamp",
  "lastMessageBy": "string (UID)"
}

// Message sub-document (organizations/{orgId}/messages/{threadId}/entries/{messageId})
{
  "messageId": "string",
  "senderId": "string (Firebase Auth UID)",
  "senderName": "string (denormalized)",
  "body": "string",
  "isDeleted": "boolean",
  "createdAt": "Timestamp"
}
```

---

### `organizations/{organizationId}/directMessages/{threadId}` — Peer-to-Peer Messages

```json
// Thread document
{
  "threadId": "string (deterministic: sorted UIDs joined with '_')",
  "participantIds": ["string (UID A)", "string (UID B)"],
  "participantNames": {"uid": "displayName"},
  "organizationId": "string",
  "lastMessage": "string",
  "lastMessageAt": "Timestamp",
  "lastMessageBy": "string (UID)"
}

// Message sub-document (directMessages/{threadId}/entries/{messageId})
{
  "messageId": "string",
  "senderId": "string",
  "body": "string",
  "isDeleted": "boolean",
  "readBy": ["string (UIDs who have read this message)"],
  "createdAt": "Timestamp"
}
```

**Security Note:** Thread IDs use a deterministic format (`sorted([uidA, uidB]).join('_')`) so either participant can look up the shared thread without a full collection scan.

---

### `organizations/{organizationId}/blockedUsers/{blockId}` — Abuse Blocks

```json
{
  "blockId": "string",
  "organizationId": "string",
  "targetUserId": "string | null (null for anonymous blocks by identifier)",
  "targetIdentifier": "string | null (device fingerprint or IP hash for anonymous users)",
  "blockedBy": "string (admin UID)",
  "reason": "string",
  "blockType": "permanent | temporary",
  "expiresAt": "Timestamp | null (null if permanent)",
  "createdAt": "Timestamp"
}
```

---

### `organizations/{organizationId}/audit_log/{entryId}` — Admin Activity Log

Immutable, append-only record of every privileged action performed by admins or Cloud Functions. Written exclusively by trusted Cloud Functions (never directly from the Flutter client) to prevent tampering. Readable only by users with the `viewAuditLogs` permission.

```json
{
  "entryId": "string (auto-generated Firestore doc ID)",
  "eventType": "string (dot-namespaced — see taxonomy below)",
  "actorId": "string (Firebase Auth UID of the admin who performed the action)",
  "actorDisplayName": "string (snapshot at time of action — denormalized)",
  "timestamp": "Timestamp (server-set)",
  "resourceType": "string ('role' | 'capability' | 'assignment' | 'category' | 'config' | 'user' | 'report' | 'bulletin')",
  "resourceId": "string (Firestore document ID of the affected resource)",
  "before": "Map? (snapshot of key changed fields before the action — omitted on creation)",
  "after":  "Map? (snapshot of key changed fields after the action — omitted on deletion)",
  "metadata": "Map? (additional context — e.g. scopeType + scopeId for role assignments)"
}
```

> **`before`/`after` capture only the changed fields**, not the full document, to keep entries small and diffs legible.

#### Event Type Taxonomy

| Event Type | Trigger |
|---|---|
| `config.branding_updated` | Admin saves display name, primary/secondary color |
| `config.category_created` | New report category added |
| `config.category_updated` | Category name, `anonymityMode`, or `identifiedNotice` changed |
| `config.category_deleted` | Category removed |
| `config.org_settings_updated` | Any other org-level setting (communityRules, features flags) |
| `roles.role_created` | New role definition saved |
| `roles.role_updated` | Role capabilities or description changed |
| `roles.role_deleted` | Role removed |
| `roles.capability_created` | Custom capability alias created |
| `roles.capability_deleted` | Custom capability alias removed |
| `roles.assignment_added` | Role assigned to a user (with scope) |
| `roles.assignment_removed` | Role assignment revoked |
| `users.application_approved` | Admin approves a join application |
| `users.application_rejected` | Admin rejects a join application |
| `users.user_blocked` | User suspended or permanently blocked |
| `users.user_unblocked` | Block lifted |
| `reports.status_changed` | Report status updated (mirrors `statusHistory` for org-level querying) |
| `reports.note_added` | Internal note appended to a report |
| `bulletins.posted` | Bulletin published (especially `org_wide`) |
| `bulletins.deleted` | Bulletin removed |

#### Implementation Strategy

All writes to `audit_log` are performed by **Firestore-triggered Cloud Functions** that react to document writes in the relevant collections. This ensures audit entries are created regardless of which client or admin tool performed the write, and that clients cannot skip or forge them. No direct Firestore writes to `audit_log` are permitted from Flutter code.

---

### `organizations/{organizationId}/communityRules/{ruleId}` — Community Rules

Displayed at signup and on the home page. Admin-customizable.

```json
{
  "ruleId": "string",
  "sortOrder": "number",
  "title": "string (e.g. 'Be Respectful')",
  "body": "string (explanation of the rule)",
  "isActive": "boolean",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

---

### `languages/{languageCode}/strings/{stringKey}` — Language Database

Global (not org-scoped). All UI text elements have a `stringKey` that maps to translated values here. English (`en`) is the default and always present.

```json
// Language metadata document (languages/{languageCode})
{
  "languageCode": "string (e.g. 'en', 'fil', 'es')",
  "displayName": "string (e.g. 'English', 'Filipino', 'Español')",
  "nativeName": "string (e.g. 'English', 'Filipino', 'Español')",
  "isDefault": "boolean",
  "isActive": "boolean",
  "completionPercent": "number (0–100, how much of the string set is translated)",
  "updatedAt": "Timestamp"
}

// String entry (languages/{languageCode}/strings/{stringKey})
{
  "stringKey": "string (e.g. 'home.welcomeMessage', 'submit.buttonLabel')",
  "value": "string (translated text)",
  "updatedAt": "Timestamp"
}
```

**Implementation Notes:**
- In practice, language strings may be bundled as JSON assets in the Flutter app for offline access and performance, with Firestore used for admin-side editing and hot-updating without app re-release
- English strings serve as the fallback when a key is missing in the selected language
- The language selector dropdown on the home page writes the user's choice to `users/{userId}.preferredLanguage`

### Required Composite Indexes

```
Collection: organizations/{orgId}/reports
Indexes:
  1. organizationId ASC + status ASC + createdAt DESC
  2. organizationId ASC + categoryId ASC + createdAt DESC
  3. organizationId ASC + submittedBy ASC + createdAt DESC
  4. organizationId ASC + assignedTo ASC + status ASC + createdAt DESC
  5. organizationId ASC + status ASC + categoryId ASC + createdAt DESC

Collection: organizations/{orgId}/bulletins
Indexes:
  1. organizationId ASC + isPinned DESC + createdAt DESC

Collection: organizations/{orgId}/newsPosts
Indexes:
  1. organizationId ASC + visibility ASC + createdAt DESC
  2. organizationId ASC + groupId ASC + createdAt DESC

Collection: organizations/{orgId}/reminders
Indexes:
  1. status ASC + createdAt DESC
  2. createdBy ASC + createdAt DESC
  3. Collection group: status ASC + scheduledAt ASC (scheduled publisher)
  4. Collection group: status ASC + expiresAt ASC (expiration job)

Collection: organizations/{orgId}/reminders/{reminderId}/responses
Indexes:
  1. submittedAt DESC (list responses for a reminder)

Collection: organizations/{orgId}/notification_history
Indexes:
  1. createdBy ASC + removedAt DESC (author history view)
  2. removedAt DESC (admin org-wide view)

Collection: organizations/{orgId}/directMessages
Indexes:
  1. participantIds ARRAY_CONTAINS + lastMessageAt DESC

Collection: organizations/{orgId}/blockedUsers
Indexes:
  1. organizationId ASC + targetUserId ASC + expiresAt ASC

Collection: organizations/{orgId}/audit_log
Indexes:
  1. resourceType ASC + timestamp DESC
  2. actorId ASC + timestamp DESC
  3. eventType ASC + timestamp DESC

Collection: organizations/{orgId}/roster
Indexes:
  1. isRegistered ASC + importedAt DESC
```

These indexes must be created in `firestore.indexes.json` and deployed via Firebase CLI.

---

## Data Retention & Privacy

- Resolved/closed reports are retained for **2 years** by default (configurable per organization)
- Anonymous report metadata (IP, device info) is never stored
- User profiles can be deleted via a GDPR/data rights request flow (future Sprint)
- `statusHistory` provides the full audit trail for compliance

---

## Firestore Security Rules (Outline)

Full rules are maintained in `firestore.rules`. Key principles:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Organization documents: only authenticated members can read
    match /organizations/{organizationId} {
      allow read: if isOrgMember(organizationId);
      allow write: if isSuperAdmin(organizationId);

      // Reports: users see own reports; admins see all
      match /reports/{reportId} {
        allow read: if isAdmin(organizationId)
                    || (isOrgMember(organizationId)
                        && resource.data.submittedBy == request.auth.uid);
        allow create: if isOrgMember(organizationId)
                      && isValidReport(request.resource.data);
        allow update: if isAdmin(organizationId);
      }

      // Users: can read/write own profile
      match /users/{userId} {
        allow read, write: if request.auth.uid == userId
                           && isOrgMember(organizationId);
        allow read: if isAdmin(organizationId);
      }

      // Categories: readable by all org members
      match /categories/{categoryId} {
        allow read: if isOrgMember(organizationId);
        allow write: if isAdmin(organizationId);
      }
    }
  }
}
```

See `firestore.rules` for the complete, deployed rules.
