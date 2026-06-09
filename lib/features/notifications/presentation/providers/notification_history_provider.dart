import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/config/app_config.dart';
import 'package:speakup_connect/core/permissions/app_permission.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:speakup_connect/features/notifications/data/repositories/notification_history_repository_impl.dart';
import 'package:speakup_connect/features/notifications/domain/entities/notification_history_entity.dart';
import 'package:speakup_connect/features/notifications/domain/repositories/notification_history_repository.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';

final notificationHistoryRepositoryProvider =
    Provider<NotificationHistoryRepository>((ref) {
  return NotificationHistoryRepositoryImpl(FirebaseFirestore.instance);
});

/// True when the user may open the notification history screen.
final canViewNotificationHistoryProvider = Provider.autoDispose<bool>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  final canBroadcast =
      ref.watch(hasPermissionProvider(AppPermission.broadcastReminders));
  return (profile?.isAdmin ?? false) || canBroadcast;
});

final notificationHistoryProvider =
    StreamProvider.autoDispose<List<NotificationHistoryEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();

  final profile = ref.watch(userProfileProvider).value;
  final repo = ref.watch(notificationHistoryRepositoryProvider);
  final orgId = AppConfig.defaultOrganizationId;

  if (profile?.isAdmin ?? false) {
    return repo.watchOrgHistory(orgId);
  }
  return repo.watchAuthorHistory(organizationId: orgId, userId: user.uid);
});
