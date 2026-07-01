# Report Category RBAC — Role-Scoped Report Permissions

> **Epic:** 2.12 extension · **Sprint:** 16  
> **Status:** Active implementation  
> **Related:** [RBAC_ARCHITECTURE.md](RBAC_ARCHITECTURE.md) · [DATABASE_DESIGN.md](DATABASE_DESIGN.md) → `roles`

---

## Summary

Each role definition stores `allowedCategoryIds` — a list of report category document IDs from `organizations/{orgId}/categories/{categoryId}`. Report-related permissions apply **only** to reports whose `categoryId` is in the user's resolved allowed set (union across all role assignments).

**User value:** Org admins model real school workflows (counseling vs discipline triage), reduce accidental access to sensitive report types, and enforce boundaries server-side — not UI-only hiding.

---

## Report-Related Permissions

| Permission | Scope |
|------------|--------|
| `viewAllReports` | Read/triage list — all reports **within allowed categories** (non-admin) |
| `viewGroupReports` | Read/triage list — scoped report access (category filter in v1; no `groupId` on reports yet) |
| `approveReport` | Approve / close reports in allowed categories |
| `manageReports` | Status update, escalate, add notes, assign — in allowed categories |

Non-report permissions (reminders, bulletins, roster, etc.) are **unaffected** by `allowedCategoryIds`.

---

## Role Schema

Field on `organizations/{organizationId}/roles/{roleId}`:

```json
{
  "allowedCategoryIds": ["bullying", "conduct"]
}
```

| Value | Meaning |
|-------|---------|
| `null` or field omitted on `org-admin` | Unrestricted — all categories |
| Non-empty array | Only those `categoryId` values |
| Empty array `[]` | No report category access (even if report capabilities granted) |
| Field omitted on custom/starter roles | **Strict:** treat as `[]` (no access until admin configures) |

---

## Permission Evaluation

### Effective set (app)

`EffectivePermissionSet` carries:

- `grants` — resolved capability grants (unchanged)
- `allowedCategoryIds` — union across roles; `null` = unrestricted

Rules:

1. If permission is **not** report-related → ignore category list.
2. If permission **is** report-related:
   - Unrestricted (`allowedCategoryIds == null`) → allow any `categoryId`
   - Else require `report.categoryId ∈ allowedCategoryIds`
3. User with report capabilities but empty allowed set → deny all report actions.
4. Multiple role assignments → **union** of categories and permissions.

### JWT custom claims (Cloud Functions)

`syncCustomClaims` / `refreshMyPermissions` write:

```json
{
  "permissions": ["viewGroupReports", "approveReport"],
  "allowedCategoryIds": ["bullying", "conduct"],
  "tagScopes": []
}
```

| User type | `allowedCategoryIds` in JWT |
|-----------|----------------------------|
| Org admin (unrestricted) | `["*"]` |
| Scoped delegate | Union of role lists |
| No report access | `[]` |

`tagScopes` from custom capabilities remains for backward compatibility but **report enforcement uses `allowedCategoryIds` only** in v1 (no intersect with `tagScope`).

---

## Firestore Security Rules

Helpers (conceptual):

- `hasUnrestrictedReportCategories()` — `allowedCategoryIds` absent or contains `"*"`
- `reportCategoryAllowed()` — admin bypass OR `resource.data.categoryId` in token list

| Operation | Rule |
|-----------|------|
| Read report | Existing member-own path OR (`canViewOrgReports` AND `reportCategoryAllowed`) |
| Update report | Admin OR (`manageReports` OR `approveReport` in claims AND `reportCategoryAllowed`) |
| Delete report | Org admin only (unchanged) |

---

## Admin UX

### Role Editor

- Multi-select chips for org active categories when editing a role.
- Validation: if any report capability is selected, require ≥1 allowed category (except `org-admin`).
- Warn on stale category IDs not in org catalog.

### Admin Reports dashboard

- List query filtered by allowed categories (Firestore `whereIn`, max 30 — chunk or client merge if needed).
- Category filter chips show **only** categories the user may access.
- Empty state when user has report caps but no allowed categories.

### Admin report detail

- Deny view when `categoryId` outside allowed set (UI + rules).
- Admin actions gated by `manageReports` / `approveReport` **and** category match.

---

## MONHS Starter Role Matrix

| Role | Capabilities | `allowedCategoryIds` (seed) |
|------|--------------|----------------------------|
| `org-admin` | all | `null` (unrestricted) |
| `guidance-counselor` | `viewGroupReports`, `approveReport` | `["academic"]` *(interim — replace when org adds dedicated guidance category)* |
| `discipline-officer` | `viewGroupReports`, `approveReport`, `manageReports` | `["bullying", "conduct"]` |
| `member` | none | n/a |

### Open questions

1. Exact MONHS `categoryId` for guidance/counseling — not in default seed list; org may add `guidance` and update role.
2. `viewAllReports` for non-admin = all reports **within allowed categories** (documented above).
3. `org-admin`: null `allowedCategoryIds` = unrestricted — **confirmed**.
4. Reports: `tagScope` on custom capabilities **ignored** for v1 enforcement.
5. `viewGroupReports`: category scoping sufficient for v1 triage.
6. `approveReport` vs `manageReports`: rules accept either for update; UI shows manage actions when user has `manageReports`; status-to-closed also allowed with `approveReport`.

---

## Migration

Re-run `seed_roles.js` or in-app **Seed Default Roles** to merge `allowedCategoryIds` onto starter roles. Admins should review custom roles created before Sprint 16 — missing field means no report access until categories are assigned.

Optional future: org setting `reportCategoryRbacEnforced` for gradual rollout.

---

## Test Matrix (manual smoke)

1. Seed categories; assign Guidance role with `academic` only → User A.
2. Assign Discipline role with `bullying` only → User B.
3. Student submits bullying report → A does not see; B sees and can update.
4. Reverse for academic report.
5. Deep link to out-of-scope report → UI denied + Firestore write fails.
6. Org admin sees all categories.
7. After role save → `refreshMyPermissions` → rules enforce without app restart.
