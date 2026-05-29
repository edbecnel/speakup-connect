# Client-Specific Builds — Developer Playbook

> **Scope:** This document covers the end-to-end process for creating, maintaining,
> and deploying a VIP client-specific build of Speakup Connect — a separate app
> store listing with a custom app name, custom icon color theme, and pre-configured
> org settings, while sharing 100% of the core codebase.
>
> **Worked example throughout:** MONHS (red/black, "Speakup Connect MONHS").

---

## 1. What Is a Client Build?

A client build is a Flutter **build flavor** that produces a distinct binary from
the same source tree. It differs from the standard app in:

| Property | Standard App | Client Build (MONHS) |
|---|---|---|
| App store name | Speakup Connect | Speakup Connect MONHS |
| Android `applicationId` | `com.speakupconnect.speakup_connect` | `com.speakupconnect.speakup_connect.monhs` |
| iOS Bundle ID | `com.speakupconnect.speakupConnect` | `com.speakupconnect.speakupConnect.monhs` |
| Launcher icon | Blue/green | Red/black |
| Default org pre-loaded | None (login picks org) | `monhs-ph-001` hardcoded |
| Firebase App registration | Standard Android/iOS app | Separate registered app (same project) |
| App Store / Play Store listing | Main listing | Separate listing |
| Git branch | `main` | `client/monhs` |

Everything else — Firestore data, Auth, all features, all screens — is identical.

---

## 2. Eligibility

Client builds are reserved for:

- **Pilot clients** (e.g., MONHS during the initial launch)
- **VIP / Enterprise paying clients** who have explicitly contracted for a
  branded build

Standard-plan organizations get runtime theme customization inside the standard
app (colors, logo, in-app name) but do **not** get a separate app store listing
or a custom app icon.

---

## 3. Git Branching Strategy

### Branch name convention

```
client/{org-id}
```

Examples:
- `client/monhs`
- `client/xavier-academy`
- `client/lgu-oroquieta`

### Rules

- `client/*` branches are **long-lived**. They are never merged back into `main`.
- They are **rebased onto `main`** whenever `main` advances (use
  `git rebase main` from the client branch, resolve conflicts, force-push).
- Only flavor-specific files are committed on the client branch on top of `main`.
  Core feature changes always go to `main` first.
- CI/CD deploys the client build from the client branch only.

### File diff between `main` and `client/monhs`

Files that exist only on `client/monhs` (never on `main`):

```
lib/main_monhs.dart
lib/flavor_config.dart                  ← shared stub added to main when first client added
assets/icons/flavors/monhs/icon.png     ← 1024×1024 source icon (red/black)
android/app/src/monhs/
    res/values/strings.xml              ← app_name override
    res/mipmap-*/ic_launcher*.png       ← generated icons (via flutter_launcher_icons)
    google-services.json                ← flavor-specific Firebase registration (git-ignored)
ios/Runner/GoogleService-Info-monhs.plist  ← flavor-specific (git-ignored)
flutter_launcher_icons-monhs.yaml
```

Files modified on `client/monhs` relative to `main`:

```
android/app/build.gradle.kts           ← productFlavors block added
ios/Runner.xcodeproj/project.pbxproj   ← new scheme + build configs
ios/Runner/Info.plist                  ← CFBundleDisplayName uses $(APP_DISPLAY_NAME)
pubspec.yaml                           ← flutter_launcher_icons dev dependency
```

---

## 4. FlavorConfig — Shared Dart Layer

Add this file to `main` when the first client build is set up. All entry points
reference it at startup.

### `lib/flavor_config.dart`

