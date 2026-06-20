export type DeliveryCheckReason =
  | 'eligible'
  | 'missing'
  | 'not_published'
  | 'already_delivered'
  | 'scheduled_for_future';

export type DeliveryCheck = {
  shouldDeliver: boolean;
  reason: DeliveryCheckReason;
};

export type BulletinDeliveryCandidate = {
  status?: string;
  deliveredAt?: unknown;
  scheduledAt?: { toMillis(): number } | null;
};

export function shouldDeliverBulletin(
  data?: BulletinDeliveryCandidate,
  nowMs: number = Date.now(),
): DeliveryCheck {
  if (!data) return { shouldDeliver: false, reason: 'missing' };
  if (data.status !== 'published') {
    return { shouldDeliver: false, reason: 'not_published' };
  }
  if (data.deliveredAt) {
    return { shouldDeliver: false, reason: 'already_delivered' };
  }
  if (data.scheduledAt && data.scheduledAt.toMillis() > nowMs) {
    return { shouldDeliver: false, reason: 'scheduled_for_future' };
  }
  return { shouldDeliver: true, reason: 'eligible' };
}

export function buildBulletinRecipientIds(
  recipientIds: string[],
  authorId?: string | null,
): string[] {
  const uniqueIds = new Set<string>(recipientIds);
  if (authorId) uniqueIds.add(authorId);
  return [...uniqueIds];
}
