import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/features/reminders/data/repositories/reminder_response_repository_impl.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_entity.dart';
import 'package:speakup_connect/features/reminders/domain/repositories/reminder_response_repository.dart';
import 'package:speakup_connect/features/reminders/presentation/providers/reminder_provider.dart';

final reminderResponseRepositoryProvider =
    Provider<ReminderResponseRepository>((ref) {
  return ReminderResponseRepositoryImpl(FirebaseFirestore.instance);
});

final myReminderResponseProvider = StreamProvider.autoDispose
    .family<ReminderResponseEntity?, String>((ref, reminderId) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(reminderResponseRepositoryProvider).watchMyResponse(
        organizationId: AppConfig.defaultOrganizationId,
        reminderId: reminderId,
        userId: user.uid,
      );
});

final reminderResponsesProvider = StreamProvider.autoDispose
    .family<List<ReminderResponseEntity>, String>((ref, reminderId) {
  return ref.watch(reminderResponseRepositoryProvider).watchResponses(
        organizationId: AppConfig.defaultOrganizationId,
        reminderId: reminderId,
      );
});

final canViewReminderResponsesProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, reminderId) async {
  final reminder = await ref.watch(reminderByIdProvider(reminderId).future);
  if (reminder == null || !reminder.acceptsResponses) return false;
  final user = ref.watch(currentUserProvider);
  final profile = ref.watch(userProfileProvider).value;
  if (user == null) return false;
  return reminder.createdBy == user.uid || (profile?.isAdmin ?? false);
});

class SubmitReminderResponseNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> submit({
    required String organizationId,
    required String reminderId,
    String? text,
    List<String>? selectedOptionIds,
    String? selectedOptionId,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(reminderResponseRepositoryProvider).submitResponse(
            organizationId: organizationId,
            reminderId: reminderId,
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

final submitReminderResponseProvider =
    NotifierProvider<SubmitReminderResponseNotifier, AsyncValue<void>>(
  SubmitReminderResponseNotifier.new,
);
