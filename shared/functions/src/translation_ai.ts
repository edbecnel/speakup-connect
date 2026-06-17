import { HttpsError } from 'firebase-functions/v2/https';

const LOCALE_NAMES: Record<string, string> = {
  ceb: 'Bisaya / Cebuano',
  fil: 'Tagalog (Filipino)',
  en: 'US English',
};

export function targetLocaleName(code: string): string {
  return LOCALE_NAMES[code] ?? code;
}

/** Extract top-level `{...}` placeholders (handles nested ICU plural/select braces). */
export function extractPlaceholders(text: string): string[] {
  const placeholders: string[] = [];
  let i = 0;
  while (i < text.length) {
    if (text[i] !== '{') {
      i++;
      continue;
    }
    let depth = 0;
    const start = i;
    for (; i < text.length; i++) {
      if (text[i] === '{') depth++;
      else if (text[i] === '}') {
        depth--;
        if (depth === 0) {
          placeholders.push(text.slice(start, i + 1));
          i++;
          break;
        }
      }
    }
  }
  return placeholders;
}

function extractIcuCategoryKeys(icuRest: string): string[] {
  const keys: string[] = [];
  let i = icuRest.indexOf(',') + 1;
  while (i < icuRest.length) {
    while (i < icuRest.length && /\s/.test(icuRest[i])) i++;
    if (i >= icuRest.length) break;
    const keyStart = i;
    while (i < icuRest.length && icuRest[i] !== '{') i++;
    if (i >= icuRest.length) break;
    keys.push(icuRest.slice(keyStart, i).trim());
    if (icuRest[i] === '{') {
      let depth = 0;
      for (; i < icuRest.length; i++) {
        if (icuRest[i] === '{') depth++;
        else if (icuRest[i] === '}') {
          depth--;
          if (depth === 0) {
            i++;
            break;
          }
        }
      }
    }
  }
  return keys.sort();
}

function placeholderSignature(block: string): string {
  const inner = block.slice(1, -1);
  const firstComma = inner.indexOf(',');
  if (firstComma === -1) {
    return `simple:${inner.trim()}`;
  }
  const name = inner.slice(0, firstComma).trim();
  const rest = inner.slice(firstComma + 1).trim();
  if (rest.startsWith('plural')) {
    return `plural:${name}:${extractIcuCategoryKeys(rest).join(',')}`;
  }
  if (rest.startsWith('select')) {
    return `select:${name}:${extractIcuCategoryKeys(rest).join(',')}`;
  }
  return `simple:${inner.trim()}`;
}

function describePlaceholderRequirements(sourceText: string): string[] {
  return extractPlaceholders(sourceText).map((block) => {
    const sig = placeholderSignature(block);
    if (sig.startsWith('simple:')) {
      return `Copy exactly: ${block}`;
    }
    return (
      `Preserve ICU structure and plural/select keywords; translate only the ` +
      `human-readable text inside each branch: ${block}`
    );
  });
}

export function placeholdersMatch(source: string, target: string): boolean {
  const srcBlocks = extractPlaceholders(source);
  const tgtBlocks = extractPlaceholders(target);
  if (srcBlocks.length !== tgtBlocks.length) return false;

  for (let i = 0; i < srcBlocks.length; i++) {
    const srcSig = placeholderSignature(srcBlocks[i]);
    const tgtSig = placeholderSignature(tgtBlocks[i]);
    if (srcSig.startsWith('simple:')) {
      if (srcBlocks[i] !== tgtBlocks[i]) return false;
    } else if (srcSig !== tgtSig) {
      return false;
    }
  }
  return true;
}

/** Reads AI provider settings from Cloud Functions environment (shared/functions/.env at deploy). */
export function getTranslationAiConfig(): {
  apiKey: string;
  provider: string;
  model: string;
} {
  const apiKey = process.env.TRANSLATION_AI_API_KEY?.trim();
  if (!apiKey) {
    throw new HttpsError(
      'failed-precondition',
      'TRANSLATION_AI_API_KEY is not set. Add it to shared/functions/.env (see .env.example) ' +
        'and redeploy draftTranslation and batchDraftTranslations.',
    );
  }
  return {
    apiKey,
    provider: process.env.TRANSLATION_AI_PROVIDER?.trim() || 'openai',
    model: process.env.TRANSLATION_AI_MODEL?.trim() || 'gpt-4o-mini',
  };
}

