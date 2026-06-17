---
name: spec-to-implementation-plan-speakup
description: Converts a feature spec into an implementation plan for SpeakUp Connect (Flutter + Firebase) using shared/docs/ as the source of truth. Use when the user asks for a handoff packet, implementation plan, design-to-build breakdown, minimal file list, or test plan. Must cite shared/docs/ for architectural rules, folder placement, standards, and schema; do not implement or edit code.
disable-model-invocation: true
---

# Spec → Implementation Plan (SpeakUp)

## Verbatim requirements (do not paraphrase)

Skill: “Spec → Implementation Plan (SpeakUp)”

Output: the Handoff packet above, plus a minimal file list and test plan.

Constraint: must cite shared/docs/ as source of truth; no implementation.

## Operating rules (hard constraints)

1. **Docs-first, docs-only source of truth**
   - Treat `shared/docs/` as authoritative for architecture, folder placement, and workflow.
   - If the spec conflicts with `shared/docs/`, surface it as a conflict and propose the doc-aligned option.
2. **No implementation**
   - Do not write or modify code.
   - Do not propose copy/pastable code blocks (pseudocode is OK if it’s non-executable and high level).
3. **Citations required**
   - Every major decision or invariant in the plan must cite its source in `shared/docs/`.
   - Use this citation format inline: **(Source: `shared/docs/<FILE>.md` → <section heading>)**

## Minimal docs to consult (expand only as needed)

- `shared/docs/PROJECT_OVERVIEW.md` (product + multi-tenant framing)
- `shared/docs/ARCHITECTURE.md` (Clean Architecture layers, multi-tenancy, Firebase boundaries)
- `shared/docs/FOLDER_STRUCTURE.md` (canonical paths and feature module layout)
- `shared/docs/CODING_STANDARDS.md` (naming, layering rules, localization rule)
- `shared/docs/AI_DEVELOPMENT_WORKFLOW.md` (documentation-first workflow + review checklist)
- `shared/docs/DATABASE_DESIGN.md` (Firestore schema; only if data is touched)
- `shared/docs/RBAC_ARCHITECTURE.md` (permissions/claims; only if access control is touched)
- `shared/docs/SECURITY_AND_PRIVACY.md` (privacy constraints; only if relevant)
- `shared/docs/INTERNATIONALIZATION.md` (only if user-facing strings change)
- `shared/docs/SPRINT_TRACKER.md` (sprint alignment and scope discipline)

## Output: “Handoff Packet” template (produce exactly this shape)

Return a single markdown document with these sections, in this order.

### 1) Summary

- **Goal**: 1–2 sentences.
- **User value**: 1–2 bullets.
- **Sprint alignment**: Is this in the active sprint? If unknown, state what must be checked.  
  (Source: `shared/docs/AI_DEVELOPMENT_WORKFLOW.md` → Documentation-First Workflow; `shared/docs/SPRINT_TRACKER.md` → Active Sprint)

### 2) Requirements (from the spec)

- **Must-have**
- **Should-have**
- **Won’t-do / out of scope** (explicitly list)

### 3) Constraints & invariants (doc-derived)

List the non-negotiables that shape the implementation plan, each with a citation:

- **Multi-tenancy scoping** (organization-scoped data access)  
  (Source: `shared/docs/ARCHITECTURE.md` → Multi-Tenant Architecture)
- **Layer boundaries** (Presentation → Domain ← Data; no Firebase calls in UI/providers)  
  (Source: `shared/docs/CODING_STANDARDS.md` → Architecture Rules; `shared/docs/ARCHITECTURE.md` → Clean Architecture Layers)
- **Feature folder rules** (no feature-to-feature imports; shared vs feature widgets)  
  (Source: `shared/docs/FOLDER_STRUCTURE.md` → Folder Conventions)
- **Localization rule for user-facing strings** (English ARB is source of truth)  
  (Source: `shared/docs/CODING_STANDARDS.md` → String Localization)

Add any others that apply (RBAC, privacy, performance, etc.) with citations.

### 4) Proposed approach (high-level design)