```dart
/// Compile-time flavor identity injected at app startup.
///
/// Each client entry point (main_monhs.dart, etc.) sets [FlavorConfig.instance]
/// before calling [mainCommon]. The rest of the app reads from this singleton.
enum AppFlavor { standard, monhs }

class FlavorConfig {
  FlavorConfig._({
    required this.flavor,
    required this.orgId,
    required this.appDisplayName,
  });

  static FlavorConfig _instance = FlavorConfig._(
    flavor: AppFlavor.standard,
    orgId: null,
    appDisplayName: 'Speakup Connect',
  );

  static FlavorConfig get instance => _instance;
  static set instance(FlavorConfig config) => _instance = config;

  /// Which flavor this binary is.
  final AppFlavor flavor;

  /// If non-null, skip org selection and pre-load this org on first launch.
  final String? orgId;

  /// Displayed on the splash screen and used as the window title.
  final String appDisplayName;

  bool get isStandard => flavor == AppFlavor.standard;
}
```

### `lib/main.dart` (standard — already exists, update slightly)

```dart
void main() async {
  // FlavorConfig.instance stays at its default (AppFlavor.standard).
  await mainCommon();
}
```

### `lib/main_monhs.dart` (new file on client/monhs branch)

```dart
import 'package:speakup_connect/flavor_config.dart';
import 'package:speakup_connect/main_common.dart';

void main() async {
  FlavorConfig.instance = FlavorConfig._(
    flavor: AppFlavor.monhs,
    orgId: 'monhs-ph-001',
    appDisplayName: 'Speakup Connect MONHS',
  );
  await mainCommon();
}
```

### `lib/main_common.dart` (extract shared init — refactor of main.dart)

```dart
Future<void> mainCommon() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ... existing Firebase init, etc.
  runApp(const ProviderScope(child: App()));
}
```

---

## 5. Android Flavor Setup

### 5.1 `android/app/build.gradle.kts` — add `productFlavors`

```kotlin
android {
    // ... existing config ...

    flavorDimensions += "client"

    productFlavors {
        create("standard") {
            dimension = "client"
            applicationId = "com.speakupconnect.speakup_connect"
            resValue("string", "app_name", "Speakup Connect")
        }
        create("monhs") {
            dimension = "client"
            applicationId = "com.speakupconnect.speakup_connect.monhs"
            resValue("string", "app_name", "Speakup Connect MONHS")
        }
    }
}
```

> Using `resValue` means you do NOT need a per-flavor `strings.xml`; the
> `app_name` string is injected at build time. The `AndroidManifest.xml`
> `android:label` must reference `@string/app_name`.

### 5.2 `android/app/src/main/AndroidManifest.xml` — ensure label uses string ref

```xml
<application
    android:label="@string/app_name"
    ...>
```

### 5.3 Firebase `google-services.json` per flavor

Register a **separate Android app** in the Firebase Console (same project
`speakup-connect-891dd`) for each client flavor:

- Package name: `com.speakupconnect.speakup_connect.monhs`
- Download its `google-services.json`
- Place it at:

```
android/app/src/monhs/google-services.json   ← git-ignored, generated per-developer
```

The standard `google-services.json` stays at `android/app/google-services.json`.
The Google Services Gradle plugin automatically picks the right file based on the
active flavor.

### 5.4 Build commands

```powershell
# Standard app
flutter build apk --flavor standard -t lib/main.dart
flutter build appbundle --flavor standard -t lib/main.dart

# MONHS client build
flutter build apk --flavor monhs -t lib/main_monhs.dart
flutter build appbundle --flavor monhs -t lib/main_monhs.dart

# Run MONHS flavor in debug
flutter run --flavor monhs -t lib/main_monhs.dart
```

---

## 6. iOS Flavor Setup

iOS uses **Schemes** and **Build Configurations** instead of flavors. Flutter
maps `--flavor monhs` to the scheme named `monhs`.

### 6.1 In Xcode — create the MONHS scheme

1. Open `ios/Runner.xcworkspace` in Xcode.
2. **Product → Scheme → Manage Schemes** → duplicate `Runner` → rename to `monhs`.
3. In **Project → Info → Configurations**, duplicate `Debug` and `Release` →
   name them `Debug-monhs` and `Release-monhs`.
