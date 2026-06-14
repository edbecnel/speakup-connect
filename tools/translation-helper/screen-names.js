/**
 * Screen name registry UI — CRUD + route assignment for Translation Helper.
 */
import { ASSIGNABLE_ROUTES } from './assignable-routes.js';

/** @typedef {{ screenId: string, name: string, assignedRoute: string | null, assignedRouteLabel: string | null, badgeEnabled?: boolean }} TranslationScreen */

/**
 * @param {object} deps
 * @param {(name: string) => import('https://www.gstatic.com/firebasejs/10.14.1/firebase-functions.js').HttpsCallable} deps.call
 * @param {() => Promise<Record<string, unknown>>} deps.callPayload
 * @param {(text: string, kind?: string) => void} deps.setStatus
 * @param {(err: unknown) => string} deps.formatError
 * @param {(html: string) => string} deps.escapeHtml
 */
export function createScreenNamesPanel(deps) {
  const { call, callPayload, setStatus, formatError, escapeHtml } = deps;

  /** @type {TranslationScreen[]} */
  let screens = [];

  const els = {
    section: document.getElementById('screen-names-section'),
    status: document.getElementById('screen-names-status'),
    newName: document.getElementById('screen-name-new'),
    addBtn: document.getElementById('screen-name-add-btn'),
    namesBody: document.getElementById('screen-names-body'),
    routesBody: document.getElementById('screen-routes-body'),
    refreshBtn: document.getElementById('screen-names-refresh-btn'),
  };

  function screenAssignedToRoute(route) {
    return screens.find((s) => s.assignedRoute === route) ?? null;
  }

  /** Screen names not assigned to any route, plus optional current for a route row. */
  function availableNamesForRoute(route) {
    const current = screenAssignedToRoute(route);
    return screens.filter(
      (s) => !s.assignedRoute || (current && s.screenId === current.screenId),
    );
  }

  /** All catalog names for per-string context (many strings may share a name). */
  function allScreenNames() {
    return [...screens].sort((a, b) => a.name.localeCompare(b.name));
  }

  function buildContextSelectOptions(currentContext) {
    const options = ['<option value="">(none)</option>'];
    for (const screen of allScreenNames()) {
      const selected = currentContext === screen.name ? ' selected' : '';
      options.push(
        `<option value="${escapeHtml(screen.name)}"${selected}>${escapeHtml(screen.name)}</option>`,
      );
    }
    return options.join('');
  }

  async function loadScreens() {
    setStatus('Loading screen names…');
    try {
      const { data } = await call('listTranslationScreens')(await callPayload());
      screens = data.screens ?? [];
      render();
      setStatus(`${screens.length} screen name${screens.length === 1 ? '' : 's'} loaded.`, 'ok');
    } catch (err) {
      setStatus(formatError(err), 'error');
      throw err;
    }
  }

  function renderNamesTable() {
    if (!els.namesBody) return;
    if (screens.length === 0) {
      els.namesBody.innerHTML =
        '<tr><td colspan="4" class="muted">No screen names yet. Add one above.</td></tr>';
      return;
    }

    els.namesBody.innerHTML = screens
      .map((screen) => {
        const routeLabel = screen.assignedRouteLabel ?? screen.assignedRoute ?? '—';
        const canDelete = !screen.assignedRoute;
        return `
          <tr data-screen-id="${screen.screenId}">
            <td>
              <input type="text" class="screen-name-input" data-screen-id="${screen.screenId}" value="${escapeHtml(screen.name)}" />
            </td>
            <td>${screen.assignedRoute ? escapeHtml(routeLabel) : '<span class="muted">—</span>'}</td>
            <td>
              ${
                screen.assignedRoute
                  ? `<button type="button" class="secondary screen-unassign-btn" data-screen-id="${screen.screenId}">Unassign route</button>`
                  : '<span class="muted">—</span>'
              }
            </td>
            <td class="actions">
              <button type="button" class="secondary screen-save-name-btn" data-screen-id="${screen.screenId}">Save name</button>
              <button type="button" class="secondary screen-delete-btn" data-screen-id="${screen.screenId}" ${canDelete ? '' : 'disabled title="Unassign from route before deleting"'}>Delete</button>
            </td>
          </tr>`;
      })
      .join('');
  }

  function renderRoutesTable() {
    if (!els.routesBody) return;
    els.routesBody.innerHTML = ASSIGNABLE_ROUTES.map((route) => {
      const assigned = screenAssignedToRoute(route.route);
      const available = availableNamesForRoute(route.route);
      const options = [
        '<option value="">(unassigned)</option>',
        ...available.map(
          (s) =>
            `<option value="${s.screenId}"${assigned?.screenId === s.screenId ? ' selected' : ''}>${escapeHtml(s.name)}</option>`,
        ),
      ];
      return `
        <tr data-route="${route.route}">
          <td>${escapeHtml(route.label)}</td>
          <td><code>${escapeHtml(route.route)}</code></td>
          <td>
            <select class="route-screen-select" data-route="${route.route}" aria-label="Screen name for ${escapeHtml(route.label)}">
              ${options.join('')}
            </select>
          </td>
          <td class="route-badge-cell">
            ${
              assigned
                ? `<label class="route-badge-toggle"><input type="checkbox" class="route-badge-checkbox" data-screen-id="${assigned.screenId}" ${assigned.badgeEnabled ? 'checked' : ''} /> Translation badges</label>`
                : '<span class="muted">Assign a screen name first</span>'
            }
          </td>
        </tr>`;
    }).join('');
  }

  function render() {
    renderNamesTable();
    renderRoutesTable();
  }

  async function createScreen() {
    const name = els.newName?.value?.trim() ?? '';
    if (!name) {
      setStatus('Enter a screen name.', 'error');
      return;
    }
    setStatus('Creating screen name…');
    try {
      await call('createTranslationScreen')(await callPayload({ name }));
      if (els.newName) els.newName.value = '';
      await loadScreens();
      setStatus(`Created screen name "${name}".`, 'ok');
    } catch (err) {
      setStatus(formatError(err), 'error');
    }
  }

  async function saveName(screenId) {
    const input = els.namesBody?.querySelector(
      `.screen-name-input[data-screen-id="${screenId}"]`,
    );
    const name = input?.value?.trim() ?? '';
    if (!name) {
      setStatus('Screen name cannot be empty.', 'error');
      return;
    }
    setStatus('Saving screen name…');
    try {
      const { data } = await call('updateTranslationScreen')(
        await callPayload({ screenId, name }),
      );
      const renamed = data.contextsRenamed ?? 0;
      await loadScreens();
      setStatus(
        renamed > 0
          ? `Saved. Updated ${renamed} string context${renamed === 1 ? '' : 's'}.`
          : 'Screen name saved.',
        'ok',
      );
    } catch (err) {
      setStatus(formatError(err), 'error');
    }
  }

  async function unassignRoute(screenId) {
    setStatus('Unassigning route…');
    try {
      await call('updateTranslationScreen')(
        await callPayload({ screenId, assignedRoute: null }),
      );
      await loadScreens();
      setStatus('Route unassigned.', 'ok');
    } catch (err) {
      setStatus(formatError(err), 'error');
    }
  }

  async function setBadgeEnabled(screenId, enabled) {
    setStatus('Updating translation badges…');
    try {
      await call('updateTranslationScreen')(
        await callPayload({ screenId, badgeEnabled: enabled }),
      );
      await loadScreens();
      setStatus(
        enabled
          ? 'Translation badges enabled for this app screen.'
          : 'Translation badges disabled for this app screen.',
        'ok',
      );
    } catch (err) {
      setStatus(formatError(err), 'error');
      renderRoutesTable();
    }
  }

  async function assignRoute(route, screenId) {
    setStatus('Assigning screen name…');
    try {
      if (!screenId) {
        const current = screenAssignedToRoute(route);
        if (current) {
          await call('updateTranslationScreen')(
            await callPayload({
              screenId: current.screenId,
              assignedRoute: null,
            }),
          );
        }
        await loadScreens();
        setStatus('Route unassigned.', 'ok');
        return;
      }
      await call('updateTranslationScreen')(
        await callPayload({ screenId, assignedRoute: route }),
      );
      await loadScreens();
      setStatus('Screen name assigned to route.', 'ok');
    } catch (err) {
      setStatus(formatError(err), 'error');
      renderRoutesTable();
    }
  }

  async function deleteScreen(screenId) {
    const screen = screens.find((s) => s.screenId === screenId);
    if (!screen) return;
    if (
      !window.confirm(
        `Delete screen name "${screen.name}"?\n\nThis cannot be undone.`,
      )
    ) {
      return;
    }
    setStatus('Deleting screen name…');
    try {
      await call('deleteTranslationScreen')(await callPayload({ screenId }));
      await loadScreens();
      setStatus('Screen name deleted.', 'ok');
    } catch (err) {
      setStatus(formatError(err), 'error');
    }
  }

  function bindEvents() {
    els.addBtn?.addEventListener('click', () => createScreen());
    els.newName?.addEventListener('keydown', (e) => {
      if (e.key === 'Enter') createScreen();
    });
    els.refreshBtn?.addEventListener('click', () => loadScreens());

    els.namesBody?.addEventListener('click', (e) => {
      const target = e.target;
      if (!(target instanceof HTMLElement)) return;
      const saveBtn = target.closest('.screen-save-name-btn');
      if (saveBtn instanceof HTMLElement && saveBtn.dataset.screenId) {
        saveName(saveBtn.dataset.screenId);
        return;
      }
      const unassignBtn = target.closest('.screen-unassign-btn');
      if (unassignBtn instanceof HTMLElement && unassignBtn.dataset.screenId) {
        unassignRoute(unassignBtn.dataset.screenId);
        return;
      }
      const deleteBtn = target.closest('.screen-delete-btn');
      if (deleteBtn instanceof HTMLElement && deleteBtn.dataset.screenId) {
        deleteScreen(deleteBtn.dataset.screenId);
      }
    });

    els.routesBody?.addEventListener('change', (e) => {
      const target = e.target;
      if (target instanceof HTMLSelectElement && target.classList.contains('route-screen-select')) {
        const route = target.dataset.route;
        if (!route) return;
        assignRoute(route, target.value || null);
        return;
      }
      if (target instanceof HTMLInputElement && target.classList.contains('route-badge-checkbox')) {
        const screenId = target.dataset.screenId;
        if (!screenId) return;
        setBadgeEnabled(screenId, target.checked);
      }
    });
  }

  bindEvents();

  return {
    loadScreens,
    allScreenNames,
    buildContextSelectOptions,
    getScreens: () => screens,
  };
}
