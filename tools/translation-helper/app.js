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

if (location.hostname === 'localhost' || location.hostname === '127.0.0.1') {
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
  search: document.getElementById('search'),
  importArb: document.getElementById('import-arb'),
  refreshBtn: document.getElementById('refresh-btn'),
  batchAiBtn: document.getElementById('batch-ai-btn'),
  exportBtn: document.getElementById('export-btn'),
  meta: document.getElementById('meta'),
  entriesBody: document.getElementById('entries-body'),
};

let entries = [];
let searchTimer;

function setStatus(text, kind = '') {
  els.authStatus.textContent = text;
  els.authStatus.className = `status ${kind}`.trim();
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

function renderTable() {
  const status = els.statusFilter.value;
  const feature = els.featureFilter.value;
  const q = els.search.value.trim().toLowerCase();

  const filtered = entries.filter((e) => {
    if (status && e.status !== status) return false;
    if (feature && parseFeature(e.stringKey) !== feature) return false;
    if (!q) return true;
    const blob = [e.stringKey, e.sourceValue, e.targetValue, e.aiDraft]
      .filter(Boolean)
      .join(' ')
      .toLowerCase();
    return blob.includes(q);
  });

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
  const { data } = await call('listTranslationEntries')({
    targetLocale: els.targetLocale.value,
  });
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

  setStatus(`Importing ${entriesToImport.length} keys…`);
  const { data } = await call('importTranslationSource')({
    targetLocale: els.targetLocale.value,
    entries: entriesToImport,
  });
  setStatus(`Imported ${data.imported} new, updated ${data.updated}`, 'ok');
  await loadEntries();
}

async function saveEntry(stringKey, approve = false) {
  const textarea = els.entriesBody.querySelector(`textarea[data-key="${stringKey}"]`);
  const targetValue = textarea?.value?.trim() ?? '';
  await call('saveTranslationEntry')({
    targetLocale: els.targetLocale.value,
    stringKey,
    targetValue,
    status: approve ? 'approved' : 'in_review',
  });
  await loadEntries();
}

async function draftOne(stringKey) {
  setStatus(`AI drafting ${stringKey}…`);
  try {
    await call('draftTranslation')({
      targetLocale: els.targetLocale.value,
      stringKey,
    });
    setStatus('Draft ready', 'ok');
  } catch (err) {
    setStatus(err.message ?? String(err), 'error');
  }
  await loadEntries();
}

async function batchDraft() {
  els.batchAiBtn.disabled = true;
  setStatus('Batch AI translation running…');
  try {
    const { data } = await call('batchDraftTranslations')({
      targetLocale: els.targetLocale.value,
      onlyMissing: true,
    });
    setStatus(`AI batch: ${data.succeeded}/${data.total} succeeded`, 'ok');
  } catch (err) {
    setStatus(err.message ?? String(err), 'error');
  } finally {
    els.batchAiBtn.disabled = false;
  }
  await loadEntries();
}

async function exportArb() {
  const { data } = await call('exportTranslationArb')({
    targetLocale: els.targetLocale.value,
    includeEnglishFallback: true,
  });
  const blob = new Blob([JSON.stringify(data.arb, null, 2)], {
    type: 'application/json',
  });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = `app_${data.locale}.arb`;
  a.click();
  URL.revokeObjectURL(a.href);
  setStatus(`Exported ${data.keyCount} keys → app_${data.locale}.arb`, 'ok');
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
els.search.addEventListener('input', () => {
  clearTimeout(searchTimer);
  searchTimer = setTimeout(renderTable, 200);
});
els.refreshBtn.addEventListener('click', () => loadEntries().catch(showError));
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
  setStatus(err.message ?? String(err), 'error');
}

onAuthStateChanged(auth, async (user) => {
  if (!user) {
    els.workspace.classList.add('hidden');
    els.signOutBtn.classList.add('hidden');
    setStatus('Not signed in');
    return;
  }
  const token = await user.getIdTokenResult();
  if (token.claims.role !== 'super_admin') {
    await signOut(auth);
    setStatus('Access denied — super_admin role required on JWT.', 'error');
    return;
  }
  els.workspace.classList.remove('hidden');
  els.signOutBtn.classList.remove('hidden');
  await loadEntries();
});
