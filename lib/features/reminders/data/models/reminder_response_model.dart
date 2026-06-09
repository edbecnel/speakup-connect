import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_config.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_entity.dart';

class ReminderResponseModel extends ReminderResponseEntity {
  const ReminderResponseModel({
    required super.userId,
    required super.organizationId,
    required super.reminderId,
    required super.responseType,
    required super.submittedAt,
    super.userDisplayName,
    super.text,
    super.selectedOptionIds,
    super.selectedOptionId,
  });

  factory ReminderResponseModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    DateTime? toDate(dynamic v) => v is Timestamp ? v.toDate() : null;
    final optionIds =
        (data['selectedOptionIds'] as List<dynamic>? ?? const [])
            .whereType<String>()
            .toList();

    return ReminderResponseModel(
      userId: documentId,
      organizationId: data['organizationId'] as String? ?? '',
      reminderId: data['reminderId'] as String? ?? '',
      userDisplayName: data['userDisplayName'] as String?,
      responseType: ReminderResponseType.fromValue(
        data['responseType'] as String? ?? ReminderResponseType.freeText.value,
      ),
      text: data['text'] as String?,
      selectedOptionIds: optionIds,
      selectedOptionId: data['selectedOptionId'] as String?,
      submittedAt: toDate(data['submittedAt']) ?? DateTime.now(),
    );
  }
}
