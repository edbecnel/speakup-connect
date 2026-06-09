Help assets layout
====================

Org-specific guides (used by the app):
  orgs/{organizationId}/member_guide.md
  orgs/{organizationId}/admin_guide.md

Fallback:
  _default/member_guide.md
  _default/admin_guide.md

Legacy flat files at this folder root (member_guide.md, admin_guide.md):
  Copies of _default — kept so Flutter hot restart does not fail after
  asset path changes. The app loads org-specific paths via HelpAssetResolver.

Sync from docs/help/ when editing guides.
