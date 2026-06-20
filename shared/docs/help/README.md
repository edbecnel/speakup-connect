# In-App Help — SpeakUp Connect

Help content is organized around a reusable **canonical school source** with optional org overrides.

## Canonical structure

```
shared/docs/help/
├── README.md
├── _default/           ← platform fallback docs
├── school/             ← canonical reusable school docs
└── orgs/{orgId}/       ← optional org-specific overrides

speakup_connect_app/assets/help/
├── _default/
├── school/
└── orgs/{orgId}/       ← optional overrides only when necessary
```

School source-of-truth: [`school/`](school/).

## Help Center resolution order

`HelpAssetResolver` loads articles in this order:

1. `assets/help/orgs/{organizationId}/{articleName}_{locale}.md`
2. `assets/help/orgs/{organizationId}/{articleName}.md`
3. `assets/help/school/{articleName}_{locale}.md`
4. `assets/help/school/{articleName}.md`
5. `assets/help/_default/{articleName}_{locale}.md`
6. `assets/help/_default/{articleName}.md`

This preserves fallback behavior while removing the need for per-org school duplication.

## Article labels and catalog

Use user-facing labels in UI and documentation:

- Member Guide
- Administrator Guide
- Member Tutorial
- Administrator Tutorial

## Onboarding guidance

For new schools:

1. Start from `shared/docs/help/school/`.
2. Add `shared/docs/help/orgs/{orgId}/` only for true org-specific policy differences.
3. Add matching `assets/help/orgs/{orgId}/` assets only when overrides are required.
4. Keep `_default/` as global safety fallback.

## Sync workflow

When help content changes:

1. Update canonical docs in `shared/docs/help/school/` (or `_default/` if global).
2. Mirror corresponding in-app markdown under `speakup_connect_app/assets/help/`.
3. Restart `flutter run` after asset path changes.

Legacy root shim files (`assets/help/member_guide.md`, `assets/help/admin_guide.md`) remain for hot-restart compatibility.

## Related docs

- [school/README.md](school/README.md)
- [ONBOARDING_NEW_SCHOOL.md](../ONBOARDING_NEW_SCHOOL.md)
- [CLIENT_BUILDS.md](../CLIENT_BUILDS.md)
