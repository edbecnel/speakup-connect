# Speakup Connect – Branding, App Icon, and App Name Customization Specification

## Purpose

This document defines the branding architecture, restrictions, and platform-specific implementation strategy for customizable app branding within Speakup Connect.

The goal is to:
- Support organization/school-specific branding
- Preserve the core "Speakup Connect" identity
- Allow scalable white-label style deployments
- Maintain App Store / Play Store compliance
- Allow controlled customization without fragmenting the brand

---

# 1. Branding Model Overview

Speakup Connect will support two branding modes:

## A. Standard Multi-Tenant App (Primary Deployment Model)

A single public app:
- App Store
- Google Play Store

Users install:
- "Speakup Connect"

This version supports:
- Custom themes
- Custom icon color variants
- Organization branding inside the app
- Organization-specific configuration pushed remotely
- Optional alternate launcher icons
- Optional organization suffixes where platform limitations allow

---

## B. Organization-Specific Branded Builds (Premium / Enterprise Clients)

For important schools, organizations, or enterprise customers:
- Separate app builds may be released

Examples:
- Speakup Connect MONHS
- Speakup Connect Xavier Academy
- Speakup Connect City Government

These builds:
- Still retain Speakup Connect branding
- Use organization-specific color schemes
- Include organization presets/configuration
- May include organization-specific onboarding
- May include preconfigured integrations/features

These are effectively:
- Build flavors
- White-label variants
- Tenant-specific deployments

---

# 2. Branding Restrictions (MANDATORY)

These restrictions are REQUIRED to preserve the Speakup Connect brand identity.

---

## 2.1 App Icon Restrictions

### REQUIRED:
- All icons MUST use the official Speakup Connect graphic/logo
- Only color schemes may be customized

### NOT ALLOWED:
- Replacing the logo graphic entirely
- Custom organization-created icons
- Removal of Speakup Connect identity elements

### Examples

Allowed:
- Blue/green default icon
- Red/black MONHS theme
- Gold/navy premium theme
- Purple/silver organization theme

Not Allowed:
- Completely different mascot/logo
- Different symbol replacing Speakup Connect logo
- Organization-only branding without Speakup Connect logo

---

## 2.2 App Name Restrictions

### REQUIRED:
All app names MUST begin with:

"Speakup Connect"

### Optional Allowed Suffix:
Organizations may append their identifying name.

### Examples

Allowed:
- Speakup Connect
- Speakup Connect MONHS
- Speakup Connect Xavier Academy
- Speakup Connect LGU Oroquieta

Not Allowed:
- MONHS App
- Xavier Connect
- SchoolConnect
- MONHS Messenger

The Speakup Connect prefix is mandatory.

---

# 3. Standard App Branding Features

The standard Speakup Connect app should support runtime branding customization where platform limitations allow.

---

## 3.1 Runtime Theme Customization

Supported:
- Organization color themes
- Header colors
- Accent colors
- Splash screens
- Background imagery
- Organization logo inside app
- Role-based themes

Theme configuration may be:
- Server-controlled
- Tenant-controlled
- Broadcast by superuser admin

---

## 3.2 Alternate App Icons

The app should support:
- Built-in alternate color-themed icons

Examples:
- Blue/green (default)
- Red/black
- Gold/navy
- Purple/silver
- Dark mode

IMPORTANT:
- Only approved built-in icons are allowed
- Icons must preserve the official Speakup Connect graphic
- Only colors may vary

---

# 4. Superuser-Controlled Branding Broadcast

## Goal

Allow a school/organization superuser admin to define branding preferences that propagate to normal users.

Examples:
- School chooses red/black theme
- Students and teachers automatically receive:
  - Theme colors
  - Organization branding
  - Recommended app icon

---

## 4.1 Theme Broadcast

Supported:
- Remote organization theme configuration
- Automatic app theme updates

Recommended architecture:
- Tenant branding configuration stored server-side
- App periodically syncs branding profile

