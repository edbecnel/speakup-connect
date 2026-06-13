import { defineSecret, defineString } from 'firebase-functions/params';

export const translationAiApiKey = defineSecret('TRANSLATION_AI_API_KEY');
export const translationAiProvider = defineString('TRANSLATION_AI_PROVIDER', {
  default: 'openai',
});
export const translationAiModel = defineString('TRANSLATION_AI_MODEL', {
  default: 'gpt-4o-mini',
});

const LOCALE_NAMES: Record<string, string> = {
  ceb: 'Bisaya / Cebuano',
  fil: 'Tagalog (Filipino)',
  en: 'US English',
};

export function targetLocaleName(code: string): string {
  return LOCALE_NAMES[code] ?? code;
}

/** Extract ICU-style placeholders from ARB text. */
export function extractPlaceholders(text: string): string[] {
  const matches = text.match(/\{[^{}]+\}/g) ?? [];
  return [...new Set(matches)].sort();
}

export function placeholdersMatch(source: string, target: string): boolean {
  const a = extractPlaceholders(source).join('|');
  const b = extractPlaceholders(target).join('|');
  return a === b;
}

function buildPrompt(
  stringKey: string,
  sourceText: string,
  targetLocaleCode: string,
  context?: string,
): string {
  const targetName = targetLocaleName(targetLocaleCode);
  return [
    'You translate UI strings for a school community mobile app (SpeakUp Connect).',
    `Source locale: en-US. Target locale: ${targetName} (${targetLocaleCode}).`,
    'Preserve ICU placeholders exactly, e.g. {name}, {count, plural, =0{No reports} other{{count} reports}}.',
    'Return ONLY the translated string — no quotes, labels, or explanation.',
    '',
    `Key: ${stringKey}`,
    context ? `Context: ${context}` : '',
    `English: ${sourceText}`,
  ]
    .filter(Boolean)
    .join('\n');
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
    throw new Error(
      `Placeholder mismatch for ${params.stringKey}. ` +
        `Expected: ${extractPlaceholders(params.sourceText).join(', ') || '(none)'}`,
    );
  }

  return { draft, model: params.model };
}

export function parseFeatureFromKey(stringKey: string): string {
  const match = stringKey.match(/^([a-z]+)/i);
  return match?.[1]?.toLowerCase() ?? 'other';
}
