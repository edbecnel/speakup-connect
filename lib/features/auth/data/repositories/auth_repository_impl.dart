import 'package:firebase_auth/firebase_auth.dart';
import 'package:speakup_connect/core/auth/student_auth_credentials.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';
import 'package:speakup_connect/features/auth/domain/entities/user_entity.dart';
import 'package:speakup_connect/features/auth/domain/repositories/auth_repository.dart';

/// Firebase Authentication implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(
          (user) => user != null ? _mapUser(user) : null,
        );
  }

  @override
  UserEntity? get currentUser {
    final user = _firebaseAuth.currentUser;
    return user != null ? _mapUser(user) : null;
  }

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return signInWithIdentifier(
      identifier: email,
      password: password,
    );
  }

  @override
  Future<UserEntity> signInWithIdentifier({
    required String identifier,
    required String password,
    String? organizationId,
  }) async {
    final resolved = resolveLoginCredentials(
      identifier: identifier,
      password: password,
      organizationId: organizationId,
    );
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: resolved.email,
        password: resolved.password,
      );
      return _mapUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Sign in failed', code: e.code);
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Update the display name in Firebase Auth
      await credential.user!.updateDisplayName(displayName.trim());
      await credential.user!.reload();
      return _mapUser(_firebaseAuth.currentUser!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Sign up failed', code: e.code);
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<UserEntity> signInAnonymously() async {
    try {
      final credential = await _firebaseAuth.signInAnonymously();
      return _mapUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Anonymous sign-in failed', code: e.code);
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Sign out failed', code: e.code);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Failed to send reset email', code: e.code);
    }
  }

  UserEntity _mapUser(User user) {
    return UserEntity(
      uid: user.uid,
      isAnonymous: user.isAnonymous,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}
