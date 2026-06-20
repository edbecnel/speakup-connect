# SpeakUp Connect

> A multi-tenant community reporting and communication platform built with Flutter and Firebase.

---

## Overview

SpeakUp Connect empowers communities — schools, municipalities, NGOs, churches, and other organizations — to give their members a safe, structured voice. Users can submit concerns, complaints, suggestions, safety reports, and incident reports directly to authorized administrators.

The platform is designed as a **multi-tenant SaaS solution**, meaning a single codebase serves many organizations with complete data isolation, per-organization branding, and configurable settings.

---

## Project Status

> **Current Phase:** Sprint 1 — Foundation & Architecture  
> **Stage:** Documentation & Project Setup  
> See [shared/docs/SPRINT_TRACKER.md](shared/docs/SPRINT_TRACKER.md) for live sprint status.

---

## Technology Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Dart) |
| UI Framework | Material Design 3 |
| State Management | Riverpod 2.x |
| Navigation | go_router |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| File Storage | Firebase Storage |
| Push Notifications | Firebase Cloud Messaging (FCM) |
| Architecture | Clean Architecture + Feature-Based Modular |

---

## Target Platforms

- ✅ Android (primary)
- 🔲 iOS (planned)
- 🔲 Web (future)

---

## Project Documentation

| Document | Description |
|---|---|
| [shared/docs/PROJECT_OVERVIEW.md](shared/docs/PROJECT_OVERVIEW.md) | Full platform description & vision |
| [shared/docs/ARCHITECTURE.md](shared/docs/ARCHITECTURE.md) | System architecture & design decisions |
| [shared/docs/FOLDER_STRUCTURE.md](shared/docs/FOLDER_STRUCTURE.md) | Folder organization & conventions |
| [shared/docs/DATABASE_DESIGN.md](shared/docs/DATABASE_DESIGN.md) | Firestore schema & data models |
| [shared/docs/SECURITY_AND_PRIVACY.md](shared/docs/SECURITY_AND_PRIVACY.md) | Privacy, security, and moderation |
| [shared/docs/ROADMAP.md](shared/docs/ROADMAP.md) | MVP, pilot, and long-term goals |
| [shared/docs/SPRINT_TRACKER.md](shared/docs/SPRINT_TRACKER.md) | Active sprint tracking |
| [shared/docs/MASTER_TASK_LIST.md](shared/docs/MASTER_TASK_LIST.md) | Full project task breakdown |
| [shared/docs/CODING_STANDARDS.md](shared/docs/CODING_STANDARDS.md) | Coding conventions & standards |
| [shared/docs/AI_DEVELOPMENT_WORKFLOW.md](shared/docs/AI_DEVELOPMENT_WORKFLOW.md) | AI-assisted development process |
| [shared/docs/ONBOARDING_NEW_SCHOOL.md](shared/docs/ONBOARDING_NEW_SCHOOL.md) | **Onboarding a new school** — client app name, flavors, checklist |
| [shared/docs/CLIENT_BUILDS.md](shared/docs/CLIENT_BUILDS.md) | Gradle/iOS flavors, CI/CD, git branching for client builds |
| [shared/docs/help/README.md](shared/docs/help/README.md) | In-app help architecture and fallback model |
| [shared/docs/help/school/](shared/docs/help/school/) | Canonical school help source (guides + tutorials) |
| [shared/docs/help/_default/](shared/docs/help/_default/) | Generic fallback guides for new tenants |

---

## Development Setup

### Prerequisites

- Flutter SDK `>=3.19.0`
- Dart SDK `>=3.3.0`
- Android Studio or VS Code with Flutter extension
- Firebase CLI (`npm install -g firebase-tools`)
- Git

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-org/speakup-connect.git
cd speakup-connect
cd speakup_connect_app

# 2. Install Flutter dependencies
flutter pub get

# 3. Configure Firebase  ← SEE "Firebase Setup" SECTION BELOW — required before running

