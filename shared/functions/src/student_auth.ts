/** Shared helpers for admin-provisioned student accounts. */

export const STUDENT_AUTH_EMAIL_DOMAIN = 'students.speakupconnect.app';

/** Normalizes a school-issued ID for the synthetic auth email local-part. */
export function normalizeStudentIdForAuth(studentId: string): string {
  return studentId.trim().toLowerCase().replace(/[^a-z0-9-]/g, '');
}

/** Synthetic Firebase Auth email for student-ID login. */
export function studentAuthEmail(orgId: string, studentId: string): string {
  const local = normalizeStudentIdForAuth(studentId);
  return `${local}@${orgId}.${STUDENT_AUTH_EMAIL_DOMAIN}`;
}

/** Firebase Auth requires passwords of at least 6 characters. */
export function assertStudentPasswordLength(studentId: string): void {
  const trimmed = studentId.trim();
  if (trimmed.length < 6) {
    throw new Error(
      'Student ID must be at least 6 characters (it is used as the initial password).',
    );
  }
}

/** Normalizes a contact email for storage and lookup (case-insensitive). */
export function normalizeContactEmail(email: string): string {
  return email.trim().toLowerCase();
}
