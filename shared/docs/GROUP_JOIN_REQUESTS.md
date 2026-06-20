# Group Membership Requests — Feature Design

> **Status:** Design approved for implementation (June 2026)  
> **Epic:** [MASTER_TASK_LIST.md → Epic 2.6.1](MASTER_TASK_LIST.md)  
> **Related:** [DATABASE_DESIGN.md](DATABASE_DESIGN.md), [RBAC_ARCHITECTURE.md](RBAC_ARCHITECTURE.md)

Covers **join** (opt-in requests to enter a group) and **leave** (voluntary exit vs approval-required exit).

---

## Problem

Today, students cannot join or leave a club from the app. Rosters are built only when an **administrator** or **group leader** searches approved members and assigns or removes them. That works for small clubs but does not scale when many students want to sign up for open activities (e.g. Drum and Lyre Corps, SPJ).

Some groups must remain **closed to join** — membership is by election or adviser appointment only (e.g. **SSLG**). Those groups should not show a join path in the app.

Some groups also need **controlled exit** — officers and corps members should not silently leave without adviser awareness (e.g. SSLG). Other groups may allow students to leave on their own (e.g. casual interest clubs).

---

## Goals

**Join**
1. Let **approved org members** request to join a group when that group allows it.
2. Let **org admins** and **group leaders** turn join requests **on or off** per group.
3. Default new and existing groups to **closed** (no join requests) until explicitly opened.
4. Give leaders and admins a queue to **approve** or **reject** join requests; approval adds the user to the roster.

**Leave**
5. Let **org admins** and **group leaders** set per group whether members may **leave voluntarily** or must **request to leave** (with a required reason).
6. When leave requires approval, leaders/admins review a leave queue; approval removes the member from the roster.
7. Send **automated in-app alerts** (and push where configured) when a member is **removed**, when a **leave request is denied** (including the reason), and at other key membership events (see Notifications).

## Non-goals (v1)

- Self-join without approval (instant membership).
- Join or leave requests from users who are not yet approved org members.
- Public / non-member discovery of group details outside the org.
- Class (homeroom) enrollment — groups/clubs only.
- Replacing election workflows for SSLG (closed groups stay invitation-only).
- Blocking admin/leader **forced removal** — advisers can always remove a member from the roster; this policy only governs **member-initiated** exit.

---

## Join policy per group

| `allowJoinRequests` | Behaviour |
|---------------------|-----------|
| `false` *(default)* | **Closed.** Members see the group in browse lists with no request action. Copy: “Membership by invitation only.” SSLG, elected bodies. |
| `true` | **Open to requests.** Approved members who are not on the roster see **Request to Join**. Leaders/admins approve or reject. |

**Who can change the setting**

| Actor | Can toggle `allowJoinRequests` |
|-------|-------------------------------|
| Org admin | Yes, any group |
| User with `manageGroupRoster` | Yes, any group |
| Group leader (roster role) | Yes, **only groups they lead** |

Leaders cannot open join requests for groups where they are only a **Member**.

**Optional copy field (v1 stretch):** `joinRequestHint` — short text shown on the browse/detail card when requests are enabled (e.g. “Auditions in August — request now to be notified”).

---

## Leave policy per group

| `memberLeavePolicy` | Behaviour |
|---------------------|-----------|
| `voluntary` | Member sees **Leave group** on **My Groups & Clubs**. Confirmation dialog → immediate removal from roster (no approval queue). |
| `request_required` *(default)* | Member sees **Request to leave**. Required form: **reason** (min 20 chars, max 500). Leader/admin approves or denies; denial **must** include a reason shown to the member. |

**Who can change the setting**

| Actor | Can set `memberLeavePolicy` |
|-------|----------------------------|
| Org admin | Yes, any group |
| User with `manageGroupRoster` | Yes, any group |
| Group leader (roster role) | Yes, **only groups they lead** |

**Leaders and forced removal:** Admins and leaders can always **Remove from group** from the roster screen regardless of `memberLeavePolicy`. The removed member receives an automated alert (see Notifications).

**Last leader edge case (v1):** If the sole leader attempts voluntary leave or an approved leave request, block with message: “Assign another leader before leaving.” (Stretch: auto-demote not in v1.)