# 4. Run the application
flutter run
```

### Environment Configuration

Copy the environment template and fill in your values:

```bash
cp .env.example .env
```

See [shared/docs/ARCHITECTURE.md](shared/docs/ARCHITECTURE.md) for full environment configuration details.

---

## 🔴 Firebase Setup — REQUIRED BEFORE RUNNING

> **This step is mandatory. The app will crash on launch without these files.**
>
> `google-services.json` and `firebase_options.dart` are **intentionally excluded
> from git** because this is a public repository. They contain API keys and
> project identifiers that must not be committed to version control.

### Files you need (not in the repo)

| File | Where it goes | What it does |
|---|---|---|
| `google-services.json` | `speakup_connect_app/android/app/google-services.json` | Connects the Android app to Firebase |
| `firebase_options.dart` | `speakup_connect_app/lib/config/firebase_options.dart` | Dart-side Firebase initialization config |

### How to generate them

**Option A — FlutterFire CLI (recommended)**

```bash
# Install the FlutterFire CLI (once)
dart pub global activate flutterfire_cli

# Log in to Firebase
firebase login

# Generate both files for the existing Firebase project
flutterfire configure --project=speakup-connect-891dd
```

This writes both files to the correct locations automatically.

**Option B — Manual download**

1. Go to [Firebase Console](https://console.firebase.google.com) → project **speakup-connect-891dd**
2. **Project Settings → Your Apps → Android app** → Download `google-services.json`
3. Place it at `speakup_connect_app/android/app/google-services.json`
4. For `firebase_options.dart`, Option A is still required (it cannot be downloaded manually)

### CI/CD (GitHub Actions)

Store the file contents as repository secrets and write them before building:

```yaml
- name: Write Firebase config
  run: |
    echo "${{ secrets.GOOGLE_SERVICES_JSON }}" > speakup_connect_app/android/app/google-services.json
    echo "${{ secrets.FIREBASE_OPTIONS_DART }}" > speakup_connect_app/lib/config/firebase_options.dart
```

Required secrets to add in **GitHub → Settings → Secrets and variables → Actions**:
- `GOOGLE_SERVICES_JSON` — full content of `speakup_connect_app/android/app/google-services.json`
- `FIREBASE_OPTIONS_DART` — full content of `speakup_connect_app/lib/config/firebase_options.dart`

### Verify your setup

Before running, confirm both files exist:

```powershell
Test-Path speakup_connect_app\android\app\google-services.json   # must return True
Test-Path speakup_connect_app\lib\config\firebase_options.dart    # must return True
```

---

## Architecture Overview

SpeakUp Connect uses **Clean Architecture** with a **feature-based folder structure**:

```
lib/
├── core/           # App-wide utilities, theme, routing, errors
├── config/         # App config, environment, Firebase options
├── features/       # Feature modules (auth, reports, admin, settings)
│   └── [feature]/
│       ├── data/       # Repositories, models, datasources
│       ├── domain/     # Entities, repository interfaces, use cases
│       └── presentation/ # Screens, providers, widgets
└── shared/         # Shared widgets, models, and utilities
```

See [shared/docs/FOLDER_STRUCTURE.md](shared/docs/FOLDER_STRUCTURE.md) and [shared/docs/ARCHITECTURE.md](shared/docs/ARCHITECTURE.md) for the full breakdown.

---

## Multi-Tenant Design

Every piece of data is scoped to an `organizationId`. There are no hard-coded organization names anywhere in the codebase. Organizations are configured via Firestore and loaded at runtime.

See [shared/docs/DATABASE_DESIGN.md](shared/docs/DATABASE_DESIGN.md) for the isolation strategy.

---

## Contributing

This project uses an agile sprint-based workflow. Before contributing:

1. Read [shared/docs/CODING_STANDARDS.md](shared/docs/CODING_STANDARDS.md)
2. Read [shared/docs/AI_DEVELOPMENT_WORKFLOW.md](shared/docs/AI_DEVELOPMENT_WORKFLOW.md)
3. Check [shared/docs/SPRINT_TRACKER.md](shared/docs/SPRINT_TRACKER.md) for current priorities
4. Follow the clean architecture guidelines strictly

---

## License

MIT License — See `LICENSE` for details.

---

## Initial Deployment

The first pilot deployment targets a high school in the Philippines. The architecture is designed from the ground up to support multiple organizations and eventual SaaS scaling.
