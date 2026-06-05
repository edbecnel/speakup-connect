import 'package:flutter/material.dart';

/// Bell / alerts icon with an optional unread-count badge.
class NotificationBadgeIcon extends StatelessWidget {
  const NotificationBadgeIcon({
    super.key,
    required this.icon,
    required this.unreadCount,
  });

  final IconData icon;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final label = unreadCount > 99 ? '99+' : '$unreadCount';
    return Badge(
      isLabelVisible: unreadCount > 0,
      label: Text(label),
      child: Icon(icon),
    );
  }
}
