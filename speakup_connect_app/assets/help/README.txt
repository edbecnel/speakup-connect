Help assets layout
====================

Org-specific guides (used by the app):
  orgs/{organizationId}/member_guide.md
  orgs/{organizationId}/admin_guide.md
  orgs/{organizationId}/member_tutorial.md
  orgs/{organizationId}/admin_tutorial.md

Canonical school bundle (shared across school orgs):
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
  orgs/{organizationId}/member_guide_ceb.md
  orgs/{organizationId}/admin_guide_ceb.md

HelpAssetResolver tries {article}_guide_{locale}.md then {article}_guide.md
with this order:
  orgs/{orgId} -> school -> _default
Sync docs/help/*_CEB.md when editing Cebuano copies.

Legacy flat files at this folder root (member_guide.md, admin_guide.md):
  Copies of _default — kept so Flutter hot restart does not fail after
  asset path changes. The app loads org-specific paths via HelpAssetResolver.

Sync from docs/help/ when editing guides.

App language UI: globe dropdown at top of Home + Settings → Appearance → Language.
Picker labels use kLanguageNativeLabels (English / Bisaya / Cebuano) — see docs/INTERNATIONALIZATION.md §6.1.
