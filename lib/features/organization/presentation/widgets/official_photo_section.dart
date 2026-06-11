import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/features/organization/presentation/providers/profile_photo_provider.dart';
import 'package:speakup_connect/features/organization/presentation/widgets/profile_photo_picker.dart';

/// Admin section for uploading a student's official school photo.
class OfficialPhotoSection extends ConsumerWidget {
  const OfficialPhotoSection({
    required this.displayName,
    this.officialPhotoUrl,
    this.studentId,
    this.userId,
    super.key,
  });

  final String displayName;
  final String? officialPhotoUrl;
  final String? studentId;
  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final busy = ref.watch(profilePhotoProvider).isLoading;

    ref.listen(profilePhotoProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading && next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo update failed: ${next.error}'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Official school photo',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Permanent school record for faculty and admins. Stored separately '
          'from any personal photo the student may add in Settings (when '
          'allowed). A student personal badge never replaces or deletes this '
          'official image.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: ProfilePhotoPicker(
            displayName: displayName,
            officialPhotoUrl: officialPhotoUrl,
            radius: 48,
            isLoading: busy,
            showRemove: true,
            onPick: (path) async {
              final ok = await ref
                  .read(profilePhotoProvider.notifier)
                  .uploadOfficialPhoto(
                    localPath: path,
                    studentId: studentId,
                    userId: userId,
                  );
              if (context.mounted && ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Official photo updated')),
                );
              }
            },
            onRemove: () async {
              final ok = await ref
                  .read(profilePhotoProvider.notifier)
                  .clearOfficialPhoto(
                    studentId: studentId,
                    userId: userId,
                  );
              if (context.mounted && ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Official photo removed')),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
