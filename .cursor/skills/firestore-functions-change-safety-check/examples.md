# Examples

## Example 1: Rule tightening + claim rename

**Input (proposed change):**
“Rename custom claim `role` → `roles` (array), update rules to require `roles` contains `org_admin`, and update client queries to read `organizations/{orgId}/reports`.”

**Output (shape example):**

### Summary

- **Change intent**: Migrate from single-role claim to multi-role claims and tighten admin-only access to reports.
- **Risk level**: High
  - Rules + claims change simultaneously; token refresh propagation can break access.
  - Reports access is a core workflow; risk of widespread `PERMISSION_DENIED`.
- **Primary blast radius**: Admin report views; any function that reads reports using the new claim.

### Affected surfaces (rules/claims/indexes/functions/limits)

- **Rules**: `firestore.rules` (unknown exact path)
- **Claims**: `role` → `roles[]`, token reads in rules + backend
- **Indexes**: reports query shape changes (must confirm filters/orderBy)
- **Functions**: any report aggregation/export functions (must confirm)
- **Batch/transaction limits**: none stated (must confirm)

### Checklist (preflight + rollout)

#### Rules (Firestore security rules)

- [ ] Confirm which report docs are protected (paths + org scoping).
- [ ] Confirm rules allow both claim shapes during migration (dual-read).
- [ ] Emulator validation plan: admin allowed, non-admin denied, user with stale token behavior.

#### Claims (custom auth claims / token fields)

- [ ] Dual-read window: accept `role == 'org_admin'` OR `roles` contains `org_admin`.
- [ ] Token refresh plan: force refresh on next app launch or require re-login.
- [ ] Confirm claim size stays within limit (see `reference.md`).

#### Indexes (Firestore indexes + query shapes)

- [ ] List exact report queries (filters + orderBy); verify required composite indexes exist.
- [ ] Plan for missing-index errors during rollout while indexes build.

#### Functions (Cloud Functions / background triggers / HTTP)

- [ ] Find any backend checks using `role`; update plan to dual-read until migration completes.

#### Batch/transaction limits (hard caps + hot paths)

- [ ] N/A unless report updates are batched; confirm none exceed 500 writes.

#### Observability + release safety

- [ ] Monitor `PERMISSION_DENIED` rates and support tickets for admins.
- [ ] Monitor auth token refresh success rate (if instrumented).

### What could break (symptoms + root causes)

- **Symptom**: Admin sees “Missing permissions” / empty reports  
  **Likely cause**: Token still has `role` but rules only read `roles`  
  **Fast check**: Inspect decoded ID token; check rule condition on `request.auth.token`

- **Symptom**: Query fails with “requires an index”  
  **Likely cause**: New filter/orderBy combo needs a composite index  
  **Fast check**: Reproduce query; inspect console error + index suggestion

### Rollback plan

- **Fast rollback (minutes)**:
  - Restore previous rules that accept `role`.
  - Pause rollout of the claim rename if possible.
  - Verify: admin can read reports; permission denied returns to baseline.
- **Safe rollback / cleanup (hours–days)**:
  - Keep dual-read until all clients updated; only then remove legacy `role`.

## Example 2: Function changes + batched writes

**Input (proposed change):**
“Update `onMessageCreated` Firestore trigger to also increment counters on `organizations/{orgId}/stats/{day}` using batched writes.”

Key items your output should call out:

- The trigger loop / hot path risk (high-frequency writes to stats doc).
- The **500 writes per batch/transaction** cap if the counter update fans out to many docs.
- Idempotency/retry handling for background triggers (dedupe key).
- Rollback plan to “disable behavior” quickly (feature flag / config doc) rather than deleting the function.

