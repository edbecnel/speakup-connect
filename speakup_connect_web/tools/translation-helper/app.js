import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.14.1/firebase-app.js';
import {
  getAuth,
  onAuthStateChanged,
  signInWithEmailAndPassword,
  signOut,
} from 'https://www.gstatic.com/firebasejs/10.14.1/firebase-auth.js';
import {
  getFunctions,
  httpsCallable,
  connectFunctionsEmulator,
} from 'https://www.gstatic.com/firebasejs/10.14.1/firebase-functions.js';
import { parseTranslationCsv, rowsToCsv } from './csv-utils.js';
import { createColumnHeaderFilter, matchesColumnFilter } from './column-filter.js';
import { createScreenNamesPanel } from './screen-names.js';
import { ASSIGNABLE_ROUTES } from './assignable-routes.js';

const config = window.FIREBASE_CONFIG;
if (!config?.apiKey || config.apiKey === 'YOUR_API_KEY') {
  document.getElementById('auth-status').textContent =
    'Copy firebase-config.example.js → firebase-config.js and add your web app config.';
  document.getElementById('auth-status').className = 'status error';
  throw new Error('Missing firebase-config.js');
}

const app = initializeApp(config);
const auth = getAuth(app);
const functions = getFunctions(app, 'us-central1');

if (window.USE_FUNCTIONS_EMULATOR === true) {
  const localHost =
    location.hostname === 'localhost' || location.hostname === '127.0.0.1';
  if (localHost) {
    connectFunctionsEmulator(functions, '127.0.0.1', 5001);
  } else {
    console.warn(
      'USE_FUNCTIONS_EMULATOR is true but the page is not on localhost — ' +
        'calls will fail from a LAN URL (http://192.168.x.x:5050). ' +
        'Set USE_FUNCTIONS_EMULATOR = false in firebase-config.js for LAN access.',
    );
  }
}

const call = (name) => httpsCallable(functions, name);

const els = {
  workspace: document.getElementById('workspace'),
  authStatus: document.getElementById('auth-status'),
  authPopover: document.getElementById('auth-popover'),
  headerSignInBtn: document.getElementById('header-sign-in-btn'),
  headerAuth: document.getElementById('header-auth'),
  email: document.getElementById('email'),
  password: document.getElementById('password'),
  passwordToggleBtn: document.getElementById('password-toggle-btn'),
  signInBtn: document.getElementById('sign-in-btn'),
  signOutBtn: document.getElementById('sign-out-btn'),
  targetLocale: document.getElementById('target-locale'),
  clearFiltersBtn: document.getElementById('clear-filters-btn'),
  importArb: document.getElementById('import-arb'),
  refreshBtn: document.getElementById('refresh-btn'),
  approveAllSavedBtn: document.getElementById('approve-all-saved-btn'),
  saveAllAiDraftsBtn: document.getElementById('save-all-ai-drafts-btn'),
  batchAiBtn: document.getElementById('batch-ai-btn'),
  exportBtn: document.getElementById('export-btn'),
  exportCsvBtn: document.getElementById('export-csv-btn'),
  importCsv: document.getElementById('import-csv'),
  meta: document.getElementById('meta'),
  workspaceStatus: document.getElementById('workspace-status'),
  entriesHead: document.getElementById('entries-head'),
  entriesBody: document.getElementById('entries-body'),
  helpPanel: document.getElementById('help-panel'),
  helpToggleBtn: document.getElementById('help-toggle-btn'),
  headerCollapseBtn: document.getElementById('header-collapse-btn'),
  operationsPanel: document.getElementById('operations-panel'),
  tableWrap: document.getElementById('table-wrap'),
  tableHeadWrap: document.getElementById('table-head-wrap'),
  navTranslationsBtn: document.getElementById('nav-translations-btn'),
  navScreenNamesBtn: document.getElementById('nav-screen-names-btn'),
  screenNamesSection: document.getElementById('screen-names-section'),
  translationsSection: document.getElementById('translations-section'),
};

let entries = [];
/** @type {Map<string, { notes: string, verified: string }>} Session cache for CSV review columns (not persisted). */
let importReviewMetaByKey = new Map();
let workspaceAccess = {
  isPlatformSuperAdmin: false,
  organizationId: null,
  canImportSource: false,
  canExportArb: false,
  canBatchAi: false,
};

const SCREEN_NONE_LABEL = 'Unassigned';
const SCREEN_BADGES_ON_LABEL = '(badges on)';

const STATUS_OPTIONS = [
  'missing',
  'ai_draft',
  'ai_draft_failed',
  'in_review',
  'approved',
];

let renderTableScheduled = false;

const ASSIGNABLE_ROUTE_LABEL_BY_ROUTE = new Map(
  ASSIGNABLE_ROUTES.map((r) => [r.route, r.label]),
);

/** @type {Map<string, string>} */
let screenOverrideNameByRoute = new Map();
/** @type {Set<string>} */
let badgeEnabledRoutes = new Set();

function refreshScreenOverrideCache() {
  screenOverrideNameByRoute = new Map();
  badgeEnabledRoutes = new Set();
  const screens = screenNamesPanel?.getScreens?.() ?? [];
  for (const screen of screens) {
    const route = String(screen?.assignedRoute ?? '').trim();
    const name = String(screen?.name ?? '').trim();
    if (route && name) screenOverrideNameByRoute.set(route, name);
    if (route && screen?.badgeEnabled) badgeEnabledRoutes.add(route);
  }
}

function translationRouteLabel(route) {
  const r = String(route ?? '').trim();
  if (!r) return null;
  return ASSIGNABLE_ROUTE_LABEL_BY_ROUTE.get(r) ?? r;
}

function translationScreenDisplayLabel(route) {
  const r = String(route ?? '').trim();
  if (!r) return SCREEN_NONE_LABEL;
  const override = screenOverrideNameByRoute.get(r);
  if (override && override.trim()) return override.trim();
  return translationRouteLabel(r) ?? r;
}

