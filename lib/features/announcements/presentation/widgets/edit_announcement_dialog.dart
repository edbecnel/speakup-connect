import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speakup_connect/core/utils/picked_image_file.dart';
import 'package:speakup_connect/features/announcements/domain/entities/bulletin_entity.dart';
import 'package:speakup_connect/features/announcements/presentation/widgets/announcement_image_section.dart';
import 'package:speakup_connect/features/reminders/domain/entities/reminder_response_config.dart';
import 'package:speakup_connect/features/reminders/presentation/widgets/expiration_picker_section.dart';
import 'package:speakup_connect/features/reminders/presentation/widgets/response_config_section.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/app_text_field.dart';

/// Dialog to edit an announcement's title, body, expiration, image, and response settings.
class EditAnnouncementDialog extends StatefulWidget {
  const EditAnnouncementDialog({
    required this.bulletin,
    super.key,
  });

  final BulletinEntity bulletin;

  static Future<
      ({
        String title,
        String body,
        DateTime? expiresAt,
        bool clearExpiration,
        ReminderResponseConfig responseConfig,
        String? newImageLocalPath,
        bool clearImage,
        bool clearResponseConfig,
      })?> show(
    BuildContext context, {
    required BulletinEntity bulletin,
  }) {
    return showDialog<
        ({
          String title,
          String body,
          DateTime? expiresAt,
          bool clearExpiration,
          ReminderResponseConfig responseConfig,
          String? newImageLocalPath,
          bool clearImage,
          bool clearResponseConfig,
        })>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditAnnouncementDialog(bulletin: bulletin),
    );
  }

  @override
  State<EditAnnouncementDialog> createState() => _EditAnnouncementDialogState();
}

class _EditAnnouncementDialogState extends State<EditAnnouncementDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late ExpirationPickerValue _expiration;
  late bool _hadExpiration;
  late ReminderResponseConfig _responseConfig;
  late bool _initialResponseEnabled;
  String? _previewImagePath;
  bool _clearedImage = false;
  bool _pickingImage = false;

  @override
  void initState() {
    super.initState();
    final bulletin = widget.bulletin;
    _titleController = TextEditingController(text: bulletin.title);
    _bodyController = TextEditingController(text: bulletin.body);
    _expiration = ExpirationPickerValue.fromExpiresAt(bulletin.expiresAt);
    _hadExpiration = bulletin.expiresAt != null;
    _responseConfig = bulletin.responseConfig ?? const ReminderResponseConfig();
    _initialResponseEnabled = bulletin.responseConfig?.enabled ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  String? get _existingImageUrl {
    if (_clearedImage || _previewImagePath != null) return null;
    return widget.bulletin.imageUrl;
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_pickingImage) return;
    setState(() => _pickingImage = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
      );
      if (!mounted) return;
      if (picked == null) return;

      final path = await persistPickedImage(picked);
      if (!mounted) return;
      if (path == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load that image. Try another photo.'),
          ),
        );
        return;
      }

      setState(() {
        _previewImagePath = path;
        _clearedImage = false;
      });
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  void _removeImage() {
    setState(() {
      _previewImagePath = null;
      _clearedImage = true;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final resolved = _expiration.resolve();
    if (_expiration.isEnabled && !_expiration.isValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expiration must be in the future')),
      );
      return;
    }
    if (!_responseConfig.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Complete the optional response settings or turn them off.',
          ),
        ),
      );
      return;
    }

    final clearExpiration = _hadExpiration && !_expiration.isEnabled;
    final clearImage = _clearedImage && _previewImagePath == null;
    final clearResponseConfig =
        _initialResponseEnabled && !_responseConfig.enabled;

    Navigator.of(context).pop((
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      expiresAt: _expiration.isEnabled ? resolved : null,
      clearExpiration: clearExpiration,
      responseConfig: _responseConfig,
      newImageLocalPath: _previewImagePath,
      clearImage: clearImage,
      clearResponseConfig: clearResponseConfig,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit announcement'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: _titleController,
                label: 'Title',
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _bodyController,
                label: 'Message',
                maxLines: 4,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Enter a message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              ExpirationPickerSection(
                value: _expiration,
                onChanged: (v) => setState(() => _expiration = v),
              ),
              const SizedBox(height: 16),
              AnnouncementImageSection(
                imagePath: _previewImagePath,
                existingImageUrl: _existingImageUrl,
                isLoading: _pickingImage,
                onPick: _pickImage,
                onRemove: _removeImage,
              ),
              const SizedBox(height: 16),
              ResponseConfigSection(
                value: _responseConfig,
                onChanged: (v) => setState(() => _responseConfig = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        AppButton.primary(
          label: 'Save',
          onPressed: _submit,
        ),
      ],
    );
  }
}
