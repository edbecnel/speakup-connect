import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';

/// Optional single-image attachment for announcements.
class AnnouncementImageSection extends StatelessWidget {
  const AnnouncementImageSection({
    required this.imagePath,
    required this.onPick,
    required this.onRemove,
    this.existingImageUrl,
    this.isLoading = false,
    super.key,
  });

  final String? imagePath;
  final String? existingImageUrl;
  final bool isLoading;
  final Future<void> Function(ImageSource source) onPick;
  final VoidCallback onRemove;

  Future<void> _showImageSourceSheet(BuildContext context) async {
    if (isLoading) return;
    final l10n = context.l10n;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.announcementsChooseFromGallery),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.announcementsTakePhoto),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source != null) await onPick(source);
  }

  Widget _imagePreview(BuildContext context, ThemeData theme) {
    final hasLocal = imagePath != null && imagePath!.isNotEmpty;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: hasLocal
              ? Image.file(
                  File(imagePath!),
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imageError(theme),
                )
              : Image.network(
                  existingImageUrl!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return SizedBox(
                      height: 180,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => _imageError(theme),
                ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton.filledTonal(
            tooltip: context.l10n.announcementsRemoveImage,
            onPressed: onRemove,
            icon: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }

  Widget _imageError(ThemeData theme) {
    return Container(
      height: 180,
      alignment: Alignment.center,
      color: theme.colorScheme.errorContainer,
      child: Text(
        'Could not display image',
        style: TextStyle(color: theme.colorScheme.onErrorContainer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final hasLocal = imagePath != null && imagePath!.isNotEmpty;
    final hasRemote =
        !hasLocal && existingImageUrl != null && existingImageUrl!.isNotEmpty;
    final hasImage = hasLocal || hasRemote;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image (optional)',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Add a photo for recruitment flyers, event posters, etc.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        if (isLoading)
          Container(
            height: 180,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(l10n.announcementsPreparingImage),
              ],
            ),
          )
        else if (hasImage) ...[
          _imagePreview(context, theme),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _showImageSourceSheet(context),
              icon: const Icon(Icons.swap_horiz, size: 18),
              label: Text(l10n.announcementsChangePhoto),
            ),
          ),
        ]
        else
          OutlinedButton.icon(
            onPressed: () => _showImageSourceSheet(context),
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text(l10n.announcementsAddImage),
          ),
      ],
    );
  }
}
