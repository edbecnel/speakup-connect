import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

type ReviewAction = 'approve' | 'reject';

async function loadUserProfile(orgId: string, uid: string) {
  const snap = await db
    .collection('organizations').doc(orgId)
    .collection('users').doc(uid)
    .get();
  return { snap, data: snap.data() ?? {} };
}

async function assertApprovedOrgMember(orgId: string, uid: string) {
  const { data } = await loadUserProfile(orgId, uid);
  if (data['organizationId'] !== orgId || data['approvalStatus'] !== 'approved') {
    throw new HttpsError(
      'permission-denied',
      'Only approved organization members can perform this action.',
    );
  }
  return data;
}

async function isGroupLeader(orgId: string, groupId: string, uid: string) {
  const rosterSnap = await db
    .collection('organizations').doc(orgId)
    .collection('groups').doc(groupId)
    .collection('members').doc(uid)
    .get();
  if (rosterSnap.exists && rosterSnap.data()?.['groupRole'] === 'leader') {
    return true;
  }
  const indexSnap = await db
    .collection('organizations').doc(orgId)
    .collection('users').doc(uid)
    .collection('groupMemberships').doc(groupId)
    .get();
  return indexSnap.exists && indexSnap.data()?.['groupRole'] === 'leader';
}

async function isOrgAdmin(orgId: string, uid: string, token: Record<string, unknown>) {
  const role = token['role'] as string | undefined;
  const tokenOrg =
    (token['orgId'] as string | undefined) ??
    (token['organizationId'] as string | undefined);
  if (
    tokenOrg === orgId &&
    (role === 'admin' || role === 'super_admin' || role === 'owner')
  ) {
    return true;
  }
  const { data } = await loadUserProfile(orgId, uid);
  const profileRole = data['role'] as string | undefined;
  return (
    data['organizationId'] === orgId &&
    data['approvalStatus'] === 'approved' &&
    (profileRole === 'admin' ||
      profileRole === 'super_admin' ||
      profileRole === 'owner')
  );
}

async function hasManageGroupRoster(
  orgId: string,
  uid: string,
  token: Record<string, unknown>,
) {
  const perms = (token['permissions'] as string[] | undefined) ?? [];
  if (perms.includes('manageGroupRoster')) return true;
  const { data } = await loadUserProfile(orgId, uid);
  const profilePerms = (data['permissions'] as string[] | undefined) ?? [];
  return profilePerms.includes('manageGroupRoster');
}

async function assertCanReviewGroupMembership(
  orgId: string,
  groupId: string,
  uid: string,
  token: Record<string, unknown>,
) {
  if (await isOrgAdmin(orgId, uid, token)) return;
  if (await hasManageGroupRoster(orgId, uid, token)) return;
  if (await isGroupLeader(orgId, groupId, uid)) return;
  throw new HttpsError(
    'permission-denied',
    'You cannot review membership requests for this group.',
  );
}

async function isOnGroupRoster(orgId: string, groupId: string, uid: string) {
  const snap = await db
    .collection('organizations').doc(orgId)
    .collection('groups').doc(groupId)
    .collection('members').doc(uid)
    .get();
  return snap.exists;
}

async function countGroupLeaders(orgId: string, groupId: string) {
  const snap = await db
    .collection('organizations').doc(orgId)
    .collection('groups').doc(groupId)
    .collection('members')
    .where('groupRole', '==', 'leader')
    .get();
  return snap.size;
}

