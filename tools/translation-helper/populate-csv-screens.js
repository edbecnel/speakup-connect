/**
 * Add or refresh the screen column in a translation CSV using codebase key→screen mapping.
 *
 * Essential after app_en.arb is updated or new keys are added — run before sharing
 * the CSV with human reviewers.
 *
 * Usage (from repo root):
 *   node tools/translation-helper/populate-csv-screens.js lib/l10n/ceb_translations.csv
 *
 * Mapping logic: map-l10n-screens.js (scans lib/**/*.dart for l10n key usage).
 * Docs: docs/INTERNATIONALIZATION.md §11 — Populate screen column for reviewer CSV
 */
const fs = require('fs');
const path = require('path');
const { resolveScreen, keyToScreens } = require('./map-l10n-screens');

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
  const hasScreen = headers.includes('screen');
  const keyIdx = headers.indexOf('key');
  if (keyIdx < 0) {
    console.error('CSV must have a key column.');
    process.exit(1);
  }

  const outHeaders = hasScreen
    ? table[0]
    : ['key', 'screen', ...table[0].slice(1)];

  const normalizedOut = outHeaders.map(normalizeHeader);
  const screenOutIdx = normalizedOut.indexOf('screen');

  const rows = [];
  let fromCode = 0;
  let fromKey = 0;

  for (let i = 1; i < table.length; i++) {
    const cells = table[i];
    const row = {};
    for (let c = 0; c < headers.length; c++) {
      row[headers[c]] = cells[c] ?? '';
    }
    const key = String(row.key ?? '').trim();
    if (!key) continue;

    const screen = resolveScreen(key);
    if (keyToScreens.has(key)) {
      fromCode++;
    } else {
      fromKey++;
    }

    row.screen = screen;
    rows.push(
      Object.fromEntries(
        normalizedOut.map((h) => [h, row[h] ?? '']),
      ),
    );
  }

  const csv = rowsToCsv(rows, normalizedOut);
  fs.writeFileSync(csvFile, csv, 'utf8');
  console.log(`Updated ${rows.length} rows in ${csvFile}`);
  console.log(`Screen labels: ${fromCode} from Dart usage, ${fromKey} from key heuristics.`);
}

main();
