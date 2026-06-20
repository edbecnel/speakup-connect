# Administrator Tutorial

> Audience: First-time organization administrators and delegated staff  
> Purpose: Learn SpeakUp Connect in a guided sequence before using the full reference guide  
> Use this with: `ADMIN_GUIDE.md` (feature reference)

---

## How to use this tutorial

- Follow modules in order (0 -> 8).
- Complete each **Try this now** task before moving on.
- If you need details, open the matching section in `ADMIN_GUIDE.md`.

### Learning outcomes

By the end of this tutorial, you should be able to:

- explain who can do what (roles and capabilities)
- onboard members and manage roster basics
- run announcements, alerts, and approval workflows
- support language selection and translation moderation
- use the web Translation Helper for translation operations

---

## Module 0 - Orientation

### Goal
Understand your admin scope, environment, and where help lives.

### You will learn
- difference between org admin and delegated staff
- where to find admin menus
- how this tutorial differs from the reference guide

### Try this now
1. Open **Settings** and confirm you can see **Administration**.
2. Open `ADMIN_GUIDE.md` and skim section headings.
3. Note which menu items are visible in your account.

### Read more (reference)
- `ADMIN_GUIDE.md` -> **Administration menu**
- `shared/docs/RBAC_ARCHITECTURE.md`

---

## Module 1 - Roles and capabilities first

### Goal
Interpret role-based visibility so missing menu items do not cause confusion.

### You will learn
- role vs capability
- why two admins may see different menus
- minimum capabilities for common tasks

### Try this now
1. Open **Roles & Permissions**.
2. Identify one role with report access and one with translation access.
3. Record the capabilities each role includes.

### Checkpoint
- I can explain why a user sees (or does not see) a specific admin screen.

### Read more (reference)
- `ADMIN_GUIDE.md` -> **Roles and permissions**
- `shared/docs/RBAC_ARCHITECTURE.md`

---

## Module 2 - Member onboarding workflow

### Goal
Process incoming users safely and consistently.

### You will learn
- join application review
- approve vs reject decision points
- first login expectations for approved members

### Try this now
1. Open **Join Applications**.
2. Review one pending application.
3. Approve or reject using documented criteria.
4. Confirm expected user outcome.

### Checkpoint
- I can onboard a new member end-to-end.

### Read more (reference)
- `ADMIN_GUIDE.md` -> **Join applications**
- `MEMBER_GUIDE.md` -> **Signing in**

---

## Module 3 - Member management essentials

### Goal
Manage enrolled users (status, profile, password, and school-specific fields where enabled).

### You will learn
- block/unblock/unenroll/re-enroll
- edit profile fields and constraints
- reset password flow and communication

### Try this now
1. Open **Member Management**.
2. Edit a test member profile.
3. Perform a password reset using one approved method.
4. Verify the member can sign in with expected credentials.

### Checkpoint
- I can recover account access without breaking profile integrity.

### Read more (reference)
- `ADMIN_GUIDE.md` -> **Member management**

---

## Module 4 - Groups and clubs lifecycle

### Goal
Set up and maintain healthy group operations.

### You will learn
- create/edit groups
- assign leaders vs display positions
- process join/leave requests

### Try this now
1. Create or open a test group.
2. Add members and assign one leader.
3. Review at least one join/leave request path.
4. Confirm members can see updates under **My Groups & Clubs**.

### Checkpoint
- I can distinguish permission role (Leader/Member) from club position labels.

### Read more (reference)
- `ADMIN_GUIDE.md` -> **Groups and clubs**

---

## Module 5 - Announcements and alerts

### Goal
Publish information correctly and manage response collection.

### You will learn
- difference: org-wide announcements vs group alerts
- scheduling, expiration, and response options
- approval-dependent publishing behavior

### Try this now
1. Draft one announcement (with optional response request).
2. Draft one group alert (with response settings).
3. Observe what happens when approval is ON vs OFF.

### Checkpoint
- I can choose the correct channel and response settings for a message.

### Read more (reference)
- `ADMIN_GUIDE.md` -> **Announcements**
- `ADMIN_GUIDE.md` -> **Group alerts and approval workflow**

---

## Module 6 - Language basics vs translation moderation

### Goal
Separate member language choice from admin translation operations.

### You will learn
- member-side language switching
- translator moderator assignment (`manageTranslations`)
- translation status model (`missing`, `in_review`, `approved`, etc.)

### Try this now
1. Confirm member language switch path in app.
2. Assign (or review assignment of) a translation moderator role.
3. Open **Translations** and review statuses for one target language.

### Checkpoint
- I can explain "choosing language" vs "editing UI translations."

### Read more (reference)
- `ADMIN_GUIDE.md` -> **UI translations**
- `shared/docs/INTERNATIONALIZATION.md`

---

## Module 7 - Translation Helper workflow

### Goal
Run app + web translation workflow coherently.

### You will learn
- when to use in-app translation UI vs web helper
- import, edit/review, and export flow
- handoff to release pipeline

### Try this now
1. Open Translation Helper and sign in.
2. Filter strings by status and edit one entry.
3. Approve one entry and validate in-app visibility.
4. Perform a test export procedure (or dry run checklist).

### Checkpoint
- I can execute translation operations across app and web tools without mixing roles.

### Read more (reference)
- `speakup_connect_web/tools/translation-helper/README.md`
- `shared/docs/INTERNATIONALIZATION.md`
- `ADMIN_GUIDE.md` -> **UI translations**

---

## Module 8 - Common mistakes and recovery

### Goal
Handle frequent admin pitfalls with confidence.

### You will learn
- why menus disappear (capability mismatch)
- why content is pending (approval enabled)
- why translation actions are unavailable (role/setup gaps)

### Try this now
1. Diagnose one "missing menu item" scenario.
2. Diagnose one "pending publication" scenario.
3. Diagnose one "cannot translate/export" scenario.

### Quick recovery checklist
- confirm role/capability assignment
- re-authenticate if claims changed
- confirm organization settings (approval toggles)
- confirm translation setup prerequisites

---

## Final practical assessment (optional)

Complete the following in a test org/account:

1. Approve a new member
2. Edit profile + reset password
3. Add member to group and assign leader
4. Publish one announcement and one group alert
5. Process one pending approval
6. Review one translation string and mark approved

If you can do all six, you are ready to use `ADMIN_GUIDE.md` as your daily reference.
