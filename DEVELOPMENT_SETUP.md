# Development Setup — SpeakUp Connect

> **Audience:** Developers setting up a new machine (macOS, Windows, or Linux) to work on SpeakUp Connect.  
> **Goal:** Install tooling, connect the Flutter app to Firebase, and verify you can build and run locally.

---

## Quick checklist

> **In-file section links:** Checklist and troubleshooting items include a [Markdown anchor](#1-install-flutter--platform-sdks) (GitHub, VS Code, Cursor) and an Obsidian wikilink (`[[#…]]`) — use whichever works in your viewer. Links to other documents use standard Markdown only (works in both GitHub and Obsidian).

| Step | What | Required for Flutter app |
|------|------|--------------------------|
| 1 | [Install Flutter & platform SDKs](#1-install-flutter--platform-sdks) · [[#1. Install Flutter & platform SDKs]] | Yes |
| 2 | [Install Node.js & Firebase CLI](#2-install-nodejs--firebase-cli) · [[#2. Install Node.js & Firebase CLI]] | Yes (Firebase config) |
| 3 | [Clone the repository](#3-clone-the-repository) · [[#3. Clone the repository]] | Yes |
| 4 | [Flutter app dependencies](#4-flutter-app-dependencies) · [[#4. Flutter app dependencies]] | Yes |
| 5 | [Firebase setup](#5-firebase-setup--required-before-running) · [[#5. Firebase setup — REQUIRED BEFORE RUNNING]] | **Yes — app crashes without this** |
| 6 | [Run & verify](#6-run--verify) · [[#6. Run & verify]] | Yes |
| 7 | [Cloud Functions](#7-cloud-functions-optional) · [[#7. Cloud Functions (optional)]] | Only if working on backend |
| 8 | [Admin scripts](#8-admin-scripts-optional) · [[#8. Admin scripts (optional)]] | Only for seeding roles / super-admin |
| 9 | [Translation Helper web tool](#9-translation-helper-web-tool-optional) · [[#9. Translation Helper web tool (optional)]] | Only for localization workflow |

---

## Version requirements

| Tool | Version | Source |
|------|---------|--------|
| Flutter SDK | **3.44.0** (stable) recommended; `>=3.19.0` minimum | CI in [CLIENT_BUILDS](shared/docs/CLIENT_BUILDS.md) |
| Dart SDK | `>=3.3.0 <4.0.0` | `speakup_connect_app/pubspec.yaml` |
| Node.js | **20.x** | `shared/functions/package.json` |
| Firebase CLI | Latest via `npm` / `npx` | Project tooling |
| Git | Any recent version | — |

The repo does **not** pin Flutter via FVM. Match **3.44.0** when possible so local builds align with CI.

---

## 1. Install Flutter & platform SDKs

### 1.1 Flutter SDK

**macOS (recommended paths):**

```bash
# Option A — Homebrew
brew install --cask flutter

# Option B — Official installer / manual
# https://docs.flutter.dev/get-started/install/macos
```

Add Flutter to your `PATH` if needed (Homebrew usually handles this). Ensure `dart` is available too (bundled with Flutter).

Verify:

```bash
flutter --version    # target 3.44.x
flutter doctor -v
```

Fix anything `flutter doctor` flags before continuing (Android licenses, Xcode, etc.).

### 1.2 Android (primary target platform)

1. Install [Android Studio](https://developer.android.com/studio).
2. Open **SDK Manager** → install Android SDK, platform tools, and at least one system image.
3. Create an Android Virtual Device (AVD) or connect a physical device with USB debugging enabled.
4. Accept licenses:

```bash
flutter doctor --android-licenses
```

### 1.3 iOS (macOS only — planned target)

1. Install **Xcode** from the Mac App Store.
2. Open Xcode once and accept the license; install additional components if prompted.
3. Install CocoaPods:

```bash
sudo gem install cocoapods
```

4. Confirm iOS toolchain in `flutter doctor`.

> **Note:** iOS Firebase config for **client flavor builds** (e.g. MONHS) is documented in [CLIENT_BUILDS](shared/docs/CLIENT_BUILDS.md). Standard app setup uses FlutterFire CLI (see [§5](#5-firebase-setup--required-before-running) · [[#5. Firebase setup — REQUIRED BEFORE RUNNING]]).

### 1.4 IDE

Install one of:

- **VS Code** + [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter) and [Dart](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code) extensions
- **Android Studio** + Flutter plugin

---

## 2. Install Node.js & Firebase CLI

Required for Firebase configuration, Cloud Functions, and deployment scripts.

```bash
# Node.js 20 — macOS via Homebrew
brew install node@20

# Firebase CLI (global) — or use npx firebase-tools per-command
npm install -g firebase-tools
```

Confirm:

```bash
node --version   # v20.x
firebase --version
```

---

## 3. Clone the repository

```bash
git clone https://github.com/edbecnel/speakup-connect.git
cd speakup-connect
```

**Repository layout (top level):**

| Path | Purpose |
|------|---------|
| `speakup_connect_app/` | Flutter mobile app (main development target) |
| `shared/functions/` | Firebase Cloud Functions (TypeScript) |
| `shared/scripts/` | Admin/seed scripts (Node.js + service account) |
| `speakup_connect_web/` | Web tools (e.g. Translation Helper) |
| `firebase.json` | Firebase project config (functions, rules, indexes) |
| `.firebaserc` | Default Firebase project ID |

---

## 4. Flutter app dependencies

```bash
cd speakup_connect_app
flutter pub get
```

### Code generation

The app uses `build_runner` (Freezed, JSON, Riverpod) and `gen-l10n` (ARB localizations). Generated files may already be committed; regenerate when you change models or ARB files:

```bash
# Localization (when app_en.arb or other ARB files change)
flutter gen-l10n

# Freezed / JSON / Riverpod (when annotated models change)
dart run build_runner build --delete-conflicting-outputs
```

### Static analysis

Before committing, the project expects a clean analyzer run:

```bash
flutter analyze
```

---

## 5. Firebase setup — REQUIRED BEFORE RUNNING

> **This step is mandatory. The app will crash on launch without these files.**
>
> `google-services.json` and `firebase_options.dart` are **intentionally excluded from git** because they contain API keys and project identifiers.

**Firebase project:** `speakup-connect-891dd` (see `.firebaserc`)

### Files you need (not in the repo)

| File | Where it goes | What it does |
|------|---------------|--------------|
| `google-services.json` | `speakup_connect_app/android/app/google-services.json` | Connects the Android app to Firebase |
| `firebase_options.dart` | `speakup_connect_app/lib/config/firebase_options.dart` | Dart-side Firebase initialization config |

### Option A — FlutterFire CLI (recommended)

Run from the **Flutter app directory** (or repo root — CLI detects `speakup_connect_app` via `firebase.json`):

```bash
# Install FlutterFire CLI (once per machine)
dart pub global activate flutterfire_cli

# Ensure ~/.pub-cache/bin is on your PATH, then:
firebase login
cd speakup_connect_app
flutterfire configure --project=speakup-connect-891dd
```

This writes both files to the correct locations automatically.

### Option B — Manual `google-services.json` only

1. Go to [Firebase Console](https://console.firebase.google.com) → project **speakup-connect-891dd**
2. **Project Settings → Your apps → Android app** → Download `google-services.json`
3. Place it at `speakup_connect_app/android/app/google-services.json`
4. For `firebase_options.dart`, **Option A is still required** — it cannot be downloaded manually from the console.

### Verify Firebase config files exist

**macOS / Linux:**

```bash
test -f speakup_connect_app/android/app/google-services.json && echo "google-services.json OK"
test -f speakup_connect_app/lib/config/firebase_options.dart && echo "firebase_options.dart OK"
```

**Windows (PowerShell):**

```powershell
Test-Path speakup_connect_app\android\app\google-services.json   # must return True
Test-Path speakup_connect_app\lib\config\firebase_options.dart  # must return True
```

### CI/CD (GitHub Actions)

Store file contents as repository secrets and write them before building:

```yaml
- name: Write Firebase config
  run: |
    echo "${{ secrets.GOOGLE_SERVICES_JSON }}" > speakup_connect_app/android/app/google-services.json
    echo "${{ secrets.FIREBASE_OPTIONS_DART }}" > speakup_connect_app/lib/config/firebase_options.dart
```

Required secrets (**GitHub → Settings → Secrets and variables → Actions**):

| Secret | Contents |
|--------|----------|
| `GOOGLE_SERVICES_JSON` | Full content of `speakup_connect_app/android/app/google-services.json` |
| `FIREBASE_OPTIONS_DART` | Full content of `speakup_connect_app/lib/config/firebase_options.dart` |

Client flavor builds use additional secrets — see [CLIENT_BUILDS](shared/docs/CLIENT_BUILDS.md).

---

## 6. Run & verify

1. Start an Android emulator or connect a device.
2. From `speakup_connect_app/`:

```bash
flutter devices
flutter run
```

3. Confirm `flutter doctor` shows no blocking issues for your target platform.
4. Run `flutter analyze` — should be clean before you commit.

### Environment configuration

The app supports `development`, `staging`, and `production` environments via `lib/config/env_config.dart`. Firebase project configuration is loaded from `firebase_options.dart`. See [ARCHITECTURE](shared/docs/ARCHITECTURE.md) for environment details.

---

## 7. Cloud Functions (optional)

Only needed if you are developing or deploying backend functions.

```bash
cd shared/functions
npm install
npm run build
```

**Firebase login & project:**

```bash
firebase login
cd shared/functions
firebase use speakup-connect-891dd
```

**Local emulator:**

```bash
npm run serve   # builds TypeScript, starts functions emulator
```

**Deploy:**

```bash
npm run deploy
```

### Translation AI key (optional)

For AI-powered translation draft functions, copy `shared/functions/.env.example` → `shared/functions/.env` and set `TRANSLATION_AI_API_KEY`. **Do not commit** `.env`. Redeploy after adding the key. Details: [translation-helper README](speakup_connect_web/tools/translation-helper/README.md).

---

## 8. Admin scripts (optional)

Scripts under `shared/scripts/` (e.g. `seed_roles.js`, `assign_super_admin.js`) use the **Firebase Admin SDK** with a service account key — **not** your `firebase login` session.

1. Firebase Console → **Project settings** → **Service accounts** → **Generate new private key**
2. Save as `shared/scripts/service-account.json` (exact filename; **git-ignored**)
3. Run scripts with credentials set:

**macOS / Linux:**

```bash
export GOOGLE_APPLICATION_CREDENTIALS="shared/scripts/service-account.json"
node shared/scripts/seed_roles.js
```

**Windows (PowerShell):**

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS = "shared\scripts\service-account.json"
node shared\scripts\seed_roles.js
```

If the key is ever exposed, revoke it in Google Cloud Console and generate a new one.

---

## 9. Translation Helper web tool (optional)

Web workspace for managing UI translations. Full setup (Firebase Auth, `firebase-config.js`, deploy steps) is in:

**[translation-helper README](speakup_connect_web/tools/translation-helper/README.md)**

End-to-end localization workflow: [INTERNATIONALIZATION](shared/docs/INTERNATIONALIZATION.md)

---

## 10. Client-specific builds (optional)

VIP / pilot schools get separate app store listings via Flutter **build flavors** (e.g. MONHS). That workflow includes per-flavor Firebase apps, icons, and CI secrets:

**[ONBOARDING_NEW_SCHOOL](shared/docs/ONBOARDING_NEW_SCHOOL.md)**  
**[CLIENT_BUILDS](shared/docs/CLIENT_BUILDS.md)**

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| App crashes immediately on launch | Missing Firebase config | Complete [§5](#5-firebase-setup--required-before-running) · [[#5. Firebase setup — REQUIRED BEFORE RUNNING]] |
| `flutterfire: command not found` | Pub global bin not on PATH | Add `~/.pub-cache/bin` (macOS/Linux) or `%LOCALAPPDATA%\Pub\Cache\bin` (Windows) to PATH |
| `flutter doctor` Android errors | SDK / licenses | Install Android Studio SDK; run `flutter doctor --android-licenses` |
| `flutter pub get` fails | Wrong Flutter/Dart version | Upgrade to Flutter 3.44.x stable |
| `ENOENT ... service-account.json` | Admin script without key | Complete [§8](#8-admin-scripts-optional) · [[#8. Admin scripts (optional)]] |
| `TRANSLATION_AI_API_KEY is not set` | AI functions without `.env` | Add key to `shared/functions/.env` and redeploy |
| Analyzer errors after pull | Stale generated code | `dart run build_runner build --delete-conflicting-outputs` |

---

## Next steps for contributors

1. [CODING_STANDARDS](shared/docs/CODING_STANDARDS.md) — naming and structure rules
2. [AI_DEVELOPMENT_WORKFLOW](shared/docs/AI_DEVELOPMENT_WORKFLOW.md) — documentation-first workflow
3. [SPRINT_TRACKER](shared/docs/SPRINT_TRACKER.md) — current sprint priorities
4. [ARCHITECTURE](shared/docs/ARCHITECTURE.md) — system design
5. [DATABASE_DESIGN](shared/docs/DATABASE_DESIGN.md) — Firestore schema (read before writing data code)
