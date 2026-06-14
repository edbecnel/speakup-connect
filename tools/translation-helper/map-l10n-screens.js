/**
 * Build stringKey → human screen label map from Dart usage + key heuristics.
 * Run: node tools/translation-helper/map-l10n-screens.js
 */
const fs = require('fs');
const path = require('path');

const REPO_ROOT = path.resolve(__dirname, '../..');
const LIB_DIR = path.join(REPO_ROOT, 'lib');

const L10N_REF =
  /(?:context\.l10n|\.l10n|l10n)\.([a-zA-Z][a-zA-Z0-9]*)/g;
const VALIDATION_REF =
  /\b(validation[A-Z][a-zA-Z0-9]*)\b/g;

/** @param {string} snake */
function titleFromSnake(snake) {
  return snake
    .split('_')
    .filter(Boolean)
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase())
    .join(' ');
}

/** @param {string} filePath */
function screenLabelFromFile(filePath) {
  const rel = filePath.replace(/\\/g, '/');
  const screen = rel.match(/\/([a-z0-9_]+)_screen\.dart$/i);
  if (screen) return titleFromSnake(screen[1]);

  if (rel.includes('core/l10n/form_validators.dart')) {
    return 'Shared (forms)';
  }

  const widget = rel.match(
    /features\/[^/]+\/presentation\/(?:widgets|dialogs)\/([a-z0-9_]+)\.dart$/i,
  );
  if (widget) {
    const feature = rel.match(/features\/([^/]+)\//);
    const featureLabel = feature
      ? titleFromSnake(feature[1])
      : 'Shared';
    return `${featureLabel} — ${titleFromSnake(widget[1])}`;
  }

  const feature = rel.match(/features\/([^/]+)\//);
  if (feature) return `${titleFromSnake(feature[1])} (shared)`;

  if (rel.includes('/core/')) return 'Shared';
  return 'App';
}

/** @param {string} key */
function screenLabelFromKey(key) {
  if (key === 'appName') return 'App';

  const lowerPrefixes = [
    ['common', 'Shared'],
    ['validation', 'Shared (forms)'],
    ['orgTypeWord', 'Shared (org types)'],
    ['orgType', 'Organization'],
  ];
  for (const [prefix, label] of lowerPrefixes) {
    if (key.startsWith(prefix)) return label;
  }

  const parts = key.split(/(?=[A-Z])/);
  if (parts.length < 2) {
    return titleFromSnake(parts[0] ?? key);
  }

  const feature = parts[0].toLowerCase();
  const screenWord = parts[1];

  const featureLabels = {
    admin: 'Admin',
    auth: 'Auth',
    home: 'Home',
    settings: 'Settings',
    groups: 'Groups',
    reminder: 'Reminders',
    reminders: 'Reminders',
    compose: 'Compose',
    pending: 'Pending Approvals',
    member: 'Member Management',
    school: 'School',
    student: 'Student',
    role: 'Roles',
    roles: 'Roles',
    assign: 'Assign Role',
    capabilities: 'Capabilities',
    permission: 'Permissions',
    report: 'Reports',
    submit: 'Submit Report',
    help: 'Help',
    change: 'Change Password',
    translation: 'Translations',
    my: 'My Content',
    org: 'Organization',
    splash: 'Splash',
    announcement: 'Announcements',
    notifications: 'Notifications',
    alerts: 'Alerts',
  };

  const featureLabel = featureLabels[feature] ?? titleFromSnake(feature);

  /** Known second segments that name a screen (not a field type). */
  const screenSegments = new Set([
    'Dashboard',
    'Report',
    'Detail',
    'Branding',
    'Settings',
    'Screen',
    'Hub',
    'List',
    'Browse',
    'Create',
    'Edit',
    'Members',
    'Management',
    'Queue',
    'Roster',
    'Password',
    'Login',
    'Register',
    'Splash',
    'Approvals',
    'Responses',
    'Compose',
    'Confirmation',
    'Workspace',
    'Article',
    'Assignments',
    'Editor',
    'Capabilities',
    'Grades',
    'Users',
    'Enrolled',
    'Student',
    'Group',
    'Groups',
    'Announcement',
    'Announcements',
    'Reminder',
    'Reminders',
    'Broadcast',
    'Broadcasts',
    'Alerts',
    'History',
    'Profile',
    'Join',
    'Pending',
    'Blocked',
    'Unenrolled',
    'Apply',
    'Forgot',
    'Information',
    'Info',
  ]);

  if (screenWord === 'Dashboard') {
    return `${featureLabel} Dashboard`;
  }

  if (screenSegments.has(screenWord)) {
    const third = parts[2];
    if (third === 'Detail' && parts.length >= 3) {
      return `${featureLabel} ${screenWord} Detail`;
    }
    return `${featureLabel} ${screenWord}`;
  }

  return `${featureLabel} — ${screenWord}`;
}

/** @param {string} key */
function keyBasedScreen(key) {
  const label = screenLabelFromKey(key);
  if (label.includes('—')) return null;
  return label;
}

/** @param {string} dir */
function walkDartFiles(dir) {
  /** @type {string[]} */
  const out = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      if (entry.name === 'l10n' && dir.endsWith(`${path.sep}lib`)) continue;
      out.push(...walkDartFiles(full));
    } else if (entry.name.endsWith('.dart') && !entry.name.endsWith('.g.dart')) {
      out.push(full);
    }
  }
  return out;
}

/** @type {Map<string, Set<string>>} */
const keyToScreens = new Map();

for (const file of walkDartFiles(LIB_DIR)) {
  const text = fs.readFileSync(file, 'utf8');
  const label = screenLabelFromFile(file);

  for (const match of text.matchAll(L10N_REF)) {
    const key = match[1];
    if (!keyToScreens.has(key)) keyToScreens.set(key, new Set());
    keyToScreens.get(key).add(label);
  }

  if (file.replace(/\\/g, '/').includes('form_validators.dart')) {
    for (const match of text.matchAll(VALIDATION_REF)) {
      const key = match[1];
      if (!keyToScreens.has(key)) keyToScreens.set(key, new Set());
      keyToScreens.get(key).add('Shared (forms)');
    }
  }
}

/** @param {string} key */
function resolveScreen(key) {
  const fromKey = keyBasedScreen(key);
  const screens = keyToScreens.get(key);

  if (fromKey) {
    if (!screens || screens.size === 0) return fromKey;
    const list = [...screens];
    const onlyShared = list.every(
      (s) => s.endsWith('(shared)') || s === 'Shared' || s.startsWith('Shared ('),
    );
    if (onlyShared) return fromKey;
  }

  if (screens && screens.size > 0) {
    const list = [...screens].sort();
    if (list.length === 1) {
      if (list[0].endsWith('(shared)') && fromKey) return fromKey;
      return list[0];
    }
    if (list.length <= 3) return list.join(' / ');
    return fromKey ?? 'Shared';
  }
  return screenLabelFromKey(key);
}

module.exports = { resolveScreen, keyToScreens, screenLabelFromKey, keyBasedScreen };

if (require.main === module) {
  const keys = [...keyToScreens.keys()].sort();
  console.log(`Mapped ${keys.length} keys from Dart usage.`);
  console.log('adminDashboardLoadFailed →', resolveScreen('adminDashboardLoadFailed'));
  console.log('commonCancel →', resolveScreen('commonCancel'));
}
