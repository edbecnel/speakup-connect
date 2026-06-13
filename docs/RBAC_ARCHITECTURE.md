# Role-Based Access Control (RBAC) Architecture — SpeakUp Connect

> **Status:** Design finalized (May 2026). Implementation blocked pending MONHS feedback.  
> See [`ADMIN_APP_REQUIREMENTS.md → Open Questions`](ADMIN_APP_REQUIREMENTS.md) before beginning Epic 2.12.

---

## Overview

SpeakUp Connect uses a **two-tier permission-based RBAC** model. It is designed to:

- Give organization admins meaningful flexibility to define roles that match their real-world structure
- Keep all security enforcement in code and Firestore Security Rules — never in runtime-evaluated strings
- Scale from simple two-role orgs (Admin / Member) to complex multi-role school environments (Counselors, Homeroom Teachers, Discipline Officers, Department Heads)
- Support MONHS's requirement to scope access to specific content categories (e.g., a counselor sees only guidance-tagged reports)

---

## Design Principles

1. **Names are user-defined; behaviour is developer-defined.** Org admins name roles and capabilities. The behaviour those capabilities trigger is always coded, not interpreted at runtime.
2. **Capabilities compose roles.** A role is simply a named collection of capabilities + an optional content scope. There are no hardcoded role checks in UI code — only capability checks.
3. **Scope narrows, never widens.** Content tag scope can only restrict what a user sees — it cannot grant access beyond what the capability allows.
4. **Server-side is the security boundary.** App-level checks are UX gates. Firestore Security Rules (enforced via Custom Claims or Cloud Function proxy) are the actual security boundary.

---

## Two-Tier Model

### Tier 1 — Capabilities (Fixed, Code-Controlled)

Capabilities are defined as an `AppPermission` enum in Dart. They map 1-to-1 with actual app behaviour: a UI widget that appears, a Firestore write that is permitted, or a screen that is unlocked.

```dart
enum AppPermission {
  // Reports
  viewAllReports,
  viewGroupReports,
  approveReport,
  manageReports,       // update status, escalate, reject, add notes

  // Bulletins & News
  postBulletinOrgWide,
  postBulletinToGroup,

  // Reminders
  broadcastReminders,

  // Roster & Users
  manageGroupRoster,
  approveApplications,
  blockUsers,

  // Org Administration
  manageOrganizationSettings,
  manageRoles,
  manageTranslations,
  viewAuditLogs,
}
```

**Why an enum and not strings?**

- Compile-time typo detection — `AppPermission.approveReprot` is a build error, not a silent auth bypass
- IDE "Find All References" — instantly see every screen/widget gated by a capability
- Dead code detection — unused capabilities are caught by the analyzer
- The real constraint: `if (canApprove) ApproveButton(...)` — this Flutter widget line must be written by a developer. A string stored in Firestore cannot conjure a widget into existence at runtime.

**Adding a new capability** requires:
1. Adding the enum value in Dart
2. Writing the UI widget/action it unlocks
3. Adding the Firestore Security Rule that enforces it
4. Deploying the app update

This is the intentional security gate. New behaviour = deliberate developer action.

---

### Tier 2 — Content Scope (Org-Defined, Zero Code Change)

Org admins create arbitrary **content tags** in Firestore (e.g., `guidance`, `discipline`, `faculty`, `mental-health`). Tags are attached to content: report categories, groups, bulletin boards.

A **role assignment** can include an optional tag scope:

```
userId: "abc123"
roleId: "guidance-counselor"
scopeType: "tag"          // "org" | "class" | "group" | "tag"
scopeId: "guidance"
```

A user with `viewGroupReports` + tag scope `guidance` can only see reports tagged `guidance` — not `discipline`, not untagged reports.

This gives orgs unlimited flexibility to define content boundaries **without any code change or app update**.

---

## Role Structure

A role is stored in Firestore at `organizations/{orgId}/roles/{roleId}`.

