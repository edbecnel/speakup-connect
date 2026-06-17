/**
 * Screen name registry UI — CRUD + route assignment for Translation Helper.
 */
import { ASSIGNABLE_ROUTES } from './assignable-routes.js';
import { createColumnHeaderFilter, matchesColumnFilter } from './column-filter.js';

/** @typedef {{ screenId: string, name: string, assignedRoute: string | null, assignedRouteLabel: string | null, badgeEnabled?: boolean }} TranslationScreen */

const UNASSIGNED_LABEL = '(unassigned)';
const BADGE_ON = 'On';
const BADGE_OFF = 'Off';
const BADGE_NONE = 'Not assigned';

const SORTED_ASSIGNABLE_ROUTES = [...ASSIGNABLE_ROUTES].sort((a, b) =>
  a.label.localeCompare(b.label),
);

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
    namesHead: document.getElementById('screen-names-head'),
    namesHeadWrap: document.getElementById('screen-names-head-wrap'),
    namesBodyScroll: document.getElementById('screen-names-body-scroll'),
    namesBody: document.getElementById('screen-names-body'),
    routesHead: document.getElementById('screen-routes-head'),
    routesHeadWrap: document.getElementById('screen-routes-head-wrap'),
    routesBodyScroll: document.getElementById('screen-routes-body-scroll'),
    routesBody: document.getElementById('screen-routes-body'),
    refreshBtn: document.getElementById('screen-names-refresh-btn'),
    catalogRefreshBtn: document.getElementById('screen-names-catalog-refresh-btn'),
    routesRefreshBtn: document.getElementById('screen-names-routes-refresh-btn'),
    importBtn: document.getElementById('screen-names-import-btn'),
  };

  const catalogFilters = {
    name: createColumnHeaderFilter({
      columnLabel: 'Screen name',
      getOptions: () =>
        [...new Set(screens.map((s) => s.name))]
          .sort((a, b) => a.localeCompare(b))
          .map((name) => ({ value: name, label: name })),
      onFilter: () => renderNamesTable(),
    }),
    assignedAppScreen: createColumnHeaderFilter({
      columnLabel: 'Assigned app screen',
      getOptions: () => {
        const labels = screens.map((s) =>
          s.assignedRoute
            ? s.assignedRouteLabel ?? s.assignedRoute ?? UNASSIGNED_LABEL
            : UNASSIGNED_LABEL,
        );
        return [...new Set(labels)]
          .sort((a, b) => a.localeCompare(b))
          .map((label) => ({ value: label, label }));
      },
      onFilter: () => renderNamesTable(),
    }),
  };

  const routesFilters = {
    appScreen: createColumnHeaderFilter({
      columnLabel: 'App screen',
      getOptions: () =>
        SORTED_ASSIGNABLE_ROUTES.map((r) => ({
          value: r.label,
          label: r.label,
        })),
      onFilter: () => renderRoutesTable(),
    }),
    route: createColumnHeaderFilter({
      columnLabel: 'Route',
      getOptions: () =>
        SORTED_ASSIGNABLE_ROUTES.map((r) => ({
          value: r.route,
          label: r.route,
        })),
      onFilter: () => renderRoutesTable(),
    }),
    screenName: createColumnHeaderFilter({
      columnLabel: 'Screen name',
      getOptions: () => {
        const names = SORTED_ASSIGNABLE_ROUTES.map((route) => {
          const assigned = screenAssignedToRoute(route.route);
          return assigned?.name ?? UNASSIGNED_LABEL;
        });
        return [...new Set(names)]
          .sort((a, b) => a.localeCompare(b))
          .map((label) => ({ value: label, label }));
      },
      onFilter: () => renderRoutesTable(),
    }),
    badges: createColumnHeaderFilter({
      columnLabel: 'Translation badges',
      getOptions: () => [
        { value: BADGE_ON, label: BADGE_ON },
        { value: BADGE_OFF, label: BADGE_OFF },
        { value: BADGE_NONE, label: BADGE_NONE },
      ],
      onFilter: () => renderRoutesTable(),
    }),
  };

  function mountTableHeads() {
    if (els.namesHead && !els.namesHead.querySelector('tr')) {
      const row = document.createElement('tr');
      row.append(
        catalogFilters.name.th,
        catalogFilters.assignedAppScreen.th,
        document.createElement('th'),
        document.createElement('th'),
      );
      row.children[2].textContent = 'Unassign';
      row.children[2].scope = 'col';
      row.children[3].textContent = 'Actions';
      row.children[3].scope = 'col';
      els.namesHead.appendChild(row);
    }

    if (els.routesHead && !els.routesHead.querySelector('tr')) {
      const row = document.createElement('tr');
      row.append(
        routesFilters.appScreen.th,
        routesFilters.route.th,
        routesFilters.screenName.th,
        routesFilters.badges.th,
      );
      els.routesHead.appendChild(row);
    }
  }

  mountTableHeads();

  function syncTableHeadScroll(headWrap, bodyScroll) {
    if (!headWrap || !bodyScroll) return;
    const headTable = headWrap.querySelector('table');
    if (!headTable) return;
    headTable.style.transform = `translateX(-${bodyScroll.scrollLeft}px)`;
  }

  function bindTableScrollSync(headWrap, bodyScroll) {
    if (!headWrap || !bodyScroll) return;
    bodyScroll.addEventListener(
      'scroll',
      () => syncTableHeadScroll(headWrap, bodyScroll),
      { passive: true },
    );
  }

  bindTableScrollSync(els.namesHeadWrap, els.namesBodyScroll);
  bindTableScrollSync(els.routesHeadWrap, els.routesBodyScroll);

  function screenAssignedToRoute(route) {
    return screens.find((s) => s.assignedRoute === route) ?? null;
  }

  function assignedAppScreenLabel(screen) {
    if (!screen.assignedRoute) return UNASSIGNED_LABEL;
    return screen.assignedRouteLabel ?? screen.assignedRoute;
  }

  function badgeLabelForRoute(routePath) {
    const assigned = screenAssignedToRoute(routePath);
    if (!assigned) return BADGE_NONE;
    return assigned.badgeEnabled ? BADGE_ON : BADGE_OFF;
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

  function buildContextSelectOptions(currentContext, extraNames = []) {
    const catalogNames = new Set(allScreenNames().map((s) => s.name));
    const merged = allScreenNames().map((s) => s.name);
    for (const raw of extraNames) {
      const name = String(raw ?? '').trim();
      if (name && !catalogNames.has(name)) {
        merged.push(name);
        catalogNames.add(name);
      }
    }
    merged.sort((a, b) => a.localeCompare(b));

    const options = ['<option value="">(none)</option>'];
    for (const name of merged) {
      const selected = currentContext === name ? ' selected' : '';
      options.push(
        `<option value="${escapeHtml(name)}"${selected}>${escapeHtml(name)}</option>`,
      );
    }
    return options.join('');
  }

  function filteredScreens() {
    const nameQ = catalogFilters.name.getValue();
    const assignedQ = catalogFilters.assignedAppScreen.getValue();
    return screens.filter((screen) => {
      if (!matchesColumnFilter(screen.name, nameQ)) return false;
      if (!matchesColumnFilter(assignedAppScreenLabel(screen), assignedQ)) {
        return false;
      }
      return true;
    });
  }

  function filteredRoutes() {
    const appScreenQ = routesFilters.appScreen.getValue();
    const routeQ = routesFilters.route.getValue();
    const screenNameQ = routesFilters.screenName.getValue();
    const badgesQ = routesFilters.badges.getValue();

    return SORTED_ASSIGNABLE_ROUTES.filter((route) => {
      const assigned = screenAssignedToRoute(route.route);
      const screenName = assigned?.name ?? UNASSIGNED_LABEL;
      const badges = badgeLabelForRoute(route.route);

      if (!matchesColumnFilter(route.label, appScreenQ)) return false;
      if (!matchesColumnFilter(route.route, routeQ)) return false;
      if (!matchesColumnFilter(screenName, screenNameQ)) return false;
      if (!matchesColumnFilter(badges, badgesQ)) return false;
      return true;
    });
  }

  async function loadScreens() {
    setStatus('Loading screen names…');
    try {
      const { data } = await call('listTranslationScreens')(await callPayload());
      screens = data.screens ?? [];
      render();
      const seeded = data.seededFromContexts;
      const backfilled = data.routesBackfilled ?? 0;
      if (seeded?.created > 0) {
        const routeNote =
          seeded.routesAssigned > 0
            ? ` ${seeded.routesAssigned} matched an app screen route.`
            : '';
        setStatus(
          `Imported ${seeded.created} screen name${seeded.created === 1 ? '' : 's'} from existing string tags.${routeNote}`,
          'ok',
        );
      } else if (backfilled > 0) {
        setStatus(
          `Assigned ${backfilled} screen name${backfilled === 1 ? '' : 's'} to app routes from existing tags.`,
          'ok',
        );
      } else {
        setStatus(`${screens.length} screen name${screens.length === 1 ? '' : 's'} loaded.`, 'ok');
      }
    } catch (err) {
      setStatus(formatError(err), 'error');
      throw err;
    }
  }

  async function importFromStringTags() {
    setStatus('Importing screen names from string tags…');
    try {
      const { data } = await call('seedTranslationScreensFromContexts')(
        await callPayload(),
      );
      screens = data.screens ?? [];
      render();
      const created = data.created ?? 0;
      const routesAssigned = data.routesAssigned ?? 0;
      const deduped = data.deduped ?? 0;
      const routeNote =
        routesAssigned > 0
          ? ` ${routesAssigned} assigned to app screen routes.`
          : '';
      const dedupeNote =
        deduped > 0
          ? ` Removed ${deduped} redundant shorter duplicate${deduped === 1 ? '' : 's'}.`
          : '';
      if (created > 0) {
        setStatus(
          `Added ${created} screen name${created === 1 ? '' : 's'} from string tags.${routeNote}${dedupeNote}`,
          'ok',
        );
      } else if (routesAssigned > 0) {
        setStatus(
          `Assigned ${routesAssigned} screen name${routesAssigned === 1 ? '' : 's'} to app routes.${dedupeNote}`,
          'ok',
        );
      } else if (deduped > 0) {
        setStatus(`Removed ${deduped} redundant duplicate screen name${deduped === 1 ? '' : 's'}.${routeNote}`, 'ok');
      } else {
        setStatus('No new screen names found in string tags.', 'ok');
      }
    } catch (err) {
      setStatus(formatError(err), 'error');
    }
  }

  function renderNamesTable() {
    if (!els.namesBody) return;
    const filtered = filteredScreens();

    if (screens.length === 0) {
      els.namesBody.innerHTML =
        '<tr><td colspan="4" class="muted">No screen names yet. Add one above.</td></tr>';
      return;
    }

    if (filtered.length === 0) {
      els.namesBody.innerHTML =
        '<tr><td colspan="4" class="muted">No screen names match the current filters.</td></tr>';
      return;
    }

    els.namesBody.innerHTML = filtered
      .map((screen) => {
        const routeLabel = assignedAppScreenLabel(screen);
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
    const routes = filteredRoutes();

    if (routes.length === 0) {
      els.routesBody.innerHTML =
        '<tr><td colspan="4" class="muted">No app screens match the current filters.</td></tr>';
      return;
    }

    els.routesBody.innerHTML = routes
      .map((route) => {
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
      })
      .join('');
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
      render();
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
    els.refreshBtn?.addEventListener('click', () => loadScreens().catch(() => {}));

    function handleSummaryRefreshClick(e) {
      e.preventDefault();
      e.stopPropagation();
      loadScreens().catch((err) => {
        // loadScreens already sets status; avoid unhandled rejection
        console.warn('Header refresh failed', err);
      });
    }

    els.catalogRefreshBtn?.addEventListener('click', handleSummaryRefreshClick);
    els.routesRefreshBtn?.addEventListener('click', handleSummaryRefreshClick);
    els.importBtn?.addEventListener('click', () => importFromStringTags());

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
