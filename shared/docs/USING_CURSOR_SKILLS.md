# Using Cursor Skills effectively (SpeakUp Connect)

This project uses Cursor **Rules** for always-on constraints and Cursor **Skills** for repeatable, on-demand workflows. The goal is to keep chats small, reduce token usage, and prevent scope creep while staying consistent with `shared/docs/`.

## Rules vs Skills (when to use which)

### Use Rules for invariants (always true)
Rules should be short and stable. Examples:
- Clean Architecture boundaries (Presentation → Domain ← Data)
- Multi-tenancy (everything scoped by `organizationId`)
- No direct Firebase calls in UI/providers
- Localization policy (no hardcoded user-facing strings)

**Why**: Rules are injected all the time, so long rules increase cost and noise.

### Use Skills for workflows (run only when needed)
Skills are best for:
- Writing an implementation plan (handoff packet)
- Generating a feature slice scaffold
- Performing a Firestore/Functions change safety check
- Producing a standardized output format

**Why**: You invoke a skill only when you want that behavior/output. This keeps day-to-day chats lightweight.

## How Skills work (mental model)

A Skill is a saved instruction file under `.cursor/skills/<skill-name>/SKILL.md`.  
When you invoke it, Cursor sends:
- the Skill’s instructions (required output format, constraints)
- your message (the “inputs”)

Skills typically do **not** have strict typed parameters. Instead they describe:
- what input is helpful (“Inputs” / “Accept a single message containing…”)
- what to do if input is missing (“choose smallest reasonable default”)
- what the output must look like (“produce exactly this shape”)

## How to invoke a Skill

In Cursor Chat, type:

- `/<skill-name>`
- then add your request in normal language

Example:

- `/spec-to-implementation-plan-speakup`
- `Spec: Add a join-request flow for groups requiring admin approval…`

## Best practice: Minimum viable input (MVI)

Don’t fill out every field the Skill mentions unless the task is complex.

For most work, this is enough:

1. **Goal**: 1–2 sentences describing what you want.
2. **Surface / layer hint**: e.g. “Flutter presentation only” or “Functions + Firestore rules”.
3. **Pointers** to existing docs/code (optional but very helpful):
   - docs: `@shared/docs/DATABASE_DESIGN.md`, `@shared/docs/CODING_STANDARDS.md`, etc.
   - code: `@speakup_connect_app/lib/features/reminders/`, `@shared/functions/src/index.ts`, etc.

### Why pointers help
Pointers reduce search and ambiguity:
- Less time scanning
- Less chance of inventing new patterns
- Lower token usage (cost)

## “Pointers” convention (recommended)

Use short lines like:

- `Relevant docs: @shared/docs/DATABASE_DESIGN.md @shared/docs/ARCHITECTURE.md`
- `Relevant code: @speakup_connect_app/lib/features/groups/ @shared/functions/src/group_membership.ts`

This is not a required format—it’s just an efficient habit.

## When to provide more detail (only when necessary)

Add more detail when any of these are true:
- You’re changing Firestore schema or writing new queries
- You’re touching permissions/RBAC/custom claims/security rules
- The feature spans multiple layers (domain + data + presentation)
- You need strict acceptance criteria

In those cases, provide:
- **Expected Firestore paths + key fields**
- **Exact repository interface / method signatures**
- **Acceptance criteria (must / must not)**
- **Test plan expectations** (even minimal)

## Recommended workflow for low cost + high correctness

### 1) Plan first (Ask-mode / planning skill)
Invoke a planning skill (e.g. `spec-to-implementation-plan-speakup`) with a short spec + pointers.
Result: a “handoff packet” / implementation plan.

### 2) Implement second (Agent-mode / implementation skill)
Start a fresh Agent chat and paste:
- the handoff packet
- 1–2 critical file references (interfaces or example feature)

This keeps the implementation chat narrowly scoped and reduces back-and-forth.

## Skill-specific quick-start (SpeakUp Connect)

### `/spec-to-implementation-plan-speakup` (planning only)
Use when you want:
- a handoff packet
- a structured implementation plan
- a minimal file list and test plan (no code)

Minimum input:

- `Spec: <one paragraph>`
- optionally: `Relevant docs:` and `Relevant code:`

### `/implement-flutter-feature-slice-clean-architecture` (implementation)
Use when you want:
- a new feature slice scaffold/implementation within `lib/features/<feature>/...`

Minimum input (good defaults):
- `Feature name: <feature>`
- `Layers: <domain|data|presentation>`
- `Follow pattern: @lib/features/<similar-feature>/`

Add interfaces/schema only if needed.

### `/firestore-functions-change-safety-check` (risk review)
Use before:
- claims/rules changes
- high-fanout triggers
- new queries/indexes
- batch writes/FCM fanout changes

Minimum input:
- `Proposed change: <2–6 bullets>`
- `Affected areas (if known): rules/claims/functions/indexes`

## Cost control checklist (quick)

Before invoking a Skill, ask:
- Can I reference existing code/docs instead of pasting it?
- Can I keep the spec to one paragraph + 3 bullets?
- Do I really need multiple skills/subagents, or just one?

After receiving output, verify:
- Multi-tenancy (`organizationId`) is enforced everywhere
- Clean Architecture boundaries aren’t violated
- User-facing strings are localization-ready
- No scope creep: only what was requested