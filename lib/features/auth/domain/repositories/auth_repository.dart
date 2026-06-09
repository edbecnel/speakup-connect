import 'package:speakup_connect/features/auth/domain/entities/user_entity.dart';

/// Abstract authentication repository interface.
///
/// Defines all auth operations available to the domain and presentation layers.
/// The Firebase implementation lives in the data layer.
abstract class AuthRepository {
  /// Stream of the currently authenticated user.
  /// Emits null when the user is signed out.
  Stream<UserEntity?> get authStateChanges;

  /// Returns the currently signed-in user, or null if not signed in.
  UserEntity? get currentUser;

  /// Signs in with [email] and [password].
  /// Throws [AuthFailure] on invalid credentials.
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  /// Signs in with an email address or a school-issued student ID.
  Future<UserEntity> signInWithIdentifier({
    required String identifier,
    required String password,
    String? organizationId,
  });

  /// Creates a new account with [email] and [password].
  /// Throws [AuthFailure] if the email is already in use.
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Signs in anonymously for anonymous report submission.
  /// The anonymous session is short-lived and signed out after submission.
  Future<UserEntity> signInAnonymously();

  /// Signs out the current user.
  Future<void> signOut();

  /// Sends a password reset email to [email].
  Future<void> sendPasswordResetEmail(String email);
}
