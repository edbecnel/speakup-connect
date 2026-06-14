/**
 * Refresh reviewer CSV columns: screen (from Dart usage), plus review/verified placeholders.
 *
 * Essential after app_en.arb is updated or new keys are added — run before sharing
 * the CSV with human reviewers.
 *
 * Output columns: key, screen, english, translation, review, verified, status
 * The review column feeds the Translation Helper Review column on CSV import.
 *
 * Usage (from repo root):
 *   node tools/translation-helper/populate-csv-screens.js lib/l10n/ceb_translations.csv
 *
 * Mapping logic: map-l10n-screens.js (scans lib Dart files for l10n key usage).
 * Docs: docs/INTERNATIONALIZATION.md §11 — Populate screen column for reviewer CSV
 */
const fs = require('fs');
const path = require('path');
const { resolveScreen, keyToScreens } = require('./map-l10n-screens');

/** Canonical reviewer CSV column order. */
const CANONICAL_HEADERS = [
  'key',
  'screen',
  'english',
  'translation',
  'review',
  'verified',
  'status',
];

function escapeCsvField(value) {
  const s = String(value ?? '');
  if (/[",\r\n]/.test(s)) {
    return `"${s.replace(/"/g, '""')}"`;
  }
  return s;
}

function rowsToCsv(rows, headers) {
  const lines = [headers.map(escapeCsvField).join(',')];
  for (const row of rows) {
    lines.push(headers.map((h) => escapeCsvField(row[h] ?? '')).join(','));
  }
  return `\uFEFF${lines.join('\r\n')}`;
}

function parseCsv(text) {
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

function normalizeHeader(header) {
  return String(header ?? '')
    .trim()
    .toLowerCase()
    .replace(/[\s-]+/g, '_');
}

/** @param {Record<string, string>} row */
function reviewTextFromRow(row) {
  return String(row.review ?? row.notes ?? '').trim();
}

function main() {
  const csvFile =
    process.argv[2] ||
    path.join(__dirname, '../../lib/l10n/ceb_translations.csv');
  const text = fs.readFileSync(csvFile, 'utf8');
  const table = parseCsv(text);
  if (table.length === 0) {
    console.error('CSV is empty.');
    process.exit(1);
  }

  const headers = table[0].map(normalizeHeader);
  const keyIdx = headers.indexOf('key');
  if (keyIdx < 0) {
    console.error('CSV must have a key column.');
    process.exit(1);
  }

  const rows = [];
  let fromCode = 0;
  let fromKey = 0;

  for (let i = 1; i < table.length; i++) {
    const cells = table[i];
    const raw = {};
    for (let c = 0; c < headers.length; c++) {
      raw[headers[c]] = cells[c] ?? '';
    }
    const key = String(raw.key ?? '').trim();
    if (!key) continue;

    const screen = resolveScreen(key);
    if (keyToScreens.has(key)) {
      fromCode++;
    } else {
      fromKey++;
    }

    rows.push({
      key,
      screen,
      english: raw.english ?? '',
      translation: raw.translation ?? '',
      review: reviewTextFromRow(raw),
      verified: raw.verified ?? '',
      status: raw.status ?? '',
    });
  }

  const csv = rowsToCsv(rows, CANONICAL_HEADERS);
  fs.writeFileSync(csvFile, csv, 'utf8');
  console.log(`Updated ${rows.length} rows in ${csvFile}`);
  console.log(`Columns: ${CANONICAL_HEADERS.join(', ')}`);
  console.log(`Screen labels: ${fromCode} from Dart usage, ${fromKey} from key heuristics.`);
}

main();
