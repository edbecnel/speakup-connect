import 'package:flutter_test/flutter_test.dart';
import 'package:speakup_connect/features/notifications/domain/entities/app_notification_entity.dart';

void main() {
  AppNotificationEntity notification({
    String type = 'group_membership',
    Map<String, dynamic> data = const {},
  }) {
    return AppNotificationEntity(
      id: 'n1',
      type: type,
      title: 'Test',
      body: 'Body',
      createdAt: DateTime(2026, 1, 1),
      data: data,
    );
  }

  test('leave_approved opens detail screen, not review queue', () {
    final n = notification(
      data: {'event': 'leave_approved', 'groupId': 'g1'},
    );

    expect(n.opensGroupMembershipRequests, isFalse);
    expect(n.isInformationalGroupMembership, isTrue);
  });

  test('membership_review opens review queue', () {
    final n = notification(
      data: {'event': 'membership_review', 'groupId': 'g1'},
    );

    expect(n.opensGroupMembershipRequests, isTrue);
    expect(n.isInformationalGroupMembership, isFalse);
  });

  test('removed is informational', () {
    final n = notification(
      data: {'event': 'removed', 'groupId': 'g1'},
    );

    expect(n.opensGroupMembershipRequests, isFalse);
    expect(n.isInformationalGroupMembership, isTrue);
  });
}
