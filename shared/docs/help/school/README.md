# School Help Source

Canonical reusable help content for school deployments lives in this folder.

Use these files as the maintained source-of-truth for school onboarding and in-app Help Center assets.

| Document | Purpose |
|---|---|
| `MEMBER_GUIDE.md` | Reference guide for approved members |
| `ADMIN_GUIDE.md` | Reference guide for administrators and delegated staff |
| `MEMBER_TUTORIAL.md` | Step-by-step onboarding for first-time members |
| `ADMIN_TUTORIAL.md` | Step-by-step onboarding for first-time administrators |
| `TUTORIAL_QUALITY_CHECKLIST.md` | Mobile-first tutorial quality gate |
| `TUTORIAL_REVIEW_SCORECARD.md` | Fast pass/fail tutorial review sheet |

## Usage model

- Maintain school-generic content here.
- Add org-specific copies only when truly necessary.
- In app, Help Center resolves assets in this order: `orgs/{orgId}` -> `school` -> `_default`.
- Keep labels user-facing in copy and UI, such as **Member Guide** and **Administrator Guide**.