function buildRouteSelectOptions(currentRoute) {
  const current = String(currentRoute ?? '').trim();
  const known = new Set(ASSIGNABLE_ROUTES.map((r) => r.route));
  const merged = [
    ...(current && !known.has(current) ? [{ route: current, label: current }] : []),
    ...ASSIGNABLE_ROUTES,
  ];

  const options = [`<option value="">${escapeHtml(SCREEN_NONE_LABEL)}</option>`];
  for (const item of merged) {
    const route = String(item.route ?? '').trim();
    if (!route) continue;
    const display = escapeHtml(translationScreenDisplayLabel(route));
    const selected = route === current ? ' selected' : '';
    options.push(
      `<option value="${escapeHtml(route)}"${selected}>${display} — ${escapeHtml(route)}</option>`,
    );
  }
  return options.join('');
}

function scheduleRenderTable() {
  if (renderTableScheduled) return;
  renderTableScheduled = true;
  requestAnimationFrame(() => {
    renderTableScheduled = false;
    renderTable();
  });
}

const tableFilters = {
  key: createColumnHeaderFilter({
    columnLabel: 'Key',
    getOptions: () =>
      [...new Set(entries.map((e) => parseFeature(e.stringKey)))]
        .sort((a, b) => a.localeCompare(b))
        .map((feature) => ({ value: feature, label: feature })),
    onFilter: () => scheduleRenderTable(),
  }),
  screen: createColumnHeaderFilter({
    columnLabel: 'Screen',
    getOptions: () => {
      const screens = entries
        .map((e) => translationScreenDisplayLabel(e.route))
        .filter(Boolean);
      const uniq = [...new Set(screens)]
        .sort((a, b) => a.localeCompare(b))
        .map((screen) => ({ value: screen, label: screen }));
      return [{ value: SCREEN_BADGES_ON_LABEL, label: SCREEN_BADGES_ON_LABEL }, ...uniq];
    },
    onFilter: () => scheduleRenderTable(),
  }),
  english: createColumnHeaderFilter({
    columnLabel: 'English',
    getOptions: () => [],
    onFilter: () => scheduleRenderTable(),
  }),
  target: createColumnHeaderFilter({
    columnLabel: 'Target',
    getOptions: () => [],
    onFilter: () => scheduleRenderTable(),
  }),
  review: createColumnHeaderFilter({
    columnLabel: 'Review',
    getOptions: () => [
      { value: 'Has', label: 'Has' },
      { value: 'None', label: 'None' },
    ],
    onFilter: () => scheduleRenderTable(),
  }),
  verified: createColumnHeaderFilter({
    columnLabel: 'Verified',
    getOptions: () => [
      { value: 'Has', label: 'Has' },
      { value: 'None', label: 'None' },
    ],
    onFilter: () => scheduleRenderTable(),
  }),
  status: createColumnHeaderFilter({
    columnLabel: 'Status',
    getOptions: () => STATUS_OPTIONS.map((s) => ({ value: s, label: s })),
    onFilter: () => scheduleRenderTable(),
  }),
};

function mountTranslationsTableHead() {
  const head = els.entriesHead ?? document.getElementById('entries-head');
  if (head && !els.entriesHead) {
    els.entriesHead = head;
  }
  if (!head || head.querySelector('tr')) return;
  const row = document.createElement('tr');
  row.append(
    tableFilters.key.th,
    tableFilters.screen.th,
    tableFilters.english.th,
    tableFilters.target.th,
    tableFilters.review.th,
    tableFilters.verified.th,
    tableFilters.status.th,
    document.createElement('th'),
  );
  const actionsTh = row.children[row.children.length - 1];
  actionsTh.textContent = 'Actions';
  actionsTh.scope = 'col';
  head.appendChild(row);
}

mountTranslationsTableHead();

function resolveOrgIdFromConfig() {
  return workspaceAccess.organizationId || window.ORGANIZATION_ID || null;
}

function orgPayload(extra = {}) {
  const orgId = resolveOrgIdFromConfig();
  if (workspaceAccess.isPlatformSuperAdmin) {
    return orgId ? { organizationId: orgId, ...extra } : { ...extra };
  }
  return { organizationId: orgId, ...extra };
}

async function callPayload(extra = {}) {
  const orgId = resolveOrgIdFromConfig();
  const user = auth.currentUser;
  if (user) {
    const token = await user.getIdTokenResult();
    if (token.claims.role === 'super_admin') {
      return orgId ? { organizationId: orgId, ...extra } : { ...extra };
    }
  }
  return orgPayload(extra);
}

async function ensureFreshAuthToken() {
  const user = auth.currentUser;
  if (user) {
    await user.getIdToken(true);
  }
}

function applyWorkspaceCapabilities() {
  els.importArb.closest('label')?.classList.toggle(
    'hidden',
    !workspaceAccess.canImportSource,
  );
  els.batchAiBtn.classList.toggle('hidden', !workspaceAccess.canBatchAi);
  els.exportBtn.classList.toggle('hidden', !workspaceAccess.canExportArb);
  applyHelpVisibility();
}

function applyHelpVisibility() {
  const showPlatform = workspaceAccess.canImportSource;
  const showOrgAdmin =
    workspaceAccess.canExportArb || workspaceAccess.canBatchAi;

  document.querySelectorAll('.help-platform').forEach((el) => {
    el.classList.toggle('help-hidden', !showPlatform);
  });
  document.querySelectorAll('.help-org-admin').forEach((el) => {
    el.classList.toggle('help-hidden', !showOrgAdmin);
  });
}

