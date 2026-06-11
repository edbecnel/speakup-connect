import 'package:flutter_test/flutter_test.dart';
import 'package:speakup_connect/core/auth/student_auth_credentials.dart';

void main() {
  group('resolveLoginCredentials', () {
    test('maps student ID to synthetic auth email', () {
      final resolved = resolveLoginCredentials(
        identifier: 'MONHS-2024-001',
        password: 'MONHS-2024-001',
        organizationId: 'monhs-ph-001',
      );

      expect(
        resolved.email,
        'monhs-2024-001@monhs-ph-001.students.speakupconnect.app',
      );
      expect(resolved.password, 'MONHS-2024-001');
    });

    test('passes through email identifiers unchanged', () {
      final resolved = resolveLoginCredentials(
        identifier: 'Student@School.edu',
        password: 'secret',
        organizationId: 'monhs-ph-001',
      );

      expect(resolved.email, 'Student@School.edu');
    });

    test('isStudentIdLogin distinguishes ID from email', () {
      expect(isStudentIdLogin('abc-123456'), isTrue);
      expect(isStudentIdLogin('user@school.edu'), isFalse);
    });
  });
}
