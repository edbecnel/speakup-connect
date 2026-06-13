import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions';
import * as admin from 'firebase-admin';
import { assertPlatformSuperAdmin } from './translation_auth';
import {
  draftTranslationText,
  parseFeatureFromKey,
  placeholdersMatch,
  translationAiApiKey,
  translationAiModel,
  translationAiProvider,
} from './translation_ai';

const db = admin.firestore();

const BATCH_CHUNK_SIZE = 25;
const BATCH_DELAY_MS = 400;

export type TranslationStatus =
  | 'missing'
  | 'ai_draft'
  | 'ai_draft_failed'
  | 'in_review'
  | 'approved';

interface TranslationEntry {
  stringKey: string;
  sourceLocale: string;
  sourceValue: string;
  targetValue: string | null;
  aiDraft: string | null;
  aiModel: string | null;
  aiDraftedAt: admin.firestore.Timestamp | null;
  aiDraftError: string | null;
  status: TranslationStatus;
  context: string | null;
  reviewedBy: string | null;
  updatedAt: admin.firestore.Timestamp;
}

function stringsRef(locale: string) {
  return db.collection('languages').doc(locale).collection('strings');
}

function stringDocRef(locale: string, stringKey: string) {
  return stringsRef(locale).doc(stringKey);
}

async function isAiDraftEnabled(): Promise<boolean> {
  const snap = await db.collection('platform').doc('i18n').get();
  if (!snap.exists) return true;
  return snap.data()?.['useAiDraft'] !== false;
}

