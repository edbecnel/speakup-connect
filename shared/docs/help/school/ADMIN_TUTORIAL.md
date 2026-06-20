# Administrator Tutorial

Audience: First-time school administrators and delegated staff.

Run modules in order. Keep this tutorial mobile-friendly and actionable.

---

## Module 1 - Roles and capabilities first

### Goal
Understand role-based access so you can quickly explain why menus/actions appear (or do not appear) for each staff account.

### Who should complete this module
- **Org Admins** (required)
- **Delegated staff** who manage reports, groups, approvals, or translations

### What you will learn
- role vs capability in practical terms
- why two admin/staff users may see different menus
- how to verify and correct access setup
- common permission mistakes and how to fix them

### Before you start
Confirm these first:
1. You are signed in with your admin/staff account.
2. You can open **Settings**.
3. You have access to your school's role assignment workflow.

---

### Core concept: role vs capability

- A **role** is a named bundle (example: "Guidance Staff", "Translator Moderator").
- A **capability** is the actual permission that unlocks an action/menu.
- UI visibility depends on capabilities, not the role name itself.

**Example**
Two users may both be called "staff," but only the one with `manageTranslations` sees translation tools.

---

### Step 1 - Identify what you can currently access
1. Open **Settings -> Administration**.
2. List which admin items you can see.
3. Note missing items you expected to have.

Use this as your baseline before making permission changes.

---

### Step 2 - Inspect role assignments
1. Open **Roles & Permissions** (or equivalent admin path in your build).
2. Find your user account assignment.
3. Record:
   - assigned role names
   - included capabilities
4. Compare assigned capabilities against the tasks you need to perform.

---

### Step 3 - Map tasks to required capabilities
For each task your school expects you to do, confirm the matching capability exists in your assigned role.

Common examples:
- report triage/review
- group roster management
- approval queue actions
- translation moderation (`manageTranslations`)

If a task is required but capability is missing, request role update from Org Admin.

---

### Step 4 - Validate changes after role updates
After role/capability changes:
1. Sign out.
2. Sign back in.
3. Re-open **Settings -> Administration**.
4. Confirm expected menu items/actions now appear.

If not updated, verify role assignment saved correctly and retry.

---

### Visibility troubleshooting: "Why don't I see this menu?"

Check in this order:
1. Correct account? (not personal/member-only login)
2. Correct org context?
3. Capability actually assigned in role?
4. Re-authentication done after role change?
5. Feature enabled for this tenant?

---

### Capability troubleshooting: "I see menu but action fails"

Possible causes:
- You can open the screen but lack a specific action capability.
- Item requires higher privilege (Org Admin-only flow).
- Data condition prevents action (status/state rules).
- Pending claim refresh after role change.

Action:
1. Capture exact action and error message.
2. Re-check role capabilities.
3. Re-authenticate.
4. Escalate to Org Admin/deployment lead if mismatch persists.

---

### Common mistakes to avoid
- Assuming role title alone guarantees access.
- Granting broad admin access when a single capability is enough.
- Forgetting sign out/sign in after role updates.
- Debugging menu visibility before confirming correct account/org.
- Creating duplicate role names with inconsistent capabilities.

---

### Quick role-design guidance (least privilege)
Use the minimum capability set needed for each job function:
- Keep **Org Admin** limited to true admin owners.
- Create focused delegated roles (reports-only, groups-only, translation-only).
- Review role assignments periodically (start/end of term).

---

### Try this now (practice)
1. Pick one delegated staff user.
2. Define two tasks they must perform.
3. Verify role includes needed capabilities.
4. Test visibility/action in app.
5. Remove any unnecessary capabilities.

---

### Scenario check
A staff member says: "I can open Administration, but I can't access Translations."

What should you verify first?

**Expected response order:**
1. Confirm staff account and org context.
2. Check assigned role includes `manageTranslations`.
3. Have user sign out/sign back in after any role change.
4. Confirm translation feature is enabled in current environment.

---

### Optional deep dive
Need complete permission reference? Open **Help Center -> Administrator Guide** and review the roles/permissions section.

---

## Module 2 - Member onboarding workflow

### Goal
Process new member applications consistently so only valid users are approved and account setup issues are minimized.

### Who can do this
- **Org Admin:** typically owns final approval/rejection decisions.
- **Delegated staff:** may assist review only if granted appropriate access.
- If you do not see **Join Applications**, ask an Org Admin to confirm your role/capabilities.

### What you will learn
- how to review pending applications
- when to **Approve**, **Reject**, or **Hold for verification**
- what to communicate to applicants after a decision
- how to avoid common onboarding mistakes

### Before you start
Confirm these first:
1. Your school's acceptance criteria are documented (who is eligible to join).
2. You know required identity fields (student ID, name format, email rules, etc.).
3. You have a process for handling uncertain or incomplete applications.

---

### Core concept: onboarding quality affects everything later

A rushed approval creates downstream issues:
- duplicate accounts
- wrong student ID mappings
- avoidable password-reset/support requests
- cleanup work in Member Management

A careful review now saves significant admin time later.

---

### Step 1 - Open and triage pending applications
1. Open **Settings -> Administration -> Join Applications**.
2. Review pending entries one by one.
3. For each application, verify:
   - full name
   - student ID (if required by your school)
   - contact email (if used)
   - any school-specific required fields

Tag each as:
- **Ready to approve**
- **Needs verification**
- **Reject**

---

### Step 2 - Apply decision criteria

#### Approve when
- applicant matches school eligibility policy
- required identity fields are valid and complete
- no obvious duplicate/conflict with existing records

