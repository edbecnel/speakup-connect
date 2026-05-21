import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/organization/data/repositories/user_profile_repository_impl.dart';
import 'package:speakup_connect/features/organization/domain/entities/user_profile_entity.dart';
import 'package:speakup_connect/features/organization/domain/repositories/user_profile_repository.dart';

// --- Infrastructure ---

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepositoryImpl(FirebaseFirestore.instance);
});

// --- User Profile Stream ---

/// Watches the current user's profile for the default organisation.
///
/// Emits [null] when:
///   - The user is not authenticated.
///   - No profile document exists (new sign-up, not yet applied).
///
/// Emits a [UserProfileEntity] with [ApprovalStatus.pending] while the
/// admin has not yet reviewed the application.
final userProfileProvider = StreamProvider<UserProfileEntity?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);

  const orgId = AppConfig.defaultOrganizationId;
  return ref
      .read(userProfileRepositoryProvider)
      .watchUserProfile(orgId: orgId, userId: user.uid);
});

// --- Join Application Notifier ---

/// State for the apply-to-join form submission.
class JoinApplicationNotifier
    extends StateNotifier<AsyncValue<void>> {
  JoinApplicationNotifier(this._repository) : super(const AsyncValue.data(null));

  final UserProfileRepository _repository;

  Future<void> submitApplication({
    required String orgId,
    required String userId,
    required String displayName,
    required String fullName,
    String? studentId,
    String? email,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repository.createUserProfile(
        orgId: orgId,
        userId: userId,
        displayName: displayName,
        fullName: fullName,
        studentId: studentId,
        email: email,
      ),
    );
  }
}

final joinApplicationProvider =
    StateNotifierProvider.autoDispose<JoinApplicationNotifier, AsyncValue<void>>(
  (ref) => JoinApplicationNotifier(ref.read(userProfileRepositoryProvider)),
);