async function refreshAccess() {
  await ensureFreshAuthToken();
  const { data } = await call('getTranslationWorkspaceAccess')(
    await callPayload({ targetLocale: els.targetLocale.value }),
  );
  workspaceAccess = {
    isPlatformSuperAdmin: data.isPlatformSuperAdmin === true,
    organizationId: data.organizationId ?? window.ORGANIZATION_ID ?? null,
    canImportSource: data.canImportSource === true,
    canExportArb: data.canExportArb === true,
    canBatchAi: data.canBatchAi === true,
  };
  applyWorkspaceCapabilities();
}

function setStatus(text, kind = '') {
  els.authStatus.textContent = text;
  els.authStatus.className = `status ${kind}`.trim();
}

function setWorkspaceStatus(text, kind = '') {
  if (!els.workspaceStatus) return;
  els.workspaceStatus.textContent = text;
  els.workspaceStatus.className = `status workspace-status ${kind}`.trim();
}

function formatError(err) {
  const code = err?.code;
  const message = err?.message ?? String(err);
  const details = err?.details;
  const detailText =
    typeof details === 'string'
      ? details
      : details != null
        ? JSON.stringify(details)
        : '';
  if (code === 'functions/already-exists') {
    const conflict = details?.conflictingScreenName;
    const hint = conflict
      ? ` Look for "${conflict}" in the Screen names catalog — you may have two entries for the same app screen (e.g. "Browse Groups" and "Browse Groups / My Groups"). Delete the unassigned duplicate or pick a unique name.`
      : ' Reload the page to reset the name field, then check the catalog for another entry with that name.';
    return `${code}: ${message}${hint}`;
  }
  if (code === 'functions/internal') {
    const serverHint =
      message && message !== 'internal' ? message : detailText;
    const hint =
      /internal error/i.test(message) || message === 'internal'
        ? (serverHint
            ? ` ${serverHint}`
            : ' Check Firebase Functions logs (listTranslationEntries / getTranslationWorkspaceAccess / importTranslationSource).') +
          ' Hard-refresh this page, sign out/in, and confirm USE_FUNCTIONS_EMULATOR is false.'
        : '';
    return `${code}: ${message}${hint}`;
  }
  return code ? `${code}: ${message}` : message;
}

function countMissingEntries() {
  return entries.filter(
    (e) => e.status === 'missing' || e.status === 'ai_draft_failed',
  ).length;
}

function countAiDraftEntries() {
  return entries.filter(
    (e) => e.status === 'ai_draft' && String(e.aiDraft ?? '').trim(),
  ).length;
}

function effectiveTargetText(entry) {
  return String(entry.targetValue ?? entry.aiDraft ?? '').trim();
}

function entryReadyToApprove(entry) {
  return entry.status === 'in_review' && Boolean(effectiveTargetText(entry));
}

function parseFeature(key) {
  const m = key.match(/^([a-z]+)/i);
  return m ? m[1].toLowerCase() : 'other';
}

function entryReviewMeta(entry) {
  return importReviewMetaByKey.get(entry.stringKey);
}

function displayValue(entry) {
  if (entry.status === 'approved' && entry.targetValue) return entry.targetValue;
  if (entry.targetValue) return entry.targetValue;
  if (entry.aiDraft) return entry.aiDraft;
  return '';
}

function hasActiveTableFilters() {
  return Boolean(
    tableFilters.key.getValue() ||
      tableFilters.screen.getValue() ||
      tableFilters.english.getValue() ||
      tableFilters.target.getValue() ||
      tableFilters.review.getValue() ||
      tableFilters.verified.getValue() ||
      tableFilters.status.getValue(),
  );
}

function clearTableFilters() {
  tableFilters.key.clear();
  tableFilters.screen.clear();
  tableFilters.english.clear();
  tableFilters.target.clear();
  tableFilters.review.clear();
  tableFilters.verified.clear();
  tableFilters.status.clear();
  if (els.clearFiltersBtn) {
    els.clearFiltersBtn.disabled = true;
  }
}

function updateClearFiltersButton() {
  if (!els.clearFiltersBtn) return;
  els.clearFiltersBtn.disabled = !hasActiveTableFilters();
}