Describe the approach at the level of:

- **Feature name** (where it lives under `lib/features/<feature>/`)
- **Layer-by-layer responsibilities**
  - **Domain**: entities, repository interfaces, use cases
  - **Data**: models, datasources, repository impls
  - **Presentation**: providers, screens, widgets
  (Source: `shared/docs/ARCHITECTURE.md` → Feature Module Structure; `shared/docs/FOLDER_STRUCTURE.md` → Full Folder Tree)

If the spec implies cross-feature interaction, describe how it routes through **shared providers** or **router**, not direct imports.  
(Source: `shared/docs/FOLDER_STRUCTURE.md` → `features/` — Business Features)

### 5) Data model / schema impact (only if applicable)

- **Firestore collections/documents touched** (use org-scoped paths)
- **New fields** (name, type, meaning, default)
- **Indexes** (if queries require them)
- **Backward compatibility / migration**

All items must cite `shared/docs/DATABASE_DESIGN.md` (and/or the specific doc that defines the schema).

### 6) Permissions / RBAC impact (only if applicable)

- **Who can do what** (capability-level)
- **Security rule implications** (high level)
- **Custom claims / role assignment impact** (if any)

(Source: `shared/docs/ARCHITECTURE.md` → Role-Based Access Control; `shared/docs/RBAC_ARCHITECTURE.md`)

### 7) UX / flows (only what’s needed to implement)

- **Entry points** (navigation / routes involved)
- **Primary happy path**
- **Error states and empty states**
- **Loading states**

If routes/guards matter, cite router guidance.  
(Source: `shared/docs/ARCHITECTURE.md` → Navigation: go_router)

### 8) Edge cases, risks, and mitigations

- **Edge cases** (bullets)
- **Risks** (bullets)
- **Mitigations** (bullets)

### 9) Open questions (blockers)

List unanswered decisions as questions. If a doc implies an answer, point to it; otherwise mark as “needs product decision.”

### 10) Minimal file list (required)

Provide the smallest set of files expected to change, grouped by layer, using repo-relative paths and following `shared/docs/FOLDER_STRUCTURE.md`.

Format:

- **Create**
  - `lib/features/<feature>/domain/...`
  - `lib/features/<feature>/data/...`
  - `lib/features/<feature>/presentation/...`
- **Modify**
  - `lib/core/...` (only if truly cross-cutting)
  - `lib/shared/...` (only if truly shared)
- **No changes expected**
  - (List notable areas explicitly excluded to prevent scope creep)

(Source: `shared/docs/FOLDER_STRUCTURE.md` → Full Folder Tree; `shared/docs/ARCHITECTURE.md` → Feature Module Structure)

### 11) Test plan (required; no code)

Include only tests and verification steps that are necessary and minimal:

- **Unit tests** (domain/use cases; what to mock; key cases)
- **Widget tests** (screens/widgets; states: loading/error/data)
- **Integration / manual smoke** (1–2 critical end-to-end paths)
- **Static checks** (what to run; keep it minimal)

Test guidance must align with Clean Architecture testability goals.  
(Source: `shared/docs/ARCHITECTURE.md` → Architecture Philosophy; `shared/docs/AI_DEVELOPMENT_WORKFLOW.md` → Self-Review Checklist)

### 12) Sources consulted (required)

List every `shared/docs/*.md` file you relied on (no external sources).

## Quality bar (final self-check)

Before returning the handoff packet, verify:

- Every section is present (even if “N/A”).
- Every major design constraint has a `shared/docs/` citation.
- File paths match `shared/docs/FOLDER_STRUCTURE.md`.
- No implementation/code was produced.

## Example (tiny)

**Input (spec excerpt):**
“Add a join-request flow for groups with admin approval.”

**Output (expectation):**
A filled Handoff Packet that cites `shared/docs/GROUP_JOIN_REQUESTS.md` for requirements, `shared/docs/DATABASE_DESIGN.md` for schema paths, and `shared/docs/FOLDER_STRUCTURE.md` for the minimal file list.