#### Reject when
- applicant is ineligible under school policy
- critical data is invalid/fraudulent
- duplicate or conflict cannot be resolved safely

#### Hold for verification when
- information is incomplete but potentially valid
- identity conflict requires manual check
- school office confirmation is pending

**Tip:** If your UI has only Approve/Reject, use your internal process to track "hold" items before final action.

---

### Step 3 - Complete decision and communicate outcome
1. Approve or reject in **Join Applications**.
2. If rejecting, provide clear reason text (when supported by UI).
3. Record internal notes if your process requires audit trail.
4. Communicate next steps to applicant where appropriate.

---

### Applicant communication guidance

After **Approve**, communicate:
- account is now active
- how to sign in (student ID/email + password)
- where to get help if sign-in fails

After **Reject**, communicate:
- clear reason (policy-based, not personal)
- correction or appeal path if your school allows it

For **Verification pending** (internal hold):
- expected timeline
- what additional info is required

---

### Duplicate and conflict handling

If you suspect duplicate identity:
1. Search existing members first.
2. Compare student ID/email/name carefully.
3. Avoid approving duplicate account entries.
4. Resolve with school records owner before final decision.

If duplicate was already approved, resolve in **Member Management** promptly.

---

### If you do not see Join Applications
Check in this order:
1. Correct account signed in?
2. Role includes join-application capability?
3. Re-authentication completed after role updates?
4. Feature enabled in this tenant's config/policy?

---

### Troubleshooting: "Applicant says still pending after approval"

1. Re-open **Join Applications** and confirm final status saved.
2. Confirm you approved the correct applicant record.
3. Ask applicant to sign out/in or retry login.
4. Verify applicant uses correct identifier (student ID/email).
5. If issue persists, check for duplicate/conflicting member records.

---

### Common mistakes to avoid
- Approving without checking student ID conflicts.
- Rejecting without clear reason when reason field is available.
- Using approval queue as long-term backlog (no triage discipline).
- Assuming approval instantly solves all sign-in problems.
- Forgetting to align decisions with school policy owner.

---

### Quick onboarding checklist (per applicant)
- [ ] Eligibility confirmed
- [ ] Required fields valid
- [ ] No duplicate/conflict found
- [ ] Correct decision applied
- [ ] Applicant communication sent (or queued)

---

### Try this now (practice)
1. Open **Join Applications**.
2. Review three pending applications.
3. Classify each as approve/reject/verify.
4. Complete one approval and one rejection using policy-based reasoning.
5. Confirm final statuses and expected applicant outcomes.

---

### Scenario check
An application has a valid name but a student ID that already exists on another active account.

What should you do first?

**Expected response order:**
1. Pause approval and mark for verification.
2. Confirm conflict against school records.
3. Resolve which identity record is authoritative.
4. Only then approve/reject with documented reason.

---

### Optional deep dive
Need full feature reference? Open **Help Center -> Administrator Guide**.

---

## Module 3 - Member management essentials

### Goal
Manage member accounts safely and consistently, including profile updates, access status changes, and password recovery.

### Who can do this
- **Org Admin:** full access to member management actions.
- **Delegated staff:** may have partial access depending on assigned capabilities.
- If you do not see **Member Management**, ask an Org Admin to review your role/capabilities.

### What you will learn
- how to find and edit member records
- when to use **Block**, **Unenroll**, or **Re-enroll**
- how to reset passwords without creating sign-in confusion
- how to handle common account access issues

### Before you start
Confirm these first:
1. You are signed in with an account that has member-management access.
2. You know your school’s policy for blocking and unenrolling users.
3. You have a secure way to communicate temporary/new passwords.

---

### Steps: open and review a member record
1. Open **Settings -> Administration -> Member Management**.
2. Search by name, student ID, or email.
3. Open the member row to view profile and status.
4. Confirm identity details before making changes:
   - Full name
   - Student ID (username)
   - Contact email
   - Grade (if enabled)

**Tip:** Always verify you opened the correct record before resetting a password or changing access status.

---

### Steps: edit profile safely
1. Open the member profile from **Member Management**.
2. Update only required fields (name, contact email, grade, etc.).
3. Save changes.
4. Tell the member what changed (especially login-related changes).

**Important**
- Student ID is usually a controlled school identifier.
- Avoid changing multiple identity fields at once unless required by policy.

---

### Decision guide: Block vs Unenroll vs Re-enroll

Use this quick rule set:

- **Block** when:
  - access must be temporarily or immediately restricted
  - member record should remain active in school systems
  - you may restore access later

- **Unenroll** when:
  - member is no longer part of the organization
  - account should be removed from active org access

- **Re-enroll / Unblock** when:
  - the member is returning or restriction is resolved
  - school policy confirms access can be restored

If unsure, pause and confirm with school admin policy owner before changing status.

---

### Steps: reset password (recommended flow)
1. Open member profile -> **Reset password**.
2. Set a temporary/new password using approved school method.
3. Confirm reset.
4. Share credentials securely with the member.
5. Ask member to sign in immediately and test access.
6. Ask member to change password after successful login (if policy requires).

### Post-reset verification checklist
- [ ] Member can sign in with student ID.
- [ ] Member can sign in with contact email (if present on profile).
- [ ] Member confirms successful login on their device.
- [ ] No blocked/unenrolled status remains by mistake.

---

### If you do not see Member Management
Check in this order:
1. Are you signed into the correct admin/staff account?
2. Does your role include member-management capability?
3. Did role changes happen recently (sign out/in may be required)?
4. Confirm with Org Admin whether your tenant has this feature enabled as expected.

