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

const config = window.FIREBASE_CONFIG;
if (!config?.apiKey || config.apiKey === 'YOUR_API_KEY') {
  document.getElementById('auth-status').textContent =
    'Copy firebase-config.example.js → firebase-config.js and add your web app config.';
  document.getElementById('auth-status').className = 'status error';
  throw new Error('Missing firebase-config.js');
}

const app = initializeApp(config);
const auth = getAuth(app);
const functions = getFunctions(app);

if (
  window.USE_FUNCTIONS_EMULATOR === true &&
  (location.hostname === 'localhost' || location.hostname === '127.0.0.1')
) {
  connectFunctionsEmulator(functions, '127.0.0.1', 5001);
}

const call = (name) => httpsCallable(functions, name);

const els = {
  authSection: document.getElementById('auth-section'),
  workspace: document.getElementById('workspace'),
  authStatus: document.getElementById('auth-status'),
  email: document.getElementById('email'),
  password: document.getElementById('password'),
  signInBtn: document.getElementById('sign-in-btn'),
  signOutBtn: document.getElementById('sign-out-btn'),
  targetLocale: document.getElementById('target-locale'),
  statusFilter: document.getElementById('status-filter'),
  featureFilter: document.getElementById('feature-filter'),
  searchKey: document.getElementById('search-key'),
  searchEnglish: document.getElementById('search-english'),
  searchTarget: document.getElementById('search-target'),
  clearFiltersBtn: document.getElementById('clear-filters-btn'),
  importArb: document.getElementById('import-arb'),
  refreshBtn: document.getElementById('refresh-btn'),
  approveAllSavedBtn: document.getElementById('approve-all-saved-btn'),
  saveAllAiDraftsBtn: document.getElementById('save-all-ai-drafts-btn'),
  batchAiBtn: document.getElementById('batch-ai-btn'),
  exportBtn: document.getElementById('export-btn'),
  meta: document.getElementById('meta'),
  workspaceStatus: document.getElementById('workspace-status'),
  entriesBody: document.getElementById('entries-body'),
  helpPanel: document.getElementById('help-panel'),
  helpToggleBtn: document.getElementById('help-toggle-btn'),
};

let entries = [];
let searchTimer;
let workspaceAccess = {
  isPlatformSuperAdmin: false,
  organizationId: null,
  canImportSource: false,
  canExportArb: false,
  canBatchAi: false,
};

