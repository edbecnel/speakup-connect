/**
 * Build screen label → assignable route map from Dart screens + route constants.
 * Run: node tools/translation-helper/generate-screen-route-aliases.js
 */
const fs = require('fs');
const path = require('path');

const REPO = path.resolve(__dirname, '../..');
const ASSIGNABLE = path.join(
  REPO,
  'functions/src/data/assignable_routes.json',
);
const OUT = path.join(REPO, 'functions/src/data/screen_name_route_aliases.json');

const assignableRoutes = JSON.parse(fs.readFileSync(ASSIGNABLE, 'utf8'));
const assignablePaths = new Set(assignableRoutes.map((r) => r.route));
const labelToRoute = new Map(
  assignableRoutes.map((r) => [r.label.toLowerCase(), r.route]),
);

/** @param {string} className e.g. AdminBrandingScreen */
function labelFromScreenClass(className) {
  const base = className.replace(/Screen$/, '');
  return base
    .replace(/([A-Z])/g, ' $1')
    .trim()
    .replace(/\s+/g, ' ');
}

function titleFromSnake(snake) {
  return snake
    .split('_')
    .filter(Boolean)
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase())
    .join(' ');
}

function labelFromScreenFile(filePath) {
  const rel = filePath.replace(/\\/g, '/');
  const m = rel.match(/\/([a-z0-9_]+)_screen\.dart$/i);
  return m ? titleFromSnake(m[1]) : null;
}

/** Parse Routes.xxx = '/path' from route_constants.dart */
function loadRouteConstants() {
  const text = fs.readFileSync(
    path.join(REPO, 'lib/core/constants/route_constants.dart'),
    'utf8',
  );
  /** @type {Map<string, string>} */
  const map = new Map();
  for (const m of text.matchAll(
    /static const String (\w+) = '([^']+)';/g,
  )) {
    map.set(m[1], m[2]);
  }
  return map;
}

/** Parse path: Routes.xxx + ScreenClass from app_router.dart blocks */
function loadScreenRoutes(routeConstants) {
  const text = fs.readFileSync(
    path.join(REPO, 'lib/core/router/app_router.dart'),
    'utf8',
  );
  /** @type {Map<string, string>} screenClass -> path */
  const map = new Map();
  const blocks = text.split(/GoRoute\s*\(/);
  for (const block of blocks) {
    const pathMatch = block.match(/path:\s*Routes\.(\w+)/);
    const screenMatch = block.match(/const\s+(\w+Screen)\(\)/);
    if (!pathMatch || !screenMatch) continue;
    const routeKey = pathMatch[1];
    const routePath = routeConstants.get(routeKey);
    if (!routePath) continue;
    map.set(screenMatch[1], routePath);
  }
  return map;
}

/** Manual overrides where labels differ from assignable route labels. */
const MANUAL_ALIASES = {
  'Home Dashboard': '/home',
  'Admin Branding': '/admin/settings',
  'Member Approval Queue': '/join-applications',
  'Reminder Approval Queue': '/reminders/approvals',
  'Report Details': '/reports/mine',
  'Admin Report Detail': '/admin',
  'Help Article': '/help',
  'Broadcast Detail': '/reminders/mine',
  'Announcement Detail': '/announcements',
  'Notification Detail': '/notifications/history',
  'Role Editor': '/admin/roles',
  'Assign Role': '/admin/roles',
  'Edit Member': '/enrolled-users',
  'Group Membership Requests': '/groups',
  'Add Group Members': '/groups',
  'Group Members': '/groups',
  'Edit Group': '/groups',
  'Edit Group Position Roles': '/groups',
  'Reminder Responses': '/reminders/mine',
  'Announcement Responses': '/announcements',
  'Translation Session Review': '/admin/translations',
  'Translation Screen Names': '/admin/translations',
  Splash: '/login',
  'Forgot Password': '/forgot-password',
};

function walkScreens(dir) {
  /** @type {string[]} */
  const out = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) out.push(...walkScreens(full));
    else if (entry.name.endsWith('_screen.dart')) out.push(full);
  }
  return out;
}

function addAlias(aliases, label, route) {
  if (!label || !route || !assignablePaths.has(route)) return;
  if (!aliases[label]) aliases[label] = route;
}

const routeConstants = loadRouteConstants();
const screenRoutes = loadScreenRoutes(routeConstants);
const aliases = { ...MANUAL_ALIASES };

for (const [screenClass, routePath] of screenRoutes) {
  if (!assignablePaths.has(routePath)) continue;
  addAlias(aliases, labelFromScreenClass(screenClass), routePath);
}

for (const file of walkScreens(path.join(REPO, 'lib'))) {
  const text = fs.readFileSync(file, 'utf8');
  const cls = text.match(/class\s+(\w+Screen)\s/);
  if (!cls) continue;
  const routePath = screenRoutes.get(cls[1]);
  const fileLabel = labelFromScreenFile(file);
  if (routePath && fileLabel) addAlias(aliases, fileLabel, routePath);
}

for (const { label, route } of assignableRoutes) {
  addAlias(aliases, label, route);
}

const sorted = Object.fromEntries(
  Object.entries(aliases).sort(([a], [b]) => a.localeCompare(b)),
);

fs.writeFileSync(OUT, `${JSON.stringify(sorted, null, 2)}\n`, 'utf8');
console.log(`Wrote ${Object.keys(sorted).length} aliases to ${OUT}`);