```json
{
  "id": "guidance-counselor",
  "displayName": "Guidance Counselor",
  "description": "Reviews and closes guidance referral reports. Posts to guidance board.",
  "isSystemRole": false,
  "capabilities": [
    "viewGroupReports",
    "approveReport",
    "postBulletinToGroup"
  ],
  "customCapabilities": [
    "cc_review-guidance-referral",
    "cc_post-to-guidance-board"
  ],
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**System roles** (`isSystemRole: true`) are seeded on org creation and cannot be deleted:
- `org-admin` — all org-level capabilities
- `member` — no elevated capabilities (submit + view own reports only)

---

## Role Assignment Structure

Role assignments are stored at `organizations/{orgId}/users/{userId}/roleAssignments/{assignmentId}` or denormalized onto the user document.

```json
{
  "roleId": "guidance-counselor",
  "scopeType": "tag",          // "org" | "class" | "group" | "tag"
  "scopeId": "guidance",
  "assignedBy": "userId-of-admin",
  "assignedAt": "timestamp"
}
```

A user may hold multiple role assignments (e.g., Guidance Counselor scoped to `guidance` AND Group Leader scoped to a specific group). Effective permissions are the **union** of all assignments.

### Scoped `manageRoles` Delegation

The `manageRoles` capability supports scoped delegation — an org admin can grant a Department Head the ability to assign roles **only within their own department**, rather than org-wide. This is configured in the role assignment itself:

```json
// Department Head — can only assign roles within science-dept
{
  "roleId": "department-head",
  "scopeType": "group",
  "scopeId": "science-dept",
  "assignedBy": "userId-of-admin",
  "assignedAt": "timestamp"
}

// Department Head — org-wide delegation
{
  "roleId": "department-head",
  "scopeType": "org",
  "scopeId": null,
  "assignedBy": "userId-of-admin",
  "assignedAt": "timestamp"
}
```

The permission provider enforces: *"does this user have `manageRoles` AND is the target user within the assigner's scope?"* Firestore Security Rules verify this on all role assignment writes — a scoped `manageRoles` holder cannot assign roles outside their declared scope.

### `manageTranslations` (Translation Moderator)

Org admins can edit UI translations for their organization's supported languages (`ceb`, `fil`, etc.). They may delegate this work by assigning the **`manageTranslations`** capability to any role via **Settings → Roles & Permissions**.

| Actor | Locale scope | Import EN source | Edit / approve | Single AI draft | Batch AI | Export ARB |
|-------|--------------|------------------|----------------|-----------------|----------|------------|
| Platform `super_admin` | All | ✅ | ✅ | ✅ | ✅ | ✅ |
| Org admin | Org `supportedLanguages` | ❌ | ✅ | ✅ | ✅ | ✅ |
| `manageTranslations` | Same as org admin | ❌ | ✅ | ✅ | ❌ | ❌ |

Cloud Functions require `organizationId` in the callable payload for non–super-admin callers. Writes are scoped to the org's enabled locales; moderators cannot import English keys or run bulk export/batch AI (org admin only).

---

## Custom Capabilities (Org-Defined)

Org admins can create human-readable capability names that are **aliases for pre-built actions** from the app's capability catalog.

### How It Works

An org admin creates a custom capability in the admin panel:

| Field | Example |
|---|---|
| Name | "Review Guidance Referral" |
| Description | "For counselors to close guidance referral reports" |
| Backed by action | `approveReport` (selected from dropdown) |
| Pre-scoped tag | `guidance` (optional) |

The **name** is stored in Firestore. The **behaviour** (`approveReport`) comes from the pre-built catalog. The app resolves the alias at runtime:

```
"Review Guidance Referral"  →  approveReport  →  ✅ Approve button shown
```

This gives MONHS-meaningful labels in the admin UI while the actual evaluation never changes.

### Capability Catalog (Pre-Built Actions)

| Catalog Label | Resolves To | What It Unlocks |
|---|---|---|
| Approve / Close an Item | `approveReport` | ✅ Approve button on reports |
| Update Status & Add Notes | `manageReports` | Escalate / Reject / Add Note controls |
| View Content in Assigned Groups | `viewGroupReports` | Report list filtered to assigned groups |
| View All Content Org-wide | `viewAllReports` | Full org report list |
| Post to a Board / Group | `postBulletinToGroup` | New Bulletin composer (group-scoped) |
| Post Org-Wide | `postBulletinOrgWide` | Org-wide audience picker in composer |
| Broadcast Reminder | `broadcastReminders` | Reminders screen and send action |
| Manage Group Members | `manageGroupRoster` | Add / Remove controls on group roster |
| Block a User | `blockUsers` | Block action on profiles and reports |
| Approve Join Application | `approveApplications` | Join applications queue with Approve / Reject |

**Adding a new catalog entry** (new behaviour) requires an app update. Renaming existing entries or creating new custom capabilities that use existing entries requires no code change.

### Custom Capability Firestore Schema

Stored at `organizations/{orgId}/customCapabilities/{capId}`:

```json
{
  "id": "cc_review-guidance-referral",
  "displayName": "Review Guidance Referral",
  "description": "For counselors to close guidance referral reports.",
  "resolvedAction": "approveReport",
  "tagScope": "guidance",
  "usedInRoles": ["guidance-counselor"],
  "createdBy": "userId-of-admin",
  "createdAt": "timestamp"
}
```

---

## Permission Evaluation

### App-Level Check (Riverpod)

```dart
// Conceptual — exact implementation in lib/features/roles/
final hasPermission = ref.watch(permissionProvider(AppPermission.approveReport));

