# Cursor Rules (project-specific, copy/paste)

## Rule 1 — SpeakUp Connect “non-negotiables” (architecture + multi-tenancy)
Project: SpeakUp Connect (Flutter/Dart + Firebase). Always follow Clean Architecture + feature-based modular structure.

Non-negotiables:
- Multi-tenancy: ALL data access is scoped to `organizationId`.
  - Firestore paths must be under `organizations/{organizationId}/...`
  - Never introduce cross-org queries or global collections for tenant data.
- Dependency direction: Presentation → Domain ← Data.
  - Domain must NOT import from Flutter, Riverpod, Firebase, or Data/Presentation.
- No direct Firebase calls in UI/providers/screens.
  - Firebase calls live in datasources (data layer) → repository impl → domain repo interface → use case → provider/UI.
- Features must NOT import other features directly (use shared/core/router/providers patterns).
- Never hardcode organization-specific names/IDs/branding logic in code.

## Rule 2 — Dart/Flutter conventions for this repo (Riverpod + go_router + lints)
Dart/Flutter standards:
- File names: snake_case.dart. Classes: PascalCase. Providers: camelCase…Provider.
- Prefer `ConsumerWidget` for screens; only use Stateful when truly needed.
- AsyncValue: ALWAYS handle loading/error/data (use AppLoadingIndicator/AppErrorWidget where appropriate).
- Widgets contain no business logic; providers/usecases do the work.
- Route usage:
  - Routes are centralized in `lib/core/router/app_router.dart`.
  - Use named routes/constants; no stringly-typed path concatenation in widgets.
- Localization:
  - No hardcoded user-facing strings in widgets.
  - Add English keys to `speakup_connect_app/lib/l10n/app_en.arb` and use `context.l10n.<key>()`.
- Error handling:
  - Catch Firebase exceptions in datasource/repository and translate to domain Failure types; don’t leak raw Firebase exceptions to UI.
- Keep files/classes small (target ≤300 lines/file, ≤200 lines/class); split when needed.
- Respect analyzer strictness (`analysis_options.yaml`: strict-casts/strict-inference/strict-raw-types).

## Rule 3 — Firestore schema + security expectations (design-time guardrails)
Firestore guardrails (align with shared/docs/DATABASE_DESIGN.md):
- Treat `shared/docs/DATABASE_DESIGN.md` as source of truth for schema fields and collection paths.
- Denormalized orgId fields exist for rules validation; keep them consistent.
- Append-only histories (e.g., report statusHistory / adminNotes): never delete past entries.
- Any privileged actions should be server-authoritative (Cloud Functions / Admin SDK), especially:
  - audit logs
  - notification fanout / feed copies
  - actions that bypass owner-only deletes
- Prefer pagination / bounded reads; avoid unbounded list reads.
- If changing schema, update docs first, then implement.

## Rule 4 — Cloud Functions (TypeScript) conventions for this repo
Firebase Cloud Functions (shared/functions/, Node 20, TS strict):
- Use `firebase-functions/v2` APIs (onCall, Firestore triggers, scheduler) and `HttpsError` for client-facing errors.
- Validate inputs early; return clear `invalid-argument` / `failed-precondition` / `permission-denied`.
- Enforce org scoping in every callable/trigger (orgId from token/body + membership verification).
- Never log secrets or raw tokens. Avoid logging PII unless necessary.
- Prefer idempotent, transactional “claim” patterns for scheduled/triggered fanout work (deliveries, publishing).
- Keep batch sizes under Firestore limits (use chunking; e.g., 450 writes/batch, 500 FCM tokens/multicast).
- Secrets:
  - Translation AI key must come from env (`TRANSLATION_AI_API_KEY`); never hardcode.
  
## Rule 5 — Documentation-first + sprint discipline (how this repo is run)
Workflow rules (shared/docs/AI_DEVELOPMENT_WORKFLOW.md):
- Don’t implement a feature until the documentation exists (or is updated first).
- Only work on tasks in the active sprint (check shared/docs/SPRINT_TRACKER.md).
- Before implementing Firestore logic: re-check shared/docs/DATABASE_DESIGN.md.
- Before committing/merging: `flutter analyze` should be clean; no lint regressions.
- After finishing a task: update shared/docs/SPRINT_TRACKER.md and any affected docs/ADRs/schema docs.

## Rule 6 — Cost-aware agent behavior (how to use AI efficiently in this repo)
Cost + quality policy:
- Default to concise answers and smallest viable changes; avoid “extra features”.
- Prefer targeted file/line references over pasting large files.
- Ask-mode first for design/spec; Agent-mode only after a clear “handoff packet” exists.
- Never do broad repo scans unless necessary; search narrowly (symbol/file) before expanding.
- Do not touch generated/build artifacts in analysis (ignore build/, .dart_tool/, android/.gradle/, android/.cxx/, etc.).
- When uncertain, propose 2–3 options with tradeoffs, then pick the least risky default for MVP.

## “Handoff packet” template (use between Ask → Agent chats)
### Context:
- Feature:
- Layer(s): domain | data | presentation | functions
- Relevant docs sections (paste only the smallest needed excerpts):
- Existing code to match (interfaces/entities/providers):

### Task:
- Implement:

### Acceptance criteria:
- Must:
- Must not:

### Files to create/modify (expected paths):
- lib/features/...:
- shared/functions/src/...:

### Multi-tenancy + security checklist:
- orgId scoping points:
- permissions/claims considerations:

### Test plan:
- flutter analyze:
- unit/widget tests (if any):
- emulator/manual steps:

## Suggested Skills to add (small, reusable, cost-saving)

### Skill: “Spec → Implementation Plan (SpeakUp)”

* Output: the Handoff packet above, plus a minimal file list and test plan.
* Constraint: must cite shared/docs/ as source of truth; no implementation.

### Skill: “Implement Flutter feature slice (Clean Architecture)”

* Input: feature name + layer(s) + interfaces + schema excerpt.
* Output: strictly the files needed (entities/usecases/repos/providers/screens), no cross-feature imports, all strings localized.

### Skill: “Firestore/Functions change safety check”

* Input: proposed change.
* Output: checklist of affected rules/claims/indexes/batch limits + “what could break” + rollback plan.

## Subagent routing guide (optimize for cost)
* Use a lightweight exploration subagent when you need “where is X handled?” across many files (quick pass), then switch back to targeted edits.
* Use a shell-focused subagent only for running builds/tests/emulators and summarizing failures.
* Avoid heavy multi-agent runs unless tasks are independent and you truly need parallelism (e.g., one agent maps Dart flow while another maps Functions flow).
* Run review-type subagents only on a finalized diff (otherwise you pay to review churn).
* If you want, I can tailor these further into separate rule entries per area (Auth/Reports/Groups/Reminders/Translations/RBAC) by extracting the most important invariants from the corresponding lib/features/* modules.