function renderTable() {
  refreshScreenOverrideCache();
  mountTranslationsTableHead();
  const keyQ = tableFilters.key.getValue();
  const screenQ = tableFilters.screen.getValue();
  const englishQ = tableFilters.english.getValue();
  const targetQ = tableFilters.target.getValue();
  const reviewQ = tableFilters.review.getValue();
  const verifiedQ = tableFilters.verified.getValue();
  const statusQ = tableFilters.status.getValue();

  const filtered = entries.filter((e) => {
    const feature = parseFeature(e.stringKey);
    const route = String(e.route ?? '').trim();
    const screen = translationScreenDisplayLabel(route);
    const meta = entryReviewMeta(e);
    const notes = meta?.notes?.trim() ?? '';
    const verified = meta?.verified?.trim() ?? '';
    const reviewCell = notes ? `Has ${notes}` : 'None';
    const verifiedCell = verified ? `Has ${verified}` : 'None';

    if (!matchesColumnFilter(`${e.stringKey} ${feature}`, keyQ)) return false;
    if (screenQ === SCREEN_BADGES_ON_LABEL) {
      if (!route) return false;
      if (!badgeEnabledRoutes.has(route)) return false;
    } else {
      if (!matchesColumnFilter(screen, screenQ)) return false;
    }
    if (!matchesColumnFilter(e.sourceValue, englishQ)) return false;
    const targetText = [e.targetValue, e.aiDraft].filter(Boolean).join(' ');
    if (!matchesColumnFilter(targetText, targetQ)) return false;
    if (!matchesColumnFilter(reviewCell, reviewQ)) return false;
    if (!matchesColumnFilter(verifiedCell, verifiedQ)) return false;
    if (!matchesColumnFilter(e.status, statusQ)) return false;
    return true;
  });

  updateClearFiltersButton();

  els.entriesBody.innerHTML = filtered.map((entry) => {
    const val = displayValue(entry);
    const meta = importReviewMetaByKey.get(entry.stringKey);
    const reviewText = meta?.notes?.trim() ?? '';
    const verifiedText = meta?.verified?.trim() ?? '';
    const reviewHtml = reviewText
      ? `<div class="review-meta">${escapeHtml(reviewText)}</div>`
      : '<span class="review-meta muted">—</span>';
    const verifiedHtml = verifiedText
      ? `<div class="verified-meta">${escapeHtml(verifiedText)}</div>`
      : '<span class="verified-meta muted">—</span>';
    const route = String(entry.route ?? '').trim();
    const routeOptions = buildRouteSelectOptions(route);
    return `
      <tr data-key="${entry.stringKey}">
        <td class="key">${entry.stringKey}<br><small>${parseFeature(entry.stringKey)}</small></td>
        <td class="screen">
          <select class="route-select" data-key="${entry.stringKey}" aria-label="Route for ${entry.stringKey}">
            ${routeOptions}
          </select>
        </td>
        <td class="en">${escapeHtml(entry.sourceValue)}</td>
        <td>
          <textarea class="target-input" data-key="${entry.stringKey}">${escapeHtml(val)}</textarea>
          ${entry.aiDraftError ? `<div class="status error">${escapeHtml(entry.aiDraftError)}</div>` : ''}
        </td>
        <td class="review">${reviewHtml}</td>
        <td class="verified">${verifiedHtml}</td>
        <td><span class="status-pill ${entry.status}">${entry.status}</span></td>
        <td class="actions">
          <button type="button" data-action="save" data-key="${entry.stringKey}">Save</button>
          <button type="button" data-action="approve" data-key="${entry.stringKey}">Approve</button>
          <button type="button" data-action="ai" data-key="${entry.stringKey}">AI draft</button>
        </td>
      </tr>`;
  }).join('');

  const approved = entries.filter((e) => e.status === 'approved').length;
  els.meta.textContent =
    `${entries.length} keys · ${approved} approved · showing ${filtered.length}`;
  syncTranslationTableHeadScroll();
}

