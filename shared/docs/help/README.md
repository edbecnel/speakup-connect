# In-App Help — SpeakUp Connect

Help content is resolved by **organization type first**, with `_default` fallback only.

## Canonical structure

```
shared/docs/help/
├── README.md
├── _default/           ← platform fallback docs
└── school/             ← canonical reusable school docs

speakup_connect_app/assets/help/
├── _default/
└── school/
```

School source-of-truth: [`school/`](school/).

## Help Center resolution order

`HelpAssetResolver` loads articles in this order:

1. `assets/help/{organizationType}/{articleName}_{locale}.md`
2. `assets/help/{organizationType}/{articleName}.md`
3. `assets/help/_default/{articleName}_{locale}.md`
4. `assets/help/_default/{articleName}.md`

If `organizationType` is unavailable, the resolver uses `_default` entries only.

## Article labels and catalog

Use user-facing labels in UI and documentation:

- Member Guide
- Administrator Guide
- Member Tutorial
- Administrator Tutorial

## Onboarding guidance

For new schools:

1. Maintain school content in `shared/docs/help/school/`.
2. Keep in-app school assets in `speakup_connect_app/assets/help/school/`.
3. Keep `_default/` as global safety fallback.
4. Do not create `help/orgs/{orgId}` folders or org-specific overrides.

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
