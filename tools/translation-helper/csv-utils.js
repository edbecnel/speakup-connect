/** @typedef {{ key: string, screen?: string, english?: string, translation: string, notes?: string, verified?: string, status?: string }} TranslationCsvRow */

/**
 * Escape a single CSV field (RFC 4180).
 * @param {unknown} value
 * @returns {string}
 */
export function escapeCsvField(value) {
  const s = String(value ?? '');
  if (/[",\r\n]/.test(s)) {
    return `"${s.replace(/"/g, '""')}"`;
  }
  return s;
}

/**
 * @param {Record<string, string>[]} rows
 * @param {string[]} headers
 * @returns {string}
 */
export function rowsToCsv(rows, headers) {
  const lines = [headers.map(escapeCsvField).join(',')];
  for (const row of rows) {
    lines.push(headers.map((h) => escapeCsvField(row[h] ?? '')).join(','));
  }
  // UTF-8 BOM helps Excel and Google Sheets detect encoding for Cebuano/Tagalog text.
  return `\uFEFF${lines.join('\r\n')}`;
}

/**
 * Parse CSV text into a 2D array of fields.
 * @param {string} text
 * @returns {string[][]}
 */
export function parseCsv(text) {
  const rows = [];
  let row = [];
  let field = '';
  let inQuotes = false;
  const s = text.replace(/^\uFEFF/, '');

  for (let i = 0; i < s.length; i++) {
    const c = s[i];
    const next = s[i + 1];
    if (inQuotes) {
      if (c === '"' && next === '"') {
        field += '"';
        i++;
      } else if (c === '"') {
        inQuotes = false;
      } else {
        field += c;
      }
    } else if (c === '"') {
      inQuotes = true;
    } else if (c === ',') {
      row.push(field);
      field = '';
    } else if (c === '\r' && next === '\n') {
      row.push(field);
      field = '';
      rows.push(row);
      row = [];
      i++;
    } else if (c === '\n' || c === '\r') {
      row.push(field);
      field = '';
      rows.push(row);
      row = [];
    } else {
      field += c;
    }
  }

  row.push(field);
  if (row.length > 1 || row[0] !== '') {
    rows.push(row);
  }

  while (rows.length > 0 && rows[rows.length - 1].every((cell) => cell === '')) {
    rows.pop();
  }

  return rows;
}

/** @param {string} header */
function normalizeHeader(header) {
  return String(header ?? '')
    .trim()
    .toLowerCase()
    .replace(/[\s-]+/g, '_');
}

/**
 * @param {string[]} headers
 * @param {string[]} aliases
 * @returns {number}
 */
function findColumnIndex(headers, aliases) {
  for (const alias of aliases) {
    const idx = headers.indexOf(alias);
    if (idx >= 0) return idx;
  }
  return -1;
}

const KEY_ALIASES = ['key', 'string_key', 'stringkey'];
const ENGLISH_ALIASES = ['english', 'source', 'source_value', 'sourcevalue', 'en'];
const TRANSLATION_ALIASES = [
  'translation',
  'target',
  'target_value',
  'targetvalue',
  'translated',
  'message',
];
const STATUS_ALIASES = ['status'];
const SCREEN_ALIASES = ['screen', 'ui_screen', 'location', 'context'];
const NOTES_ALIASES = ['notes', 'note', 'reviewer_notes', 'comment', 'comments'];
const VERIFIED_ALIASES = ['verified', 'checked', 'reviewed'];

/**
 * Parse translation CSV into row objects.
 * @param {string} text
 * @returns {{ rows: TranslationCsvRow[], warnings: string[] }}
 */
export function parseTranslationCsv(text) {
  const table = parseCsv(text);
  const warnings = [];
  if (table.length === 0) {
    return { rows: [], warnings: ['CSV file is empty.'] };
  }

  const headers = table[0].map(normalizeHeader);
  const keyIdx = findColumnIndex(headers, KEY_ALIASES);
  const translationIdx = findColumnIndex(headers, TRANSLATION_ALIASES);

  if (keyIdx < 0) {
    throw new Error(
      'CSV must include a "key" column (aliases: key, string_key).',
    );
  }
  if (translationIdx < 0) {
    throw new Error(
      'CSV must include a "translation" column (aliases: translation, target).',
    );
  }

  const englishIdx = findColumnIndex(headers, ENGLISH_ALIASES);
  const statusIdx = findColumnIndex(headers, STATUS_ALIASES);
  const screenIdx = findColumnIndex(headers, SCREEN_ALIASES);
  const notesIdx = findColumnIndex(headers, NOTES_ALIASES);
  const verifiedIdx = findColumnIndex(headers, VERIFIED_ALIASES);

  /** @type {TranslationCsvRow[]} */
  const rows = [];
  for (let i = 1; i < table.length; i++) {
    const cells = table[i];
    const key = String(cells[keyIdx] ?? '').trim();
    const translation = String(cells[translationIdx] ?? '').trim();
    if (!key) {
      warnings.push(`Row ${i + 1}: skipped — missing key.`);
      continue;
    }
    if (!translation) {
      continue;
    }
    /** @type {TranslationCsvRow} */
    const row = { key, translation };
    if (englishIdx >= 0) {
      row.english = String(cells[englishIdx] ?? '').trim();
    }
    if (statusIdx >= 0) {
      row.status = String(cells[statusIdx] ?? '').trim().toLowerCase();
    }
    if (screenIdx >= 0) {
      row.screen = String(cells[screenIdx] ?? '').trim();
    }
    if (notesIdx >= 0) {
      row.notes = String(cells[notesIdx] ?? '').trim();
    }
    if (verifiedIdx >= 0) {
      row.verified = String(cells[verifiedIdx] ?? '').trim();
    }
    rows.push(row);
  }

  if (rows.length === 0) {
    warnings.push('No rows with both key and translation were found.');
  }

  return { rows, warnings };
}