---

## 4.2 App Icon Broadcast Limitations

### Android

Android may support:
- Launcher alias switching
- Alternate icons

Possible:
- App icon changes automatically after sync

However:
- Behavior varies by launcher/device
- Some launchers cache aggressively

Implementation should be considered:
- Best effort
- Optional enhancement

---

### iOS

iOS limitations:
- App icons can only switch among pre-bundled icons
- Runtime icon switching requires user confirmation
- App names cannot dynamically change

Therefore:
- Superuser cannot silently force icon changes
- App can prompt users to apply organization branding

Recommended UX:
- Organization admin selects preferred branding
- App shows:
  "Your organization recommends the Red/Black MONHS theme"
- User taps:
  "Apply Branding"

---

# 5. App Name Runtime Limitations

---

## iOS

iOS does NOT support:
- Dynamic runtime app name changes

App names are:
- Defined at build time
- Controlled by bundle metadata

Therefore:
- Organization-specific names require separate app builds

Examples:
- Speakup Connect
- Speakup Connect MONHS

Would require:
- Separate build flavor
- Separate App Store deployment

---

## Android

Android supports limited launcher alias tricks.

Possible:
- Switching launcher activity labels

However:
- Behavior is inconsistent across devices
- May cause icon duplication
- Launcher caching issues possible

Recommendation:
- Do NOT rely heavily on runtime app renaming
- Prefer organization branding INSIDE the app

---

# 6. Recommended Branding Strategy

## Standard Public App

App Store Name:
- Speakup Connect

Features:
- Runtime themes
- Organization branding
- Optional alternate icons
- Tenant presets/configuration

Recommended for:
- Most schools/organizations

---

## Premium Organization Builds

Separate branded builds:
- Speakup Connect MONHS
- Speakup Connect Xavier Academy

Features:
- Custom colors
- Organization presets
- Organization onboarding
- Organization-specific integrations
- Organization-specific default branding

Still MUST:
- Retain Speakup Connect branding
- Retain Speakup Connect logo

---

# 7. Technical Implementation Notes (Flutter)

Recommended implementation:

## Flutter Features
- Build flavors
- Environment configurations
- Remote theme configuration
- Alternate launcher icons
- Dynamic theming

---

## Suggested Flutter Packages

Possible packages:
- flutter_launcher_icons
- flutter_dynamic_icon
- alternate_icon

---

## Recommended Architecture

### Shared Core App
Single shared codebase:
- Speakup Connect core functionality

### Tenant Branding Layer
Separate:
- Theme configuration
- Branding assets
- Tenant presets
- Organization metadata

### Build Flavor Layer
Optional:
- Enterprise organization builds

---

# 8. Branding Enforcement Rules

The system MUST validate:

## Icon Rules
- Only approved icon variants allowed
- Logo graphic cannot be replaced
- Only approved color palette substitutions

## Name Rules
- Must begin with:
  "Speakup Connect"
- Organization name only allowed as suffix

---

# 9. Examples

## Standard App

App Name:
- Speakup Connect

Organization Theme:
- MONHS red/black

In-App Branding:
- MONHS logo
- MONHS colors

Optional Icon:
- Red/black Speakup Connect icon

---

## Premium Organization Build

App Store Listing:
- Speakup Connect MONHS

Icon:
- Speakup Connect logo in red/black

Features:
- Preconfigured organization settings
- Organization onboarding
- Organization branding

---

# 10. Long-Term Brand Strategy

The purpose of these restrictions is to:
- Build recognition of the Speakup Connect brand
- Prevent brand fragmentation
- Maintain consistent identity across deployments
- Allow customization while preserving platform identity
- Create a recognizable ecosystem of organization-specific apps

This approach combines:
- Multi-tenant SaaS branding
- White-label flexibility
- Enterprise deployment capability
- Strong master-brand preservation

---

# 11. Visual Identity — Core Brand Colors

