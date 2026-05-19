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
> See [docs/SPRINT_TRACKER.md](docs/SPRINT_TRACKER.md) for live sprint status.

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
| [docs/PROJECT_OVERVIEW.md](docs/PROJECT_OVERVIEW.md) | Full platform description & vision |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | System architecture & design decisions |
| [docs/FOLDER_STRUCTURE.md](docs/FOLDER_STRUCTURE.md) | Folder organization & conventions |
| [docs/DATABASE_DESIGN.md](docs/DATABASE_DESIGN.md) | Firestore schema & data models |
| [docs/SECURITY_AND_PRIVACY.md](docs/SECURITY_AND_PRIVACY.md) | Privacy, security, and moderation |
| [docs/ROADMAP.md](docs/ROADMAP.md) | MVP, pilot, and long-term goals |
| [docs/SPRINT_TRACKER.md](docs/SPRINT_TRACKER.md) | Active sprint tracking |
| [docs/MASTER_TASK_LIST.md](docs/MASTER_TASK_LIST.md) | Full project task breakdown |
| [docs/CODING_STANDARDS.md](docs/CODING_STANDARDS.md) | Coding conventions & standards |
| [docs/AI_DEVELOPMENT_WORKFLOW.md](docs/AI_DEVELOPMENT_WORKFLOW.md) | AI-assisted development process |

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

# 2. Install Flutter dependencies
flutter pub get

# 3. Configure Firebase
# Create a Firebase project at https://console.firebase.google.com
# Enable Authentication, Firestore, Storage, and Cloud Messaging
# Run FlutterFire CLI to generate firebase_options.dart:
dart pub global activate flutterfire_cli
flutterfire configure

# 4. Run the application
flutter run
```

### Environment Configuration

Copy the environment template and fill in your values:

```bash
cp .env.example .env
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for full environment configuration details.

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

See [docs/FOLDER_STRUCTURE.md](docs/FOLDER_STRUCTURE.md) and [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the full breakdown.

---

## Multi-Tenant Design

Every piece of data is scoped to an `organizationId`. There are no hard-coded organization names anywhere in the codebase. Organizations are configured via Firestore and loaded at runtime.

See [docs/DATABASE_DESIGN.md](docs/DATABASE_DESIGN.md) for the isolation strategy.

---

## Contributing

This project uses an agile sprint-based workflow. Before contributing:

1. Read [docs/CODING_STANDARDS.md](docs/CODING_STANDARDS.md)
2. Read [docs/AI_DEVELOPMENT_WORKFLOW.md](docs/AI_DEVELOPMENT_WORKFLOW.md)
3. Check [docs/SPRINT_TRACKER.md](docs/SPRINT_TRACKER.md) for current priorities
4. Follow the clean architecture guidelines strictly

---

## License

MIT License — See `LICENSE` for details.

---

## Initial Deployment

The first pilot deployment targets a high school in the Philippines. The architecture is designed from the ground up to support multiple organizations and eventual SaaS scaling.
