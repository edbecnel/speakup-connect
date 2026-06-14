/** @typedef {{ value: string, label: string }} FilterComboboxOption */

/**
 * @param {string} text
 */
function normalizeQuery(text) {
  return String(text ?? '').trim().toLowerCase();
}

/**
 * Searchable filter combobox: type to narrow options; table filter uses typed text (substring).
 * @param {{
 *   input: HTMLInputElement,
 *   list: HTMLUListElement,
 *   onFilter: () => void,
 * }} config
 */
export function createFilterCombobox({ input, list, onFilter }) {
  /** @type {FilterComboboxOption[]} */
  let allOptions = [];

  function filteredOptions(query) {
    const q = normalizeQuery(query);
    if (!q) return allOptions;
    return allOptions.filter(
      (opt) =>
        opt.label.toLowerCase().includes(q) ||
        opt.value.toLowerCase().includes(q),
    );
  }

  function setExpanded(open) {
    input.setAttribute('aria-expanded', open ? 'true' : 'false');
    list.hidden = !open;
  }

  function renderList() {
    const items = filteredOptions(input.value);
    list.replaceChildren();
    if (items.length === 0) {
      setExpanded(false);
      return;
    }
    for (const opt of items) {
      const li = document.createElement('li');
      li.className = 'filter-combobox-option';
      li.setAttribute('role', 'option');
      li.textContent = opt.label;
      li.dataset.value = opt.value;
      li.dataset.label = opt.label;
      li.addEventListener('mousedown', (e) => {
        e.preventDefault();
        selectOption(opt);
      });
      list.appendChild(li);
    }
    setExpanded(true);
  }

  /** @param {FilterComboboxOption} opt */
  function selectOption(opt) {
    input.value = opt.label;
    input.dataset.selectedValue = opt.value;
    input.dataset.selectedLabel = opt.label;
    setExpanded(false);
    onFilter();
  }

  function clearSelection() {
    input.value = '';
    delete input.dataset.selectedValue;
    delete input.dataset.selectedLabel;
    setExpanded(false);
  }

  /** @returns {string} */
  function getFilterValue() {
    return input.value.trim();
  }

  function getFilterState() {
    return {
      text: input.value.trim(),
      selectedValue: input.dataset.selectedValue ?? '',
    };
  }

  /** @param {FilterComboboxOption[]} options */
  function setOptions(options) {
    allOptions = options;
    const current = input.value.trim();
    if (!current) return;
    const stillValid = allOptions.some(
      (opt) =>
        opt.label === current ||
        opt.value === input.dataset.selectedValue,
    );
    if (!stillValid) {
      clearSelection();
      onFilter();
    }
  }

  input.addEventListener('input', () => {
    delete input.dataset.selectedValue;
    delete input.dataset.selectedLabel;
    renderList();
    onFilter();
  });

  input.addEventListener('focus', () => {
    renderList();
  });

  input.addEventListener('blur', () => {
    window.setTimeout(() => setExpanded(false), 120);
  });

  input.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      setExpanded(false);
      input.blur();
    }
  });

  return {
    setOptions,
    clear: clearSelection,
    getFilterValue,
    getFilterState,
    input,
  };
}
