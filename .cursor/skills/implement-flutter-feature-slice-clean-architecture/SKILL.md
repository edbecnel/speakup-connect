---
name: implement-flutter-feature-slice-clean-architecture
description: Implement a new Flutter feature slice in SpeakUp Connect using per-feature Clean Architecture (domain/data/presentation) and Riverpod providers. Use when the user asks to scaffold or implement a new feature module, feature slice, vertical slice, or clean-architecture feature folder; when they provide a feature name, desired layers, interfaces/contracts, and a schema excerpt. Enforces no direct feature-to-feature imports, minimal file output, and localization via app_en.arb + context.l10n for all user-facing strings.
disable-model-invocation: true
---

# Implement Flutter feature slice (Clean Architecture)

## Verbatim requirements (do not paraphrase)

Skill: “Implement Flutter feature slice (Clean Architecture)”

Input: feature name + layer(s) + interfaces + schema excerpt.
Output: strictly the files needed (entities/usecases/repos/providers/screens), no cross-feature imports, all strings localized.

## Operating rules (hard constraints)

1. **Docs-first source of truth**
   - Use `docs/` as authoritative for folder placement, layer boundaries, naming conventions, Riverpod usage, and localization workflow.
   - Minimum docs to consult:
     - `docs/ARCHITECTURE.md`
     - `docs/FOLDER_STRUCTURE.md`
     - `docs/CODING_STANDARDS.md`
     - `docs/INTERNATIONALIZATION.md` (if any UI strings are involved)
2. **Clean Architecture dependency direction**
   - Dependencies flow inward only: **Presentation → Domain ← Data**.
   - **Domain** must not import from **Data** or **Presentation**.
3. **No cross-feature imports**
   - Do not import from `lib/features/<other_feature>/...` anywhere in the generated slice.
   - If the feature needs shared infrastructure/state, route through `lib/core/` and/or `lib/shared/` only.
4. **Output must be minimal and file-scoped**
   - Only create/modify what is necessary for the requested slice.
   - Output must be restricted to:
     - entities (`domain/entities/`)
     - use cases (`domain/usecases/`)
     - repositories (`domain/repositories/` and optionally `data/repositories/`)
     - providers (`presentation/providers/`)
     - screens (`presentation/screens/`)
   - Do not create feature widgets unless explicitly requested.
5. **All user-facing strings localized**
   - No hardcoded user-facing strings in screens/providers.
   - Use `context.l10n.<key>` (extension in `lib/core/l10n/app_localizations_extension.dart`).
   - If new strings are required, include a **minimal** edit to `lib/l10n/app_en.arb` (US English source of truth) and reference only those keys in Dart.

## Inputs (what to ask for / accept)

Accept a single message containing:

- **Feature name**
  - Example: `groups`, `report_feedback`, `join_requests`
- **Layer(s)**
  - Any subset of: `domain`, `data`, `presentation`
- **Interfaces**
  - Repository contract(s) and method signatures, or a short “API” list.
  - Example:
    - `GroupRepository.watchMyGroups({required String organizationId, required String userId}) -> Stream<List<GroupEntity>>`
    - `GroupRepository.requestToJoinGroup({required String organizationId, required String groupId}) -> Future<void>`
- **Schema excerpt**
  - Firestore path(s), document fields (types + required/optional), enums, and any invariants.
  - Example:
    - `organizations/{orgId}/groups/{groupId}: { name: string, createdAt: timestamp, ... }`

If information is missing, choose the smallest reasonable default that fits `docs/` (do not invent large new concepts).

## Workflow (implementation steps)

1. **Normalize naming**
   - Feature folder: `lib/features/<feature>/` where `<feature>` is lowercase snake_case if multi-word.
   - File naming: `snake_case.dart`. Class naming: `PascalCase` with repo-standard suffixes.
2. **Determine the minimal slice**
   - Generate only the layers the user requested.
   - Generate only the entities/use cases/repositories/providers/screens needed to satisfy the interfaces and a basic UI entry screen if `presentation` is requested.
3. **Domain (entities / repositories / use cases)**
   - Build **entities** directly from the schema excerpt. Use `const` constructors and `final` fields.
   - Create a **repository interface** in `domain/repositories/<feature>_repository.dart` that matches the provided interfaces exactly.
   - Create **one use case per operation** in `domain/usecases/` (single-responsibility, verb phrase naming).
   - Use a params object when an operation needs multiple inputs.
4. **Data (repository implementation) — only if `data` requested**
   - Implement the domain repository interface in `data/repositories/<feature>_repository_impl.dart`.
   - Keep Firebase/API details out of presentation.
   - Do not add new datasources/models unless explicitly requested; keep the data layer minimal.
5. **Presentation (providers / screens) — only if `presentation` requested**
   - Use Riverpod 2.x patterns consistent with the repo (annotation/codegen if that’s what the feature uses).
   - Providers live in `presentation/providers/` and may depend on domain use cases and repository providers.
   - Screens live in `presentation/screens/`.
   - Handle async UI using `AsyncValue.when(...)` and shared widgets from `lib/shared/widgets/` where appropriate.
6. **Localization**
   - If the screen needs any visible text (titles, button labels, empty/error copy), add keys to `lib/l10n/app_en.arb` and reference via `context.l10n`.
   - Prefer reusing existing `common*` keys when they semantically match.
7. **Self-check before returning**
   - No imports from other feature folders.
   - Domain imports no data/presentation.
   - No hardcoded user-facing strings in presentation files.
   - File paths match `docs/FOLDER_STRUCTURE.md`.

## Output format (produce exactly this shape)

Return a single markdown response with **only** these sections, in this order:

### Create

- List repo-relative file paths to create, grouped by layer (domain/data/presentation).
- For each file path, include its full contents in a code block immediately after the path.

### Modify (only if required)

- List repo-relative file paths to modify (typically only `lib/l10n/app_en.arb`).
- Include the smallest possible patch-like snippet (added keys only) and nothing else.

### Notes (only if truly necessary)

- Only include notes for unavoidable constraints, mismatches, or TODOs forced by missing input.

## Example inputs/outputs

See [examples.md](examples.md).

