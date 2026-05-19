# AI-Assisted Development Workflow — SpeakUp Connect

---

## Overview

SpeakUp Connect is developed using an **AI-assisted, documentation-first workflow**. GitHub Copilot (and optionally Cursor) are used as development accelerators — not as architects. The developer remains the decision-maker; AI accelerates implementation.

This document describes how to use AI tools effectively within this project's workflow.

---

## Core Workflow Principles

1. **Documentation First** — Never write code for a feature until its documentation exists
2. **Architecture First** — Never implement before the architecture is reviewed
3. **Sprint Discipline** — Only work on tasks in the current active sprint
4. **Prompt with Context** — Always give AI the relevant documentation before asking for code
5. **Review Everything** — AI output must be reviewed against `docs/CODING_STANDARDS.md` before committing

---

## Documentation-First Workflow

Before writing any feature code:

```
1. Check docs/SPRINT_TRACKER.md → Is the task in the current sprint?
2. Read docs/ARCHITECTURE.md → Understand the layer where the code goes
3. Read docs/CODING_STANDARDS.md → Understand naming and structural rules
4. Read docs/DATABASE_DESIGN.md → If writing Firestore code, review the schema
5. Write the code (with AI assistance)
6. Review: Does it follow the architecture? Does it follow the coding standards?
7. Update docs/SPRINT_TRACKER.md → Check off the completed task
```

---

## Sprint Workflow with AI

### Starting a Sprint

```
1. Open docs/SPRINT_TRACKER.md
2. Identify the current sprint and its goals
3. Review all unchecked tasks
4. Start with the highest-priority task
```

### Working on a Task

**Before prompting AI:**

```
1. Identify which feature folder the code belongs to
2. Identify which layer (domain/data/presentation)
3. Identify what already exists (existing entities, interfaces, etc.)
4. Have the relevant docs section open
```

**Good AI prompt pattern:**

```
Context:
- Project: SpeakUp Connect (Flutter, Riverpod, go_router, Firebase)
- Feature: [feature name]
- Layer: [domain | data | presentation]
- Architecture: Clean Architecture with feature-based folders
- Relevant schema: [paste relevant doc section]

Task:
Create [specific class/file] following the conventions in our CODING_STANDARDS.md.

Requirements:
- [list specific requirements]

Existing related code:
- [paste existing entity/interface if relevant]
```

### After AI Generates Code

**Review checklist before accepting:**

- [ ] Does the file path match the folder structure in `docs/FOLDER_STRUCTURE.md`?
- [ ] Does the class name follow the naming conventions in `docs/CODING_STANDARDS.md`?
- [ ] Are there no hard-coded organization names or org-specific logic?
- [ ] Does the domain layer have zero imports from data or presentation layers?
- [ ] Are all `AsyncValue` states handled (loading/error/data)?
- [ ] Are there no direct Firebase calls outside of datasource classes?
- [ ] Are string literals user-facing? If so, should they be localized?

---

## Prompt Engineering Guidelines

### Always Include in Prompts

1. **Project name and stack** — "SpeakUp Connect, Flutter, Riverpod, go_router, Firestore"
2. **Layer context** — "This is the domain layer entity, it must have no dependencies"
3. **Existing interfaces** — Paste the abstract class so the AI implements it correctly
4. **Naming conventions** — Reference the standards file or paste key rules
5. **Multi-tenancy reminder** — "All data must be scoped by `organizationId`"

### Prompt Templates

#### Creating a Use Case

```
Create a Flutter use case class for SpeakUp Connect.

Stack: Flutter, Riverpod, Clean Architecture
Layer: Domain (no Flutter imports, no Firebase imports)
Feature: [feature]

The use case is called [VerbNounUseCase].
It takes [ParamsClass] as input.
It returns [ReturnType].
It calls [RepositoryInterface.method()].

Repository interface:
[paste repository interface]

Follow these naming conventions:
- Class: PascalCase with UseCase suffix
- Params: PascalCase with Params suffix
- File: snake_case.dart
```

#### Creating a Repository Implementation

```
Create a Firestore repository implementation for SpeakUp Connect.

Stack: Flutter, cloud_firestore, Clean Architecture
Layer: Data (implements domain interface)
Feature: [feature]

The implementation class is [FeatureRepositoryImpl].
It implements [FeatureRepository] (interface below).
All Firestore queries MUST include organizationId for multi-tenant isolation.
All Firebase exceptions should be caught and rethrown as domain Failure types.

Repository interface to implement:
[paste interface]

Firestore schema (relevant collection):
[paste schema from docs/DATABASE_DESIGN.md]
```