---

## User flows

### A — Member requests to join

**Preconditions:** Signed in, `approvalStatus == approved`, not already on roster, `allowJoinRequests == true`, no existing `pending` request for this group.

1. Member opens **Browse Groups & Clubs** (Home or Settings — entry TBD in UI).
2. Sees searchable list of **active** org groups with membership status chip: **Member** | **Pending** | **Request to join** | **Invitation only**.
3. Taps **Request to Join** on an open group.
4. Optional: short message to the leader (max 200 chars).
5. Submits → request doc `status: pending`; UI shows **Pending**.
6. Leaders/admins with pending items get a notification.

### B — Leader / admin reviews request

**Preconditions:** Admin, `manageGroupRoster`, or **leader** on that group.

1. Open **Join Requests** from:
   - Group card / members screen badge, or
   - Admin **Groups & Clubs** list badge, or
   - Settings → **Pending Group Requests** (aggregate).
2. See requester name, student ID (if any), optional message, requested date.
3. **Approve** → create `members/{userId}` as `groupRole: member`, set request `status: approved`, sync `groupMemberships` index, notify requester.
4. **Reject** → set `status: rejected`, optional reason, notify requester.
5. Requester may submit a **new** request after rejection (new doc or reset — implement as single doc per userId with status transition).

### C — Requester withdraws (v1 nice-to-have)

Pending requester can tap **Cancel request** → `status: withdrawn`.

### D — Admin creates group

`CreateGroupScreen` includes toggle **Allow students to request to join** (default **OFF**). SSLG and similar stay closed unless an admin explicitly opens them (unlikely).

### E — Leader opens club for sign-ups

Drum and Lyre adviser (as leader) enables **Allow join requests** on their group card or group settings sheet. Students request; leaders approve from the join queue.

### F — Member leaves voluntarily (`memberLeavePolicy: voluntary`)

**Preconditions:** On roster, policy is `voluntary`, not the sole leader (if leader).

1. Member opens **My Groups & Clubs** → group card → **Leave group**.
2. Confirmation dialog explains they will stop receiving group alerts.
3. Confirms → callable removes `members/{userId}`, syncs `groupMemberships` index.
4. Optional: notify group leaders that a member left (in-app; push stretch).

### G — Member requests to leave (`memberLeavePolicy: request_required`)

**Preconditions:** On roster, policy is `request_required`, no existing `pending` leave request.

1. Member taps **Request to leave** on the group card.
2. Form: **Why do you want to leave?** (required, 20–500 chars).
3. Submits → `leaveRequests/{userId}` with `status: pending`; UI shows **Leave pending**.
4. Leaders/admins notified (same channels as join requests).

### H — Leader / admin reviews leave request

**Preconditions:** Admin, `manageGroupRoster`, or **leader** on that group.

1. Open **Leave Requests** tab on `GroupJoinRequestsScreen` (or combined membership requests screen with Join | Leave tabs).
2. See member name, reason, date.
3. **Approve** → remove from roster, sync index, set request `status: approved`, notify member that they have left the group.
4. **Deny** → set `status: rejected`, **rejection reason required** (shown to member in alert), notify member with reason.
5. Member may submit a new leave request after denial.

### I — Leader / admin removes member (existing flow, enhanced)

When an admin or leader uses **Remove from group** on the roster:

1. Existing confirmation dialog.
2. Removal via callable (not raw client delete) so server can:
   - Delete `members/{userId}` and sync index.
   - Send **automated alert** to removed member: “You were removed from {groupName}.” Optional note from remover (stretch).
3. Cancel any pending leave request for that user on the group.

### J — Admin configures leave policy

`CreateGroupScreen` and **Edit Group** include **Member leave policy**:

- **Leave anytime** (`voluntary`)
- **Must request to leave** (`request_required`) — default

SSLG typically uses `request_required` so officers cannot exit without adviser review.

---

## Data model

### Group document — new fields

Path: `organizations/{organizationId}/groups/{groupId}`

```json
{
  "allowJoinRequests": "boolean (default false)",
  "joinRequestHint": "string | null (optional helper text when allowJoinRequests is true)",
  "memberLeavePolicy": "voluntary | request_required (default request_required)",
  "pendingJoinRequestCount": "number (denormalized, optional v1 — for badges)",
  "pendingLeaveRequestCount": "number (denormalized, optional v1 — for badges)"
}
```

