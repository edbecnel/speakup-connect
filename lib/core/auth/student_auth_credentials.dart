import 'package:speakup_connect/config/app_config.dart';

/// Internal domain for Firebase Auth accounts provisioned from student IDs.
const String kStudentAuthEmailDomain = 'students.speakupconnect.app';

/// Normalizes a school-issued ID for use in a synthetic auth email local-part.
String normalizeStudentIdForAuth(String studentId) {
  return studentId.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9-]'), '');
}

/// Synthetic email used for Firebase Auth when a student signs in with their ID.
String studentAuthEmail({
  required String studentId,
  String? organizationId,
}) {
  final orgId = organizationId ?? AppConfig.defaultOrganizationId;
  final local = normalizeStudentIdForAuth(studentId);
  return '$local@$orgId.$kStudentAuthEmailDomain';
}

/// True when [identifier] is a student ID rather than an email address.
bool isStudentIdLogin(String identifier) => !identifier.contains('@');

/// Resolves login fields for Firebase email/password auth.
({String email, String password}) resolveLoginCredentials({
  required String identifier,
  required String password,
  String? organizationId,
}) {
  final trimmed = identifier.trim();
  if (isStudentIdLogin(trimmed)) {
    return (
      email: studentAuthEmail(
        studentId: trimmed,
        organizationId: organizationId,
      ),
      password: password,
    );
  }
  return (email: trimmed, password: password);
}
