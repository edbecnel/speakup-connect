/// Domain entity representing an authenticated user.
///
/// This is organization-agnostic — it represents the authenticated identity.
/// Organization-scoped user profile data (role, display name within org) is
/// separate and lives in the organization's users subcollection.
class UserEntity {
  const UserEntity({
    required this.uid,
    required this.isAnonymous,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  /// Firebase Auth UID.
  final String uid;

  /// Whether this is an anonymous auth session.
  final bool isAnonymous;

  /// Email address (null for anonymous users).
  final String? email;

  /// Display name (null for anonymous users).
  final String? displayName;

  /// Profile photo URL (null for anonymous users).
  final String? photoUrl;

  bool get isEmailVerified => email != null && !isAnonymous;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UserEntity && other.uid == uid);

  @override
  int get hashCode => uid.hashCode;
}