4. Edit the `monhs` scheme: set the Build Configuration to `Debug-monhs` (debug)
   and `Release-monhs` (archive).
5. In **Build Settings** for each `-monhs` configuration set:
   - `FLUTTER_TARGET` → `lib/main_monhs.dart`
   - `PRODUCT_BUNDLE_IDENTIFIER` → `com.speakupconnect.speakupConnect.monhs`
   - `APP_DISPLAY_NAME` → `Speakup Connect MONHS`

### 6.2 `ios/Runner/Info.plist` — use the build setting variable

```xml
<key>CFBundleDisplayName</key>
<string>$(APP_DISPLAY_NAME)</string>
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
```

The standard Runner configuration keeps `APP_DISPLAY_NAME = Speakup Connect`.

### 6.3 Firebase `GoogleService-Info.plist` per flavor

Register a **separate iOS app** in the Firebase Console for:

- Bundle ID: `com.speakupconnect.speakupConnect.monhs`
- Download its `GoogleService-Info.plist` → save as
  `ios/Runner/GoogleService-Info-monhs.plist` (git-ignored)

In Xcode, add a **Run Script Build Phase** (before Compile Sources) that copies
the correct plist:

```bash
# Copy the correct GoogleService-Info.plist based on the active configuration
if [[ "${CONFIGURATION}" == *"monhs"* ]]; then
  cp "${PROJECT_DIR}/Runner/GoogleService-Info-monhs.plist" \
     "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
else
  cp "${PROJECT_DIR}/Runner/GoogleService-Info.plist" \
     "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
fi
```

### 6.4 Build command

```powershell
flutter build ipa --flavor monhs -t lib/main_monhs.dart
```

---

## 7. App Icon Generation

### 7.1 Source icon requirements

Each client flavor needs a **1024×1024 PNG** source icon that follows the
branding rules in [SPEAKUP CONNECT BRANDING.md](SPEAKUP%20CONNECT%20BRANDING.md):

- Same Speakup Connect logo graphic
- Only the color scheme differs
- No transparency (required by Play Store / App Store)
- File path: `assets/icons/flavors/{flavor}/icon.png`

Example: `assets/icons/flavors/monhs/icon.png` — red/black color scheme.

### 7.2 Per-flavor `flutter_launcher_icons` config

Create a separate YAML file for each flavor (these live in the repo root on the
client branch):

**`flutter_launcher_icons-monhs.yaml`**

```yaml
flutter_launcher_icons:
  android: "ic_launcher"
  ios: true
  image_path: "assets/icons/flavors/monhs/icon.png"
  flavor: monhs
  min_sdk_android: 21
  adaptive_icon_foreground: "assets/icons/flavors/monhs/icon_foreground.png"
  adaptive_icon_background: "#CC0000"   # MONHS red
```

> For adaptive icons (Android 8+), provide a foreground layer PNG (the logo on
> transparent background) and set the background color separately.

### 7.3 Generate icons

```powershell
# From repo root — generates icons for the monhs flavor only
dart run flutter_launcher_icons -f flutter_launcher_icons-monhs.yaml
```

This writes generated PNGs into:
```
android/app/src/monhs/res/mipmap-mdpi/ic_launcher.png
android/app/src/monhs/res/mipmap-hdpi/ic_launcher.png
android/app/src/monhs/res/mipmap-xhdpi/ic_launcher.png
android/app/src/monhs/res/mipmap-xxhdpi/ic_launcher.png
android/app/src/monhs/res/mipmap-xxxhdpi/ic_launcher.png
ios/Runner/Assets.xcassets/AppIcon-monhs.appiconset/
```

**Commit the generated PNGs** to the `client/monhs` branch. They are binary
assets, not secrets.

