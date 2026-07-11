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
| **[DEVELOPMENT_SETUP.md](DEVELOPMENT_SETUP.md)** | **New machine setup** — Flutter, Firebase, tooling, and verification |
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

**→ See [DEVELOPMENT_SETUP.md](DEVELOPMENT_SETUP.md) for the full new-machine guide** (Flutter SDK install, Android/iOS tooling, Firebase config, Cloud Functions, and verification).

Quick start (after Flutter and Firebase CLI are installed):

```bash
git clone https://github.com/edbecnel/speakup-connect.git
cd speakup-connect/speakup_connect_app
flutter pub get
# Configure Firebase — required; see DEVELOPMENT_SETUP.md §5
flutter run
```

> **Firebase is mandatory before first run.** The app will crash without `google-services.json` and `firebase_options.dart` (git-ignored). Use FlutterFire CLI: `flutterfire configure --project=speakup-connect-891dd`.

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
