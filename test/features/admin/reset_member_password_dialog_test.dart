import 'package:flutter_test/flutter_test.dart';
import 'package:speakup_connect/features/admin/presentation/widgets/reset_member_password_dialog.dart';

void main() {
  test('generateRandomDigitPassword returns 8 digits', () {
    final password = generateRandomDigitPassword();
    expect(password.length, 8);
    expect(RegExp(r'^\d{8}$').hasMatch(password), isTrue);
  });

  test('generateRandomDigitPassword respects custom length', () {
    final password = generateRandomDigitPassword(length: 10);
    expect(password.length, 10);
    expect(RegExp(r'^\d{10}$').hasMatch(password), isTrue);
  });
}