---

### Troubleshooting: member still cannot sign in after reset

1. Re-check account status:
   - ensure member is not blocked/unenrolled
2. Re-check identifier:
   - confirm exact student ID and/or contact email used
3. Re-check latest password:
   - ensure member is using the newest reset value
4. Re-run reset once if needed and communicate clearly
5. If still failing, escalate to deployment/platform support with:
   - member ID
   - timestamp of reset
   - observed error message (without exposing sensitive info publicly)

---

### Common mistakes to avoid
- Resetting password on the wrong member record.
- Blocking when the intended action was unenroll (or vice versa).
- Updating profile fields and status in one rushed step without verification.
- Assuming role changes apply instantly without re-authentication.
- Sharing credentials in insecure channels.

---

### Try this now (practice)
1. Open **Member Management**.
2. Select a test account.
3. Update one non-sensitive profile field.
4. Perform a password reset.
5. Confirm test sign-in works.
6. Return account to expected final state.

---

### Scenario check
A student reports: “I used my new password, but login still fails.”

What should you do first?

**Expected response order:**
1. Verify account status (not blocked/unenrolled).
2. Verify exact login identifier (student ID/email).
3. Verify latest reset password value.
4. Re-run reset once if needed and retest.
5. Escalate with reset timestamp + account details if issue persists.

---

### Optional deep dive
Need full feature reference and policy details? Open **Help Center -> Administrator Guide**.

---

## Module 4 - Groups and clubs lifecycle

### Goal
Set up and manage groups/clubs correctly, including roster roles, join/leave requests, and day-to-day leader operations.

### Who can do this
- **Org Admin:** full group oversight across the organization.
- **Delegated staff (`manageGroupRoster`):** can manage groups based on assigned capability.
- **Group Leader (roster role):** can manage only the groups they lead (within configured limits).

### What you will learn
- how to create and configure groups
- difference between **Leader/Member role** and **club position label**
- how to process join/leave requests
- how to avoid common roster management mistakes

### Before you start
Confirm these first:
1. Your school has decided which groups/clubs should be active.
2. You understand your join and leave policy settings.
3. You know who can approve requests (admin/staff/leader in your setup).

---

### Core concept: permission role vs display position

These are different and should not be mixed:

- **Leader / Member** = permission role (what someone can do)
- **Club position** (President, Secretary, etc.) = display label/title

A member may have a position label without having leader permissions.

---

### Step 1 - Create or open a group
1. Open **Settings -> Administration -> Groups & Clubs**.
2. Create a group or open an existing one.
3. Set basic details:
   - name
   - description
   - active/inactive state (if available)

Use clear naming so students can find the right group easily.

---

### Step 2 - Configure join/leave policies
1. Open group settings/edit.
2. Set:
   - whether join requests are allowed
   - optional join instructions/hint text
   - leave behavior (direct leave vs approval-required)
3. Save and confirm policy is visible to users where applicable.

Policy clarity reduces request confusion and support load.

---

### Step 3 - Manage roster members
1. Open group roster.
2. Add members from approved organization users.
3. Assign each person:
   - role: Leader or Member
   - optional club position label
4. Save and re-check roster list/order.

After adding members, ask them to refresh **My Groups & Clubs**.

---

### Step 4 - Process join/leave requests
1. Open **Requests** for the target group.
2. Review each request against policy and capacity.
3. Approve or deny with consistent criteria.
4. Re-check resulting roster and pending queue.

Use the same criteria for similar cases to keep process fair.

---

### Step 5 - Delegate correctly to group leaders
For leader-managed groups:
1. Confirm roster role is set to **Leader** for selected users.
2. Verify leaders can access expected tools for their own group:
   - manage members
   - review requests
   - send group alerts
   - post group-linked announcements (if enabled)
3. Confirm they cannot manage unrelated groups.

---

### Decision guide: who should perform which action

Use **Org Admin / delegated staff** for:
- creating/deleting groups
- changing global group policies
- resolving complex roster conflicts

Use **Group Leaders** for:
- routine member updates in their group
- join/leave request handling for their group
- group communications (as allowed)

Escalate to **Org Admin** when:
- policy exceptions are needed
- cross-group conflicts occur
- permissions appear inconsistent

---

### If you do not see Groups & Clubs management
Check in this order:
1. Are you signed in with the correct admin/staff account?
2. Do you have `manageGroupRoster` or org admin access?
3. Did you re-authenticate after role updates?
4. Is group management enabled for this tenant/build?

---

### Troubleshooting: “Member can’t see newly assigned group”
1. Confirm member was added to correct group.
2. Confirm add action saved successfully.
3. Ask member to refresh/reopen app.
4. Confirm account status is active (not blocked/unenrolled).
5. Confirm group is active (not hidden/inactive).

---

### Troubleshooting: “Leader can’t manage members”
1. Verify user is **Leader** in that group roster.
2. Confirm group-level leader actions are enabled in your setup.
3. Re-authenticate after role/roster changes.
4. Verify leader is trying to manage the correct group.

---

### Common mistakes to avoid
- Confusing club position labels with permission roles.
- Allowing join requests without clear join criteria.
- Assigning too many leaders without governance.
- Forgetting to review pending requests regularly.
- Making broad changes in wrong group due to similar names.

---

### Quick operations checklist (weekly)
- [ ] Review pending join/leave requests.
- [ ] Confirm leader assignments are still accurate.
- [ ] Archive/deactivate inactive groups as needed.
- [ ] Validate high-visibility groups have correct descriptions and policies.
- [ ] Spot-check member-reported access issues.

