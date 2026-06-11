import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/features/announcements/data/repositories/bulletin_response_repository_impl.dart';
import 'package:speakup_connect/features/announcements/domain/repositories/bulletin_response_repository.dart';
import 'package:speakup_connect/features/announcements/presentation/providers/announcement_provider.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_entity.dart';

final bulletinResponseRepositoryProvider =
    Provider<BulletinResponseRepository>((ref) {
  return BulletinResponseRepositoryImpl(FirebaseFirestore.instance);
});

final myBulletinResponseProvider = StreamProvider.autoDispose
    .family<ReminderResponseEntity?, String>((ref, bulletinId) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(bulletinResponseRepositoryProvider).watchMyResponse(
        organizationId: AppConfig.defaultOrganizationId,
        bulletinId: bulletinId,
        userId: user.uid,
      );
});

final bulletinResponsesProvider = StreamProvider.autoDispose
    .family<List<ReminderResponseEntity>, String>((ref, bulletinId) {
  return ref.watch(bulletinResponseRepositoryProvider).watchResponses(
        organizationId: AppConfig.defaultOrganizationId,
        bulletinId: bulletinId,
      );
});

final canViewBulletinResponsesProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, bulletinId) async {
  final bulletin = await ref.watch(bulletinByIdProvider(bulletinId).future);
  if (bulletin == null || !bulletin.acceptsResponses) return false;
  final user = ref.watch(currentUserProvider);
  final profile = ref.watch(userProfileProvider).value;
  if (user == null) return false;
  return bulletin.authorId == user.uid || (profile?.isAdmin ?? false);
});

class SubmitBulletinResponseNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> submit({
    required String organizationId,
    required String bulletinId,
    String? text,
    List<String>? selectedOptionIds,
    String? selectedOptionId,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(bulletinResponseRepositoryProvider).submitResponse(
            organizationId: organizationId,
            bulletinId: bulletinId,
            text: text,
            selectedOptionIds: selectedOptionIds,
            selectedOptionId: selectedOptionId,
          );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final submitBulletinResponseProvider =
    NotifierProvider<SubmitBulletinResponseNotifier, AsyncValue<void>>(
  SubmitBulletinResponseNotifier.new,
);
