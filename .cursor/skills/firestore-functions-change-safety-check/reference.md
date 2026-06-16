# Reference: Firestore + Cloud Functions change safety

Keep this page as “commonly-forgotten constraints” and pointers. Prefer verifying exact numbers against current Firebase docs for your project.

## Common platform limits to explicitly check

- **Batched writes / transactions**
  - **500** write operations per `WriteBatch` and per transaction (hard cap).
  - Partial failure behavior: a batch is all-or-nothing for commit, but your app may create multiple batches; ensure retries don’t duplicate side effects.
- **Custom auth claims**
  - Custom claims payload is **size-limited** (commonly documented as **≤ 1000 bytes** total). Treat claim bloat as a breaking change risk.
  - Claims update propagation requires ID token refresh; users may appear “stuck” on old permissions until refresh.
- **Document size**
  - Firestore documents have a hard size limit (commonly **1 MiB**). Fan-out writes that add arrays/maps can grow unexpectedly.
- **Index build latency**
  - Composite indexes may take minutes to hours to build. During builds, queries can fail with “requires an index”.

## Rule-change break patterns

- **Renaming/removing fields used in rules**
  - Example: rules check `resource.data.organizationId` but the field is renamed → widespread `PERMISSION_DENIED`.
- **Authz predicate moved from server to client (or vice versa)**
  - Can silently expand access or break legitimate access.
- **Introducing stricter validation without migrating existing docs**
  - Old docs fail validation on update, blocking edits.

## Index/query break patterns

- **Adding `orderBy` to a query**
  - Frequently introduces a composite index requirement when combined with multiple `where` clauses.
- **Switching to collection group queries**
  - Index requirements differ; rules often need to allow access across multiple parent paths.
- **Changing pagination fields**
  - If the cursor field changes, old clients may page incorrectly or error.

## Functions break patterns

- **Background triggers + retries**
  - Retries can cause duplicate processing unless idempotent.
- **Trigger loops**
  - A function that writes back into the same collection (or a downstream collection) can create cascading triggers.
- **Breaking changes to callable/HTTP contracts**
  - Client versions diverge; prefer versioned endpoints or backward-compatible payload parsing.

## Rollback heuristics

- **Prefer “disable behavior” over “delete function”**
  - For trigger functions, deploy a guard (feature flag / env var / config document) that exits early to stop damage quickly.
- **Rules rollback is fast; index rollback is slow**
  - Rules publish quickly; index changes may take time to converge. Plan rollback order accordingly.
- **Staged claim migrations**
  - Dual-read window, then remove old claims only after all clients and rules have been updated and token refresh propagation is accounted for.

