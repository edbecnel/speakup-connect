import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/features/announcements/domain/entities/bulletin_entity.dart';
import 'package:speakup_connect/features/announcements/presentation/providers/announcement_provider.dart';

class MyAnnouncementsScreen extends ConsumerWidget {
  const MyAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bulletinsAsync = ref.watch(myBulletinsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('My Announcements'),
      ),
      body: bulletinsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (bulletins) {
          if (bulletins.isEmpty) {
            return const Center(child: Text('You have not posted any announcements yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bulletins.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final bulletin = bulletins[i];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  title: Text(bulletin.title),
                  subtitle: Text(
                    '${_statusLabel(bulletin)} · '
                    '${DateFormat.yMMMd().format(bulletin.createdAt)}',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: bulletin.isPublished
                      ? () => context.push(
                            Routes.announcementDetailPath(bulletin.bulletinId),
                          )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _statusLabel(BulletinEntity bulletin) {
    return switch (bulletin.status) {
      BulletinStatus.pending => 'Pending approval',
      BulletinStatus.published => 'Published',
      BulletinStatus.rejected => 'Rejected',
    };
  }
}