> ✅ **Confirmed May 21, 2026.** All hex values are finalized.  
> All UI components, themes, and organization palette options are derived from this foundation.

---

## 11.1 Default Brand Palette

| Role | Name | Hex | Usage |
|---|---|---|---|
| Primary | Speakup Blue | `#2563EB` | Primary buttons, links, active states |
| Secondary | Speakup Green | `#10B981` | Success states, secondary actions |
| Background | Surface White | `#FAFAFA` | App background |
| Surface | Card Grey | `#F3F4F6` | Cards, bottom sheets |
| On Primary | Text on Primary | `#FFFFFF` | Text/icons on primary color |
| Error | Alert Red | `#DC2626` | Error messages, destructive actions |
| Warning | Caution Amber | `#F59E0B` | Warnings, pending states |
| Neutral Dark | Text Primary | `#111827` | Primary body text |
| Neutral Mid | Text Secondary | `#6B7280` | Secondary/hint text |
| Neutral Light | Divider | `#E5E7EB` | Dividers, borders |

> **Contrast check:** `#2563EB` on white = 5.03:1 ✓ (WCAG AA). White text on `#2563EB` = 5.03:1 ✓.  
> `#DC2626` on white = 4.93:1 ✓. `#10B981` must use dark text (`#111827`) when used as background — contrast 8.26:1 ✓.

---

## 11.2 Dark Mode Palette

| Role | Name | Hex | Notes |
|---|---|---|---|
| Primary (dark) | Speakup Blue Light | `#60A5FA` | Lightened for dark surface contrast — on dark bg = 4.7:1 ✓ |
| Background (dark) | Dark Background | `#111827` | gray-900 |
| Surface (dark) | Dark Surface | `#1F2937` | gray-800 — cards and sheets |
| Text Primary (dark) | Dark Text | `#F9FAFB` | gray-50 — on dark background = 16.7:1 ✓ |

---

## 11.3 Approved Organization Theme Palettes

Each approved theme must pass the accessibility contrast check defined in Section 18.

| Theme Name | Primary | Secondary | Intended Tenant Use |
|---|---|---|---|
| Default (Blue/Green) | `#2563EB` | `#10B981` | Standard public app |
| Crimson/Black | `#C0182C` | `#1A1A1A` | MONHS pilot — white text on both |
| Gold/Navy | `#1E3A5F` | `#D4A017` | Premium — navy primary (white text), gold accent (use dark text) |
| Purple/Silver | `#7C3AED` | `#9CA3AF` | Premium — white text on purple; dark text on silver |
| Admin (Shield Blue) | `#1E40AF` | `#3B82F6` | Admin app flavor only — visually distinct from user app |

> Organizations may NOT define free-pick custom hex colors. They must select from this approved palette list. This prevents accessibility failures and brand fragmentation.

---

# 12. Typography

> ✅ **Confirmed May 21, 2026.** Font choices are finalized.

---

## 12.1 Font Stack

| Role | Font Family | Weight(s) | Fallback |
|---|---|---|---|
| Display / Heading | Plus Jakarta Sans | Bold (700), SemiBold (600) | System sans-serif |
| Body | Inter | Regular (400), Medium (500) | System sans-serif |
| Monospace / Code | JetBrains Mono | Regular (400) | System monospace |

> All three fonts are free on Google Fonts. Plus Jakarta Sans and Inter both include full Latin Extended character sets with Filipino diacritics (ñ, á, é, í, ó, ú).

---

## 12.2 Type Scale

| Token | Size | Weight | Line Height | Usage |
|---|---|---|---|---|
| `displayLarge` | 32sp | 700 | 1.20 | Splash / hero headings |
| `headlineMedium` | 24sp | 600 | 1.30 | Section headings |
| `titleMedium` | 16sp | 600 | 1.50 | Card titles, list headers |
| `bodyLarge` | 16sp | 400 | 1.50 | Primary body text |
| `bodyMedium` | 14sp | 400 | 1.43 | Secondary body text |
| `labelLarge` | 14sp | 500 | 1.43 | Buttons |
| `labelSmall` | 11sp | 400 | 1.45 | Captions, timestamps |