---

### Try this now (practice)
1. Create (or open) one test group.
2. Configure join/leave policy.
3. Add two members and assign one leader.
4. Process one sample join or leave request.
5. Verify member and leader experience in app.

---

### Scenario check
A student is marked “President” but cannot approve join requests. They say this is a bug.

What should you check first?

**Expected response order:**
1. Confirm whether they are **Leader** or only have a position label.
2. Verify leader permissions for that specific group.
3. Update roster role if policy says they should manage requests.
4. Re-test leader tools after refresh/sign-in.

---

### Optional deep dive
Need full feature reference? Open **Help Center -> Administrator Guide**.

---

## Module 5 - Announcements and alerts

### Goal
Publish the right message through the right channel, with correct approval handling and response settings.

### Who can do this
- **Org Admin:** full control of publishing and approvals.
- **Delegated staff:** may post/approve based on assigned capabilities.
- **Group Leaders:** can usually send group alerts and may post announcements on behalf of their group (if enabled).

### What you will learn
- difference between **Announcements** and **Group Alerts**
- when to publish now vs schedule vs submit for approval
- how to configure response-required forms correctly
- how to troubleshoot "why is my post not visible yet?"

### Before you start
Confirm these first:
1. You know whether **Require approval before publishing** is ON or OFF.
2. You can access the relevant compose screens in your role.
3. You understand your target audience (all members vs specific group).

---

### Core concept: choose the correct channel first

Use **Announcements** when:
- message is organization-wide
- school-wide bulletin information is needed

Use **Group Alerts** when:
- message is for a specific group/club/targeted audience
- you need group-level reminders or response collection

If unsure, ask: "Should all members see this?"
- Yes -> Announcement
- No -> Group Alert

---

### Step 1 - Check approval mode
1. Open **Settings -> Administration -> Organization Settings**.
2. Check **Require approval before publishing** status.
3. Record this before composing.

Why this matters:
- **OFF**: eligible publishers can send directly.
- **ON**: non-approver content goes to **Pending Approvals** first.

---

### Step 2 - Compose an announcement (org-wide)
1. Open **Home -> Announcements -> Post**.
2. Enter title and body.
3. Optional:
   - schedule send time
   - expiration
   - image
   - response request
4. Submit/publish according to approval mode.

**Use this for:** school-wide notices, policy updates, org-level events.

---

### Step 3 - Compose a group alert (targeted)
1. Open **Alerts** compose flow (or group card action such as **Send Alert**).
2. Select audience (group-specific as allowed by your role).
3. Enter title/body.
4. Optional:
   - expiration
   - response request type
5. Submit/publish according to approval mode.

**Use this for:** group reminders, attendance checks, club-specific actions.

---

### Step 4 - Configure responses correctly

When enabling **Request a response**, choose carefully:

- **Free text:** open-ended input
- **Checkboxes:** one/many selectable options (including single checkbox use cases)
- **Multiple choice:** single-option selection

Then set:
- **Response required** = user must respond before dismissing
- **Allow changing responses**:
  - ON for flexible updates
  - OFF for vote-like or locked responses

---

### Decision guide: Publish now, schedule, or submit for approval

Use **Publish now** when:
- time-sensitive and you have direct publish permission

Use **Schedule** when:
- message should appear at a specific future time

Use **Submit for approval** when:
- approval mode is ON and your role is non-approver
- policy requires review before release

---

### Where to monitor status
Check these areas after submission:

- **Announcements list / My announcements** for scheduled/live states
- **Alerts sent list** for delivered group alerts
- **Pending Approvals** for queued items (when approval is ON)

If item is not visible to recipients, check queue state first.

---

### If you do not see publish actions
Check in this order:
1. Are you signed in with the correct admin/staff/leader account?
2. Do you have required publish capability for that channel?
3. Is this action restricted to Org Admin in your tenant policy?
4. Did you re-authenticate after role updates?

---

### Troubleshooting: "My post didn't go live"
1. Confirm approval mode status.
2. Check if item is in **Pending Approvals**.
3. Check schedule time/date and timezone assumptions.
4. Confirm audience targeting (group vs org-wide).
5. Confirm item was saved/submitted successfully.
6. If still unclear, have an approver/admin inspect queue and logs.

---

### Common mistakes to avoid
- Sending a school-wide message as a group alert by accident.
- Forgetting approval mode is ON and assuming immediate delivery.
- Scheduling with incorrect date/time.
- Enabling **Response required** unintentionally for non-critical messages.
- Leaving **Allow changing responses** ON for vote-like forms.

---

### Quick content safety checks before sending
- Is the audience correct?
- Is wording clear and concise?
- Is any response truly required?
- Does this need immediate send or scheduled release?
- Does this require admin review first?

---

### Try this now (practice)
1. Draft one announcement with schedule enabled.
2. Draft one group alert with response request enabled.
3. Submit both under current approval mode.
4. Verify where each item appears (live list vs pending queue).
5. Confirm expected recipient visibility.

---

### Scenario check
A group leader says: "I posted an alert but members can't see it."

What should you check first?

**Expected response order:**
1. Is **Require approval before publishing** ON?
2. Is the alert waiting in **Pending Approvals**?
3. Was the audience set to the correct group?
4. Was the alert scheduled for future time?
5. Does the leader role have the expected publish scope?

---

### Optional deep dive
Need full feature reference? Open **Help Center -> Administrator Guide**.

