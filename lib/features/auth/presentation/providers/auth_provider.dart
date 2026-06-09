import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';
import 'package:speakup_connect/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:speakup_connect/features/auth/domain/entities/user_entity.dart';
import 'package:speakup_connect/features/auth/domain/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

// --- Infrastructure Providers ---

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(FirebaseAuth.instance);
}

// --- Auth State Stream ---

/// Watches the Firebase Auth state. Emits [UserEntity] when signed in, null when signed out.
/// Used by the router to enforce auth guards.
@riverpod
Stream<UserEntity?> authStateChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

/// Returns the currently signed-in [UserEntity] synchronously, or null.
@riverpod
UserEntity? currentUser(Ref ref) {
  return ref.watch(authStateChangesProvider).value;
}

// --- Auth Notifier (Sign In / Sign Up / Sign Out) ---

/// Manages authentication operations: sign-in, sign-up, anonymous sign-in, sign-out.
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signInWithIdentifier(
            identifier: email,
            password: password,
          );
      state = const AsyncData(null);
    } on AppException catch (e) {
      state = AsyncError(e.toFailure(), StackTrace.current);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signUpWithEmail(
            email: email,
            password: password,
            displayName: displayName,
          );
      state = const AsyncData(null);
    } on AppException catch (e) {
      state = AsyncError(e.toFailure(), StackTrace.current);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> signInAnonymously() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signInAnonymously();
      state = const AsyncData(null);
    } on AppException catch (e) {
      state = AsyncError(e.toFailure(), StackTrace.current);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signOut();
      state = const AsyncData(null);
    } on AppException catch (e) {
      state = AsyncError(e.toFailure(), StackTrace.current);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
