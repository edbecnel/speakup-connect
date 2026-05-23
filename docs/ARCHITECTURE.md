# System Architecture — SpeakUp Connect

---

## Architecture Philosophy

SpeakUp Connect follows **Clean Architecture** principles combined with a **feature-based modular structure**. The goals are:

1. **Separation of Concerns** — UI, business logic, and data access are fully decoupled
2. **Testability** — Every layer can be tested independently with mocked dependencies
3. **Scalability** — Features can be added or modified without touching unrelated code
4. **Multi-Tenancy** — All data and logic is organization-scoped from the start
5. **AI-Friendly** — Consistent structure makes AI-assisted development predictable

---

## High-Level System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Flutter App                             │
│                                                                 │
│  ┌──────────┐  ┌──────────────┐  ┌────────────────────────┐     │
│  │  Auth    │  │   Reports    │  │        Admin           │     │
│  │ Feature  │  │   Feature    │  │       Feature          │     │
│  └──────────┘  └──────────────┘  └────────────────────────┘     │
│       │               │                      │                  │
│  ┌────▼───────────────▼──────────────────────▼───────────────┐  │
│  │                   Core Layer                              │  │
│  │   Theme · Router · Constants · Errors · Validators        │  │
│  └────────────────────────────────────────────────────────── ┘  │
│       │               │                      │                  │
│  ┌────▼───────────────▼──────────────────────▼───────────────┐  │
│  │                 Firebase Services                         │  │
│  │   Auth · Firestore · Storage · Cloud Messaging            │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────▼─────────────────┐
              │         Google Firebase         │
              │                                 │
              │  ┌───────────┐  ┌─────────────┐ │
              │  │  Auth     │  │  Firestore  │ │
              │  └───────────┘  └─────────────┘ │
              │  ┌───────────┐  ┌─────────────┐ │
              │  │  Storage  │  │     FCM     │ │
              │  └───────────┘  └─────────────┘ │
              └─────────────────────────────────┘
```

---

## Clean Architecture Layers

Each feature module follows a three-layer clean architecture pattern:

### 1. Domain Layer (innermost — no dependencies)

- **Entities** — Pure Dart classes representing core business objects
- **Repository Interfaces** — Abstract contracts defining what data operations are available
- **Use Cases** — Single-responsibility classes encapsulating business logic

```
domain/
├── entities/       # Pure business objects
├── repositories/   # Abstract interfaces (no implementation)
└── usecases/       # Business logic operations
```

### 2. Data Layer (implements domain contracts)

- **Models** — Data transfer objects that extend entities (with JSON serialization)
- **Datasources** — Raw API/Firebase calls (remote datasources)
- **Repository Implementations** — Concrete implementations of domain repository interfaces

```
data/
├── models/         # JSON-serializable DTOs
├── datasources/    # Firebase/API interaction
└── repositories/   # Concrete repository implementations
```

### 3. Presentation Layer (outermost)

- **Screens** — Full-page widgets rendered by go_router
- **Providers** — Riverpod providers managing state
- **Widgets** — Reusable UI components scoped to the feature

```
presentation/
├── screens/        # Full-page UI
├── providers/      # Riverpod state management
└── widgets/        # Feature-scoped UI components
```

---

## Feature Module Structure

Every feature follows this exact structure:

```
lib/features/[feature_name]/
├── data/
│   ├── datasources/
│   │   └── [feature]_remote_datasource.dart
│   ├── models/
│   │   └── [entity]_model.dart
│   └── repositories/
│       └── [feature]_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── [entity]_entity.dart
│   ├── repositories/
│   │   └── [feature]_repository.dart
│   └── usecases/
│       └── [action]_usecase.dart
└── presentation/
    ├── providers/
    │   └── [feature]_provider.dart
    ├── screens/
    │   └── [screen]_screen.dart
    └── widgets/
        └── [widget]_widget.dart