async function sendMembershipNotification(
  orgId: string,
  userId: string,
  payload: {
    title: string;
    body: string;
    groupId?: string;
    event?: string;
  },
) {
  const notification: Record<string, unknown> = {
    type: 'group_membership',
    title: payload.title,
    body: payload.body,
    read: false,
    data: {
      ...(payload.groupId ? { groupId: payload.groupId } : {}),
      ...(payload.event ? { event: payload.event } : {}),
    },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await db
    .collection('organizations').doc(orgId)
    .collection('users').doc(userId)
    .collection('notifications')
    .add(notification);
}

async function adjustPendingCount(
  orgId: string,
  groupId: string,
  field: 'pendingJoinRequestCount' | 'pendingLeaveRequestCount',
  delta: number,
) {
  if (delta === 0) return;
  const groupRef = db
    .collection('organizations').doc(orgId)
    .collection('groups').doc(groupId);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(groupRef);
    if (!snap.exists) return;
    const current = (snap.data()?.[field] as number | undefined) ?? 0;
    const next = Math.max(0, current + delta);
    tx.update(groupRef, {
      [field]: next,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });
}

async function addMemberToGroup(
  orgId: string,
  groupId: string,
  userId: string,
  displayName: string,
  addedBy: string,
) {
  const groupRef = db
    .collection('organizations').doc(orgId)
    .collection('groups').doc(groupId);
  const memberRef = groupRef.collection('members').doc(userId);

  await db.runTransaction(async (tx) => {
    const groupSnap = await tx.get(groupRef);
    if (!groupSnap.exists) {
      throw new HttpsError('not-found', 'Group not found.');
    }
    const memberSnap = await tx.get(memberRef);
    if (memberSnap.exists) {
      throw new HttpsError('already-exists', 'User is already a member.');
    }
    const groupName = (groupSnap.data()?.['name'] as string | undefined) ?? 'Group';
    tx.set(memberRef, {
      userId,
      organizationId: orgId,
      groupId,
      displayName,
      groupRole: 'member',
      joinedAt: admin.firestore.FieldValue.serverTimestamp(),
      addedBy,
    });
    tx.update(groupRef, {
      memberCount: admin.firestore.FieldValue.increment(1),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    // Index sync handled by syncUserGroupMembershipIndex trigger.
    void groupName;
  });
}

async function removeMemberFromGroup(
  orgId: string,
  groupId: string,
  userId: string,
) {
  const groupRef = db
    .collection('organizations').doc(orgId)
    .collection('groups').doc(groupId);
  const memberRef = groupRef.collection('members').doc(userId);

  await db.runTransaction(async (tx) => {
    const memberSnap = await tx.get(memberRef);
    if (!memberSnap.exists) return;
    tx.delete(memberRef);
    tx.update(groupRef, {
      memberCount: admin.firestore.FieldValue.increment(-1),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  const leaveReqRef = groupRef.collection('leaveRequests').doc(userId);
  const leaveSnap = await leaveReqRef.get();
  if (leaveSnap.exists && leaveSnap.data()?.['status'] === 'pending') {
    await leaveReqRef.update({
      status: 'withdrawn',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await adjustPendingCount(orgId, groupId, 'pendingLeaveRequestCount', -1);
  }
}

async function notifyGroupReviewers(
  orgId: string,
  groupId: string,
  groupName: string,
  title: string,
  body: string,
  excludeUid?: string,
) {
  const membersSnap = await db
    .collection('organizations').doc(orgId)
    .collection('groups').doc(groupId)
    .collection('members')
    .where('groupRole', '==', 'leader')
    .get();

  const reviewerIds = new Set<string>();
  for (const doc of membersSnap.docs) {
    if (doc.id !== excludeUid) reviewerIds.add(doc.id);
  }

  const orgSnap = await db.collection('organizations').doc(orgId).get();
  const adminsSnap = await db
    .collection('organizations').doc(orgId)
    .collection('users')
    .where('role', 'in', ['admin', 'owner', 'super_admin'])
    .get();
  for (const doc of adminsSnap.docs) {
    if (doc.id !== excludeUid) reviewerIds.add(doc.id);
  }
  void orgSnap;

  await Promise.all(
    Array.from(reviewerIds).map((uid) =>
      sendMembershipNotification(orgId, uid, {
        title,
        body,
        groupId,
        event: 'membership_review',
      }),
    ),
  );
}

async function loadGroup(orgId: string, groupId: string) {
  const snap = await db
    .collection('organizations').doc(orgId)
    .collection('groups').doc(groupId)
    .get();
  if (!snap.exists) {
    throw new HttpsError('not-found', 'Group not found.');
  }
  return { snap, data: snap.data() ?? {} };
}

// ── Join requests ─────────────────────────────────────────────────────────────

export const submitGroupJoinRequest = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const { orgId, groupId, message } = (request.data ?? {}) as {
    orgId?: string;
    groupId?: string;
    message?: string;
  };
  if (!orgId || !groupId) {
    throw new HttpsError('invalid-argument', 'orgId and groupId are required.');
  }

  const uid = request.auth.uid;
  const profile = await assertApprovedOrgMember(orgId, uid);
  const { data: groupData } = await loadGroup(orgId, groupId);

  if (groupData['allowJoinRequests'] !== true) {
    throw new HttpsError(
      'failed-precondition',
      'This group does not accept join requests.',
    );
  }
  if (await isOnGroupRoster(orgId, groupId, uid)) {
    throw new HttpsError('already-exists', 'You are already a member.');
  }

  const trimmedMessage = (message ?? '').trim();
  if (trimmedMessage.length > 200) {
    throw new HttpsError(
      'invalid-argument',
      'Message must be 200 characters or fewer.',
    );
  }

  const groupName = (groupData['name'] as string | undefined) ?? 'Group';
  const reqRef = db
    .collection('organizations').doc(orgId)
    .collection('groups').doc(groupId)
    .collection('joinRequests').doc(uid);

  const existing = await reqRef.get();
  if (existing.exists && existing.data()?.['status'] === 'pending') {
    throw new HttpsError('already-exists', 'You already have a pending request.');
  }

  const wasPending = existing.exists && existing.data()?.['status'] === 'pending';
  await reqRef.set({
    userId: uid,
    organizationId: orgId,
    groupId,
    groupName,
    displayName: (profile['displayName'] as string | undefined) ?? 'Member',
    studentId: (profile['studentId'] as string | undefined) ?? null,
    message: trimmedMessage || null,
    status: 'pending',
    reviewedBy: null,
    reviewedAt: null,
    rejectionReason: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  if (!wasPending) {
    await adjustPendingCount(orgId, groupId, 'pendingJoinRequestCount', 1);
  }

  await notifyGroupReviewers(
    orgId,
    groupId,
    groupName,
    'New join request',
    `${profile['displayName'] ?? 'A member'} requested to join ${groupName}.`,
    uid,
  );

  return { ok: true };
});

export const withdrawGroupJoinRequest = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }
  const { orgId, groupId } = (request.data ?? {}) as {
    orgId?: string;
    groupId?: string;
  };
  if (!orgId || !groupId) {
    throw new HttpsError('invalid-argument', 'orgId and groupId are required.');
  }

  const uid = request.auth.uid;
  const reqRef = db
    .collection('organizations').doc(orgId)
    .collection('groups').doc(groupId)
    .collection('joinRequests').doc(uid);
  const snap = await reqRef.get();
  if (!snap.exists || snap.data()?.['status'] !== 'pending') {
    throw new HttpsError('not-found', 'No pending join request found.');
  }

  await reqRef.update({
    status: 'withdrawn',
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  await adjustPendingCount(orgId, groupId, 'pendingJoinRequestCount', -1);
  return { ok: true };
});

export const reviewGroupJoinRequest = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const { orgId, groupId, userId, action, rejectionReason } = (request.data ?? {}) as {
    orgId?: string;
    groupId?: string;
    userId?: string;
    action?: ReviewAction;
    rejectionReason?: string;
  };
  if (!orgId || !groupId || !userId || !action) {
    throw new HttpsError(
      'invalid-argument',
      'orgId, groupId, userId, and action are required.',
    );
  }

  const reviewerUid = request.auth.uid;
  const token = request.auth.token as Record<string, unknown>;
  await assertCanReviewGroupMembership(orgId, groupId, reviewerUid, token);

  const reqRef = db
    .collection('organizations').doc(orgId)
    .collection('groups').doc(groupId)
    .collection('joinRequests').doc(userId);
  const reqSnap = await reqRef.get();
  if (!reqSnap.exists || reqSnap.data()?.['status'] !== 'pending') {
    throw new HttpsError('not-found', 'No pending join request found.');
  }

  const reqData = reqSnap.data() ?? {};
  const groupName = (reqData['groupName'] as string | undefined) ?? 'Group';

  if (action === 'approve') {
    await addMemberToGroup(
      orgId,
      groupId,
      userId,
      (reqData['displayName'] as string | undefined) ?? 'Member',
      reviewerUid,
    );
    await reqRef.update({
      status: 'approved',
      reviewedBy: reviewerUid,
      reviewedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await adjustPendingCount(orgId, groupId, 'pendingJoinRequestCount', -1);
    await sendMembershipNotification(orgId, userId, {
      title: 'Added to group',
      body: `You were added to ${groupName}.`,
      groupId,
      event: 'join_approved',
    });
  } else {
    const reason = (rejectionReason ?? '').trim();
    await reqRef.update({
      status: 'rejected',
      reviewedBy: reviewerUid,
      reviewedAt: admin.firestore.FieldValue.serverTimestamp(),
      rejectionReason: reason || null,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await adjustPendingCount(orgId, groupId, 'pendingJoinRequestCount', -1);
    const body = reason
      ? `Your request to join ${groupName} was declined. Reason: ${reason}`
      : `Your request to join ${groupName} was declined.`;
    await sendMembershipNotification(orgId, userId, {
      title: 'Join request declined',
      body,
      groupId,
      event: 'join_rejected',
    });
  }

  return { ok: true };
});

// ── Leave requests ────────────────────────────────────────────────────────────

async function assertNotSoleLeader(orgId: string, groupId: string, uid: string) {
  const memberSnap = await db
    .collection('organizations').doc(orgId)
    .collection('groups').doc(groupId)
    .collection('members').doc(uid)
    .get();
  if (!memberSnap.exists) return;
  if (memberSnap.data()?.['groupRole'] !== 'leader') return;
  const leaderCount = await countGroupLeaders(orgId, groupId);
  if (leaderCount <= 1) {
    throw new HttpsError(
      'failed-precondition',
      'Assign another leader before leaving.',
    );
  }
}

export const voluntaryLeaveGroup = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const { orgId, groupId } = (request.data ?? {}) as {
    orgId?: string;
    groupId?: string;
  };
  if (!orgId || !groupId) {
    throw new HttpsError('invalid-argument', 'orgId and groupId are required.');
  }

  const uid = request.auth.uid;
  await assertApprovedOrgMember(orgId, uid);
  const { data: groupData } = await loadGroup(orgId, groupId);

  if (groupData['memberLeavePolicy'] !== 'voluntary') {
    throw new HttpsError(
      'failed-precondition',
      'This group requires approval to leave.',
    );
  }
  if (!(await isOnGroupRoster(orgId, groupId, uid))) {
    throw new HttpsError('not-found', 'You are not a member of this group.');
  }

  await assertNotSoleLeader(orgId, groupId, uid);

  const groupName = (groupData['name'] as string | undefined) ?? 'Group';
  const profile = await loadUserProfile(orgId, uid);
  const displayName = (profile.data['displayName'] as string | undefined) ?? 'Member';

  await removeMemberFromGroup(orgId, groupId, uid);

  await notifyGroupReviewers(
    orgId,
    groupId,
    groupName,
    'Member left group',
    `${displayName} left ${groupName}.`,
    uid,
  );

  return { ok: true };
});

export const submitGroupLeaveRequest = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const { orgId, groupId, reason } = (request.data ?? {}) as {
    orgId?: string;
    groupId?: string;
    reason?: string;
  };
  if (!orgId || !groupId) {
    throw new HttpsError('invalid-argument', 'orgId and groupId are required.');
  }

  const trimmedReason = (reason ?? '').trim();
  if (trimmedReason.length < 20) {
    throw new HttpsError(
      'invalid-argument',
      'Please explain why you want to leave (at least 20 characters).',
    );
  }
  if (trimmedReason.length > 500) {
    throw new HttpsError(
      'invalid-argument',
      'Reason must be 500 characters or fewer.',
    );
  }

  const uid = request.auth.uid;
  const profile = await assertApprovedOrgMember(orgId, uid);
  const { data: groupData } = await loadGroup(orgId, groupId);

  if (groupData['memberLeavePolicy'] === 'voluntary') {
    throw new HttpsError(
      'failed-precondition',
      'You can leave this group directly without a request.',
    );
  }
  if (!(await isOnGroupRoster(orgId, groupId, uid))) {
    throw new HttpsError('not-found', 'You are not a member of this group.');
  }

  const groupName = (groupData['name'] as string | undefined) ?? 'Group';
  const reqRef = db
    .collection('organizations').doc(orgId)
    .collection('groups').doc(groupId)
    .collection('leaveRequests').doc(uid);

  const existing = await reqRef.get();
  if (existing.exists && existing.data()?.['status'] === 'pending') {
    throw new HttpsError('already-exists', 'You already have a pending leave request.');
  }

  const wasPending = existing.exists && existing.data()?.['status'] === 'pending';
  await reqRef.set({
    userId: uid,
    organizationId: orgId,
    groupId,
    groupName,
    displayName: (profile['displayName'] as string | undefined) ?? 'Member',
    studentId: (profile['studentId'] as string | undefined) ?? null,
    reason: trimmedReason,
    status: 'pending',
    reviewedBy: null,
    reviewedAt: null,
    rejectionReason: null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  if (!wasPending) {
    await adjustPendingCount(orgId, groupId, 'pendingLeaveRequestCount', 1);
  }

  await notifyGroupReviewers(
    orgId,
    groupId,
    groupName,
    'Leave request',
    `${profile['displayName'] ?? 'A member'} requested to leave ${groupName}.`,
    uid,
  );

  return { ok: true };
});

export const withdrawGroupLeaveRequest = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }
  const { orgId, groupId } = (request.data ?? {}) as {
    orgId?: string;
    groupId?: string;
  };
  if (!orgId || !groupId) {
    throw new HttpsError('invalid-argument', 'orgId and groupId are required.');
  }

  const uid = request.auth.uid;
  const reqRef = db
    .collection('organizations').doc(orgId)
    .collection('groups').doc(groupId)
    .collection('leaveRequests').doc(uid);
  const snap = await reqRef.get();
  if (!snap.exists || snap.data()?.['status'] !== 'pending') {
    throw new HttpsError('not-found', 'No pending leave request found.');
  }

  await reqRef.update({
    status: 'withdrawn',
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  await adjustPendingCount(orgId, groupId, 'pendingLeaveRequestCount', -1);
  return { ok: true };
});

export const reviewGroupLeaveRequest = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const { orgId, groupId, userId, action, rejectionReason } = (request.data ?? {}) as {
    orgId?: string;
    groupId?: string;
    userId?: string;
    action?: ReviewAction;
    rejectionReason?: string;
  };
  if (!orgId || !groupId || !userId || !action) {
    throw new HttpsError(
      'invalid-argument',
      'orgId, groupId, userId, and action are required.',
    );
  }

  const reviewerUid = request.auth.uid;
  const token = request.auth.token as Record<string, unknown>;
  await assertCanReviewGroupMembership(orgId, groupId, reviewerUid, token);

  const reqRef = db
    .collection('organizations').doc(orgId)
    .collection('groups').doc(groupId)
    .collection('leaveRequests').doc(userId);
  const reqSnap = await reqRef.get();
  if (!reqSnap.exists || reqSnap.data()?.['status'] !== 'pending') {
    throw new HttpsError('not-found', 'No pending leave request found.');
  }

  const reqData = reqSnap.data() ?? {};
  const groupName = (reqData['groupName'] as string | undefined) ?? 'Group';

  if (action === 'approve') {
    const memberSnap = await db
      .collection('organizations').doc(orgId)
      .collection('groups').doc(groupId)
      .collection('members').doc(userId)
      .get();
    if (memberSnap.exists && memberSnap.data()?.['groupRole'] === 'leader') {
      const leaderCount = await countGroupLeaders(orgId, groupId);
      if (leaderCount <= 1) {
        throw new HttpsError(
          'failed-precondition',
          'Assign another leader before approving this leave request.',
        );
      }
    }

    await removeMemberFromGroup(orgId, groupId, userId);
    await reqRef.update({
      status: 'approved',
      reviewedBy: reviewerUid,
      reviewedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await adjustPendingCount(orgId, groupId, 'pendingLeaveRequestCount', -1);
    await sendMembershipNotification(orgId, userId, {
      title: 'Left group',
      body: `You have left ${groupName}.`,
      groupId,
      event: 'leave_approved',
    });
  } else {
    const reason = (rejectionReason ?? '').trim();
    if (!reason) {
      throw new HttpsError(
        'invalid-argument',
        'A reason is required when denying a leave request.',
      );
    }
    await reqRef.update({
      status: 'rejected',
      reviewedBy: reviewerUid,
      reviewedAt: admin.firestore.FieldValue.serverTimestamp(),
      rejectionReason: reason,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await adjustPendingCount(orgId, groupId, 'pendingLeaveRequestCount', -1);
    await sendMembershipNotification(orgId, userId, {
      title: 'Leave request denied',
      body: `Your request to leave ${groupName} was denied. Reason: ${reason}`,
      groupId,
      event: 'leave_rejected',
    });
  }

  return { ok: true };
});

export const removeGroupMemberWithNotification = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const { orgId, groupId, userId } = (request.data ?? {}) as {
    orgId?: string;
    groupId?: string;
    userId?: string;
  };
  if (!orgId || !groupId || !userId) {
    throw new HttpsError(
      'invalid-argument',
      'orgId, groupId, and userId are required.',
    );
  }

  const actorUid = request.auth.uid;
  const token = request.auth.token as Record<string, unknown>;
  await assertCanReviewGroupMembership(orgId, groupId, actorUid, token);

  const { data: groupData } = await loadGroup(orgId, groupId);
  const groupName = (groupData['name'] as string | undefined) ?? 'Group';

  if (!(await isOnGroupRoster(orgId, groupId, userId))) {
    throw new HttpsError('not-found', 'Member not found on roster.');
  }

  await removeMemberFromGroup(orgId, groupId, userId);

  if (userId !== actorUid) {
    await sendMembershipNotification(orgId, userId, {
      title: 'Removed from group',
      body: `You were removed from ${groupName}.`,
      groupId,
      event: 'removed',
    });
  }

  logger.info('removeGroupMemberWithNotification', { orgId, groupId, userId, actorUid });
  return { ok: true };
});
