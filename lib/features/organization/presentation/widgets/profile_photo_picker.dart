import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speakup_connect/core/utils/picked_image_file.dart';
import 'package:speakup_connect/shared/widgets/app_avatar.dart';

enum _PhotoPickerAction { gallery, camera, remove }

/// Tappable profile circle for picking a personal or official school photo.
class ProfilePhotoPicker extends StatelessWidget {
  const ProfilePhotoPicker({
    required this.displayName,
    this.avatarUrl,
    this.officialPhotoUrl,
    this.radius = 32,
    this.isLoading = false,
    this.onPick,
    this.onRemove,
    this.showRemove = false,
    super.key,
  });

  final String? displayName;
  final String? avatarUrl;
  final String? officialPhotoUrl;
  final double radius;
  final bool isLoading;
  final Future<void> Function(String localPath)? onPick;
  final VoidCallback? onRemove;
  final bool showRemove;

  Future<void> _showSourceSheet(BuildContext context) async {
    if (isLoading || onPick == null) return;

    final action = await showModalBottomSheet<_PhotoPickerAction>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(ctx).pop(_PhotoPickerAction.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(ctx).pop(_PhotoPickerAction.camera),
            ),
            if (showRemove &&
                onRemove != null &&
                avatarUrl != null &&
                avatarUrl!.isNotEmpty)
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: Theme.of(ctx).colorScheme.error,
                ),
                title: Text(
                  'Remove photo',
                  style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                ),
                onTap: () => Navigator.of(ctx).pop(_PhotoPickerAction.remove),
              ),
          ],
        ),
      ),
    );

    if (action == null || !context.mounted) return;

    if (action == _PhotoPickerAction.remove) {
      onRemove?.call();
      return;
    }

    final picked = await ImagePicker().pickImage(
      source: action == _PhotoPickerAction.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (picked == null || !context.mounted) return;

    final path = await persistPickedImage(picked);
    if (path == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load that image. Try another photo.'),
          ),
        );
      }
      return;
    }

    await onPick!(path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPhoto =
        (avatarUrl != null && avatarUrl!.isNotEmpty) ||
        (officialPhotoUrl != null && officialPhotoUrl!.isNotEmpty);

    return Semantics(
      button: true,
      label: hasPhoto ? 'Change profile photo' : 'Add profile photo',
      child: InkWell(
        onTap: isLoading ? null : () => _showSourceSheet(context),
        customBorder: const CircleBorder(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AppAvatar(
              displayName: displayName,
              avatarUrl: avatarUrl,
              officialPhotoUrl: officialPhotoUrl,
              radius: radius,
            ),
            if (isLoading)
              Positioned.fill(
                child: CircleAvatar(
                  radius: radius,
                  backgroundColor: Colors.black38,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            else
              Positioned(
                right: -2,
                bottom: -2,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.colorScheme.primary,
                  child: Icon(
                    hasPhoto ? Icons.edit_outlined : Icons.add_a_photo_outlined,
                    size: 16,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
