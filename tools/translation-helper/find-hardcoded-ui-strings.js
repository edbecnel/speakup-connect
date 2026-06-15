/**
 * Exhaustive inventory of likely user-facing hardcoded UI strings in lib/.
 * Run: node tools/translation-helper/find-hardcoded-ui-strings.js
 *      node tools/translation-helper/find-hardcoded-ui-strings.js --json
 *      node tools/translation-helper/find-hardcoded-ui-strings.js --check   (exit 1 if any remain)
 *
 * Pair with map-l10n-screens.js screen labels for Translation Helper context.
 */
const fs = require('fs');
const path = require('path');
const { screenLabelFromFile } = require('./map-l10n-screens.js');

const REPO_ROOT = path.resolve(__dirname, '../..');
const LIB_DIR = path.join(REPO_ROOT, 'lib');
const ALLOWLIST_PATH = path.join(__dirname, 'hardcoded-ui-allowlist.json');

/** @type {Array<{ id: string, re: RegExp, group?: number }>} */
const DETECTORS = [
  { id: 'Text', re: /\bText\s*\(\s*'((?:\\'|[^'\\])*)'/g },
  { id: 'Text', re: /\bText\s*\(\s*"((?:\\"|[^"\\])*)"/g },
  { id: 'const Text', re: /\bconst\s+Text\s*\(\s*'((?:\\'|[^'\\])*)'/g },
  { id: 'const Text', re: /\bconst\s+Text\s*\(\s*"((?:\\"|[^"\\])*)"/g },
  { id: 'label', re: /\blabel:\s*'((?:\\'|[^'\\])*)'/g },
  { id: 'label', re: /\blabel:\s*"((?:\\"|[^"\\])*)"/g },
  { id: 'title', re: /\btitle:\s*'((?:\\'|[^'\\])*)'/g },
  { id: 'title', re: /\btitle:\s*"((?:\\"|[^"\\])*)"/g },
  { id: 'hintText', re: /\bhintText:\s*'((?:\\'|[^'\\])*)'/g },
  { id: 'hintText', re: /\bhintText:\s*"((?:\\"|[^"\\])*)"/g },
  { id: 'hint', re: /\bhint:\s*'((?:\\'|[^'\\])*)'/g },
  { id: 'hint', re: /\bhint:\s*"((?:\\"|[^"\\])*)"/g },
  { id: 'labelText', re: /\blabelText:\s*'((?:\\'|[^'\\])*)'/g },
  { id: 'labelText', re: /\blabelText:\s*"((?:\\"|[^"\\])*)"/g },
  { id: 'helperText', re: /\bhelperText:\s*'((?:\\'|[^'\\])*)'/g },
  { id: 'helperText', re: /\bhelperText:\s*"((?:\\"|[^"\\])*)"/g },
  { id: 'tooltip', re: /\btooltip:\s*'((?:\\'|[^'\\])*)'/g },
  { id: 'tooltip', re: /\btooltip:\s*"((?:\\"|[^"\\])*)"/g },
  { id: 'semanticLabel', re: /\bsemanticLabel:\s*'((?:\\'|[^'\\])*)'/g },
  { id: 'semanticLabel', re: /\bsemanticLabel:\s*"((?:\\"|[^"\\])*)"/g },
  { id: 'message', re: /\bmessage:\s*'((?:\\'|[^'\\])*)'/g },
  { id: 'message', re: /\bmessage:\s*"((?:\\"|[^"\\])*)"/g },
  { id: 'content', re: /\bcontent:\s*Text\s*\(\s*'((?:\\'|[^'\\])*)'/g },
  { id: 'content', re: /\bcontent:\s*Text\s*\(\s*"((?:\\"|[^"\\])*)"/g },
  { id: 'content', re: /\bcontent:\s*'((?:\\'|[^'\\])*)'/g },
  { id: 'content', re: /\bcontent:\s*"((?:\\"|[^"\\])*)"/g },
  { id: 'child', re: /\bchild:\s*Text\s*\(\s*'((?:\\'|[^'\\])*)'/g },
  { id: 'child', re: /\bchild:\s*Text\s*\(\s*"((?:\\"|[^"\\])*)"/g },
];

const SKIP_PATH_PARTS = [
  '/l10n/app_localizations',
  '.g.dart',
  '.freezed.dart',
  '/generated/',
  '/test/',
];

const SKIP_FILE_SUFFIXES = ['_test.dart'];

/** Paths scanned for UI strings (presentation + shared widgets + validators). */
const SCAN_ROOTS = [
  path.join(LIB_DIR, 'features'),
  path.join(LIB_DIR, 'shared', 'widgets'),
  path.join(LIB_DIR, 'core', 'l10n', 'form_validators.dart'),
];

function shouldSkipFile(filePath) {
  const rel = filePath.replace(/\\/g, '/');
  if (SKIP_FILE_SUFFIXES.some((s) => rel.endsWith(s))) return true;
  if (SKIP_PATH_PARTS.some((p) => rel.includes(p))) return true;
  if (rel.includes('/domain/')) return true;
  if (rel.includes('/data/')) return true;
  if (rel.endsWith('translation_assignable_routes.dart')) return true;
  return false;
}

function walkDartFiles(dir) {
  if (!fs.existsSync(dir)) return [];
  if (fs.statSync(dir).isFile()) {
    return shouldSkipFile(dir) ? [] : [dir];
  }
  /** @type {string[]} */
  const out = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) out.push(...walkDartFiles(full));
    else if (entry.name.endsWith('.dart')) out.push(full);
  }
  return out.filter((f) => !shouldSkipFile(f));
}

function loadAllowlist() {
  if (!fs.existsSync(ALLOWLIST_PATH)) return [];
  try {
    const raw = JSON.parse(fs.readFileSync(ALLOWLIST_PATH, 'utf8'));
    return Array.isArray(raw) ? raw : [];
  } catch {
    return [];
  }
}

function allowlistMatch(entry, allowlist) {
  return allowlist.some((rule) => {
    if (rule.file && !entry.file.replace(/\\/g, '/').endsWith(rule.file)) {
      return false;
    }
    if (rule.line && rule.line !== entry.line) return false;
    if (rule.text && rule.text !== entry.text) return false;
    if (rule.pattern && !entry.text.includes(rule.pattern)) return false;
    return true;
  });
}

function isLocalizedLine(line) {
  return (
    /\bl10n\b/.test(line) ||
    /context\.l10n/.test(line) ||
    /AppLocalizations/.test(line) ||
    /localizedPermissionName/.test(line) ||
    /validation[A-Z]/.test(line)
  );
}

function looksUserFacing(text) {
  const t = text.trim();
  if (!t || t.length < 2) return false;
  if (/^[\d\s.,:;!?\-–—]+$/.test(t)) return false;
  if (/^https?:\/\//.test(t)) return false;
  if (/^\/[a-z]/.test(t)) return false;
  if (/^[a-z_]+$/.test(t) && t.includes('_') && !t.includes(' ')) return false;
  if (t.startsWith('package:')) return false;
  if (t === '...' || t === '—') return false;
  return /[A-Za-z]/.test(t);
}

function unescapeDartString(text) {
  return text.replace(/\\'/g, "'").replace(/\\"/g, '"').replace(/\\n/g, '\n');
}

function scanFile(filePath) {
  const rel = path.relative(REPO_ROOT, filePath).replace(/\\/g, '/');
  const screen = screenLabelFromFile(filePath) ?? 'App';
  const lines = fs.readFileSync(filePath, 'utf8').split(/\r?\n/);
  /** @type {Array<{ file: string, line: number, screen: string, kind: string, text: string, source: string }>} */
  const findings = [];

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    if (line.trimStart().startsWith('//')) continue;
    if (isLocalizedLine(line)) continue;

    for (const detector of DETECTORS) {
      detector.re.lastIndex = 0;
      let match;
      while ((match = detector.re.exec(line)) !== null) {
        const raw = match[1] ?? '';
        const text = unescapeDartString(raw);
        if (!looksUserFacing(text)) continue;
        // Flag string literals that start with user-facing English even when
        // they use Dart interpolation (${...}).
        const textPrefix = text.replace(/\$\{.*$/, '').trim();
        if (textPrefix && !looksUserFacing(textPrefix)) continue;
        findings.push({
          file: rel,
          line: i + 1,
          screen,
          kind: detector.id,
          text,
          source: line.trim(),
        });
      }
    }
  }

  return findings;
}

function main() {
  const asJson = process.argv.includes('--json');
  const checkOnly = process.argv.includes('--check');
  const allowlist = loadAllowlist();

  /** @type {string[]} */
  const files = [];
  for (const root of SCAN_ROOTS) {
    files.push(...walkDartFiles(root));
  }

  let findings = files.flatMap(scanFile);
  findings = findings.filter((f) => !allowlistMatch(f, allowlist));

  findings.sort(
    (a, b) =>
      a.screen.localeCompare(b.screen) ||
      a.file.localeCompare(b.file) ||
      a.line - b.line,
  );

  const byScreen = new Map();
  for (const f of findings) {
    if (!byScreen.has(f.screen)) byScreen.set(f.screen, []);
    byScreen.get(f.screen).push(f);
  }

  if (asJson) {
    console.log(JSON.stringify({ total: findings.length, findings }, null, 2));
  } else {
    console.log(`Scanned ${files.length} Dart files under lib/features, lib/shared/widgets, form_validators.`);
    console.log(`Hardcoded UI string candidates: ${findings.length} (after allowlist)\n`);
    for (const [screen, items] of [...byScreen.entries()].sort()) {
      console.log(`## ${screen} (${items.length})`);
      for (const item of items) {
        console.log(`  ${item.file}:${item.line} [${item.kind}] ${JSON.stringify(item.text)}`);
      }
      console.log('');
    }
    if (findings.length > 0) {
      console.log(
        'Next: add app_en.arb keys, replace literals with context.l10n.*, re-run with --check until 0.',
      );
    }
  }

  if (checkOnly && findings.length > 0) {
    process.exit(1);
  }
}

main();