function entryFromSnap(
  id: string,
  data: admin.firestore.DocumentData,
): TranslationEntry {
  return {
    stringKey: id,
    sourceLocale: (data['sourceLocale'] as string) ?? 'en',
    sourceValue: (data['sourceValue'] as string) ?? '',
    targetValue: (data['targetValue'] as string | null) ?? null,
    aiDraft: (data['aiDraft'] as string | null) ?? null,
    aiModel: (data['aiModel'] as string | null) ?? null,
    aiDraftedAt: (data['aiDraftedAt'] as admin.firestore.Timestamp | null) ?? null,
    aiDraftError: (data['aiDraftError'] as string | null) ?? null,
    status: (data['status'] as TranslationStatus) ?? 'missing',
    context: (data['context'] as string | null) ?? null,
    reviewedBy: (data['reviewedBy'] as string | null) ?? null,
    updatedAt:
      (data['updatedAt'] as admin.firestore.Timestamp) ??
      admin.firestore.Timestamp.now(),
  };
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function updateLocaleMetadata(locale: string): Promise<void> {
  const snap = await stringsRef(locale).get();
  const total = snap.size;
  let approved = 0;
  for (const doc of snap.docs) {
    if (doc.data()['status'] === 'approved') approved++;
  }
  const completionPercent = total === 0 ? 0 : Math.round((approved / total) * 100);
  await db.collection('languages').doc(locale).set(
    {
      languageCode: locale,
      stringCount: total,
      completionPercent,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
}

const aiSecrets = [translationAiApiKey];

export const importTranslationSource = onCall(async (request) => {
  assertPlatformSuperAdmin(request);
  const targetLocale = request.data?.['targetLocale'] as string | undefined;
  const entries = request.data?.['entries'] as
    | Array<{ key: string; sourceValue: string; context?: string }>
    | undefined;

  if (!targetLocale || !Array.isArray(entries) || entries.length === 0) {
    throw new HttpsError(
      'invalid-argument',
      'targetLocale and entries[] are required.',
    );
  }

  let imported = 0;
  let updated = 0;
  const batch = db.batch();
  const now = admin.firestore.FieldValue.serverTimestamp();

  for (const entry of entries) {
    const key = entry.key?.trim();
    if (!key || key.startsWith('@') || !entry.sourceValue) continue;

    const ref = stringDocRef(targetLocale, key);
    const existing = await ref.get();
    if (existing.exists) {
      const data = existing.data() ?? {};
      batch.set(
        ref,
        {
          sourceLocale: 'en',
          sourceValue: entry.sourceValue,
          context: entry.context ?? data['context'] ?? null,
          updatedAt: now,
        },
        { merge: true },
      );
      updated++;
    } else {
      batch.set(ref, {
        stringKey: key,
        sourceLocale: 'en',
        sourceValue: entry.sourceValue,
        targetValue: null,
        aiDraft: null,
        aiModel: null,
        aiDraftedAt: null,
        aiDraftError: null,
        status: 'missing',
        context: entry.context ?? null,
        reviewedBy: null,
        updatedAt: now,
      });
      imported++;
    }
  }

  await batch.commit();
  await updateLocaleMetadata(targetLocale);

  logger.info('importTranslationSource', { targetLocale, imported, updated });
  return { ok: true, imported, updated, total: imported + updated };
});

export const listTranslationEntries = onCall(async (request) => {
  assertPlatformSuperAdmin(request);
  const targetLocale = request.data?.['targetLocale'] as string | undefined;
  const statusFilter = request.data?.['status'] as TranslationStatus | undefined;
  const featureFilter = request.data?.['feature'] as string | undefined;
  const search = (request.data?.['search'] as string | undefined)?.trim().toLowerCase();

  if (!targetLocale) {
    throw new HttpsError('invalid-argument', 'targetLocale is required.');
  }

  const snap = await stringsRef(targetLocale).get();
  let entries = snap.docs
    .map((doc) => entryFromSnap(doc.id, doc.data()))
    .sort((a, b) => a.stringKey.localeCompare(b.stringKey));

  if (statusFilter) {
    entries = entries.filter((e) => e.status === statusFilter);
  }
  if (featureFilter) {
    entries = entries.filter(
      (e) => parseFeatureFromKey(e.stringKey) === featureFilter.toLowerCase(),
    );
  }
  if (search) {
    entries = entries.filter(
      (e) =>
        e.stringKey.toLowerCase().includes(search) ||
        e.sourceValue.toLowerCase().includes(search) ||
        (e.targetValue?.toLowerCase().includes(search) ?? false) ||
        (e.aiDraft?.toLowerCase().includes(search) ?? false),
    );
  }

  return { entries };
});

export const saveTranslationEntry = onCall(async (request) => {
  const uid = assertPlatformSuperAdmin(request);
  const targetLocale = request.data?.['targetLocale'] as string | undefined;
  const stringKey = request.data?.['stringKey'] as string | undefined;
  const targetValue = request.data?.['targetValue'] as string | undefined;
  const status = request.data?.['status'] as TranslationStatus | undefined;
  const context = request.data?.['context'] as string | undefined;

  if (!targetLocale || !stringKey) {
    throw new HttpsError('invalid-argument', 'targetLocale and stringKey required.');
  }

  const ref = stringDocRef(targetLocale, stringKey);
  const existing = await ref.get();
  if (!existing.exists) {
    throw new HttpsError('not-found', `Unknown string key: ${stringKey}`);
  }

  const sourceValue = (existing.data()?.['sourceValue'] as string) ?? '';
  const patch: Record<string, unknown> = {
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  if (targetValue !== undefined) {
    if (targetValue && !placeholdersMatch(sourceValue, targetValue)) {
      throw new HttpsError(
        'invalid-argument',
        'Target text must preserve ICU placeholders from English source.',
      );
    }
    patch['targetValue'] = targetValue || null;
  }
  if (status !== undefined) {
    patch['status'] = status;
    if (status === 'approved') {
      patch['reviewedBy'] = uid;
    }
  }
  if (context !== undefined) {
    patch['context'] = context || null;
  }

  await ref.set(patch, { merge: true });
  await updateLocaleMetadata(targetLocale);
  return { ok: true };
});

export const draftTranslation = onCall(
  { secrets: aiSecrets },
  async (request) => {
    assertPlatformSuperAdmin(request);
    if (!(await isAiDraftEnabled())) {
      throw new HttpsError('failed-precondition', 'AI draft is disabled.');
    }

    const targetLocale = request.data?.['targetLocale'] as string | undefined;
    const stringKey = request.data?.['stringKey'] as string | undefined;
    let sourceText = request.data?.['sourceText'] as string | undefined;
    const context = request.data?.['context'] as string | undefined;

    if (!targetLocale || !stringKey) {
      throw new HttpsError('invalid-argument', 'targetLocale and stringKey required.');
    }

    const ref = stringDocRef(targetLocale, stringKey);
    const existing = await ref.get();
    if (existing.exists) {
      const data = existing.data() ?? {};
      sourceText = sourceText ?? (data['sourceValue'] as string);
      if (
        data['status'] === 'approved' &&
        data['sourceValue'] === sourceText &&
        data['aiDraft']
      ) {
        return {
          draft: data['aiDraft'],
          model: data['aiModel'],
          cached: true,
        };
      }
    }

    if (!sourceText) {
      throw new HttpsError('invalid-argument', 'sourceText is required.');
    }

    try {
      const { draft, model } = await draftTranslationText({
        stringKey,
        sourceText,
        targetLocaleCode: targetLocale,
        context,
        apiKey: translationAiApiKey.value(),
        provider: translationAiProvider.value(),
        model: translationAiModel.value(),
      });

      await ref.set(
        {
          stringKey,
          sourceLocale: 'en',
          sourceValue: sourceText,
          aiDraft: draft,
          aiModel: model,
          aiDraftedAt: admin.firestore.FieldValue.serverTimestamp(),
          aiDraftError: null,
          status: 'ai_draft',
          context: context ?? existing.data()?.['context'] ?? null,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      await updateLocaleMetadata(targetLocale);

      logger.info('draftTranslation ok', { stringKey, targetLocale, model });
      return { draft, model, cached: false };
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      await ref.set(
        {
          stringKey,
          sourceLocale: 'en',
          sourceValue: sourceText,
          status: 'ai_draft_failed',
          aiDraftError: message,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      throw new HttpsError('internal', message);
    }
  },
);

export const batchDraftTranslations = onCall(
  { secrets: aiSecrets },
  async (request) => {
    assertPlatformSuperAdmin(request);
    if (!(await isAiDraftEnabled())) {
      throw new HttpsError('failed-precondition', 'AI draft is disabled.');
    }

    const targetLocale = request.data?.['targetLocale'] as string | undefined;
    const stringKeys = request.data?.['stringKeys'] as string[] | undefined;
    const onlyMissing = request.data?.['onlyMissing'] !== false;

    if (!targetLocale) {
      throw new HttpsError('invalid-argument', 'targetLocale is required.');
    }

    let keys = stringKeys ?? [];
    if (keys.length === 0) {
      const snap = await stringsRef(targetLocale).get();
      keys = snap.docs
        .filter((doc) => {
          if (!onlyMissing) return true;
          const status = doc.data()['status'] as string;
          return status === 'missing' || status === 'ai_draft_failed';
        })
        .map((doc) => doc.id);
    }

    if (keys.length === 0) {
      return { ok: true, total: 0, succeeded: 0, results: [] };
    }

    const results: Array<{ stringKey: string; ok: boolean; error?: string }> = [];
    const apiKey = translationAiApiKey.value();
    const provider = translationAiProvider.value();
    const model = translationAiModel.value();

    for (let i = 0; i < keys.length; i += BATCH_CHUNK_SIZE) {
      const chunk = keys.slice(i, i + BATCH_CHUNK_SIZE);
      for (const stringKey of chunk) {
        const ref = stringDocRef(targetLocale, stringKey);
        const snap = await ref.get();
        if (!snap.exists) {
          results.push({ stringKey, ok: false, error: 'not_found' });
          continue;
        }
        const data = snap.data() ?? {};
        const sourceText = data['sourceValue'] as string;
        if (!sourceText) {
          results.push({ stringKey, ok: false, error: 'no_source' });
          continue;
        }
        if (
          onlyMissing &&
          data['status'] === 'approved' &&
          data['aiDraft'] &&
          data['sourceValue'] === sourceText
        ) {
          results.push({ stringKey, ok: true });
          continue;
        }

        try {
          const { draft, model: usedModel } = await draftTranslationText({
            stringKey,
            sourceText,
            targetLocaleCode: targetLocale,
            context: (data['context'] as string | undefined) ?? undefined,
            apiKey,
            provider,
            model,
          });
          await ref.set(
            {
              aiDraft: draft,
              aiModel: usedModel,
              aiDraftedAt: admin.firestore.FieldValue.serverTimestamp(),
              aiDraftError: null,
              status: 'ai_draft',
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true },
          );
          results.push({ stringKey, ok: true });
        } catch (err) {
          const message = err instanceof Error ? err.message : String(err);
          await ref.set(
            {
              status: 'ai_draft_failed',
              aiDraftError: message,
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true },
          );
          results.push({ stringKey, ok: false, error: message });
        }
      }
      if (i + BATCH_CHUNK_SIZE < keys.length) {
        await sleep(BATCH_DELAY_MS);
      }
    }

    await updateLocaleMetadata(targetLocale);
    const succeeded = results.filter((r) => r.ok).length;
    logger.info('batchDraftTranslations', {
      targetLocale,
      total: results.length,
      succeeded,
    });
    return { ok: true, total: results.length, succeeded, results };
  },
);

export const exportTranslationArb = onCall(async (request) => {
  assertPlatformSuperAdmin(request);
  const targetLocale = request.data?.['targetLocale'] as string | undefined;
  const includeEnglishFallback =
    request.data?.['includeEnglishFallback'] !== false;

  if (!targetLocale) {
    throw new HttpsError('invalid-argument', 'targetLocale is required.');
  }

  const snap = await stringsRef(targetLocale).get();
  const arb: Record<string, string> = {
    '@@locale': targetLocale === 'en' ? 'en' : targetLocale,
  };

  for (const doc of snap.docs) {
    const data = doc.data();
    const key = doc.id;
    if (key.startsWith('@')) continue;

    let value: string | null = null;
    if (data['status'] === 'approved' && data['targetValue']) {
      value = data['targetValue'] as string;
    } else if (includeEnglishFallback) {
      value = (data['targetValue'] as string | null) ??
        (data['aiDraft'] as string | null) ??
        (data['sourceValue'] as string);
    }

    if (value) {
      arb[key] = value;
    }
  }

  return { locale: targetLocale, arb, keyCount: Object.keys(arb).length - 1 };
});
