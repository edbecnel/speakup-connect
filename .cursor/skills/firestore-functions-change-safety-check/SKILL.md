---
name: firestore-functions-change-safety-check
description: Produces a change-safety checklist and rollback plan for proposed Firebase Firestore + Cloud Functions changes. Use when the user proposes edits to Firestore security rules, Firestore indexes, data model/schema, custom auth claims used for authorization, batched writes/transactions, or Cloud Functions (HTTP/callable/background triggers).
disable-model-invocation: true
---

# Firestore/Functions change safety check

## Verbatim requirements (do not paraphrase)

Skill: “Firestore/Functions change safety check”

Input: proposed change.
Output: checklist of affected rules/claims/indexes/batch limits + “what could break” + rollback plan.

## Operating rules (hard constraints)

1. **Assume production risk unless stated otherwise**
   - Treat the change as if it could impact prod authz, data access, and function execution.
2. **No implementation**
   - Do not write code or config. This skill only produces an analysis + checklist + rollback plan.
3. **Be explicit about “unknowns”**
   - If the proposed change lacks details (collections, queries, claim names, function triggers), list the missing info under the checklist as “Must confirm”.
4. **Prefer backward-compatible rollout plans**
   - If the change touches schema/claims/rules, propose staged rollout (additive → dual-read → tighten → cleanup) when applicable.

## Inputs (what to accept)

Accept a single message containing any of:

- **Proposed change** (required): plain-English description and/or diff excerpt.
- **Environment**: prod/stage/dev; Firebase project(s) involved.
- **Touched areas**: rules, indexes, functions, client queries, schema, claims.
- **Risk tolerance**: “must be zero-downtime”, “ok to brief maintenance window”, etc.

## Workflow (how to produce the safety check)

1. **Normalize the change into “surfaces”**
   - Rules surface: what read/write paths and auth conditions change?
   - Claims surface: what token fields/roles/permissions change?
   - Index surface: what queries change (filters/orderBy/collectionGroup)?
   - Functions surface: what triggers/endpoints change (name, region, runtime, retries)?
   - Limits surface: where do batch/transaction/size/quota constraints apply?
2. **Map dependencies**
   - **Claims ↔ Rules**: where do rules read `request.auth.token.<claim>` (directly or indirectly)?
   - **Rules ↔ Client/Functions**: what reads/writes/queries rely on current rules behavior?
   - **Queries ↔ Indexes**: what composite indexes are required and could be missing post-change?
   - **Functions ↔ Firestore**: do triggers or admin writes create loops, duplicates, or hot paths?
3. **Enumerate break modes**
   - Translate each surface change into concrete failure symptoms (permission denied, missing index, retries/double processing, timeouts, billing spikes).
4. **Produce a rollback plan**
   - Include “fast rollback” (restore previous deployment/config) and “data rollback” (if any irreversible writes/migrations are involved).

## Output format (produce exactly this shape)

Return a single markdown response with **only** these sections, in this order:

### Summary

- **Change intent**: 1–2 sentences.
- **Risk level**: Low / Medium / High (and why, in 1–2 bullets).
- **Primary blast radius**: what user flows / systems are most likely impacted.

### Affected surfaces (rules/claims/indexes/functions/limits)

List what is affected and where to look (repo-relative paths if known; otherwise “unknown”).

- **Rules**:
- **Claims**:
- **Indexes**:
- **Functions**:
- **Batch/transaction limits**:

### Checklist (preflight + rollout)

#### Rules (Firestore security rules)

- [ ] Identify all collections/docs affected (paths + read/write operations).
- [ ] Confirm auth predicates (e.g., org scoping, role checks, ownership checks) still match intended policy.
- [ ] Confirm any new fields used for authz exist on all relevant docs (or are safely defaulted).
- [ ] If tightening rules, plan a staged rollout (log-only/observe → dual-allow → enforce).
- [ ] Emulator validation plan: which reads/writes must be exercised (happy path + negative cases).

#### Claims (custom auth claims / token fields)

- [ ] List current claim names and proposed claim names/shape (including removals/renames).
- [ ] Identify every place claims are read:
  - Rules: `request.auth.token.<...>`
  - Functions/backend: token verification / role checks
  - Client: UI gating (if any)
- [ ] Backward compatibility: if renaming/changing semantics, plan **dual-read** (accept old+new) until all clients are updated.
- [ ] Token propagation risk: users may need to refresh ID tokens to see new claims; plan comms and/or forced refresh.
- [ ] Size risk: confirm claim payload remains within platform limits (see [reference.md](reference.md)).

#### Indexes (Firestore indexes + query shapes)

- [ ] Enumerate query shapes impacted (collection vs collectionGroup, `where` filters, `orderBy`, pagination).
- [ ] For each query shape, confirm whether a composite index is required and present (or will be deployed).
- [ ] Rollout timing: index builds can take time; plan for “missing index” failures between deploy and build completion.
- [ ] Backward compatibility: if changing sort/filter fields, ensure both old and new queries remain supported during rollout.

#### Functions (Cloud Functions / background triggers / HTTP)

- [ ] List functions impacted (name, trigger type, region, runtime generation if known).
- [ ] Retry/dedup: if triggers can retry, ensure processing is idempotent (or include a mitigation plan).
- [ ] Loop risk: if function writes to Firestore, confirm it cannot re-trigger itself (directly or indirectly).
- [ ] Timeout/memory/concurrency: if workload changes, reassess runtime settings and downstream rate limits.
- [ ] Permissions: confirm service account / admin SDK access is appropriate; avoid overbroad access patterns.

#### Batch/transaction limits (hard caps + hot paths)

- [ ] Identify all batched writes / transactions affected (client and functions).
- [ ] Confirm operation counts do not exceed known caps (e.g., **500 writes per batch/transaction**).
- [ ] Confirm payload/document sizes and fan-out patterns are safe for peak traffic (see [reference.md](reference.md)).
- [ ] If near caps, include a mitigation: chunking strategy, backoff, queueing, or a different write model.

#### Observability + release safety

- [ ] Define success metrics and alarms (permission denied spikes, missing index errors, function error rate/latency, Firestore write rates).
- [ ] Ensure logs include correlation identifiers for changed paths/workflows.
- [ ] Define a “stop condition” for rollout (what metric triggers rollback).

### What could break (symptoms + root causes)

Provide a concise list of plausible failures, each with:

- **Symptom**
- **Likely cause**
- **Fast check** (how to confirm quickly)

### Rollback plan

Include both:

- **Fast rollback (minutes)**:
  - What to redeploy/revert first (rules vs functions vs indexes vs clients) to restore service.
  - How to verify rollback success (specific metrics/logs).
- **Safe rollback / cleanup (hours–days)**:
  - How to unwind partially-completed rollouts (incomplete index builds, mixed client versions, dual-claim period).
  - Any data repair steps (if writes/migrations were part of the change).

## Additional resources

- Limits and “gotchas”: see [reference.md](reference.md)
- Output examples: see [examples.md](examples.md)
