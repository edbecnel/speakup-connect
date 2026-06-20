# Onboarding a New School — Client App Build Guide

> **Audience:** Developers deploying Speakup Connect for a new VIP / pilot school  
> **Prerequisite:** Organization document already exists in Firestore (`organizations/{orgId}`) — typically created by the [self-serve wizard](SCHOOL_ONBOARDING_AND_SUBSCRIPTIONS.md) or super-admin seed  
> **Deep dive:** [CLIENT_BUILDS.md](CLIENT_BUILDS.md) (Gradle flavors, CI/CD, Firebase per flavor)  
> **Product flow (wizard, billing, VIP vs standard):** [SCHOOL_ONBOARDING_AND_SUBSCRIPTIONS.md](SCHOOL_ONBOARDING_AND_SUBSCRIPTIONS.md)

---

## 1. Two Ways Schools Join the Platform

| Model | App store listing | Launcher name | Icon | Default org | When to use |
|---|---|---|---|---|---|
| **Standard app** | One shared listing: *Speakup Connect* | `Speakup Connect` | Default blue/green | User picks / joins org at runtime | Standard-plan schools; multi-tenant in one app; admin uses **setup wizard → pay to activate** |
| **Client build (VIP)** | **Separate listing per school** | `Speakup {ShortName}` (e.g. `Speakup MONHS`) | School color theme on home screen | Pre-loaded `orgId` | Enterprise / VIP contracts; icon and launcher name fixed at install time |

**Rule of thumb:** If the school needs its **own icon and name under the app icon on the phone home screen**, you must publish a **client build**. Colors, logo, tagline, and in-app org name can still be changed at runtime via Firestore — but the **OS launcher label and icon are fixed at install time**.

---

## 2. App Naming Convention

| Build | Launcher / task-switcher name | In-app splash (two lines) |
|---|---|---|
| Standard | `Speakup Connect` | `SpeakUp` + org `displayName` from Firestore |
| Client (MONHS) | `Speakup MONHS` | `SpeakUp` + `MONHS` (or Firestore `displayName` when loaded) |

- Client builds use the short form **`Speakup {SchoolAbbrev}`** under the icon (space is limited on Android).
- The word **Speakup** (product brand) is always present; the school suffix identifies the variant.
- Do **not** use school-only names (`MONHS App`, `Xavier Connect`, etc.) — see [SPEAKUP CONNECT BRANDING.md](SPEAKUP%20CONNECT%20BRANDING.md).

---

## 3. What Is Already Implemented (MONHS Pilot)

These files exist on `main` today and serve as the template for the next school:

| File | Purpose |
|---|---|
| `lib/flavor_config.dart` | Compile-time identity: `appDisplayName`, `orgId`, flavor enum |
| `lib/main_common.dart` | Shared Firebase + `runApp` startup |
| `lib/main.dart` | **MONHS entry point** — sets `FlavorConfig.monhs()` |
| `lib/main_standard.dart` | Standard app entry point — `FlavorConfig.standard()` |
| `lib/config/app_config.dart` | Reads `appName` and `defaultOrganizationId` from `FlavorConfig` |
| `android/app/src/main/AndroidManifest.xml` | `android:label="Speakup MONHS"` (pilot; move to Gradle `resValue` when second flavor is added) |
| `ios/Runner/Info.plist` | `CFBundleDisplayName` = `Speakup MONHS` |

**Run the MONHS pilot locally:**

```powershell
flutter run -d <device-id>
# Uses lib/main.dart → Speakup MONHS, org monhs-ph-001
```

**Run the standard app (future store listing):**

```powershell
flutter run -t lib/main_standard.dart -d <device-id>
```