---

## 12.3 Multilingual Typography

SpeakUp Connect supports multi-language (including Filipino/Tagalog and potentially others). Font selection must:
- Include full Latin Extended character set
- Support diacritics used in Filipino (ñ, á, é, í, ó, ú)
- Be tested with longer translated strings — Filipino text is typically 20–40% longer than English equivalents

---

# 13. Logo Specification

> ⚠️ **[ TO BE DEFINED ]** — Logo artwork and source files must be finalized before asset generation.

---

## 13.1 Logo Variants

| Variant | Usage |
|---|---|
| Full lockup (icon + wordmark) | Splash screen, onboarding, marketing |
| Icon only | App launcher icon, favicon, avatar placeholder |
| Wordmark only | Web header, email footer |
| Monochrome (white) | Dark backgrounds, notification icons |
| Monochrome (dark) | Light backgrounds, print |

---

## 13.2 Clear Space Rule

The logo must have clear space of at least **`[ TBD ]`** (e.g., 1× the icon height) on all sides. No other graphic element, text, or edge may enter this space.

---

## 13.3 Minimum Sizes

| Context | Minimum Size |
|---|---|
| App launcher icon | 48×48 dp (Android), 29×29 pt (iOS) |
| In-app avatar/badge | `[ TBD ]` |
| Web favicon | 16×16 px |
| Web header | `[ TBD ]` height |
| Print (business card) | `[ TBD ]` mm |

---

## 13.4 Forbidden Logo Uses

- Do NOT stretch or distort the logo
- Do NOT recolor the logo outside of the approved monochrome or themed variants
- Do NOT place the logo on a background that fails the contrast check (Section 18)
- Do NOT add drop shadows, outlines, or effects to the logo
- Do NOT crop, rotate, or rearrange logo elements
- Do NOT substitute the Speakup Connect logo with an organization's own logo

---

## 13.5 Source Asset Requirements

| Asset | Format | Resolution |
|---|---|---|
| Master logo | SVG (vector) | Scalable |
| App icon source | PNG | Minimum 1024×1024 px |
| Splash screen artwork | SVG or PNG | Minimum 2048×2048 px |
| Favicon source | SVG or PNG | 512×512 px |

---

# 14. In-App Branding Placement

Defines where and how organization branding appears inside the app for the standard multi-tenant build.

---

## 14.1 Placement Map

| Location | What Appears | Rules |
|---|---|---|
| Splash / launch screen | Speakup Connect logo centered | Org logo may appear below as "Powered by" — optional |
| App bar / top header | App name (org-suffixed if applicable) | Org logo may appear as leading icon — max height `[ TBD ]` dp |
| Home screen hero banner | Org name + optional org banner image | Aspect ratio 16:9 or 3:1; max file size `[ TBD ]` KB |
| Login screen | Speakup Connect logo + org name | Org logo may appear above the form |
| Drawer / side menu header | Org logo + org name + user name | Org logo: max `[ TBD ]` dp diameter |
| Footer / about screen | "Powered by Speakup Connect" | Always present — cannot be removed |
| Push notification icon | Speakup Connect monochrome icon | Platform standard — cannot be org-customized |

---

## 14.2 Organization Logo Requirements (Uploaded by Org Admin)

| Property | Requirement |
|---|---|
| Format | PNG or JPG |
| Recommended size | 512×512 px (square) or `[ TBD ]` (rectangular) |
| Maximum file size | `[ TBD ]` KB |
| Background | Transparent preferred; solid fill accepted |
| Content | Must not contain offensive imagery (moderated on upload) |

---

# 15. Admin App Branding