function orgPayload(extra = {}) {
  if (workspaceAccess.isPlatformSuperAdmin) {
    return { ...extra };
  }
  const orgId =
    workspaceAccess.organizationId ||
    window.ORGANIZATION_ID ||
    null;
  return { organizationId: orgId, ...extra };
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
  const { data } = await call('getTranslationWorkspaceAccess')(
    orgPayload({ targetLocale: els.targetLocale.value }),
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
  if (code === 'functions/internal' && /internal error/i.test(message)) {
    return (
      `${code}: ${message} — batch may have timed out. Redeploy ` +
      'batchDraftTranslations, hard-refresh this page, and try again.'
    );
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

function updateFeatureFilter() {
  const features = [...new Set(entries.map((e) => parseFeature(e.stringKey)))].sort();
  const current = els.featureFilter.value;
  els.featureFilter.innerHTML = '<option value="">All</option>' +
    features.map((f) => `<option value="${f}">${f}</option>`).join('');
  if (features.includes(current)) els.featureFilter.value = current;
}

function displayValue(entry) {
  if (entry.status === 'approved' && entry.targetValue) return entry.targetValue;
  if (entry.targetValue) return entry.targetValue;
  if (entry.aiDraft) return entry.aiDraft;
  return '';
}

function normalizeSearchText(text) {
  return String(text ?? '')
    .toLowerCase()
    .replace(/\s+/g, ' ')
    .trim();
}

function matchesFilter(value, query) {
  if (!query) return true;
  return normalizeSearchText(value).includes(normalizeSearchText(query));
}

function getSearchFilters() {
  return {
    key: els.searchKey.value.trim().toLowerCase(),
    english: els.searchEnglish.value.trim().toLowerCase(),
    target: els.searchTarget.value.trim().toLowerCase(),
  };
}

function hasActiveTableFilters() {
  const f = getSearchFilters();
  return Boolean(f.key || f.english || f.target || els.statusFilter.value);
}

function clearTableFilters() {
  els.searchKey.value = '';
  els.searchEnglish.value = '';
  els.searchTarget.value = '';
  els.statusFilter.value = '';
  els.clearFiltersBtn.disabled = true;
  renderTable();
}

function updateClearFiltersButton() {
  els.clearFiltersBtn.disabled = !hasActiveTableFilters();
}

function renderTable() {
  const status = els.statusFilter.value;
  const feature = els.featureFilter.value;
  const { key: keyQ, english: englishQ, target: targetQ } = getSearchFilters();

  const filtered = entries.filter((e) => {
    if (status && e.status !== status) return false;
    if (feature && parseFeature(e.stringKey) !== feature) return false;
    if (!matchesFilter(e.stringKey, keyQ)) return false;
    if (!matchesFilter(e.sourceValue, englishQ)) return false;
    const targetText = [e.targetValue, e.aiDraft].filter(Boolean).join(' ');
    if (!matchesFilter(targetText, targetQ)) return false;
    return true;
  });

  updateClearFiltersButton();

  els.entriesBody.innerHTML = filtered.map((entry) => {
    const val = displayValue(entry);
    return `
      <tr data-key="${entry.stringKey}">
        <td class="key">${entry.stringKey}<br><small>${parseFeature(entry.stringKey)}</small></td>
        <td class="en">${escapeHtml(entry.sourceValue)}</td>
        <td>
          <textarea class="target-input" data-key="${entry.stringKey}">${escapeHtml(val)}</textarea>
          ${entry.aiDraftError ? `<div class="status error">${escapeHtml(entry.aiDraftError)}</div>` : ''}
        </td>
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
}

function escapeHtml(s) {
  return String(s ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

async function loadEntries() {
  setStatus('Loading…');
  await refreshAccess();
  const { data } = await call('listTranslationEntries')(orgPayload({
    targetLocale: els.targetLocale.value,
  }));
  entries = data.entries ?? [];
  updateFeatureFilter();
  renderTable();
  setStatus(`Signed in as ${auth.currentUser?.email}`, 'ok');
}

async function importArbFile(file) {
  const text = await file.text();
  const json = JSON.parse(text);
  const entriesToImport = Object.entries(json)
    .filter(([k, v]) => !k.startsWith('@') && typeof v === 'string')
    .map(([key, sourceValue]) => ({ key, sourceValue }));

  setWorkspaceStatus(`Importing ${entriesToImport.length} keys…`);
  try {
    const { data } = await call('importTranslationSource')(orgPayload({
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
  await call('saveTranslationEntry')(orgPayload({
    targetLocale: els.targetLocale.value,
    stringKey,
    targetValue,
    status: approve ? 'approved' : 'in_review',
  }));
  await loadEntries();
}

async function draftOne(stringKey) {
  setWorkspaceStatus(`AI drafting ${stringKey}…`);
  els.batchAiBtn.disabled = true;
  try {
    await call('draftTranslation')(orgPayload({
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
      const { data } = await call('batchDraftTranslations')(orgPayload({
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
      orgPayload({
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
        orgPayload({ targetLocale: els.targetLocale.value }),
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
        orgPayload({
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
        orgPayload({ targetLocale: els.targetLocale.value }),
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
    const { data } = await call('exportTranslationArb')(orgPayload({
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

els.signInBtn.addEventListener('click', async () => {
  try {
    await signInWithEmailAndPassword(auth, els.email.value.trim(), els.password.value);
  } catch (err) {
    setStatus(err.message ?? String(err), 'error');
  }
});

els.signOutBtn.addEventListener('click', () => signOut(auth));

els.targetLocale.addEventListener('change', () => loadEntries().catch(showError));
els.statusFilter.addEventListener('change', renderTable);
els.featureFilter.addEventListener('change', renderTable);
for (const input of [els.searchKey, els.searchEnglish, els.searchTarget]) {
  input.addEventListener('input', () => {
    clearTimeout(searchTimer);
    searchTimer = setTimeout(renderTable, 200);
  });
}
els.clearFiltersBtn.addEventListener('click', clearTableFilters);
els.clearFiltersBtn.disabled = true;
els.refreshBtn.addEventListener('click', () => loadEntries().catch(showError));
els.approveAllSavedBtn.addEventListener('click', () =>
  approveAllSaved().catch(showError),
);
els.saveAllAiDraftsBtn.addEventListener('click', () =>
  saveAllAiDrafts().catch(showError),
);
els.batchAiBtn.addEventListener('click', () => batchDraft().catch(showError));
els.exportBtn.addEventListener('click', () => exportArb().catch(showError));

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

function showError(err) {
  const message = formatError(err);
  setStatus(message, 'error');
  setWorkspaceStatus(message, 'error');
}

onAuthStateChanged(auth, async (user) => {
  if (!user) {
    els.workspace.classList.add('hidden');
    els.signOutBtn.classList.add('hidden');
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
  els.workspace.classList.remove('hidden');
  els.signOutBtn.classList.remove('hidden');
  els.helpToggleBtn?.classList.remove('hidden');
  await loadEntries();
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