function escapeHtml(s) {
  return String(s ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

const screenNamesPanel = createScreenNamesPanel({
  call,
  callPayload,
  setStatus: (text, kind = '') => {
    const el = document.getElementById('screen-names-status');
    if (!el) return;
    el.textContent = text;
    el.className = `status ${kind}`.trim();
  },
  formatError,
  escapeHtml,
});

function showWorkspaceView(view) {
  const isStrings = view === 'strings';
  els.navTranslationsBtn?.classList.toggle('active', isStrings);
  els.navScreenNamesBtn?.classList.toggle('active', !isStrings);
  els.screenNamesSection?.classList.toggle('hidden', isStrings);
  els.translationsSection?.classList.toggle('hidden', !isStrings);
  els.helpPanel?.classList.toggle('hidden', !isStrings);
  els.operationsPanel?.classList.toggle('hidden', !isStrings);
  document.body.classList.toggle('screen-names-view', !isStrings);
  if (!isStrings) {
    refreshAccess()
      .then(() => screenNamesPanel.loadScreens())
      .catch(showError);
  }
}

els.navTranslationsBtn?.addEventListener('click', () => showWorkspaceView('strings'));
els.navScreenNamesBtn?.addEventListener('click', () => showWorkspaceView('screen-names'));

async function loadEntries({ clearReviewMeta = true, resetWorkspaceStatus = true } = {}) {
  setStatus('Loading…');
  const targetLocale = els.targetLocale.value;
  if (!targetLocale) {
    throw new Error('Select a target locale first.');
  }
  const hadReviewMeta = clearReviewMeta && importReviewMetaByKey.size > 0;
  if (hadReviewMeta) {
    importReviewMetaByKey.clear();
  }
  try {
    await refreshAccess();
    const { data } = await call('listTranslationEntries')(
      await callPayload({ targetLocale }),
    );
    entries = data.entries ?? [];
    try {
      await screenNamesPanel.loadScreens();
    } catch (screenErr) {
      console.warn('Screen names load failed', screenErr);
    }
    renderTable();
    setStatus(`Signed in as ${auth.currentUser?.email}`, 'ok');
    if (hadReviewMeta) {
      setWorkspaceStatus(
        'Notes and verified columns cleared. Re-import CSV to restore them.',
        'ok',
      );
    } else if (resetWorkspaceStatus) {
      setWorkspaceStatus('', '');
    }
  } catch (err) {
    console.error('loadEntries failed', err);
    throw err;
  }
}

async function importArbFile(file) {
  const text = await file.text();
  const json = JSON.parse(text);
  const entriesToImport = Object.entries(json)
    .filter(([k, v]) => !k.startsWith('@') && typeof v === 'string')
    .map(([key, sourceValue]) => ({ key, sourceValue }));

  setWorkspaceStatus(`Importing ${entriesToImport.length} keys…`);
  try {
    const { data } = await call('importTranslationSource')(await callPayload({
      targetLocale: els.targetLocale.value,
      entries: entriesToImport,
    }));
    setWorkspaceStatus(
      `Import complete: ${data.imported} new, ${data.updated} updated.`,
      'ok',
    );
  } catch (err) {
    setWorkspaceStatus(formatError(err), 'error');
    throw err;
  }
  await loadEntries();
}

async function saveEntry(stringKey, approve = false) {
  const textarea = els.entriesBody.querySelector(`textarea[data-key="${stringKey}"]`);
  const targetValue = textarea?.value?.trim() ?? '';
  const routeSelect = els.entriesBody.querySelector(
    `select.route-select[data-key="${stringKey}"]`,
  );
  const routeValue = routeSelect?.value?.trim() ?? '';
  await call('saveTranslationEntry')(await callPayload({
    targetLocale: els.targetLocale.value,
    stringKey,
    targetValue,
    status: approve ? 'approved' : 'in_review',
    route: routeValue,
  }));
  await loadEntries();
}

async function saveEntryRoute(stringKey, routeValue) {
  await call('saveTranslationEntry')(await callPayload({
    targetLocale: els.targetLocale.value,
    stringKey,
    route: routeValue,
  }));
  const entry = entries.find((e) => e.stringKey === stringKey);
  if (entry) {
    entry.route = routeValue || null;
  }
  scheduleRenderTable();
}

async function draftOne(stringKey) {
  setWorkspaceStatus(`AI drafting ${stringKey}…`);
  els.batchAiBtn.disabled = true;
  try {
    await call('draftTranslation')(await callPayload({
      targetLocale: els.targetLocale.value,
      stringKey,
    }));
    setWorkspaceStatus(`AI draft ready for ${stringKey}.`, 'ok');
  } catch (err) {
    setWorkspaceStatus(formatError(err), 'error');
    throw err;
  } finally {
    els.batchAiBtn.disabled = false;
  }
  await loadEntries();
}

async function batchDraft() {
  const missing = countMissingEntries();
  if (missing === 0) {
    setWorkspaceStatus(
      'No missing strings to translate. Filter by status “missing” or all rows are already drafted / in review / approved.',
      'ok',
    );
    return;
  }

  const prevLabel = els.batchAiBtn.textContent;
  els.batchAiBtn.disabled = true;
  els.batchAiBtn.classList.add('busy');
  els.batchAiBtn.textContent = `Translating ${missing}…`;
  setWorkspaceStatus(
    `Batch AI started — ${missing} missing strings. This may take several minutes; keep this tab open.`,
  );

  try {
    let totalSucceeded = 0;
    let totalProcessed = 0;
    const allFailed = [];
    let batchNum = 0;
    let hasMore = true;

    while (hasMore) {
      batchNum += 1;
      const { data } = await call('batchDraftTranslations')(await callPayload({
        targetLocale: els.targetLocale.value,
        onlyMissing: true,
      }));
      const total = data.total ?? 0;
      const succeeded = data.succeeded ?? 0;
      const failed = (data.results ?? []).filter((r) => !r.ok);

      totalProcessed += total;
      totalSucceeded += succeeded;
      allFailed.push(...failed);

      if (total === 0) {
        if (batchNum === 1) {
          setWorkspaceStatus(
            'Server found no missing strings. Try Refresh, then filter status “missing”.',
            'ok',
          );
        }
        break;
      }

      hasMore = data.hasMore === true;
      els.batchAiBtn.textContent = hasMore
        ? `Translating… (${totalSucceeded} done, more pending)`
        : `Translating ${missing}…`;
      setWorkspaceStatus(
        hasMore
          ? `Batch ${batchNum}: ${succeeded} of ${total} succeeded. Continuing with remaining strings…`
          : `Batch ${batchNum}: ${succeeded} of ${total} succeeded.`,
      );

      if (!hasMore) break;
    }

    if (totalProcessed === 0) {
      // status already set above
    } else if (allFailed.length === 0) {
      setWorkspaceStatus(
        `AI batch complete: ${totalSucceeded} of ${totalProcessed} succeeded.`,
        'ok',
      );
    } else {
      const sample = allFailed
        .slice(0, 3)
        .map((r) => `${r.stringKey}: ${r.error ?? 'failed'}`)
        .join(' · ');
      const suffix = allFailed.length > 3 ? ` (+${allFailed.length - 3} more)` : '';
      setWorkspaceStatus(
        `AI batch: ${totalSucceeded} of ${totalProcessed} succeeded. Failed: ${sample}${suffix}`,
        totalSucceeded === 0 ? 'error' : 'ok',
      );
    }
  } catch (err) {
    setWorkspaceStatus(formatError(err), 'error');
  } finally {
    els.batchAiBtn.disabled = false;
    els.batchAiBtn.classList.remove('busy');
    els.batchAiBtn.textContent = prevLabel;
  }
  await loadEntries();
}

async function approveAllSavedViaSaveEntry(toApprove) {
  let approved = 0;
  for (const entry of toApprove) {
    await call('saveTranslationEntry')(
      await callPayload({
        targetLocale: els.targetLocale.value,
        stringKey: entry.stringKey,
        targetValue: effectiveTargetText(entry),
        status: 'approved',
      }),
    );
    approved++;
  }
  return approved;
}

async function approveAllSaved() {
  const toApprove = entries.filter(entryReadyToApprove);
  const inReviewCount = toApprove.length;
  if (inReviewCount === 0) {
    const inReviewOnly = entries.filter((e) => e.status === 'in_review');
    const needsSave = inReviewOnly.filter(
      (e) => !effectiveTargetText(e),
    ).length;
    setWorkspaceStatus(
      needsSave > 0
        ? `${needsSave} in-review row${needsSave === 1 ? '' : 's'} ha${needsSave === 1 ? 's' : 've'} no saved text — use Save on the row first.`
        : 'No saved/in-review strings to approve. Use Save on rows first.',
      'ok',
    );
    return;
  }

  if (
    !window.confirm(
      `Approve ${inReviewCount} saved/in-review string${inReviewCount === 1 ? '' : 's'}?`,
    )
  ) {
    return;
  }

  const prevLabel = els.approveAllSavedBtn.textContent;
  els.approveAllSavedBtn.disabled = true;
  els.batchAiBtn.disabled = true;
  els.approveAllSavedBtn.classList.add('busy');
  els.approveAllSavedBtn.textContent = `Approving ${inReviewCount}…`;
  setWorkspaceStatus(`Approving ${inReviewCount} saved/in-review strings…`);

  try {
    let approved = 0;
    let total = inReviewCount;
    try {
      const { data } = await call('batchApproveSavedTranslations')(
        await callPayload({ targetLocale: els.targetLocale.value }),
      );
      approved = data.approved ?? 0;
      total = data.total ?? 0;
    } catch (err) {
      const code = err?.code ?? '';
      const useFallback =
        code === 'functions/not-found' ||
        code === 'not-found' ||
        code === 'functions/unavailable' ||
        code === 'functions/internal';
      if (useFallback) {
        setWorkspaceStatus(
          `Batch approve unavailable — approving ${inReviewCount} saved/in-review one at a time…`,
        );
        approved = await approveAllSavedViaSaveEntry(toApprove);
      } else {
        throw err;
      }
    }

    if (total === 0) {
      setWorkspaceStatus(
        'No saved/in-review strings to approve. Use Save on rows first.',
        'ok',
      );
    } else {
      setWorkspaceStatus(
        `Approved ${approved} of ${total} saved/in-review string${total === 1 ? '' : 's'}.`,
        'ok',
      );
    }
  } catch (err) {
    setWorkspaceStatus(formatError(err), 'error');
  } finally {
    els.approveAllSavedBtn.disabled = false;
    els.batchAiBtn.disabled = false;
    els.approveAllSavedBtn.classList.remove('busy');
    els.approveAllSavedBtn.textContent = prevLabel;
  }
  await loadEntries();
}

async function saveAllAiDraftsViaSaveEntry(toSave) {
  let saved = 0;
  const failed = [];
  for (const entry of toSave) {
    try {
      await call('saveTranslationEntry')(
        await callPayload({
          targetLocale: els.targetLocale.value,
          stringKey: entry.stringKey,
          targetValue: entry.aiDraft,
          status: 'in_review',
        }),
      );
      saved++;
    } catch (err) {
      failed.push({
        stringKey: entry.stringKey,
        error: formatError(err),
      });
    }
  }
  return { saved, failed };
}

async function saveAllAiDrafts() {
  const toSave = entries.filter(
    (e) => e.status === 'ai_draft' && String(e.aiDraft ?? '').trim(),
  );
  const draftCount = toSave.length;
  if (draftCount === 0) {
    setWorkspaceStatus(
      'No AI drafts to save. Run Translate missing (AI) or AI draft on rows first.',
      'ok',
    );
    return;
  }

  if (
    !window.confirm(
      `Save ${draftCount} AI draft${draftCount === 1 ? '' : 's'} as in review?`,
    )
  ) {
    return;
  }

  const prevLabel = els.saveAllAiDraftsBtn.textContent;
  els.saveAllAiDraftsBtn.disabled = true;
  els.approveAllSavedBtn.disabled = true;
  els.batchAiBtn.disabled = true;
  els.saveAllAiDraftsBtn.classList.add('busy');
  els.saveAllAiDraftsBtn.textContent = `Saving ${draftCount}…`;
  setWorkspaceStatus(`Saving ${draftCount} AI draft${draftCount === 1 ? '' : 's'} as in review…`);

  try {
    let saved = 0;
    let total = draftCount;
    let skipped = 0;
    const failed = [];
    try {
      const { data } = await call('batchSaveAiDrafts')(
        await callPayload({ targetLocale: els.targetLocale.value }),
      );
      saved = data.saved ?? 0;
      total = data.total ?? 0;
      skipped = data.skipped ?? 0;
    } catch (err) {
      const code = err?.code ?? '';
      const useFallback =
        code === 'functions/not-found' ||
        code === 'not-found' ||
        code === 'functions/unavailable' ||
        code === 'functions/internal';
      if (useFallback) {
        setWorkspaceStatus(
          `Batch save unavailable — saving ${draftCount} AI draft${draftCount === 1 ? '' : 's'} one at a time…`,
        );
        const result = await saveAllAiDraftsViaSaveEntry(toSave);
        saved = result.saved;
        failed.push(...result.failed);
      } else {
        throw err;
      }
    }

    if (total === 0 && saved === 0 && failed.length === 0) {
      setWorkspaceStatus(
        'No AI drafts to save. Run Translate missing (AI) or AI draft on rows first.',
        'ok',
      );
    } else if (skipped > 0 || failed.length > 0) {
      const sample = failed
        .slice(0, 3)
        .map((r) => `${r.stringKey}: ${r.error}`)
        .join(' · ');
      const failCount = skipped + failed.length;
      const suffix = failCount > 3 ? ` (+${failCount - 3} more)` : '';
      setWorkspaceStatus(
        `Saved ${saved} of ${draftCount} AI draft${draftCount === 1 ? '' : 's'} as in review.` +
          (failCount > 0
            ? ` Failed/skipped ${failCount}${sample ? `: ${sample}${suffix}` : ''}.`
            : ''),
        saved === 0 ? 'error' : 'ok',
      );
    } else {
      setWorkspaceStatus(
        `Saved ${saved} AI draft${saved === 1 ? '' : 's'} as in review.`,
        'ok',
      );
    }
  } catch (err) {
    setWorkspaceStatus(formatError(err), 'error');
  } finally {
    els.saveAllAiDraftsBtn.disabled = false;
    els.approveAllSavedBtn.disabled = false;
    els.batchAiBtn.disabled = false;
    els.saveAllAiDraftsBtn.classList.remove('busy');
    els.saveAllAiDraftsBtn.textContent = prevLabel;
  }
  await loadEntries();
}

async function exportArb() {
  setWorkspaceStatus('Exporting ARB…');
  try {
    const { data } = await call('exportTranslationArb')(await callPayload({
      targetLocale: els.targetLocale.value,
      includeEnglishFallback: true,
    }));
    const blob = new Blob([JSON.stringify(data.arb, null, 2)], {
      type: 'application/json',
    });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = `app_${data.locale}.arb`;
    a.click();
    URL.revokeObjectURL(a.href);
    setWorkspaceStatus(`Exported ${data.keyCount} keys → app_${data.locale}.arb`, 'ok');
  } catch (err) {
    setWorkspaceStatus(formatError(err), 'error');
    throw err;
  }
}

const CSV_IMPORT_CHUNK = 200;

function exportCsv() {
  if (entries.length === 0) {
    setWorkspaceStatus('No entries loaded. Click Refresh first.', 'error');
    return;
  }
  const locale = els.targetLocale.value;
  const rows = entries.map((entry) => {
    const meta = importReviewMetaByKey.get(entry.stringKey);
    return {
      key: entry.stringKey,
      screen: entry.route ?? '',
      english: entry.sourceValue,
      translation: displayValue(entry),
      review: meta?.notes ?? '',
      verified: meta?.verified ?? '',
      status: entry.status,
    };
  });
  const csv = rowsToCsv(rows, [
    'key',
    'screen',
    'english',
    'translation',
    'review',
    'verified',
    'status',
  ]);
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8' });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = `app_${locale}_translations.csv`;
  a.click();
  URL.revokeObjectURL(a.href);
  setWorkspaceStatus(
    `Exported ${rows.length} rows → app_${locale}_translations.csv`,
    'ok',
  );
}

async function importCsvFile(file) {
  const text = await file.text();
  const { rows, warnings } = parseTranslationCsv(text);
  if (rows.length === 0) {
    const hint = warnings.length ? warnings.join(' ') : 'No importable rows found.';
    setWorkspaceStatus(hint, 'error');
    return;
  }

  const approvedCount = rows.filter((r) => r.status === 'approved').length;
  const reviewCount = rows.length - approvedCount;
  const confirmMsg =
    `Import ${rows.length} translation${rows.length === 1 ? '' : 's'} from CSV?\n\n` +
    `${reviewCount} will be saved as in_review` +
    (approvedCount > 0 ? `, ${approvedCount} as approved` : '') +
    '.\n\nRows with unknown keys are skipped. Placeholder mismatches are reported after import.';
  if (!window.confirm(confirmMsg)) {
    return;
  }

  for (const row of rows) {
    const notes = row.notes?.trim() ?? '';
    const verified = row.verified?.trim() ?? '';
    if (notes || verified) {
      importReviewMetaByKey.set(row.key, { notes, verified });
    }
  }

  setWorkspaceStatus(`Importing ${rows.length} translations from CSV…`);
  let updated = 0;
  let skipped = 0;
  let failed = 0;
  const allErrors = [];

  try {
    for (let i = 0; i < rows.length; i += CSV_IMPORT_CHUNK) {
      const chunk = rows.slice(i, i + CSV_IMPORT_CHUNK).map((row) => {
        /** @type {{ key: string, translation: string, status: string, context?: string, route?: string }} */
        const entry = {
          key: row.key,
          translation: row.translation,
          status: row.status === 'approved' ? 'approved' : 'in_review',
        };
        const screen = row.screen?.trim();
        if (screen) {
          if (screen.startsWith('/')) {
            entry.route = screen;
          } else {
            entry.context = screen;
          }
        }
        return entry;
      });
      const { data } = await call('importTranslationTargets')(
        await callPayload({
          targetLocale: els.targetLocale.value,
          entries: chunk,
        }),
      );
      updated += data.updated ?? 0;
      skipped += data.skipped ?? 0;
      failed += data.failed ?? 0;
      if (Array.isArray(data.errors)) {
        allErrors.push(...data.errors);
      }
      setWorkspaceStatus(
        `Importing… ${Math.min(i + chunk.length, rows.length)} of ${rows.length} rows processed.`,
      );
    }

    const sample = allErrors
      .slice(0, 3)
      .map((e) => `${e.key}: ${e.error}`)
      .join(' · ');
    const suffix = allErrors.length > 3 ? ` (+${allErrors.length - 3} more)` : '';
    let message =
      `CSV import complete: ${updated} updated, ${skipped} skipped (unknown keys)`;
    if (failed > 0) {
      message += `, ${failed} failed${sample ? ` — ${sample}${suffix}` : ''}`;
    }
    if (warnings.length > 0 && updated === 0 && failed === 0) {
      message += `. ${warnings[0]}`;
    }
    setWorkspaceStatus(message, failed > 0 && updated === 0 ? 'error' : 'ok');
  } catch (err) {
    setWorkspaceStatus(formatError(err), 'error');
    throw err;
  }

  await loadEntries({ clearReviewMeta: false, resetWorkspaceStatus: false });
}

function setAuthPopoverOpen(open) {
  if (!els.authPopover) return;
  els.authPopover.hidden = !open;
  els.authPopover.classList.toggle('hidden', !open);
  els.headerSignInBtn?.setAttribute('aria-expanded', open ? 'true' : 'false');
}

function setAuthButtonsSignedIn(signedIn) {
  els.headerSignInBtn?.classList.toggle('hidden', signedIn);
  els.signOutBtn.classList.toggle('hidden', !signedIn);
  if (signedIn) {
    setAuthPopoverOpen(false);
  }
}

els.headerSignInBtn?.addEventListener('click', (e) => {
  e.stopPropagation();
  const open = els.authPopover?.hidden !== false;
  setAuthPopoverOpen(open);
});

document.addEventListener('click', (e) => {
  if (!els.headerAuth?.contains(e.target)) {
    setAuthPopoverOpen(false);
  }
});

els.signInBtn.addEventListener('click', async () => {
  try {
    await signInWithEmailAndPassword(auth, els.email.value.trim(), els.password.value);
    setAuthPopoverOpen(false);
  } catch (err) {
    setStatus(err.message ?? String(err), 'error');
  }
});

els.password?.addEventListener('keydown', (e) => {
  if (e.key === 'Enter') {
    els.signInBtn.click();
  }
});

els.passwordToggleBtn?.addEventListener('click', () => {
  const hidden = els.password.type === 'password';
  els.password.type = hidden ? 'text' : 'password';
  els.passwordToggleBtn.setAttribute('aria-pressed', hidden ? 'true' : 'false');
  els.passwordToggleBtn.setAttribute(
    'aria-label',
    hidden ? 'Hide password' : 'Show password',
  );
  els.passwordToggleBtn.title = hidden ? 'Hide password' : 'Show password';
  els.passwordToggleBtn.querySelector('.icon-eye')?.classList.toggle('hidden', hidden);
  els.passwordToggleBtn.querySelector('.icon-eye-off')?.classList.toggle('hidden', !hidden);
});

els.signOutBtn.addEventListener('click', () => signOut(auth));

els.targetLocale.addEventListener('change', () => loadEntries().catch(showError));
els.clearFiltersBtn?.addEventListener('click', clearTableFilters);
if (els.clearFiltersBtn) els.clearFiltersBtn.disabled = true;
els.refreshBtn.addEventListener('click', () => loadEntries().catch(showError));
els.approveAllSavedBtn.addEventListener('click', () =>
  approveAllSaved().catch(showError),
);
els.saveAllAiDraftsBtn.addEventListener('click', () =>
  saveAllAiDrafts().catch(showError),
);
els.batchAiBtn.addEventListener('click', () => batchDraft().catch(showError));
els.exportCsvBtn.addEventListener('click', () => exportCsv());
els.exportBtn.addEventListener('click', () => exportArb().catch(showError));

els.importCsv.addEventListener('change', async (e) => {
  const file = e.target.files?.[0];
  if (!file) return;
  try {
    await importCsvFile(file);
  } catch (err) {
    showError(err);
  }
  e.target.value = '';
});

els.importArb.addEventListener('change', async (e) => {
  const file = e.target.files?.[0];
  if (!file) return;
  try {
    await importArbFile(file);
  } catch (err) {
    showError(err);
  }
  e.target.value = '';
});

els.entriesBody.addEventListener('click', async (e) => {
  const btn = e.target.closest('button[data-action]');
  if (!btn) return;
  const key = btn.dataset.key;
  const action = btn.dataset.action;
  btn.disabled = true;
  try {
    if (action === 'save') await saveEntry(key, false);
    if (action === 'approve') await saveEntry(key, true);
    if (action === 'ai') await draftOne(key);
  } catch (err) {
    showError(err);
  } finally {
    btn.disabled = false;
  }
});

els.entriesBody.addEventListener('change', async (e) => {
  const select = e.target.closest('select.route-select');
  if (!select) return;
  const key = select.dataset.key;
  if (!key) return;
  select.disabled = true;
  try {
    await saveEntryRoute(key, select.value.trim());
    setWorkspaceStatus(`Route updated for ${key}.`, 'ok');
  } catch (err) {
    showError(err);
    renderTable();
  } finally {
    select.disabled = false;
  }
});

function showError(err) {
  const message = formatError(err);
  setStatus(message, 'error');
  setWorkspaceStatus(message, 'error');
}

onAuthStateChanged(auth, async (user) => {
  if (!user) {
    setWorkspaceActive(false);
    els.workspace.classList.add('hidden');
    setAuthButtonsSignedIn(false);
    els.helpToggleBtn?.classList.add('hidden');
    setStatus('Not signed in');
    return;
  }
  const token = await user.getIdTokenResult();
  const role = token.claims.role;
  const perms = token.claims.permissions ?? [];
  const isSuperAdmin = role === 'super_admin';
  const isOrgAdmin = ['admin', 'owner', 'super_admin'].includes(role);
  const isModerator = perms.includes('manageTranslations');

  if (!isSuperAdmin && !isOrgAdmin && !isModerator) {
    await signOut(auth);
    setStatus(
      'Access denied — org admin or manageTranslations permission required.',
      'error',
    );
    return;
  }
  setWorkspaceActive(true);
  els.workspace.classList.remove('hidden');
  setAuthButtonsSignedIn(true);
  els.signOutBtn.title = user.email ?? '';
  els.helpToggleBtn?.classList.remove('hidden');
  try {
    await loadEntries();
  } catch (err) {
    showError(err);
  }
});

function syncTranslationTableHeadScroll() {
  if (!els.tableWrap || !els.tableHeadWrap) return;
  const headTable = els.tableHeadWrap.querySelector('table');
  if (!headTable) return;
  headTable.style.transform = `translateX(-${els.tableWrap.scrollLeft}px)`;
}

els.tableWrap?.addEventListener('scroll', syncTranslationTableHeadScroll, { passive: true });

function setWorkspaceActive(active) {
  document.body.classList.toggle('workspace-active', active);
}

function setHeaderCollapsed(collapsed) {
  document.body.classList.toggle('header-collapsed', collapsed);
  if (!els.headerCollapseBtn) return;
  els.headerCollapseBtn.setAttribute('aria-expanded', collapsed ? 'false' : 'true');
  els.headerCollapseBtn.title = collapsed ? 'Expand header' : 'Collapse header';
  const label = els.headerCollapseBtn.querySelector('.header-collapse-label');
  if (label) label.textContent = collapsed ? 'Expand' : 'Collapse';
}

els.headerCollapseBtn?.addEventListener('click', () => {
  setHeaderCollapsed(!document.body.classList.contains('header-collapsed'));
});

els.helpToggleBtn?.addEventListener('click', () => {
  if (!els.helpPanel) return;
  els.helpPanel.open = !els.helpPanel.open;
  els.helpToggleBtn.setAttribute(
    'aria-expanded',
    els.helpPanel.open ? 'true' : 'false',
  );
  if (els.helpPanel.open) {
    els.helpPanel.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }
});
