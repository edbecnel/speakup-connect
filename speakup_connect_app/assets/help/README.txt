Help assets layout
====================

Organization-type bundles:
  school/member_guide.md
  school/admin_guide.md
  school/member_tutorial.md
  school/admin_tutorial.md

Fallback:
  _default/member_guide.md
  _default/admin_guide.md

Localized (phase 1b — English placeholders until translated):
  _default/member_guide_ceb.md
  _default/admin_guide_ceb.md
  school/member_guide_ceb.md
  school/admin_guide_ceb.md

HelpAssetResolver resolves in this order:
  {orgType}/{article}_{locale}.md
  {orgType}/{article}.md
  _default/{article}_{locale}.md
  _default/{article}.md

If orgType is unavailable, resolver uses _default only.

Sync docs/help/*_CEB.md when editing Cebuano copies.

Legacy flat files at this folder root (member_guide.md, admin_guide.md):
  Copies of _default — kept so Flutter hot restart does not fail after
  asset path changes. The app resolves org-type paths via HelpAssetResolver.

Sync from docs/help/ when editing guides.

App language UI: globe dropdown at top of Home + Settings → Appearance → Language.
Picker labels use kLanguageNativeLabels (English / Bisaya / Cebuano) — see docs/INTERNATIONALIZATION.md §6.1.
