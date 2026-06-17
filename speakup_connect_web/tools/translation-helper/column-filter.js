/** @typedef {{ value: string, label: string }} ColumnFilterOption */

const FILTER_ICON = `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/></svg>`;

function normalizeQuery(text) {
  return String(text ?? '').trim().toLowerCase();
}

/**
 * Column header filter: filter icon opens a compact popover (type or pick from list).
 * @param {{
 *   columnLabel: string,
 *   getOptions: () => ColumnFilterOption[],
 *   onFilter: () => void,
 * }} config
 */
export function createColumnHeaderFilter(config) {
  let filterValue = '';
  let popoverOpen = false;

  const th = document.createElement('th');
  th.className = 'column-filter-th';
  th.scope = 'col';

  const headWrap = document.createElement('div');
  headWrap.className = 'column-filter-head';

  const labelSpan = document.createElement('span');
  labelSpan.className = 'column-filter-label';
  labelSpan.textContent = config.columnLabel;

  const btn = document.createElement('button');
  btn.type = 'button';
  btn.className = 'column-filter-btn';
  btn.setAttribute('aria-label', `Filter ${config.columnLabel}`);
  btn.setAttribute('aria-expanded', 'false');
  btn.innerHTML = FILTER_ICON;

  const popover = document.createElement('div');
  popover.className = 'column-filter-popover hidden';
  popover.hidden = true;

  const input = document.createElement('input');
  input.type = 'search';
  input.className = 'column-filter-input';
  input.placeholder = 'Filter…';
  input.setAttribute('aria-label', `Filter ${config.columnLabel}`);

  const list = document.createElement('ul');
  list.className = 'column-filter-list';
  list.setAttribute('role', 'listbox');
  list.hidden = true;

  const clearBtn = document.createElement('button');
  clearBtn.type = 'button';
  clearBtn.className = 'column-filter-clear secondary';
  clearBtn.textContent = 'Clear';

  popover.append(input, list, clearBtn);
  headWrap.append(labelSpan, btn);
  th.append(headWrap, popover);

  function setPopoverOpen(open) {
    popoverOpen = open;
    if (open) {
      popover.hidden = false;
      popover.classList.remove('hidden');
      document.body.appendChild(popover);
      positionPopover();
      btn.setAttribute('aria-expanded', 'true');
      input.focus();
      renderList();
    } else {
      popover.hidden = true;
      popover.classList.add('hidden');
      th.appendChild(popover);
      btn.setAttribute('aria-expanded', 'false');
      list.hidden = true;
    }
  }

  function positionPopover() {
    const rect = btn.getBoundingClientRect();
    popover.style.position = 'fixed';
    popover.style.top = `${rect.bottom + 4}px`;
    popover.style.left = `${Math.max(8, rect.left)}px`;
    popover.style.right = 'auto';
    popover.style.minWidth = `${Math.max(rect.width, 208)}px`;
  }

  function updateActiveState() {
    btn.classList.toggle('column-filter-btn--active', Boolean(filterValue));
  }

  function filteredOptions() {
    const q = normalizeQuery(input.value);
    const options = config.getOptions();
    if (!q) return options;
    return options.filter(
      (opt) =>
        opt.label.toLowerCase().includes(q) ||
        opt.value.toLowerCase().includes(q),
    );
  }

  function renderList() {
    const items = filteredOptions();
    list.replaceChildren();
    if (items.length === 0) {
      list.hidden = true;
      return;
    }
    for (const opt of items) {
      const li = document.createElement('li');
      li.className = 'column-filter-option';
      li.setAttribute('role', 'option');
      li.textContent = opt.label;
      li.addEventListener('mousedown', (e) => {
        e.preventDefault();
        applyValue(opt.label);
      });
      list.appendChild(li);
    }
    list.hidden = false;
  }

  function applyValue(value) {
    filterValue = value.trim();
    input.value = filterValue;
    updateActiveState();
    setPopoverOpen(false);
    config.onFilter();
  }

  function clear() {
    filterValue = '';
    input.value = '';
    updateActiveState();
    setPopoverOpen(false);
    config.onFilter();
  }

  btn.addEventListener('click', (e) => {
    e.stopPropagation();
    setPopoverOpen(!popoverOpen);
  });

  input.addEventListener('input', () => {
    filterValue = input.value.trim();
    updateActiveState();
    renderList();
    config.onFilter();
  });

  input.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      setPopoverOpen(false);
      btn.focus();
    }
  });

  clearBtn.addEventListener('click', () => clear());

  function onDocumentClick(e) {
    if (!popoverOpen) return;
    if (th.contains(e.target) || popover.contains(e.target)) return;
    setPopoverOpen(false);
  }

  window.addEventListener('resize', () => {
    if (popoverOpen) positionPopover();
  });

  document.addEventListener('scroll', () => {
    if (popoverOpen) positionPopover();
  }, true);

  document.addEventListener('click', onDocumentClick);

  return {
    th,
    getValue: () => filterValue,
    clear,
    destroy: () => document.removeEventListener('click', onDocumentClick),
  };
}

/** @param {string} haystack @param {string} query */
export function matchesColumnFilter(haystack, query) {
  const q = normalizeQuery(query);
  if (!q) return true;
  return normalizeQuery(haystack).includes(q);
}