#### Creating a Screen Widget

```
Create a Flutter screen widget for SpeakUp Connect.

Stack: Flutter, Riverpod (ConsumerWidget), go_router, Material Design 3
Feature: [feature]
Screen name: [NameScreen]

The screen should:
- [list UI requirements based on wireframe]
- Use ConsumerWidget (not StatefulWidget unless local state is needed)
- Use AppButton, AppTextField from shared/widgets/ for consistent styling
- Handle AsyncValue loading/error/data states
- Follow the wireframe layout: [describe layout]

Available providers to watch/read:
- [list relevant providers]

Navigation:
- On [action]: navigate to [route constant]
```

---

## Architecture Review Process

Before implementing any new feature or significant change:

1. **Check `docs/ARCHITECTURE.md`** — Does the planned approach align with the defined architecture?
2. **Check `docs/FOLDER_STRUCTURE.md`** — Where will the new files go?
3. **Check `docs/DATABASE_DESIGN.md`** — If touching Firestore, is the schema already defined?
4. **If something needs to change** — Update the documentation FIRST, then implement

### When to Update Documentation

Update documentation when:
- Adding a new feature not yet in the folder structure
- Changing Firestore schema
- Adding a new dependency
- Changing a naming convention
- Making an architectural decision

---

## Code Review Expectations

All code (human-written or AI-generated) must be reviewed before merging:

### Self-Review Checklist

- [ ] Code compiles without errors (`flutter analyze` passes)
- [ ] No lint warnings (analysis_options.yaml rules pass)
- [ ] Naming follows `docs/CODING_STANDARDS.md`
- [ ] Folder placement follows `docs/FOLDER_STRUCTURE.md`
- [ ] No hard-coded organization names or org-specific strings
- [ ] All user-facing strings are localization-ready
- [ ] No direct Firebase calls outside datasource layer
- [ ] Domain layer has no external dependencies
- [ ] Multi-tenancy: all Firestore queries include `organizationId`
- [ ] Error states are handled in the UI
- [ ] Loading states are handled in the UI
- [ ] `flutter analyze` passes with zero issues

### AI-Generated Code Specific Checks

- [ ] AI did not add features not requested (scope creep)
- [ ] AI did not hardcode organization-specific values
- [ ] AI followed the exact file path specified
- [ ] AI used the correct provider types for the use case
- [ ] AI did not introduce unnecessary dependencies

---

## Task Management Workflow

### Daily Workflow

```
1. Open docs/SPRINT_TRACKER.md
2. Review current sprint's task list
3. Pick the next unchecked task
4. Mark it [~] in progress
5. Implement it (with AI assistance as needed)
6. Self-review against checklist
7. Mark it [x] done in SPRINT_TRACKER.md
8. Commit with conventional commit message
9. Repeat
```

### Weekly Workflow

```
1. Review all completed tasks against sprint goals
2. Update docs/SPRINT_TRACKER.md with blockers and notes
3. Update docs/MASTER_TASK_LIST.md checkbox statuses
4. If sprint is complete: close sprint, plan next sprint
5. Update README.md project status if milestone reached
```

### Sprint Planning

At the start of each sprint:
1. Copy relevant tasks from `docs/MASTER_TASK_LIST.md` into a new sprint block in `docs/SPRINT_TRACKER.md`
2. Assign sprint number and date range
3. Define sprint goal in one sentence
4. Define "Definition of Done" criteria

---

## GitHub Copilot — VS Code Configuration

### Recommended Copilot Settings for This Project

In `.vscode/settings.json`:

```json
{
  "github.copilot.chat.codeGeneration.useInstructionFiles": true,
  "github.copilot.chat.reviewSelection.enabled": true
}
```

### Using Copilot Chat Effectively

**Provide context in the chat:**
- Open the relevant docs file alongside your code file
- Reference the architecture doc when asking structural questions
- Paste relevant schema or interface when asking for implementations

**Useful Copilot Chat commands for this project:**
- `/explain` — Use on any unfamiliar generated code
- `/tests` — Generate unit tests for a use case or repository
- `/fix` — Fix lint errors in AI-generated code

---

## Version Control for Documentation

Documentation is version-controlled alongside code. When updating docs:

```bash
# Docs-only commit
git commit -m "docs: update SPRINT_TRACKER with Sprint 2 tasks"

# Docs + code commit (document the decision)
git commit -m "feat: add org config loading on app startup

- Implements LoadOrganizationConfigUseCase
- Updates app_router.dart to guard until config is loaded
- Documents org loading sequence in ARCHITECTURE.md"
```