The Admin app flavor is visually distinct from the standard user app to prevent confusion about which app a user has open.

---

## 15.1 Icon Treatment

- Same Speakup Connect base logo
- Admin-specific color variant: **Shield Blue** (see Section 11.3)
- A small shield badge or indicator overlaid on the icon corner — `[ TBD: exact design ]`
- App Store listing name: **"SpeakUp Connect — Admin"**

---

## 15.2 In-App Visual Distinction

| Element | User App | Admin App |
|---|---|---|
| App bar color | Primary brand color | Admin accent (Shield Blue) |
| Bottom nav | Standard icons | Admin-specific icons (e.g., shield, report triage) |
| Role badge | None | Visible role chip (e.g., "Admin", "Teacher") on profile and app bar |
| Splash screen | Standard Speakup Connect | Standard + "Admin" label beneath logo |

---

## 15.3 Role-Based UI Context

Within the admin app, the UI should visually reflect the active role:

| Role | Accent Treatment |
|---|---|
| Org Admin | Full admin accent color |
| Moderator | Moderator badge, slightly muted accent |
| Teacher / Staff | Teacher badge, softer accent |
| Group Leader | Group Leader badge, neutral accent |

---

# 16. Web Branding Specification

Covers the Next.js web app — both the **user-facing portal** and the **admin portal**.

---

## 16.1 User Portal (speakupconnect.com or subdomain)

| Element | Specification |
|---|---|
| Primary font | Same as app (Section 12) |
| Color palette | Same as app default palette (Section 11.1) |
| Logo placement | Top-left in nav header |
| Favicon | Speakup Connect icon only variant |
| Page title format | `[Page Name] — Speakup Connect` |
| Org branding | Org banner and color theme applied to authenticated pages |
| Meta / OG image | `[ TBD ]` — Speakup Connect branded share image |

---

## 16.2 Admin Portal (admin.speakupconnect.com or `/admin` route group)

| Element | Specification |
|---|---|
| Color palette | Admin accent palette (Shield Blue) — visually distinct from user portal |
| Logo | Speakup Connect logo + "Admin" wordmark |
| Page title format | `[Page Name] — Speakup Connect Admin` |
| Sidebar | Persistent left sidebar on desktop; bottom sheet on mobile |
| Favicon | Admin variant (shield badge icon) |

---

## 16.3 Responsive Breakpoints

| Name | Breakpoint | Target |
|---|---|---|
| Mobile | < 640px | Phone browsers |
| Tablet | 640px – 1024px | Tablet browsers |
| Desktop | > 1024px | Laptop/desktop (primary for admin portal) |

---

# 17. Accessibility Requirements

All color themes — both default and organization-defined — MUST meet the following minimum standards.

---

## 17.1 Contrast Ratios (WCAG 2.1 AA)

| Text Type | Minimum Contrast Ratio |
|---|---|
| Normal text (< 18pt) | 4.5 : 1 |
| Large text (≥ 18pt or ≥ 14pt bold) | 3 : 1 |
| UI components and icons | 3 : 1 |

---

## 17.2 Theme Validation

When an Org Admin selects or requests a color theme:
- The system MUST automatically calculate contrast ratios for all text/background combinations in that theme
- Themes that fail any contrast check MUST be rejected or flagged before being applied
- A validation result must be shown to the admin: pass/fail per color pair

---

## 17.3 Additional Accessibility Standards

- Touch targets: minimum **48×48 dp** (Android Material), **44×44 pt** (iOS HIG)
- Font scaling: app must not break layout at system font sizes up to 200%
- Screen reader support: all interactive elements must have semantic labels
- Color must never be the **sole** means of conveying information (e.g., always pair color with an icon or text label)

---

# 18. Tenant Branding — Firestore Data Model

Defines the server-side structure that drives runtime theming and branding.

---

## 18.1 Document Path

```
/tenants/{tenantId}/branding
```

---

## 18.2 Document Schema