### Join requests subcollection

Path: `organizations/{organizationId}/groups/{groupId}/joinRequests/{userId}`

Document ID = requester's `userId` (at most one active logical request per user per group).

```json
{
  "userId": "string",
  "displayName": "string (denormalized)",
  "studentId": "string | null (denormalized)",
  "message": "string | null (requester note, max 200)",
  "status": "pending | approved | rejected | withdrawn",
  "reviewedBy": "string | null (admin or leader UID)",
  "reviewedAt": "Timestamp | null",
  "rejectionReason": "string | null",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

**Indexes**

- `joinRequests` where `status == pending` per group (leader queue).
- Collection group query for org-wide admin queue: `joinRequests` where `organizationId` + `status == pending` if denormalized on request doc (add `organizationId`, `groupId` on request for admin aggregate view).

Recommended denormalization on each request:

```json
{
  "organizationId": "string",
  "groupId": "string",
  "groupName": "string"
}
```

### Leave requests subcollection

Path: `organizations/{organizationId}/groups/{groupId}/leaveRequests/{userId}`

Document ID = requester's `userId`.

```json
{
  "userId": "string",
  "organizationId": "string (denormalized)",
  "groupId": "string (denormalized)",
  "groupName": "string (denormalized)",
  "displayName": "string",
  "studentId": "string | null",
  "reason": "string (required, 20–500 chars)",
  "status": "pending | approved | rejected | withdrawn",
  "reviewedBy": "string | null (admin or leader UID)",
  "reviewedAt": "Timestamp | null",
  "rejectionReason": "string | null (required when status is rejected)",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

**Indexes**

- `leaveRequests` where `status == pending` per group.
- Collection-group query for org-wide admin leave queue (denormalized `organizationId` on doc).

---

## Security & server enforcement

Client writes to `joinRequests` are **not** trusted for approve/reject. Use Cloud Functions:

| Callable | Caller | Action |
|----------|--------|--------|
| `submitGroupJoinRequest` | Approved org member | Validates open policy, not member, creates/updates pending request |
| `withdrawGroupJoinRequest` | Requester | Sets `withdrawn` if pending |
| `reviewGroupJoinRequest` | Admin, `manageGroupRoster`, or group leader | Approve (add member + index sync) or reject |
| `voluntaryLeaveGroup` | Member on roster | Validates `memberLeavePolicy == voluntary`; removes member + index sync |
| `submitGroupLeaveRequest` | Member on roster | Validates `request_required`; creates pending leave request |
| `withdrawGroupLeaveRequest` | Requester | Sets `withdrawn` if pending |
| `reviewGroupLeaveRequest` | Admin, `manageGroupRoster`, or group leader | Approve (remove member) or reject (reason required) |
| `removeGroupMember` *(enhance existing)* | Admin, `manageGroupRoster`, or group leader | Remove member + **notify removed user**; cancel pending leave request |

**Firestore rules (sketch)**

- `joinRequests` / `leaveRequests` read: requester (own doc), group leader, admin, `manageGroupRoster`.
- `joinRequests` / `leaveRequests` write: **deny** direct client create/update/delete — functions only.
- Group policy fields update: admin, `manageGroupRoster`, or leader on that group; `onlyGroupLeaderGroupUpdate()` allows `name`, `description`, `allowJoinRequests`, `joinRequestHint`, `memberLeavePolicy`, `updatedAt` (not `positionRoles` or `isActive`).
- Prefer routing roster **deletes** through `removeGroupMember` / review callables so notifications always fire.

---

## UI surfaces (shipped)

| Screen / widget | Audience | Purpose |
|-----------------|----------|---------|
| `BrowseGroupsScreen` | All approved members | Discover groups, status chip, request action |
| `GroupJoinRequestSheet` / join dialog | Member | Optional message + submit |
| `GroupMembershipRequestsScreen` | Leader / admin | Per-group queue with **Join** and **Leave** tabs |
| `CreateGroupScreen` | Admin / `manageGroupRoster` | Create group; join default closed; leave policy default `request_required` |
| `EditGroupScreen` | Admin, `manageGroupRoster`, or leader | Unified settings: name, description, join/leave policies, club positions (admin only), active flag (org admin only) |
| **Leave group** / **Request to leave** on `MyGroupsScreen` | Member | Policy-driven exit actions |
| `GroupLeaveRequestSheet` / leave dialog | Member | Required reason form |
| Badge on `MyGroupsScreen` leader card | Leader | Pending join + leave counts |
| Pending counts on admin `GroupsListScreen` | Admin | Per-group join + leave totals in list subtitle |

**Routes**

- `/groups/browse` — member browse
- `/groups/:groupId/edit` — edit group settings
- `/groups/:groupId/members` — roster (view or manage)
- `/groups/:groupId/membership-requests` — review join + leave queues
- `/groups/:groupId/roles` — redirects to `/groups/:groupId/edit` (legacy)

---

## Notifications

Deliver as **in-app Alerts** (system-generated reminder or dedicated `membershipEvent` notification type). Push when FCM is available.

| Event | Recipient | Message content |
|-------|-----------|-----------------|
| New **join** request | Group leaders + roster admins | “{name} requested to join {group}” |
| Join **approved** | Requester | “You were added to {group}” |
| Join **rejected** | Requester | “Your request to join {group} was declined” + optional reason |
| New **leave** request | Group leaders + roster admins | “{name} requested to leave {group}” |
| Leave **approved** | Requester | “You have left {group}” |
| Leave **denied** | Requester | “Your request to leave {group} was denied” + **required reason** |
| **Removed** by admin/leader | Removed member | “You were removed from {group}” |
| Voluntary **leave** (optional) | Group leaders | “{name} left {group}” |

Reuse existing FCM / in-app notification patterns from reminders where possible. Denied leave requests **must** include the `rejectionReason` in the alert body.

---

## MONHS examples

| Group | Join | Leave policy | Notes |
|-------|------|--------------|-------|
| **SSLG** | Closed | `request_required` | Elected officers; join by appointment; exit needs adviser approval |
| **SPJ** | Admin choice | `request_required` | Adviser-managed roster |
| **Drum and Lyre Corps** | Open requests | `voluntary` | Open sign-ups; members may leave on their own |

Member guide will document: closed join → contact adviser; open join → **Browse Groups → Request to Join**; leave policy → **Leave group** vs **Request to leave** with reason form.

---

## Help & documentation updates (at implementation)

- `shared/docs/help/school/MEMBER_GUIDE.md` — join browse/request; leave vs request-to-leave; removal alerts
- `shared/docs/help/school/ADMIN_GUIDE.md` — policy toggles on create/edit; join + leave review queues
- Sync `speakup_connect_app/assets/help/school/` copies

---

## Testing checklist

- [ ] Closed group: no request button; existing roster unchanged
- [ ] Open group: member can request; leader cannot request own group as non-member edge cases
- [ ] Duplicate request blocked while pending
- [ ] Approve adds member + appears in My Groups + receives group alerts
- [ ] Reject allows re-request
- [ ] Leader can toggle `allowJoinRequests` only on led groups
- [ ] Admin can toggle on any group
- [ ] Non-approved org user cannot request
- [ ] Rules + callables reject bypass attempts
- [ ] `voluntary`: Leave group removes member immediately
- [ ] `request_required`: reason form required; pending until reviewed
- [ ] Leave denial alert includes rejection reason
- [ ] Admin/leader removal sends alert to removed member
- [ ] Sole leader cannot leave without assigning another leader

---

## Implementation order

1. Schema + models + repository methods (join + leave)  
2. Cloud Functions (join, leave, voluntary leave, enhanced `removeGroupMember`)  
3. Firestore rules + indexes  
4. Admin/leader policy toggles on create/edit group  
5. `BrowseGroupsScreen` + join request sheet  
6. `MyGroupsScreen` leave / request-to-leave actions  
7. Combined membership requests UI + badges (Join | Leave tabs)  
8. Membership event notifications (removed, leave denied with reason, etc.)  
9. Help guides + smoke test on MONHS demo groups  

See [MASTER_TASK_LIST.md → Epic 2.6.1](MASTER_TASK_LIST.md) for granular tasks.
