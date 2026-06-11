import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/organization/data/repositories/profile_photo_repository_impl.dart';
import 'package:speakup_connect/features/organization/domain/repositories/profile_photo_repository.dart';

final profilePhotoRepositoryProvider = Provider<ProfilePhotoRepository>((ref) {
  return ProfilePhotoRepositoryImpl();
});

class ProfilePhotoNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> uploadMemberAvatar(String localPath) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;
    state = const AsyncValue.loading();
    try {
      await ref.read(profilePhotoRepositoryProvider).uploadMemberAvatar(
            orgId: AppConfig.defaultOrganizationId,
            userId: user.uid,
            localPath: localPath,
          );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> clearMemberAvatar() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(profilePhotoRepositoryProvider).clearMemberAvatar(
            orgId: AppConfig.defaultOrganizationId,
          );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> uploadOfficialPhoto({
    required String localPath,
    String? studentId,
    String? userId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(profilePhotoRepositoryProvider).uploadOfficialPhoto(
            orgId: AppConfig.defaultOrganizationId,
            localPath: localPath,
            studentId: studentId,
            userId: userId,
          );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> clearOfficialPhoto({
    String? studentId,
    String? userId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(profilePhotoRepositoryProvider).clearOfficialPhoto(
            orgId: AppConfig.defaultOrganizationId,
            studentId: studentId,
            userId: userId,
          );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final profilePhotoProvider =
    NotifierProvider<ProfilePhotoNotifier, AsyncValue<void>>(
  ProfilePhotoNotifier.new,
);
