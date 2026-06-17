/// Domain-layer failure types for SpeakUp Connect.
///
/// Failures are the domain layer's way of expressing errors without
/// coupling to external libraries (Firebase, HTTP, etc.).
/// The data layer catches specific exceptions and maps them to Failures.
/// The presentation layer catches Failures and maps them to user messages.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

/// The device has no internet connection.
class NetworkFailure extends Failure {
  const NetworkFailure()
      : super('No internet connection. Please check your network and try again.');
}

/// Firebase Authentication failed.
class AuthFailure extends Failure {
  const AuthFailure({required this.code, String? message})
      : super(message ?? 'Authentication failed. Please try again.');
  final String code;
}

/// Firestore or Storage operation failed.
class DatabaseFailure extends Failure {
  const DatabaseFailure({String? message})
      : super(message ?? 'A database error occurred. Please try again.');
}

/// The user does not have permission to perform this operation.
class PermissionFailure extends Failure {
  const PermissionFailure({String? message})
      : super(
          message ??
              'You do not have permission to perform this action.',
        );
}

/// The requested resource was not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure({String? message})
      : super(message ?? 'The requested item could not be found.');
}

/// File upload to Firebase Storage failed.
class StorageFailure extends Failure {
  const StorageFailure({String? message})
      : super(message ?? 'File upload failed. Please try again.');
}

/// Input validation failure (form-level errors).
class ValidationFailure extends Failure {
  const ValidationFailure({required String message}) : super(message);
}

/// An unexpected error that doesn't fit other categories.
class UnknownFailure extends Failure {
  const UnknownFailure({String? message})
      : super(message ?? 'An unexpected error occurred. Please try again.');
}
