# Coding Standards — SpeakUp Connect

---

## Guiding Principles

1. **Consistency** — Every file in the project should feel like it was written by one person
2. **Readability** — Code is read far more than it is written
3. **Simplicity** — Prefer simple, clear solutions over clever ones
4. **Testability** — Every class should be independently testable
5. **No Magic** — Avoid implicit behavior; make dependencies explicit

---

## Naming Conventions

### Files

Use `snake_case` for all Dart files:

```
✅ report_card.dart
✅ auth_repository_impl.dart
✅ submit_report_usecase.dart
❌ ReportCard.dart
❌ reportCard.dart
```

### Classes

Use `PascalCase`:

```dart
✅ class ReportCard extends StatelessWidget {}
✅ class AuthRepositoryImpl implements AuthRepository {}
❌ class report_card {}
❌ class reportCard {}
```

### Class Naming by Type

| Type | Suffix | Example |
|---|---|---|
| Entity | `Entity` | `ReportEntity` |
| Model (DTO) | `Model` | `ReportModel` |
| Repository interface | `Repository` | `ReportRepository` |
| Repository impl | `RepositoryImpl` | `ReportRepositoryImpl` |
| Datasource | `RemoteDataSource` | `ReportRemoteDataSource` |
| Use case | `UseCase` | `SubmitReportUseCase` |
| Screen | `Screen` | `LoginScreen` |
| Provider/Notifier | `Notifier` or `Provider` suffix in variable | `authStateProvider` |
| Widget | Descriptive, no suffix | `ReportCard`, `StepProgressIndicator` |

### Variables and Functions

Use `camelCase`:

```dart
✅ final String reportId;
✅ void submitReport() {}
✅ bool isAnonymous = false;
❌ final String ReportId;
❌ void Submit_Report() {}
```

### Constants

Use `camelCase` with `const`:

```dart
✅ const int maxPhotosPerReport = 3;
✅ const String defaultCategory = 'other';
❌ const int MAX_PHOTOS_PER_REPORT = 3;
❌ const int MaxPhotosPerReport = 3;
```

### Riverpod Providers

Use `camelCase` with a descriptive name ending in `Provider`:

```dart
✅ final authStateProvider = StreamProvider<User?>(...);
✅ final reportCategoriesProvider = FutureProvider<List<ReportCategoryEntity>>(...);
✅ final submitReportNotifierProvider = AsyncNotifierProvider<SubmitReportNotifier, void>(...);
❌ final AuthState = StreamProvider<User?>(...);
❌ final provider1 = ...;
```

### Route Constants

Use `camelCase` string constants in a class:

```dart
✅ abstract class Routes {
    static const String login = '/login';
    static const String home = '/home';
    static const String submitReport = '/report/submit';
}
```

---

## Code Organization Rules

### Import Order

Follow the standard Dart import ordering (enforced by `flutter pub run dart_fix`):

```dart
// 1. Dart core imports
import 'dart:async';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Third-party package imports (alphabetical)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 4. Internal imports (relative or package-based)
import 'package:speakup_connect/core/theme/app_colors.dart';
import 'package:speakup_connect/features/reports/domain/entities/report_entity.dart';
```

### File Length

- Maximum recommended file length: **300 lines**
- If a file exceeds this, split into smaller files
- Exception: generated code (`.g.dart`, `.freezed.dart`) has no limit

### Class Length

- Maximum recommended class length: **200 lines**
- Extract helper widgets, helper functions, or separate classes when exceeding this

---

## Architecture Rules

### Dependency Direction

Dependencies flow **inward** only:

```
Presentation → Domain ← Data
```

- **Presentation** may import from **Domain** (entities, use cases, repository interfaces)
- **Data** may import from **Domain** (to implement repository interfaces)
- **Domain** must **never** import from **Presentation** or **Data**
- Features must **never** import from other features directly

### Repository Pattern

Always use the repository abstraction, never call Firestore directly from a provider or screen:

```dart
// ✅ Correct: use case → repository interface → implementation
class SubmitReportUseCase {
  final ReportRepository _repository;
  SubmitReportUseCase(this._repository);
  Future<ReportEntity> call(SubmitReportParams params) => _repository.submitReport(params);
}

// ❌ Wrong: calling Firestore directly in a provider
final badProvider = FutureProvider((ref) async {
  final firestore = FirebaseFirestore.instance;
  await firestore.collection('reports').add({...});
});
```

### Use Cases

Each use case does **one thing** and is named as a verb phrase:

```dart
✅ SubmitReportUseCase
✅ GetMyReportsUseCase
✅ UpdateReportStatusUseCase
❌ ReportManagementUseCase  // too broad
❌ HandleReportsUseCase     // vague
```

Use cases receive a params object when they need multiple inputs:

```dart
class SubmitReportParams {
  final String organizationId;
  final String categoryId;
  final String title;
  final String description;
  final bool isAnonymous;
  final List<String> photoPaths;
  
  const SubmitReportParams({...});
}
```