```

---

## State Management: Riverpod 2.x

Riverpod is used exclusively for state management. Provider conventions:

| Provider Type | Use Case |
|---|---|
| `Provider` | Synchronous, constant values (services, repositories) |
| `StateProvider` | Simple mutable state (filters, toggles) |
| `FutureProvider` | Async one-time reads |
| `StreamProvider` | Real-time Firestore streams |
| `AsyncNotifierProvider` | Complex async state with mutations |
| `NotifierProvider` | Complex synchronous state with mutations |

All providers are defined in `presentation/providers/` within their feature.

Dependency injection flows via Riverpod's provider graph — no service locators.

---

## Navigation: go_router

All routes are defined centrally in `lib/core/router/app_router.dart`.

Route guard logic handles:
- Redirect unauthenticated users to `/login`
- Redirect authenticated users away from `/login` and `/register`
- Redirect non-admin users away from `/admin/*` routes
- Handle organization context in routes

Named routes are used exclusively (no string path concatenation in UI code).

---

## Firebase Integration Architecture

### Authentication

Firebase Authentication manages user identity. The app supports:
- Email/password (primary)
- Anonymous sign-in (for anonymous reporting)
- Google sign-in (future Sprint)

Auth state is observed via `StreamProvider<User?>` and drives route guards.

### Firestore Data Architecture

All Firestore documents are namespaced under an organization:

```
organizations/{organizationId}/
├── config/               # Organization settings & branding
├── reports/{reportId}    # All reports for this organization
├── categories/           # Report categories (configurable)
├── users/{userId}        # Organization-scoped user profiles
└── admins/{adminId}      # Admin user records
```

See [docs/DATABASE_DESIGN.md](docs/DATABASE_DESIGN.md) for full schema.

### Firebase Storage

Files (report attachments) are stored with paths scoped to organization:

```
organizations/{organizationId}/reports/{reportId}/{filename}
```

Storage Security Rules enforce organization isolation.

### Firebase Cloud Messaging

Push notifications are delivered via FCM tokens stored per user.
Admin notification topics follow the pattern: `org_{organizationId}_admins`.

---

## Multi-Tenant Architecture

### Tenant Isolation Strategy

1. **Firestore Path Isolation** — All documents live under `organizations/{organizationId}/`
2. **Security Rules Enforcement** — Firestore rules validate `organizationId` on every read/write
3. **App-Level Enforcement** — All repository calls include `organizationId` automatically
4. **No Cross-Org Queries** — No queries span multiple organizations

### Organization Configuration

Each organization has a `config` document in Firestore that controls:
- Display name and branding (colors, logo URL)
- Enabled report categories
- Privacy settings (whether anonymous reporting is enabled)
- Admin contact information
- Custom welcome message

The app loads this config at startup after auth and caches it for the session.

### OrganizationConfig Model

```dart
class OrganizationConfig {
  final String organizationId;
  final String displayName;
  final String? logoUrl;
  final Color primaryColor;
  final Color secondaryColor;
  final List<ReportCategory> enabledCategories;
  final bool allowAnonymousReports;
  final bool requirePhotoVerification;
}
```

---

## Security Architecture

### Authentication Flow

```
App Launch
    │
    ▼
Check Firebase Auth State
    │
    ├─ Not Authenticated → Splash → Login Screen
    │
    └─ Authenticated ────────────────────────────────┐
                                                     │
                                              Load User Profile
                                                     │
                                              Load Org Config
                                                     │
                                              ┌──────▼──────────┐
                                              │  Is Admin?      │
                                              │  Yes → Admin    │
                                              │  No  → Home     │
                                              └─────────────────┘
```

### Role-Based Access Control

| Role | Capabilities |
|---|---|
| `anonymous` | Submit reports only |
| `user` | Submit reports, view own reports, receive notifications |
| `admin` | View all reports, update status, assign, add notes |
| `super_admin` | Manage organization settings, manage admins |

Roles are stored in Firestore under `organizations/{orgId}/users/{userId}` and validated server-side via Security Rules.

### Firestore Security Rules Strategy

- No public read/write access
- Users can only read/write within their organization
- Users can only update their own report submissions
- Admins can read/write all reports in their organization
- Organization configs are readable by authenticated org members only
- Super-admin operations require custom claims

---

## Scalability Considerations

### Firestore Indexing

Composite indexes must be created for common query patterns:
- Reports filtered by `status` + `createdAt`
- Reports filtered by `category` + `status`
- Reports filtered by `submittedBy` + `createdAt`

### Pagination

All list views use Firestore cursor-based pagination (`startAfterDocument`) to prevent unbounded reads.

### Caching

Firestore offline persistence is enabled by default, providing:
- Offline report viewing
- Queued writes that sync when connectivity returns

### Performance

- Images are compressed before upload using `flutter_image_compress`
- Firebase Storage download URLs are cached locally
- Firestore listeners are disposed when screens unmount

---

## Environment Configuration

The app supports multiple environments via `lib/config/env_config.dart`:

| Environment | Purpose |
|---|---|
| `development` | Local development, Firebase emulators |
| `staging` | QA and testing |
| `production` | Live deployment |

Firebase project configuration is loaded from `firebase_options.dart` (generated by FlutterFire CLI).