### 7.4 `pubspec.yaml` — add dev dependency (on `main`, used by all builds)

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.0
```

---

## 8. Play Store & App Store Separate Listings

### Google Play Store

- Create a new app in Google Play Console.
- App name: **"Speakup Connect MONHS"**
- Package name: `com.speakupconnect.speakup_connect.monhs`
- Upload the AAB built with `--flavor monhs`.
- This is a completely separate listing from the standard app.

### Apple App Store

- Create a new App Record in App Store Connect.
- Bundle ID: `com.speakupconnect.speakupConnect.monhs`
- App name: **"Speakup Connect MONHS"**
- Upload the IPA built with `--flavor monhs`.
- Requires a separate Apple Developer provisioning profile for the MONHS bundle ID.

---

## 9. CI/CD — GitHub Actions

Create `.github/workflows/build-client-monhs.yml` on the `client/monhs` branch:

```yaml
name: Build — Speakup Connect MONHS

on:
  push:
    branches: [client/monhs]
  workflow_dispatch:

jobs:
  android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.44.0'
          channel: 'stable'
      - name: Restore git-ignored secrets
        run: |
          echo "${{ secrets.MONHS_GOOGLE_SERVICES_JSON }}" \
            > android/app/src/monhs/google-services.json
          echo "${{ secrets.FIREBASE_OPTIONS_DART }}" \
            > lib/config/firebase_options.dart
      - run: flutter pub get
      - run: flutter build appbundle --flavor monhs -t lib/main_monhs.dart --release

  ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.44.0'
          channel: 'stable'
      - name: Restore git-ignored secrets
        run: |
          echo "${{ secrets.MONHS_GOOGLE_SERVICE_INFO_PLIST }}" \
            > ios/Runner/GoogleService-Info-monhs.plist
          echo "${{ secrets.FIREBASE_OPTIONS_DART }}" \
            > lib/config/firebase_options.dart
      - run: flutter pub get
      - run: flutter build ipa --flavor monhs -t lib/main_monhs.dart --release \
               --export-options-plist=ios/ExportOptions-monhs.plist