---

## Module 6 - Language basics vs translation moderation

### Goal
Understand the difference between member language selection and administrator translation workflows, so language support is managed correctly.

### Who can do this
- **All members:** can choose app display language for their own device/session.
- **Org Admin:** can manage translation workflows and assign translation moderators.
- **Translation Moderator (`manageTranslations`):** can edit/review translations based on granted scope.

### What you will learn
- what members can change vs what admins/moderators can change
- how to assign translation moderation access safely
- how translation statuses work (`missing`, `in_review`, `approved`, etc.)
- common language-support issues and quick fixes

### Before you start
Confirm these first:
1. Which languages are enabled for your school.
2. Whether translation moderation is part of your current rollout.
3. Which staff should be allowed to edit translation strings.

---

### Core concept: two different language actions

#### Action A - Member language choice (personal UI)
Members can switch language from:
- **Home -> globe selector**
- **Settings -> Appearance -> Language**

This changes only what that member sees.

#### Action B - Translation moderation (content management)
Org Admins / moderators edit translation strings in admin tools.

This affects translation content used by users across the org after review/release flow.

**Do not confuse these two actions.**  
Choosing a language is not the same as editing translations.

---

### Step 1 - Verify member language switching path
1. Open member-accessible language controls:
   - **Home -> globe selector**
   - **Settings -> Appearance -> Language**
2. Switch language and confirm UI reflects selection.
3. Confirm fallback behavior where translation is incomplete (if applicable).

---

### Step 2 - Assign translation moderation role (admin flow)
1. Open **Roles & Permissions**.
2. Create or update a role for translation work.
3. Enable capability: `manageTranslations`.
4. Assign role to approved staff member.
5. Have assignee sign out/sign in to refresh permissions.

Use least privilege: grant only translation capability when possible.

---

### Step 3 - Open translation workspace and review status
1. Open **Settings -> Administration -> Translations**.
2. Select target language.
3. Search/filter translation rows.
4. Observe statuses, typically including:
   - `missing`
   - `in_review`
   - `approved`
   - (and AI-related draft states where enabled)

---

### Step 4 - Edit and review safely
For each string:
1. Read English/source context first.
2. Enter translation text.
3. Keep placeholders exactly unchanged (example: `{name}`).
4. Save as review state or approve, based on your workflow.

If AI draft is available:
- treat AI output as draft only
- always human-review before approval

---

### Decision guide: who should do what

Use **Members** for:
- personal language selection only

Use **Translation Moderators** for:
- editing/reviewing translation rows
- language quality improvements

Use **Org Admins** for:
- assigning translation roles
- final oversight/export decisions (where applicable)

---

### If you do not see Translations menu
Check in this order:
1. Correct admin/staff account signed in?
2. Role includes `manageTranslations` (or Org Admin access)?
3. Sign out/sign in after role change?
4. Is translation feature enabled for this environment/tenant?

---

### Troubleshooting: “Language switched but text still English”
Possible causes:
1. Target string has no approved translation yet.
2. Translation exists but not in final/active state.
3. Feature string not yet covered in current translation workflow.
4. App/help fallback behavior is correctly showing English.

Action:
- verify string status in translation workspace
- complete review/approval flow as required
- retest after refresh/reload

---

### Common mistakes to avoid
- Giving all admins translation edit rights when only a few need it.
- Editing placeholders incorrectly (`{...}` tokens changed or removed).
- Approving AI drafts without human review.
- Treating member language switch as a translation publishing action.
- Forgetting re-authentication after role updates.

---

### Quick governance checklist
- [ ] Translation editor roles are explicitly assigned.
- [ ] Placeholders are preserved in edited strings.
- [ ] Review standards are documented (who can approve).
- [ ] Members know where to switch language.
- [ ] Admin team knows fallback-to-English is expected when untranslated.

---

### Try this now (practice)
1. Confirm member language switch path works.
2. Assign `manageTranslations` to one test moderator.
3. Edit one translation string and save.
4. Approve one reviewed string (if in your scope).
5. Verify expected UI behavior after refresh.

---

### Scenario check
A teacher says: “I changed my app language, but this label is still English. Is the language switch broken?”

What should you check first?

**Expected response order:**
1. Confirm selected language is active in app settings.
2. Check that specific label’s translation status in workspace.
3. Confirm whether translation is approved/active.
4. Explain fallback behavior if translation is not yet complete.

---

### Optional deep dive
Need full feature reference? Open **Help Center -> Administrator Guide**.

---

## Module 7 - Translation Helper (web app) workflow

### Goal
Use the Translation Helper web app to manage translation work at scale (review, approval, export) and hand off correctly for release.

### Who can do this
- **Org Admin:** full workflow oversight, including export tasks where enabled.
- **Translation Moderator (`manageTranslations`):** edit/review translation entries.
- **Platform/deployment lead:** environment setup tasks (functions, config, source import) if needed.

### What you will learn
- when to use the web helper vs in-app translation mode
- required access and sign-in expectations
- practical edit/review/approve/export workflow
- common setup/permission errors and fixes

### Before you start
Confirm these first:
1. You can sign in with a valid Firebase Auth user for your org.
2. Your role includes translation access (`manageTranslations`) or Org Admin privileges.
3. Translation backend/setup is already enabled in your environment.
4. English source strings have been imported at least once (where required by your deployment flow).

---

### Core concept: in-app vs web translation tools

Use **in-app translation mode** when:
- you need in-context UI review on real mobile screens
- you are validating how labels look in place