// With tag scope context
final canApproveGuidance = ref.watch(
  permissionWithScopeProvider(AppPermission.approveReport, tag: 'guidance'),
);
```

The `PermissionProvider` (Epic 2.12):
1. Loads the user's role assignments from Firestore (or from custom claims if using that strategy)
2. Resolves custom capability aliases to their `resolvedAction`
3. Merges all assignments into an effective permission set
4. Returns a boolean for `hasPermission(action, [tag])` queries

### Custom Capability Resolution

When a user has a custom capability in their role, the provider resolves it:

```
User permissions (raw):    [viewGroupReports, cc_review-guidance-referral]
Custom cap registry:       cc_review-guidance-referral → approveReport (tag: guidance)
Effective action set:      [viewGroupReports, approveReport]
Tag scope:                 [guidance]
```

Policy engine evaluation:
```
evaluate('approveReport', report tagged 'guidance')  →  ✅ allow
evaluate('approveReport', report tagged 'discipline') →  ❌ deny (tag scope)
evaluate('viewGroupReports', report tagged 'guidance') → ✅ allow
```

---

## Enforcement Strategy

### Layer 1 — App UI (Riverpod Providers)

Gates widgets and navigation. Not a security boundary — can be bypassed by a modified app binary.

```dart
if (await canDo(AppPermission.approveReport, tag: report.tag))
  ApproveReportButton(report: report)
```

### Layer 2 — Firestore Security Rules (Server-Side)

The actual security boundary. Two implementation options:

#### Option A — Firebase Auth Custom Claims *(Recommended for Sprint)*

A Cloud Function writes the user's resolved permission array to their Firebase Auth token whenever their role assignments change.

```json
// Custom claim written to token
{
  "permissions": ["viewGroupReports", "approveReport"],
  "tagScope": ["guidance"],
  "orgId": "monhs"
}
```

Security Rules then reference `request.auth.token.permissions`:

```javascript
allow write: if request.auth.token.permissions.hasAny(['approveReport'])
             && request.auth.token.orgId == resource.data.organizationId;
