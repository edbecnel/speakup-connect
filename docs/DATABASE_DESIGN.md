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
│       ├── groups/          # Admin-defined groups/clubs/organizations
│       │   └── {groupId}/
│       │       ├── [group document]
│       │       └── members/     # Group membership records
│       ├── bulletins/       # Admin-posted org-wide bulletin board posts
│       ├── newsPosts/       # Group/org news board posts
│       ├── reminders/       # Broadcast reminders sent to members
│       ├── messages/        # Group chat messages (per group sub-collection)
│       ├── directMessages/  # Peer-to-peer message threads
│       ├── blockedUsers/    # Abuse block records
│       └── communityRules/  # Customizable signup/community rules
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
  "createdAt": "Timestamp"
}
```

**Default Categories (created at organization setup):**

| categoryId | label | icon |
|---|---|---|
| `safety` | Safety | `shield` |
| `bullying` | Bullying | `person_off` |
| `maintenance` | Maintenance | `build` |
| `facilities` | Facilities | `business` |
| `harassment` | Harassment | `report` |
| `suggestions` | Suggestions | `lightbulb` |
| `cleanliness` | Cleanliness | `cleaning_services` |
| `security` | Security | `security` |
| `other` | Other | `more_horiz` |

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

### `organizations/{organizationId}/groups/{groupId}` — Groups & Clubs

```json
{
  "groupId": "string",
  "organizationId": "string (denormalized)",
  "name": "string (e.g. 'Journalism Club', 'Chess Club', 'Drum and Lyre Corps')",
  "description": "string | null",
  "avatarUrl": "string | null",
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
  "reminderId": "string",
  "organizationId": "string (denormalized)",
  "title": "string",
  "body": "string",
  "authorId": "string (user UID)",
  "authorName": "string",
  "audience": "all | group | role",
  "audienceGroupId": "string | null",
  "audienceRoleId": "string | null",
  "sentAt": "Timestamp",
  "scheduledFor": "Timestamp | null (for future scheduled reminders)"
}
```

**Permission Note:** A user can create a reminder only if their role includes `canBroadcastReminders: true`.

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
  1. organizationId ASC + audience ASC + sentAt DESC
  2. organizationId ASC + audienceGroupId ASC + sentAt DESC

Collection: organizations/{orgId}/directMessages
Indexes:
  1. participantIds ARRAY_CONTAINS + lastMessageAt DESC

Collection: organizations/{orgId}/blockedUsers
Indexes:
  1. organizationId ASC + targetUserId ASC + expiresAt ASC

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
