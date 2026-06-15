import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/announcements/presentation/providers/announcement_provider.dart';
import 'package:speakup_connect/features/announcements/presentation/providers/bulletin_response_provider.dart';
import 'package:speakup_connect/features/reminders/presentation/widgets/expiration_picker_section.dart'
    show formatDateTime;

/// Lists all recipient responses for an announcement (author/admin).
class AnnouncementResponsesScreen extends ConsumerWidget {
  const AnnouncementResponsesScreen({required this.bulletinId, super.key});

  final String bulletinId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final bulletinAsync = ref.watch(bulletinByIdProvider(bulletinId));
    final responsesAsync = ref.watch(bulletinResponsesProvider(bulletinId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.myAnnouncements),
        ),
        title: Text(l10n.announcementsResponsesTitle),
      ),
      body: bulletinAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(l10n.announcementsFailedToLoadAnnouncement('$e'))),
        data: (bulletin) {
          if (bulletin == null) {
            return Center(child: Text(l10n.announcementsNotFoundShort));
          }
          final config = bulletin.responseConfig;
          if (config == null || !config.enabled) {
            return Center(
              child: Text(l10n.announcementsNoResponses),
            );
          }

          return responsesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text(l10n.announcementsFailedToLoadResponses('$e'))),
            data: (responses) {
              if (responses.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No responses yet.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: responses.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final r = responses[i];
                  return ListTile(
                    title: Text(
                      r.userDisplayName ?? r.userId,
                      style: theme.textTheme.titleSmall,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(r.displayValue(config)),
                        const SizedBox(height: 4),
                        Text(
                          formatDateTime(r.submittedAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