```

**Tradeoff:** Token is refreshed on role change (Cloud Function trigger). New permissions take effect within ~1 hour (ID token expiry) without force-refresh, or immediately if the app forces a token refresh after the Cloud Function completes.

#### Option B — Cloud Function Write Proxy *(For Complex Policy Logic)*

All sensitive writes go through a Cloud Function endpoint. The function calls the policy engine to evaluate the request before executing the Firestore write. Slower and more complex but enables full runtime policy evaluation.

**Recommendation:** Start with Custom Claims (Option A). Migrate specific write paths to Cloud Functions when policy complexity warrants it (e.g., multi-condition rules, cross-collection checks).

---

## Policy Engine (Future Sprint)

For data-access decisions (show/hide data, filter queries), a runtime policy engine eliminates hardcoded `if (role == 'admin')` checks entirely. The call site is:

```dart
final result = policyEngine.evaluate('report.view', {
  'user': currentUser,
  'resource': report,
  'context': {'orgId': orgId},
});
```

The policy engine:
1. Loads the user's effective permission set (from Custom Claims or Firestore)
2. Evaluates the requested action against the permission set and resource context
3. Returns `allow` / `deny` with an explanation for debug/audit

**This does not eliminate the pre-built action catalog.** Widget rendering still requires developer-written code. The policy engine replaces `if` checks for *data access* but not for *UI behaviour*.

**Recommended migration path:**
1. Sprint: Implement fixed `AppPermission` enum + `PermissionProvider` (simple boolean checks)
2. Later sprint: Wrap `PermissionProvider` to call a policy engine internally — call sites don't change

---

## Firestore Collections Summary

| Collection | Path | Purpose |
|---|---|---|
| Roles | `organizations/{orgId}/roles/{roleId}` | Role definitions with capability arrays |
| Custom Capabilities | `organizations/{orgId}/customCapabilities/{capId}` | Org-defined capability aliases |
| Role Assignments | `organizations/{orgId}/users/{userId}` (field) | Which roles a user holds, with scope |

See [DATABASE_DESIGN.md](DATABASE_DESIGN.md) for full Firestore schemas.

---

## Implementation Status

| Item | Status |
|---|---|
| RBAC architecture design | ✅ Finalized |
| Interactive UI mockup | ✅ [`docs/mockups/roles-management-mockup.html`](mockups/roles-management-mockup.html) |
| Classes vs Groups separation | ✅ Decided — separate `classes/` and `groups/` collections; `scopeType` includes `"class"` |
| Teacher/Staff role definition | ✅ Decided — role names are admin-configurable; no code change needed for new role names |
| Scoped `manageRoles` delegation | ✅ Decided — delegation scope set in the role assignment by org admin |
| `AppPermission` enum (Dart) | ✅ Complete — `lib/core/permissions/app_permission.dart` (incl. `displayName`, `groupLabel`) |
| `PermissionProvider` (Riverpod) | ✅ Complete — `lib/core/permissions/providers/permission_provider.dart` |
| `roles` Firestore collection + seeding | ⬜ Not started — Epic 2.12 (write path via `RoleWriter` provider complete) |
| Custom capabilities Firestore collection | ⬜ Not started — Epic 2.12 (write path via `CustomCapabilityWriter` complete) |
| `RolesManagementScreen` | ✅ Complete — `lib/features/roles/presentation/screens/roles_management_screen.dart` |
| `RoleEditorScreen` | ✅ Complete — `lib/features/roles/presentation/screens/role_editor_screen.dart` |
| `AssignRoleScreen` | ✅ Complete — `lib/features/roles/presentation/screens/assign_role_screen.dart` |
| `CapabilitiesScreen` | ✅ Complete — `lib/features/roles/presentation/screens/capabilities_screen.dart` |
| Custom Claims Cloud Function | ✅ Complete — `functions/src/index.ts` (`syncCustomClaims`, `refreshMyPermissions`) |
| Firestore Security Rules for capabilities | ✅ Complete — `roleAssignments`, `customCapabilities`, `classes`, `counselorContactRequests` added |

> All architectural decisions are resolved. Epic 2.12 implementation can proceed. See [ADMIN_APP_REQUIREMENTS.md](ADMIN_APP_REQUIREMENTS.md) for the decision log.

---

## Related Documents

- [SECURITY_AND_PRIVACY.md](SECURITY_AND_PRIVACY.md) — Security model, Firestore rules, authentication
- [DATABASE_DESIGN.md](DATABASE_DESIGN.md) — Full Firestore schema for `roles` and `customCapabilities`
- [ADMIN_APP_REQUIREMENTS.md](ADMIN_APP_REQUIREMENTS.md) — Admin mobile app scope; open questions on Teacher role
- [ARCHITECTURE.md](ARCHITECTURE.md) — System architecture overview
- [MASTER_TASK_LIST.md](MASTER_TASK_LIST.md) — Epic 2.12 task breakdown
- [mockups/roles-management-mockup.html](mockups/roles-management-mockup.html) — Interactive UI mockup (4 screens + live simulation)
