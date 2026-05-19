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
│       └── admins/          # Admin records for this org
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
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp",
  "subscriptionTier": "free | pilot | standard | enterprise",
  "subscriptionExpiresAt": "Timestamp | null"
}
```

**Field Notes:**
- `organizationId` is set as the Firestore document ID — use a short, URL-safe identifier (e.g., `ph-manila-highschool-001`)
- `primaryColor` / `secondaryColor` drive the app theme for this organization
- `allowAnonymousReports` can be toggled per organization

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
  "priority": "low | medium | high | urgent",
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
  "email": "string | null",
  "role": "user | admin | super_admin",
  "isActive": "boolean",
  "fcmTokens": ["string"],
  "notificationPreferences": {
    "statusUpdates": "boolean",
    "adminAlerts": "boolean"
  },
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp",
  "lastLoginAt": "Timestamp"
}
```

**Field Notes:**
- `userId` is set as the Firestore document ID
- `fcmTokens` is an array to support multiple devices per user
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

## Firestore Indexes

### Required Composite Indexes

```
Collection: organizations/{orgId}/reports
Indexes:
  1. organizationId ASC + status ASC + createdAt DESC
  2. organizationId ASC + categoryId ASC + createdAt DESC
  3. organizationId ASC + submittedBy ASC + createdAt DESC
  4. organizationId ASC + assignedTo ASC + status ASC + createdAt DESC
  5. organizationId ASC + status ASC + categoryId ASC + createdAt DESC
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
