import 'package:cloud_functions/cloud_functions.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/auth/student_auth_credentials.dart';
import 'package:speakup_connect/core/errors/app_exception.dart';

/// Callable-backed login identifier resolution.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._functions);

  final FirebaseFunctions _functions;

  /// Resolves [identifier] to the Firebase Auth email for sign-in.
  ///
  /// Student contact emails map to synthetic Auth emails via Cloud Functions.
  /// Falls back to local student-ID mapping only when the callable is unavailable.
  Future<String> resolveLoginEmail({
    required String identifier,
    String? organizationId,
  }) async {
    final trimmed = identifier.trim();
    final orgId = organizationId ?? AppConfig.defaultOrganizationId;

    if (orgId.isEmpty) {
      return resolveLoginCredentials(identifier: trimmed, password: '').email;
    }

    try {
      final result = await _functions
          .httpsCallable('resolveLoginEmail')
          .call<Map<String, dynamic>>({
        'orgId': orgId,
        'identifier': trimmed,
      });
      final email = result.data['email'] as String?;
      if (email != null && email.trim().isNotEmpty) {
        return email.trim();
      }
    } on FirebaseFunctionsException catch (e) {
      // Student email login requires the callable — do not guess Auth email.
      if (trimmed.contains('@') &&
          !trimmed.toLowerCase().contains(kStudentAuthEmailDomain)) {
        throw AuthException(
          message: e.message ??
              'Could not resolve email for sign-in. Try your student ID instead.',
          code: e.code,
        );
      }
      // Callable unavailable — student ID still works locally.
    }

    return resolveLoginCredentials(
      identifier: trimmed,
      password: '',
      organizationId: orgId,
    ).email;
  }
}
