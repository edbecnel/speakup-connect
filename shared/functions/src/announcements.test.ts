import test from 'node:test';
import assert from 'node:assert/strict';

import {
  buildBulletinRecipientIds,
  shouldDeliverBulletin,
} from './announcements_delivery_utils';

test('buildBulletinRecipientIds includes author and dedupes recipients', () => {
  const recipients = buildBulletinRecipientIds(['u1', 'u2', 'u1'], 'author-1');
  assert.deepEqual(
    [...recipients].sort(),
    ['author-1', 'u1', 'u2'].sort(),
  );
});

test('buildBulletinRecipientIds keeps author once when already in list', () => {
  const recipients = buildBulletinRecipientIds(['u1', 'author-1'], 'author-1');
  assert.deepEqual(recipients.sort(), ['author-1', 'u1'].sort());
});

test('shouldDeliverBulletin allows published unscheduled bulletins', () => {
  const result = shouldDeliverBulletin({ status: 'published' });
  assert.equal(result.shouldDeliver, true);
  assert.equal(result.reason, 'eligible');
});

test('shouldDeliverBulletin blocks pending bulletins', () => {
  const result = shouldDeliverBulletin({ status: 'pending' });
  assert.equal(result.shouldDeliver, false);
  assert.equal(result.reason, 'not_published');
});

test('shouldDeliverBulletin blocks scheduled bulletins before due time', () => {
  const nowMs = Date.UTC(2026, 5, 20, 10, 0, 0);
  const result = shouldDeliverBulletin(
    {
      status: 'published',
      scheduledAt: { toMillis: () => nowMs + 60_000 },
    },
    nowMs,
  );

  assert.equal(result.shouldDeliver, false);
  assert.equal(result.reason, 'scheduled_for_future');
});