```

**GitHub Secrets required per client flavor:**

| Secret name | Contents |
|---|---|
| `MONHS_GOOGLE_SERVICES_JSON` | Contents of `android/app/src/monhs/google-services.json` |
| `MONHS_GOOGLE_SERVICE_INFO_PLIST` | Contents of `ios/Runner/GoogleService-Info-monhs.plist` |
| `FIREBASE_OPTIONS_DART` | Contents of `lib/config/firebase_options.dart` (shared) |

---

## 10. App Behavior Differences at Runtime

When `FlavorConfig.instance.orgId` is non-null (i.e., any client build), the
app skips org selection and pre-loads that org's config directly:

```dart
// In organization_provider.dart — update the build() method:
final orgId = FlavorConfig.instance.orgId ?? AppConfig.defaultOrganizationId;
return await repository.getOrganizationConfig(orgId);
```

The splash screen and home dashboard should display
`FlavorConfig.instance.appDisplayName` instead of the hardcoded string
`"Speakup Connect"` wherever the app name appears in the UI.

---

## 11. Checklist — Adding a New Client Build

Use this checklist when onboarding a new VIP client (e.g., Xavier Academy):

```
[ ] 1. Confirm client is eligible (pilot or VIP paying contract)
[ ] 2. Confirm branding with client: primary + secondary colors, org name suffix
[ ] 3. Create source icon 1024×1024 PNG (red/black, gold/navy, etc.)
[ ] 4. Create Git branch: client/{org-id}
[ ] 5. Add AppFlavor.{orgId} variant to lib/flavor_config.dart (commit to main first)
[ ] 6. Create lib/main_{orgId}.dart entry point
[ ] 7. Create flutter_launcher_icons-{orgId}.yaml
[ ] 8. Run dart run flutter_launcher_icons -f flutter_launcher_icons-{orgId}.yaml
[ ] 9. Add productFlavor block to android/app/build.gradle.kts
[ ] 10. Register new Android app in Firebase Console → download google-services.json
[ ] 11. Create iOS scheme + build configs in Xcode
[ ] 12. Register new iOS app in Firebase Console → download GoogleService-Info.plist
[ ] 13. Create Google Play Console app listing
[ ] 14. Create App Store Connect app record + provisioning profile
[ ] 15. Add GitHub Secrets for the new flavor
[ ] 16. Create .github/workflows/build-client-{orgId}.yml
[ ] 17. Test: flutter run --flavor {orgId} -t lib/main_{orgId}.dart
[ ] 18. Verify correct org pre-loaded, correct icon, correct app name
```

---

## 12. What NEVER Changes Between Flavors

- All Dart feature code (`lib/features/**`)
- All Firestore data — same database, same `organizations/` collection
- All Firebase project (`speakup-connect-891dd`) — only the registered app ID differs
- All branding rules from [SPEAKUP CONNECT BRANDING.md](SPEAKUP%20CONNECT%20BRANDING.md)
  — "Speakup Connect" prefix is mandatory, logo graphic cannot be replaced

---

## 13. Testing on a Physical Android Device via USB

Use this when you want to run the app directly on your phone during development.

### 13.1 Prepare the device (one-time)

1. **Enable Developer Options** — Go to **Settings → About phone**, tap **Build
   number** 7 times until you see "You are now a developer!".
2. **Enable USB Debugging** — **Settings → Developer Options → USB Debugging**,
   toggle on.
3. Connect the phone to your PC with a USB cable and accept the
   **"Allow USB debugging?"** prompt on the device.

### 13.2 Verify ADB detects the device

```powershell
adb devices
```

Expected output (device must show `device`, not `unauthorized`):

```
List of devices attached
R5CT41XXXXX    device
```

If it shows `unauthorized`, re-check the prompt on the phone screen and
tap **Allow**.

### 13.3 Run the app

```powershell
# Standard flavor
flutter run

# MONHS client flavor
flutter run --flavor monhs -t lib/main_monhs.dart
```

Flutter will automatically target the connected USB device. If multiple devices
are available (e.g., an emulator is also running), list them first:

```powershell
flutter devices
```

Then target your phone explicitly using its device ID:

```powershell
flutter run -d <device-id>
flutter run -d <device-id> --flavor monhs -t lib/main_monhs.dart
```

### 13.4 Hot reload & hot restart

While the app is running in the terminal:

| Key | Action |
|-----|--------|
| `r` | Hot reload (preserves state) |
| `R` | Hot restart (clears state) |
| `q` | Quit |

### 13.5 Troubleshooting

| Problem | Fix |
|---------|-----|
| `adb devices` shows nothing | Try a different USB cable (data cable, not charge-only); try a different USB port |
| Device shows `unauthorized` | Unlock the phone screen and accept the USB debugging prompt |
| `flutter run` picks the wrong device | Use `flutter devices` to get the ID then pass `-d <id>` |
| App installs but crashes immediately | Run `flutter logs` to see the device logcat in real time |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | Uninstall the existing app from the phone first, then re-run |

---

## 14. Reference — MONHS Flavor Parameters

| Parameter | Value |
|---|---|
| Flavor name | `monhs` |
| Git branch | `client/monhs` |
| Android applicationId | `com.speakupconnect.speakup_connect.monhs` |
| iOS Bundle ID | `com.speakupconnect.speakupConnect.monhs` |
| App store name | `Speakup Connect MONHS` |
| Entry point | `lib/main_monhs.dart` |
| Org ID (Firestore) | `monhs-ph-001` |
| Icon primary color | `#CC0000` (red) |
| Icon secondary color | `#1A1A1A` (near-black) |
| Icon source asset | `assets/icons/flavors/monhs/icon.png` |
| Firebase project | `speakup-connect-891dd` (shared) |
