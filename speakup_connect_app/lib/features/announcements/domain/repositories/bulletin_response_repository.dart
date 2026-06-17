import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_entity.dart';

abstract class BulletinResponseRepository {
  Future<void> submitResponse({
    required String organizationId,
    required String bulletinId,
    String? text,
    List<String>? selectedOptionIds,
    String? selectedOptionId,
  });

  Stream<ReminderResponseEntity?> watchMyResponse({
    required String organizationId,
    required String bulletinId,
    required String userId,
  });

  Stream<List<ReminderResponseEntity>> watchResponses({
    required String organizationId,
    required String bulletinId,
  });
}