Use **Translation Helper web app** when:
- you need bulk filtering/review
- you are processing many strings quickly
- you need export and spreadsheet-friendly workflows

Best practice: use both together (web for throughput, app for context QA).

---

### Step 1 - Access and sign in
1. Open the Translation Helper URL for your environment.
2. Sign in using your Firebase Auth email/password (same auth system as app users).
3. Confirm your org context and language workspace.

If sign-in fails:
- verify you are using Firebase Auth credentials (not CLI/Google login credentials)
- confirm account is approved and has org membership

---

### Step 2 - Select language and filter workload
1. Choose target language (example: Cebuano).
2. Filter by status (e.g., missing, in review, approved, AI draft).
3. Use search by key or English text to focus your batch.

Recommended triage order:
1. high-visibility/common strings
2. navigation/settings/auth strings
3. lower-frequency screens

---

### Step 3 - Edit and review entries
For each string:
1. Read source/English context first.
2. Enter or refine translation.
3. Preserve placeholders exactly (example: `{name}`, `{count}`).
4. Save as review state or approve per your policy.

If AI draft is enabled:
- use as starting point only
- apply human review before approval

---

### Step 4 - Use screen/context metadata (if enabled)
1. Filter by screen name/tag where available.
2. Prioritize strings used on active rollout screens.
3. Use in-app translation mode to validate ambiguous strings in context.

This reduces literal-but-unnatural phrasing.

---

### Step 5 - Export and handoff
1. Export approved translation output (ARB/JSON per your flow).
2. Confirm only approved-ready content is included.
3. Hand off to release owner for app build integration.
4. Record export timestamp/version in your internal release notes.

Important: editing strings in workspace is not the same as shipping a new app build; follow your release process.

---

### Role-based responsibilities

#### Translation Moderator
- edit/review string entries
- flag uncertain terms for admin review
- avoid final release decisions unless policy allows

#### Org Admin
- assign moderator roles
- approve final translation quality gates
- run/authorize export and release handoff

#### Platform/Deployment Lead
- maintain environment setup and function availability
- troubleshoot backend/config issues affecting workspace access

---

### If you cannot access key web actions
Check in this order:
1. correct account and org context
2. `manageTranslations` / admin capability present
3. sign out/sign in after permission changes
4. source strings imported for target language workflow
5. environment config points to correct Firebase project/org

---

### Troubleshooting quick guide

#### “No strings appear”
- source strings may not be imported yet
- filters may be too narrow
- wrong org/environment context

#### “Save/approve fails”
- missing capability or stale auth claims
- backend function unavailable/misconfigured
- malformed translation payload (often placeholder issues)

#### “Export button missing”
- role may lack export permission path
- org admin-only action in your deployment
- workspace not in expected status state

#### “Changes don’t appear in app”
- app may still be using old bundled assets/build
- review/approval/export/build-release cycle not completed
- wrong language or org context in test app

---

### Common mistakes to avoid
- using the wrong credentials type for web sign-in
- editing without preserving placeholders
- approving AI drafts without human review
- exporting before review pass is complete
- assuming web save immediately ships to end users

---

### Quick web workflow checklist
- [ ] Signed in with correct org account
- [ ] Target language selected
- [ ] Strings triaged by status/screen
- [ ] Placeholders preserved in edits
- [ ] Review/approval policy followed
- [ ] Export completed and handoff recorded
- [ ] In-app spot-check performed after release

---

### Try this now (practice)
1. Open Translation Helper and sign in.
2. Filter to `missing` strings for one target language.
3. Edit and save 5 strings.
4. Approve at least 2 reviewed strings (if in your scope).
5. Export (or dry-run export procedure) and document handoff notes.
6. Validate one updated label in app context.

---

### Scenario check
A moderator says: “I saved many translations in web helper, but users still see English in the app.”

What should you check first?

**Expected response order:**
1. Are strings approved (not just saved/in review)?
2. Was export completed from approved set?
3. Was a build/release step completed with updated translation assets?
4. Is tester using correct org/language context in app?

---

### Optional deep dive
Need full feature/setup reference? Open:
- **Help Center -> Administrator Guide**
- `speakup_connect_web/tools/translation-helper/README.md`
- `shared/docs/INTERNATIONALIZATION.md`

## Module 8 - Publishing flows

### Goal
Publish the right message through the right channel, with the correct approval and response settings, so content reaches the intended audience on time.

### Who can do this
- **Org Admin:** full publishing and approval oversight.
- **Delegated staff:** can publish/approve based on assigned capabilities.
- **Group Leaders:** can typically publish group-scoped content and, in some setups, post announcements on behalf of their group.

### What you will learn
- when to use **Announcements** vs **Alerts**
- how approval mode changes publishing behavior
- how to use scheduling and expiration correctly
- how to configure response-required content safely

### Before you start
Confirm these first:
1. Whether **Require approval before publishing** is ON or OFF.
2. Which channels your role can publish to.
3. The audience for this message (all members vs specific groups).

---

### Core concept: channel + approval mode

#### Channel selection
- Use **Announcements** for organization-wide communication.
- Use **Alerts** for targeted/group communication.

#### Approval mode
- **OFF:** eligible users can publish directly.
- **ON:** non-approver submissions go to **Pending Approvals** before delivery.

Always check approval mode before posting.

---

### Step 1 - Verify approval settings
1. Open **Settings -> Administration -> Organization Settings**.
2. Check **Require approval before publishing**.
3. Note current state before composing content.

---

