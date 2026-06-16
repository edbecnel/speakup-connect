# Examples — Implement Flutter feature slice (Clean Architecture)

## Example 1 — Domain + Presentation (minimal)

**Invocation:**

`/implement-flutter-feature-slice-clean-architecture`

**Input:**

- Feature name: `join_requests`
- Layer(s): `domain, presentation`
- Interfaces:
  - `JoinRequestsRepository.watchMyJoinRequests({required String organizationId, required String userId}) -> Stream<List<JoinRequestEntity>>`
  - `JoinRequestsRepository.submitJoinRequest({required String organizationId, required String groupId, required String userId}) -> Future<void>`
- Schema excerpt:
  - `organizations/{orgId}/joinRequests/{requestId}: { groupId: string, userId: string, status: string, createdAt: timestamp }`

**Expected output shape:**

- Create:
  - `lib/features/join_requests/domain/entities/join_request_entity.dart`
  - `lib/features/join_requests/domain/repositories/join_requests_repository.dart`
  - `lib/features/join_requests/domain/usecases/watch_my_join_requests_usecase.dart`
  - `lib/features/join_requests/domain/usecases/submit_join_request_usecase.dart`
  - `lib/features/join_requests/presentation/providers/join_requests_provider.dart`
  - `lib/features/join_requests/presentation/screens/join_requests_screen.dart`
- Modify (only if required):
  - `lib/l10n/app_en.arb` (added keys only)

## Example 2 — Domain + Data + Presentation (repository impl included)

**Input:**

- Feature name: `feedback`
- Layer(s): `domain, data, presentation`
- Interfaces:
  - `FeedbackRepository.submitFeedback({required String organizationId, required String userId, required String message}) -> Future<void>`
- Schema excerpt:
  - `organizations/{orgId}/feedback/{feedbackId}: { userId: string, message: string, createdAt: timestamp }`

**Expected output shape:**

- Create:
  - `lib/features/feedback/domain/entities/feedback_entity.dart`
  - `lib/features/feedback/domain/repositories/feedback_repository.dart`
  - `lib/features/feedback/domain/usecases/submit_feedback_usecase.dart`
  - `lib/features/feedback/data/repositories/feedback_repository_impl.dart`
  - `lib/features/feedback/presentation/providers/feedback_provider.dart`
  - `lib/features/feedback/presentation/screens/feedback_screen.dart`
- Modify (only if required):
  - `lib/l10n/app_en.arb` (added keys only)