### No Business Logic in Widgets

Widgets are display-only. All business logic lives in providers, use cases, or domain entities:

```dart
// ✅ Correct: logic in provider, widget just calls it
ElevatedButton(
  onPressed: () => ref.read(submitReportNotifierProvider.notifier).submit(),
)

// ❌ Wrong: business logic in widget
ElevatedButton(
  onPressed: () async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('reports').add({...}); // ❌
  },
)
```

---

## Flutter Best Practices

### Widget Construction

- Prefer `StatelessWidget` over `StatefulWidget` when there is no local state
- Use `ConsumerWidget` (Riverpod) when the widget only needs to read providers
- Use `ConsumerStatefulWidget` when you need both local state and providers

### Const Constructors

Use `const` wherever possible:

```dart
✅ const Text('Hello')
✅ const SizedBox(height: 16)
✅ const EdgeInsets.all(16)
```

### Keys

Always provide keys for list items in `ListView` or dynamically reordered lists:

```dart
ListView.builder(
  itemBuilder: (context, index) {
    return ReportCard(
      key: ValueKey(reports[index].reportId), // ✅
      report: reports[index],
    );
  },
)
```

### Responsive Design

Use `MediaQuery` or `LayoutBuilder` for responsive layouts. Target minimum screen width: 360dp (common budget Android phones in the Philippines).

```dart
final screenWidth = MediaQuery.of(context).size.width;
final isSmallScreen = screenWidth < 400;
```

### String Localization

All user-facing strings must be localized from the start. Use `AppLocalizations` (or the org's configurable string system) rather than hardcoded strings:

```dart
// ✅
Text(context.l10n.welcomeMessage)

// ❌ 
Text('Welcome to our school!')  // org-specific and hardcoded
```

---

## Riverpod Usage Standards

### Provider Placement

All providers are defined in the `presentation/providers/` folder of their feature:

```
lib/features/reports/presentation/providers/report_provider.dart
```

### Provider Access

Use `ref.watch` for values that should rebuild the widget on change.  
Use `ref.read` for one-time reads (e.g., inside `onPressed`):

```dart
// ✅ In build method
final reports = ref.watch(myReportsProvider);

// ✅ In event handler
onPressed: () => ref.read(submitReportNotifierProvider.notifier).submit()

// ❌ Wrong: using ref.read in build
final reports = ref.read(myReportsProvider); // won't rebuild on change
```

### AsyncValue Handling

Always handle all three states of `AsyncValue`:

```dart
final reportsAsync = ref.watch(myReportsProvider);

return reportsAsync.when(
  loading: () => const AppLoadingIndicator(),
  error: (error, stack) => AppErrorWidget(message: error.toString()),
  data: (reports) => ReportsList(reports: reports),
);
```

### Notifier State Updates

Never mutate state directly. Always return a new state:

```dart
// ✅ Correct
state = AsyncData([...state.value!, newReport]);

// ❌ Wrong
state.value!.add(newReport); // mutating list directly
```

---

## Error Handling

### Domain Failures

Use a sealed `Failure` class in the domain layer:

```dart
sealed class Failure {
  const Failure(this.message);
  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection');
}

class AuthFailure extends Failure {
  const AuthFailure(this.code) : super('Authentication failed');
  final String code;
}

class PermissionFailure extends Failure {
  const PermissionFailure() : super('You do not have permission to do this');
}
```

### Catching Exceptions

Catch exceptions at the **datasource or repository level** and convert to `Failure` types. Never let raw Firebase exceptions bubble up to the presentation layer:

```dart
// ✅ In repository implementation
try {
  final result = await _datasource.submitReport(params);
  return result;
} on FirebaseException catch (e) {
  throw AuthFailure(e.code);
} catch (e) {
  throw UnknownFailure(e.toString());
}
```

---

## Comments & Documentation

### When to Comment

- Write comments for **why**, not **what**
- Do not write comments that just repeat the code:

```dart
// ❌ Useless comment
// Increment counter
counter++;

// ✅ Useful comment
// We increment before returning because the sequence number
// must be unique even if the transaction is retried.
counter++;
```

### Public API Documentation

All public classes and methods in the domain layer should have doc comments:

```dart
/// Submits a new report to the organization's Firestore collection.
///
/// Throws [PermissionFailure] if the user is not authenticated.
/// Throws [NetworkFailure] if the device has no connectivity.
Future<ReportEntity> submitReport(SubmitReportParams params);
```

---

## Git Conventions

### Branch Naming

```
feature/report-submission-wizard
fix/auth-redirect-loop
chore/update-dependencies
docs/update-architecture
```

### Commit Messages

Follow Conventional Commits:

```
feat: add 3-step report submission wizard
fix: correct route guard redirect for unauthenticated users
chore: update flutter_riverpod to 2.6.1
docs: add sprint 2 tasks to SPRINT_TRACKER.md
test: add unit tests for SubmitReportUseCase
```