### Step 2 - Publish an announcement (org-wide)
1. Open **Home -> Announcements -> Post**.
2. Enter title and message.
3. Optional settings:
   - schedule for later
   - expiration
   - image
   - response request
4. Publish or submit for approval (based on current mode and role).

Use announcements for school-wide notices, policy updates, and broad broadcasts.

---

### Step 3 - Publish an alert (targeted)
1. Open **Alerts** compose flow (or group card action if leader).
2. Set audience (group/target scope allowed by your role).
3. Enter title and body.
4. Optional:
   - expiration
   - response request settings
5. Publish or submit for approval.

Use alerts for group reminders, attendance checks, and targeted actions.

---

### Step 4 - Configure response requests correctly
When enabling **Request a response**, choose:

- **Free text** for open-ended input
- **Checkboxes** for one/multiple selections
- **Multiple choice** for single-option answers

Then decide:
- **Response required**
  - ON: users must respond before dismissing
  - OFF: optional response
- **Allow changing responses**
  - ON: users may revise
  - OFF: lock after submit (best for polls/votes)

---

### Step 5 - Monitor publishing status
After posting, verify delivery state in:

- announcements list / my announcements
- alerts sent list
- pending approvals queue (when approval mode is ON)

If users cannot see content, check queue/schedule/audience before assuming a bug.

---

### Decision guide: publish now, schedule, or queue approval

Use **Publish now** when:
- message is urgent
- you have direct publish permission

Use **Schedule** when:
- timing matters (future send)

Use **Submit for approval** when:
- approval mode is ON and your role is non-approver
- school policy requires pre-publication review

---

### If publishing actions are missing
Check in this order:
1. Correct account signed in?
2. Correct role/capability assigned?
3. Re-authentication done after role changes?
4. Feature/channel enabled for this tenant?

---

### Troubleshooting quick guide

#### “My post is not visible”
1. Check if it is waiting in **Pending Approvals**.
2. Check scheduled send time/date.
3. Confirm target audience was set correctly.
4. Confirm publish/submit action completed successfully.

#### “Users cannot submit responses”
1. Confirm response type is valid.
2. Check if **Response required** or lock settings are too strict.
3. Verify users are in target audience.

#### “Wrong audience received content”
1. Review selected channel (announcement vs alert).
2. Re-check audience selector before publish.
3. Use clearer naming conventions for groups to avoid mis-targeting.

---

### Common mistakes to avoid
- Posting org-wide content as a group alert.
- Forgetting approval mode is ON.
- Scheduling with wrong date/time.
- Enabling response-required for non-essential notices.
- Leaving response changes ON for vote-like forms.

---

### Quick pre-publish checklist
- [ ] Correct channel selected
- [ ] Correct audience selected
- [ ] Approval mode checked
- [ ] Schedule/expiration validated
- [ ] Response settings validated
- [ ] Message reviewed for clarity

---

### Try this now (practice)
1. Draft one announcement with scheduling enabled.
2. Draft one alert with a response request.
3. Submit both under current approval mode.
4. Verify where each appears (live vs pending).
5. Confirm expected audience visibility.

---

### Scenario check
A group leader says: “I posted an alert, but no one received it.”

What should you check first?

**Expected response order:**
1. Is approval mode ON, and is it in **Pending Approvals**?
2. Was the alert scheduled for a future time?
3. Was the correct group/audience selected?
4. Does the leader role have the expected publishing scope?

---

### Optional deep dive
Need full feature reference? Open **Help Center -> Administrator Guide**.

---

## Module 9 - Common mistakes and recovery

### Goal
Recognize frequent admin mistakes early and recover quickly without disrupting users.

### Who should complete this module
- **Org Admins** (required)
- **Delegated staff and group leaders** involved in daily operations

### What you will learn
- the most common failure patterns in school operations
- fast triage steps for access, publishing, groups, and translation issues
- when to self-fix vs when to escalate
- how to reduce repeat incidents

### Before you start
Confirm these first:
1. You have completed Modules 1-8.
2. You can access core admin areas (or know who can).
3. You know your escalation path (Org Admin -> deployment/platform lead).

---

### Core concept: diagnose by category first

Most issues fall into one of five categories:

1. **Access/permission mismatch**
2. **Account state/data mismatch**
3. **Workflow state mismatch** (pending approval, scheduled send, etc.)
4. **Audience/targeting mismatch**
5. **Environment/setup mismatch** (especially for translation tooling)

Start with category, then run the matching quick checklist.

---

### Recovery playbook A - “I can’t see this menu/action”
Use this order:
1. Confirm correct account is signed in.
2. Confirm correct org context.
3. Check role/capability assignment.
4. Sign out/sign in after changes.
5. Confirm feature is enabled for tenant/environment.

If still blocked, escalate with:
- user account
- expected action
- screen/path attempted
- timestamp

---

### Recovery playbook B - “User cannot sign in after onboarding/reset”
Use this order:
1. Check member status (active vs blocked/unenrolled).
2. Verify identifier used (student ID/email).
3. Verify latest password/reset path.
4. Check for duplicate/conflicting records.
5. Re-run reset once, communicate clearly, retest.

Escalate if repeated failure after verified reset.

---

### Recovery playbook C - “Content not delivered”
Use this order:
1. Check **Require approval before publishing** status.
2. Check **Pending Approvals** queue.
3. Check schedule date/time.
4. Confirm audience targeting.
5. Confirm author has required publish scope.

Most “missing post” issues are queue/schedule/audience related, not system bugs.

---