```json
{
  "orgName": "string",
  "orgNameSuffix": "string | null",
  "logoUrl": "string | null",
  "bannerImageUrl": "string | null",
  "themeId": "string",
  "customTheme": {
    "primaryColor": "#RRGGBB",
    "secondaryColor": "#RRGGBB",
    "surfaceColor": "#RRGGBB",
    "onPrimaryColor": "#RRGGBB"
  } ,
  "darkModeEnabled": "boolean",
  "alternateIconId": "string | null",
  "updatedAt": "Timestamp",
  "updatedBy": "string (userId)"
}
```

> `themeId` references a pre-approved theme from the approved palette (Section 11.3).  
> `customTheme` is only populated for enterprise builds with a custom approved palette.  
> If `themeId` is set, `customTheme` is ignored.

---

## 18.3 Validation Rules (Firestore Security Rules)

- Only users with `role == "org_admin"` or `role == "super_admin"` may write to this document
- `primaryColor` and `secondaryColor` must match the regex `^#[0-9A-Fa-f]{6}$`
- `logoUrl` must point to a path within `/tenants/{tenantId}/assets/` in Firebase Storage (prevents external URL injection)
- `orgNameSuffix` must not exceed 40 characters
- `orgName` must not exceed 80 characters

> ⚠️ **Implementation note:** The `/tenants/{tenantId}/branding` path above is a
> planning placeholder. The actual deployed Firestore structure stores theme fields
> (`primaryColor`, `secondaryColor`, `logoUrl`, `tagline`, `welcomeMessage`) directly
> on the `organizations/{organizationId}` root document — see §19 below.

---

# 19. Runtime Theming — Implementation Specification

> ✅ **Implemented as of May 21, 2026.**
>
> This section is the authoritative developer reference for how runtime theming
> works end-to-end: who changes it, where it's stored, how it propagates, and
> what its limits are.

---

## 19.1 Who Can Change the Theme

Only users with role `super_admin` within an organization may write theme fields.
`admin` and all lower roles are read-only for theme data.

This is enforced at two layers:
1. **Client UI** — The "Theme Settings" screen in the admin app is only rendered
   when `UserProfileEntity.role == 'super_admin'`.
2. **Firestore Security Rules** — The `organizations/{organizationId}` document
   write rule restricts updates to `primaryColor`, `secondaryColor`, `logoUrl`,
   `tagline`, and `welcomeMessage` to `super_admin` callers only.

---

## 19.2 What Can Be Changed at Runtime

The following fields on `organizations/{organizationId}` drive runtime theming
and can be updated by a super_admin without any app release:

| Field | Type | Effect | Approval palette required? |
|---|---|---|---|
| `primaryColor` | `#RRGGBB` string | Primary buttons, links, app bar background, active tab indicator | ✅ Yes — must be from §11.3 |
| `secondaryColor` | `#RRGGBB` string | Success states, secondary actions, FAB | ✅ Yes — must be from §11.3 |
| `logoUrl` | Firebase Storage URL | Org logo shown in header, drawer, splash "powered by" area | No — uploaded via Storage |
| `tagline` | string ≤ 120 chars | Splash screen subtitle | No |
| `welcomeMessage` | string ≤ 200 chars | Home dashboard hero greeting | No |

---

## 19.3 What Cannot Be Changed at Runtime

| Property | Reason | How to Change |
|---|---|---|
| App launcher icon | Platform OS caches icons at install time | Requires a new client build (§CLIENT_BUILDS.md) |
| App name in OS / app drawer | iOS: set at build time only; Android: inconsistent | Requires a new client build |
| App Store / Play Store listing name | Controlled by store accounts | Requires a new app listing |
| `organizationId` | Primary key — changing it would orphan all data | Contact platform super-admin |
| Font family | Bundled in the app binary | Requires an app release |

---

## 19.4 Firestore Document Path

```
organizations/{organizationId}
```

Theme fields written by a super_admin:

```json
{
  "primaryColor":    "#CC0000",
  "secondaryColor":  "#1A1A1A",
  "logoUrl":         "https://storage.googleapis.com/...",
  "tagline":         "One Voice. Better MONHS.",
  "welcomeMessage":  "What would you like to improve at our school?",
  "updatedAt":       "<server timestamp>"
}
```

---

## 19.5 Real-Time Propagation — How It Works

When a super_admin saves new theme colors in the Admin settings screen:

```
super_admin writes primaryColor → organizations/{orgId} in Firestore
  └─► Firestore triggers snapshot update
      └─► OrganizationRepositoryImpl.watchOrganizationConfig() emits new entity
          └─► OrganizationConfig notifier: state = AsyncValue.data(newConfig)
              └─► organizationConfigProvider notifies all watchers
                  └─► app.dart rebuilds MaterialApp.router with new AppTheme.light/dark(orgColors)
                      └─► All screens rebuild with new ColorScheme
                          ← user sees new theme within ~1–2 seconds, no restart needed
```

**Key code locations:**

| Layer | File | What it does |
|---|---|---|
| Repository stream | `organization/data/repositories/organization_repository_impl.dart` | Firestore `.snapshots()` → entity stream |
| Provider live update | `organization/presentation/providers/organization_provider.dart` | `_configSub.listen()` → updates `state` |
| Theme application | `lib/app.dart` | `ref.watch(organizationConfigProvider)` → `AppTheme.light(orgColors)` |
| Theme builder | `lib/core/theme/app_theme.dart` | Builds `ThemeData` from `OrgThemeColors` |

---

## 19.6 Admin UI Workflow (to be built — Sprint: Admin Settings)

The "Branding & Theme" settings screen in the admin app will provide:

1. **Color theme selector** — grid of approved palette cards (§11.3).
   Super_admin taps a card to preview, then taps "Apply to all users".
2. **Logo upload** — file picker → upload to
   `organizations/{orgId}/assets/logo.{ext}` in Firebase Storage →
   writes returned download URL to `logoUrl` field.
3. **Tagline editor** — single-line text field, 120-char limit.
4. **Welcome message editor** — multi-line text field, 200-char limit.
5. **Live preview panel** — renders a miniature version of the home screen
   using the selected theme before saving.
6. **"Save & Broadcast"** button — calls
   `OrganizationRepository.updateThemeColors()` which writes all changed
   fields in a single Firestore `update()` call.

All connected user clients update automatically within ~1–2 seconds of saving.
Users do not need to restart the app or pull-to-refresh.

---

## 19.7 New User Experience

When a user registers (or opens the app for the first time after installation),
the theme is loaded as part of the normal app startup sequence:

1. `main.dart` → Firebase init → `ProviderScope` created
2. `organizationConfigProvider` fires an initial `getOrganizationConfig` fetch
3. `app.dart` receives the org config and builds `MaterialApp` with the correct
   `OrgThemeColors`
4. All screens the user sees — login, apply-to-join, pending approval, home — are
   already rendered with the organization's chosen theme

There is no "default blue then flash to red" — the theme is applied before any
screen is shown because the router's splash route waits for the config to resolve.

---

## 19.8 Fallback Behavior

If Firestore is unreachable (no network, cold start before cache warms):

- The provider falls back to `OrganizationConfigModel.monhsDev()` which uses the
  default Speakup Blue/Green palette.
- Once connectivity is restored, the Firestore stream reconnects automatically and
  the correct org theme is applied within seconds.
- No user action is required.

---

## 19.9 Color Validation

Before writing, the admin UI must validate that the selected `primaryColor` and
`secondaryColor` combination passes WCAG 2.1 AA contrast (§17.1).

Only colors from the approved palette (§11.3) are selectable in the UI, so
they are pre-validated. If a future feature allows custom hex input (enterprise
tier only), contrast must be checked client-side before the write is permitted.