function buildPrompt(
  stringKey: string,
  sourceText: string,
  targetLocaleCode: string,
  context?: string,
): string {
  const targetName = targetLocaleName(targetLocaleCode);
  const placeholderLines =
    describePlaceholderRequirements(sourceText).length === 0
      ? []
      : [
          'Placeholder rules:',
          ...describePlaceholderRequirements(sourceText).map((line) => `- ${line}`),
        ];
  return [
    'You translate UI strings for a school community mobile app (SpeakUp Connect).',
    `Source locale: en-US. Target locale: ${targetName} (${targetLocaleCode}).`,
    'Preserve ICU placeholders exactly, e.g. {name}, {count, plural, =0{No reports} other{{count} reports}}.',
    'For plural/select messages, keep {variable, plural/select, ...} syntax and branch keys (=1, other, etc.); translate only the text inside each branch.',
    'Return ONLY the translated string — no quotes, labels, or explanation.',
    ...placeholderLines,
    '',
    `Key: ${stringKey}`,
    context ? `Context: ${context}` : '',
    `English: ${sourceText}`,
  ]
    .filter(Boolean)
    .join('\n');
}

function buildPlaceholderRetryPrompt(
  sourceText: string,
  targetLocaleCode: string,
  failedDraft: string,
): string {
  const targetName = targetLocaleName(targetLocaleCode);
  const requirements = describePlaceholderRequirements(sourceText);
  return [
    'Fix a UI translation that dropped or changed required placeholders.',
    `Target locale: ${targetName} (${targetLocaleCode}).`,
    `English source: ${sourceText}`,
    'Required placeholder structure:',
    ...requirements.map((line) => `- ${line}`),
    `Incorrect attempt: ${failedDraft}`,
    'Return ONLY the corrected translation — no quotes or explanation.',
  ].join('\n');
}

async function callOpenAi(
  apiKey: string,
  model: string,
  prompt: string,
): Promise<string> {
  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model,
      temperature: 0.2,
      messages: [{ role: 'user', content: prompt }],
    }),
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`OpenAI API error ${response.status}: ${body.slice(0, 200)}`);
  }

  const json = (await response.json()) as {
    choices?: Array<{ message?: { content?: string } }>;
  };
  const content = json.choices?.[0]?.message?.content?.trim();
  if (!content) {
    throw new Error('OpenAI returned empty content');
  }
  return content.replace(/^["']|["']$/g, '');
}

export async function draftTranslationText(params: {
  stringKey: string;
  sourceText: string;
  targetLocaleCode: string;
  context?: string;
  apiKey: string;
  provider: string;
  model: string;
}): Promise<{ draft: string; model: string }> {
  const prompt = buildPrompt(
    params.stringKey,
    params.sourceText,
    params.targetLocaleCode,
    params.context,
  );

  let draft: string;
  switch (params.provider) {
    case 'openai':
      draft = await callOpenAi(params.apiKey, params.model, prompt);
      break;
    default:
      throw new Error(
        `Unsupported TRANSLATION_AI_PROVIDER "${params.provider}". Use openai for MVP.`,
      );
  }

  if (!placeholdersMatch(params.sourceText, draft)) {
    const placeholders = extractPlaceholders(params.sourceText);
    if (placeholders.length > 0 && params.provider === 'openai') {
      const retryPrompt = buildPlaceholderRetryPrompt(
        params.sourceText,
        params.targetLocaleCode,
        draft,
      );
      draft = await callOpenAi(params.apiKey, params.model, retryPrompt);
    }
  }

  if (!placeholdersMatch(params.sourceText, draft)) {
    throw new Error(
      `Placeholder mismatch for ${params.stringKey}. ` +
        `Expected structure: ${describePlaceholderRequirements(params.sourceText).join(' · ') || '(none)'}`,
    );
  }

  return { draft, model: params.model };
}

export function parseFeatureFromKey(stringKey: string): string {
  const match = stringKey.match(/^([a-z]+)/i);
  return match?.[1]?.toLowerCase() ?? 'other';
}