### Recovery playbook D - “Group/leader actions not working”
Use this order:
1. Verify user is Leader in the correct group.
2. Confirm group is active.
3. Confirm policy settings (join/leave rules) for that group.
4. Re-authenticate after role/roster changes.
5. Validate user is operating in the intended group (not similarly named group).

---

### Recovery playbook E - “Translation changes not visible”
Use this order:
1. Confirm target language selected by tester.
2. Check string status (saved vs approved).
3. Confirm export step completed (if required by your flow).
4. Confirm updated assets/build released to app.
5. Confirm tester is in correct org/environment.

Reminder: saved translation does not always mean immediately shipped app text.

---

### Top 12 mistakes to avoid
1. Approving applicants without duplicate checks.
2. Resetting password on wrong account.
3. Blocking when unenroll was intended (or vice versa).
4. Assuming role title equals capability coverage.
5. Forgetting sign out/sign in after permission changes.
6. Posting to wrong channel (announcement vs alert).
7. Forgetting approval mode is ON.
8. Scheduling with wrong date/time assumptions.
9. Targeting wrong group/audience.
10. Confusing Leader permission with club position title.
11. Editing translation placeholders incorrectly.
12. Assuming web translation save instantly updates all app users.

---

### Escalation guide: when to stop and escalate

Escalate to **Org Admin** when:
- policy decision is required
- permission model changes are needed
- account conflicts involve school records

Escalate to **Deployment/Platform lead** when:
- repeated auth/permission mismatch persists after re-auth
- translation tooling/setup appears broken
- behavior suggests environment/config regression

Provide concise incident details:
- who was affected
- exact step attempted
- expected vs actual result
- timestamp + screenshot (if available)

---

### Prevention checklist (weekly)
- [ ] Review pending approvals queue.
- [ ] Review join applications backlog.
- [ ] Audit role assignments for least privilege.
- [ ] Spot-check leader assignments in active groups.
- [ ] Verify one translation QA sample per active language.
- [ ] Capture recurring issues and update local SOP notes.

---

### Incident response template (copy/paste)
- **Issue type:** Access / Account / Publishing / Group / Translation
- **User(s) affected:**
- **Screen/path used:**
- **Expected result:**
- **Actual result:**
- **First observed (date/time):**
- **What was checked already:**
- **Current blocker:**
- **Escalated to:**

---

### Try this now (practice drill)
Run one mock issue from each category:
1. Permission missing
2. Sign-in failure
3. Undelivered content
4. Group leader limitation
5. Translation not visible

For each, execute the matching recovery playbook and document outcome.

---

### Scenario check
An admin reports: “Too many random issues today; I don’t know where to start.”

What should you do first?

**Expected response order:**
1. Classify each issue by category (Access/Account/Workflow/Audience/Environment).
2. Run the matching playbook in order.
3. Document what was verified.
4. Escalate only after completing category checks.

---

### Completion checkpoint
You are operationally ready when you can:
- diagnose common issues without guesswork
- choose the right recovery playbook quickly
- escalate with complete, useful incident details

### Optional deep dive
Need full feature reference? Open **Help Center -> Administrator Guide**.

---

## Module 10 - Final operational assessment (capstone)

### Goal
Demonstrate that you can run core school admin workflows end-to-end, troubleshoot common failures, and escalate correctly when needed.

### Who should complete this module
- **All first-time Org Admins**
- **Delegated staff** who will operate daily admin workflows

### What this module validates
- practical execution across Modules 1-9
- correct decision-making under realistic conditions
- consistent documentation and escalation discipline

### Time estimate
45-90 minutes (single reviewer) or 60-120 minutes (with live reviewer)

---

### Assessment rules
1. Complete tasks in order.
2. Use test/sandbox accounts where possible.
3. Record evidence for each task (screenshot, note, or checklist entry).
4. If a task fails, log issue + attempted recovery + escalation path.

---

## Part A - End-to-end workflow simulation

Complete all tasks below:

1. **Access verification**
   - Confirm your role and visible admin menus match expected capabilities.

2. **Onboard one member**
   - Review one pending application.
   - Approve or reject using policy-based reasoning.
   - Record decision rationale.

3. **Member recovery task**
   - Perform one password reset for a test member.
   - Verify successful sign-in using valid identifier(s).

4. **Group operations**
   - Add one member to a group.
   - Assign one leader role correctly.
   - Confirm group visibility for assigned user.

5. **Publishing operations**
   - Publish (or submit) one announcement.
   - Publish (or submit) one alert with response settings.
   - Confirm queue/live status under current approval mode.

6. **Translation operations**
   - Confirm member language switch path.
   - Edit/review one translation item (in-app or web workflow).
   - Validate expected status progression.

### Part A pass criteria
- [ ] All six tasks completed
- [ ] No unresolved blockers
- [ ] Evidence captured for each step

---

## Part B - Incident response drill

Run two mini-drills using your recovery playbooks.

### Drill 1: Access/permission issue
Simulate: user cannot see a required admin menu.

Required actions:
1. classify incident category
2. run access troubleshooting sequence
3. document checks performed
4. determine fix vs escalation

### Drill 2: Delivery/status issue
Simulate: published content not visible to recipients.

Required actions:
1. verify approval/schedule/audience state
2. run publishing recovery sequence
3. document findings
4. determine fix vs escalation

### Part B pass criteria
- [ ] Correct category-based triage used
- [ ] Recovery steps followed in order
- [ ] Escalation decision was justified

---

## Part C - Governance and readiness checks

### Role hygiene check
- [ ] least-privilege roles applied
- [ ] no unnecessary elevated