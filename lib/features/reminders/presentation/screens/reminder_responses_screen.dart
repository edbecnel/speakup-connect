import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/features/reminders/presentation/providers/reminder_provider.dart';
import 'package:speakup_connect/features/reminders/presentation/providers/reminder_response_provider.dart';
import 'package:speakup_connect/features/reminders/presentation/widgets/expiration_picker_section.dart'
    show formatDateTime;

/// Lists all recipient responses for a broadcast reminder (author/admin).
class ReminderResponsesScreen extends ConsumerWidget {
  const ReminderResponsesScreen({required this.reminderId, super.key});

  final String reminderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminderAsync = ref.watch(reminderByIdProvider(reminderId));
    final responsesAsync = ref.watch(reminderResponsesProvider(reminderId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.myBroadcasts),
        ),
        title: const Text('Responses'),
      ),
      body: reminderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load reminder: $e')),
        data: (reminder) {
          if (reminder == null) {
            return const Center(child: Text('Reminder not found'));
          }
          final config = reminder.responseConfig;
          if (config == null || !config.enabled) {
            return const Center(child: Text('This reminder has no responses.'));
          }

          return responsesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Failed to load responses: $e')),
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