> After Android `productFlavors` are added, client builds will also require  
> `--flavor {orgId}` — see [CLIENT_BUILDS.md §5](CLIENT_BUILDS.md#5-android-flavor-setup).

---

## 4. School Branding — Two Separate Steps

School colors appear in **two places**. They are configured differently and must
both be completed before handoff.

| What | Where it shows | How to set | Requires app rebuild? |
|---|---|---|---|
| **Launcher app icon** | Phone home screen / app drawer | Manual image edit (GIMP) + `flutter_launcher_icons` | **Yes** — baked into the APK/IPA |
| **In-app theme** (buttons, headers, splash accent) | Inside the app after launch | **Admin → Branding Settings** (or Firestore seed) | **No** — live from Firestore |

The icon color scheme and the in-app primary/secondary colors should **match the
school's brand guide**, but they are applied through separate workflows.

### 4.A Customize the app icon colors (manual — GIMP or similar)

There is **no automated icon recolor tool** in this project. Each client build
needs a hand-edited PNG derived from the master Speakup Connect icon.

**Source asset:** `assets/icons/app_icon.png` (standard blue/green icon)

**Rules (mandatory):**
- Keep the **same Speakup Connect logo graphic** — only change colors
- Do **not** replace the logo with a school mascot or alternate symbol
- Export **1024×1024 PNG**, no transparency (Play Store / App Store requirement)
- Save to `assets/icons/flavors/{orgId}/icon.png`

**GIMP workflow (recommended):**

1. Open `assets/icons/app_icon.png` in GIMP (or Photoshop, Affinity Photo, etc.)
2. Identify the color regions to change (typically background + accent areas)
3. Use **Colors → Hue-Saturation**, **Colorize**, or selective fill to apply the
   school's primary and secondary brand colors
4. Zoom to 100% and verify edges are clean on a phone-sized preview
5. **File → Export As… → `icon.png`** (1024×1024)
6. Save to `assets/icons/flavors/{orgId}/icon.png`
7. *(Android adaptive icons)* Optionally export a foreground layer
   (`icon_foreground.png` — logo on transparent background) and set the adaptive
   background hex in `flutter_launcher_icons-{orgId}.yaml` — see
   [CLIENT_BUILDS.md §7](CLIENT_BUILDS.md#7-app-icon-generation)
8. Generate platform icons:

```powershell
dart run flutter_launcher_icons -f flutter_launcher_icons-{orgId}.yaml
```

9. Rebuild and install the app — the home-screen icon updates **only after reinstall**

**MONHS example:** red (`#CC0000`) + near-black (`#1A1A1A`) on the standard logo shape.

### 4.B Set in-app default colors (Admin Settings — before publish)

The **primary** and **secondary** colors control the in-app Material theme
(buttons, app bar, splash accent, etc.). They are stored on the org document in
Firestore and should be set **before the school receives the published app** so
first launch shows the correct branding.

**In the app (recommended):**

1. Sign in as **org-admin**
2. Open **Admin Dashboard** → tap the **palette icon** (tooltip: *Branding Settings*)
   — route: `/admin/settings`
3. Under **Brand Colors**, enter the school's hex codes:
   - **Primary Color** — e.g. `#CC0000`
   - **Secondary Color** — e.g. `#1A1A1A`
4. Optionally set **Display Name** (splash shows `SpeakUp {Display Name}`)
5. Tap **Save Branding**

Changes write to `organizations/{orgId}` (`primaryColor`, `secondaryColor`) and
propagate to all connected devices in real time. The app also caches them locally
for instant startup on the next launch.

**Alternative — seed in Firestore directly** (before first admin login):

```json
{
  "displayName": "MONHS",
  "primaryColor": "#CC0000",
  "secondaryColor": "#1A1A1A"
}
```

**Pre-publish checklist for colors:**
- [ ] Icon PNG edited in GIMP and generated via `flutter_launcher_icons`
- [ ] Admin Branding Settings saved with the **same** primary/secondary hex codes
- [ ] Fresh install shows matching icon (home screen) and theme (inside app)

---

## 5. Checklist — Onboarding a New School (Client Build)

Replace `{orgId}`, `{shortName}`, and `{OrgName}` with the school's values  
(e.g. `xavier-ph-001`, `Xavier`, `Xavier Academy`).

### 5.1 Business & Firestore (before any build)

- [ ] Confirm contract tier (pilot or VIP client build — not standard-plan only)
- [ ] Create `organizations/{orgId}` in Firestore (or run org seed script)
- [ ] Seed roles, categories, and org-admin account
- [ ] Agree launcher name with client: **`Speakup {shortName}`**
- [ ] Agree **primary + secondary** hex codes from the school's brand guide
- [ ] **Icon:** Recolor `assets/icons/app_icon.png` in **GIMP** → save as
      `assets/icons/flavors/{orgId}/icon.png` (see [§4.A](#4a-customize-the-app-icon-colors-manual--gimp-or-similar))
- [ ] **In-app theme:** Set primary/secondary in **Admin → Branding Settings**
      before publish (see [§4.B](#4b-set-in-app-default-colors-admin-settings--before-publish))

### 5.2 Dart layer (commit to `main` first)

- [ ] Add `AppFlavor.{orgId}` to `lib/flavor_config.dart`
- [ ] Add factory constructor, e.g. `FlavorConfig.xavier()`:

```dart
static FlavorConfig xavier() => FlavorConfig._(
  flavor: AppFlavor.xavier,
  appDisplayName: 'Speakup Xavier',
  orgId: 'xavier-ph-001',
);
```

- [ ] Create `lib/main_{orgId}.dart`:

```dart
import 'package:speakup_connect/flavor_config.dart';
import 'package:speakup_connect/main_common.dart';

void main() async {
  FlavorConfig.instance = FlavorConfig.xavier();
  await mainCommon();
}
```

- [ ] Verify `AppConfig.appName` and `AppConfig.defaultOrganizationId` resolve correctly (no hardcoded strings elsewhere)

### 5.3 Android

- [ ] Add `productFlavors` entry in `android/app/build.gradle.kts`:

```kotlin
create("{orgId}") {
    dimension = "client"
    applicationId = "com.speakupconnect.speakup_connect.{orgId}"
    resValue("string", "app_name", "Speakup {shortName}")
}
```

- [ ] Set `AndroidManifest.xml` → `android:label="@string/app_name"`
- [ ] Register new Android app in Firebase Console (same project, new package name)
- [ ] Place `google-services.json` at `android/app/src/{orgId}/google-services.json`
- [ ] Generate launcher icons: `dart run flutter_launcher_icons -f flutter_launcher_icons-{orgId}.yaml`

### 5.4 iOS (when targeting App Store)

- [ ] Add Xcode scheme + build configuration `{orgId}`
- [ ] Set `CFBundleDisplayName` → `Speakup {shortName}`
- [ ] Register iOS app in Firebase; add `GoogleService-Info-{orgId}.plist`
- [ ] Create App Store Connect record + provisioning profile

### 5.5 Store listings & CI

- [ ] Create Google Play Console app (separate listing)
- [ ] Create App Store Connect app (separate listing)
- [ ] Create Git branch `client/{orgId}` for flavor-specific assets only
- [ ] Add GitHub Actions workflow + secrets (see [CLIENT_BUILDS.md §9](CLIENT_BUILDS.md#9-cicd-github-actions))
- [ ] Build & smoke-test:

```powershell
flutter run --flavor {orgId} -t lib/main_{orgId}.dart -d <device-id>
flutter build appbundle --flavor {orgId} -t lib/main_{orgId}.dart --release
```

### 5.5b Help Center content (in-app)

School Help Center uses canonical school assets by organization type with `_default` fallback.

- [ ] Start from canonical source: `shared/docs/help/school/`
- [ ] Keep in-app content under `assets/help/school/` (guides + tutorials)
- [ ] Do not create `shared/docs/help/orgs/{orgId}/` or `assets/help/orgs/{orgId}/` help overrides
- [ ] Keep copy user-facing (for example, "Administrator Guide"), not filename-style wording
- [ ] Remove or tailor school-only sections (student ID login, roster, grades) for non-school org types
- [ ] Smoke-test **Settings → Help Center** on a device signed into `{orgId}`

See [shared/docs/help/README.md](../help/README.md) for layout and fallback behavior.

### 5.6 Verification before handoff

- [ ] Home-screen icon label reads **`Speakup {shortName}`** (not `Speakup Connect`)
- [ ] Home-screen **icon colors** match GIMP export (reinstall required to verify)
- [ ] App opens directly into `{orgId}` org (no org picker)
- [ ] **Admin Branding Settings** primary/secondary match the brand guide on first launch
- [ ] Splash / in-app theme colors match client contract
- [ ] Push notifications, auth, and reminders work under the new Firebase app registration
- [ ] Old MONHS / other client builds can be installed side-by-side (different `applicationId`)

---

## 6. What Schools Can Change Without a New Build

These are configured in **Firestore** (`organizations/{orgId}`) or the **admin panel** — no app rebuild:

| Setting | Where |
|---|---|
| Primary / secondary colors | Admin → Branding Settings (`/admin/settings`) |
| Logo URL | Org branding settings |
| Tagline, welcome message | Org branding settings |
| In-app org display name | `displayName` on org document (splash: "SpeakUp {displayName}") |
| Report categories, roles, permissions | Admin screens |
| Reminder approval toggle | Admin branding settings |
| In-app Help Center text | Canonical `shared/docs/help/school/` + `assets/help/school/` (fallback: `assets/help/_default/`) |

These **require a new client build** (or reinstall):

| Setting | Why |
|---|---|
| Launcher icon colors on home screen | OS caches at install; edited manually in GIMP |
| Name under the icon (`Speakup MONHS` vs `Speakup Connect`) | Android `android:label` / iOS `CFBundleDisplayName` |
| Default pre-loaded org | `FlavorConfig.orgId` compile-time |
| Separate Play Store / App Store listing | Different `applicationId` / bundle ID |

---

## 7. Reference — MONHS (First Client Build)

| Parameter | Value |
|---|---|
| Flavor / enum | `AppFlavor.monhs` |
| Firestore org ID | `monhs-ph-001` |
| Launcher name | `Speakup MONHS` |
| Entry point | `lib/main.dart` (pilot; may move to `lib/main_monhs.dart` on `client/monhs` branch) |
| Standard entry point | `lib/main_standard.dart` |
| Android label (pilot) | `android/app/src/main/AndroidManifest.xml` |
| iOS display name | `ios/Runner/Info.plist` → `Speakup MONHS` |
| Target `applicationId` (when flavors added) | `com.speakupconnect.speakup_connect.monhs` |
| Icon colors (GIMP) | Red `#CC0000` + near-black `#1A1A1A` on standard logo |
| In-app default colors | Same hex codes — set in Admin → Branding Settings before publish |

---

## 8. Related Documents

| Document | Contents |
|---|---|
| [SCHOOL_ONBOARDING_AND_SUBSCRIPTIONS.md](SCHOOL_ONBOARDING_AND_SUBSCRIPTIONS.md) | Self-serve wizard, pay-at-end activation, VIP vs standard |
| [CLIENT_BUILDS.md](CLIENT_BUILDS.md) | Full Gradle/iOS flavor setup, CI/CD, git branching |
| [SPEAKUP CONNECT BRANDING.md](SPEAKUP%20CONNECT%20BRANDING.md) | Brand rules, icon restrictions, color palettes |
| [DATABASE_DESIGN.md](DATABASE_DESIGN.md) | `organizations/{orgId}` schema |
| [RBAC_ARCHITECTURE.md](RBAC_ARCHITECTURE.md) | Seeding roles for a new org |
