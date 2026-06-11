import 'package:speakup_connect/core/errors/failure.dart';

/// Custom exception types for SpeakUp Connect.
///
/// These are thrown by the data layer and caught at the repository boundary,
/// where they are converted to [Failure] types for the domain layer.
class AppException implements Exception {
  const AppException({required this.message, this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AppException: $message (code: $code)';

  /// Converts this exception to the appropriate [Failure] type.
  Failure toFailure() => UnknownFailure(message: message);
}

class NetworkException extends AppException {
  const NetworkException() : super(message: 'No internet connection');

  @override
  Failure toFailure() => const NetworkFailure();
}

class AuthException extends AppException {
  const AuthException({required super.message, super.code});

  @override
  Failure toFailure() => AuthFailure(
        code: code ?? 'unknown',
        message: _mapFirebaseAuthCodeToMessage(code),
      );

  static String? _mapFirebaseAuthCodeToMessage(String? code) {
    switch (code) {
      case 'user-not-found':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Invalid email, student ID, or password.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'requires-recent-login':
        return 'For security, sign out and sign in again, then try changing your password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Your password is too weak. Use at least 8 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return null;
    }
  }
}

class DatabaseException extends AppException {
  const DatabaseException({super.message = 'Database error', super.code});

  @override
  Failure toFailure() => DatabaseFailure(message: message);
}

class PermissionException extends AppException {
  const PermissionException() : super(message: 'Permission denied');

  @override
  Failure toFailure() => const PermissionFailure();
}

class NotFoundException extends AppException {
  const NotFoundException({super.message = 'Not found', super.code});

  @override
  Failure toFailure() => NotFoundFailure(message: message);
}

class StorageException extends AppException {
  const StorageException({super.message = 'Storage error', super.code});

  @override
  Failure toFailure() => StorageFailure(message: message);
}
