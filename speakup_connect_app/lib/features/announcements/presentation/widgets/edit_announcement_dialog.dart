import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
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
      builder: (_) => EditAnnouncementDialog(
        key: ValueKey(
          '${bulletin.bulletinId}:${bulletin.updatedAt.microsecondsSinceEpoch}',
        ),
        bulletin: bulletin,
      ),
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
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    _seedFromBulletin(widget.bulletin);
  }

  void _seedFromBulletin(BulletinEntity bulletin) {
    _titleController.text = bulletin.title;
    _bodyController.text = bulletin.body;
    _expiration = ExpirationPickerValue.fromExpiresAt(bulletin.expiresAt);
    _hadExpiration = bulletin.expiresAt != null;
    _responseConfig = bulletin.responseConfig ?? const ReminderResponseConfig();
    _initialResponseEnabled = bulletin.responseConfig?.enabled ?? false;
    _previewImagePath = null;
    _clearedImage = false;
  }

  @override
  void didUpdateWidget(covariant EditAnnouncementDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    final idChanged =
        oldWidget.bulletin.bulletinId != widget.bulletin.bulletinId;
    final updatedAtChanged =
        oldWidget.bulletin.updatedAt != widget.bulletin.updatedAt;
    if (idChanged || updatedAtChanged) {
      _seedFromBulletin(widget.bulletin);
    }
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
          SnackBar(
            content: Text(context.l10n.composeAnnouncementImageLoadFailed),
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
        SnackBar(
          content: Text(context.l10n.announcementsExpirationMustBeFuture),
        ),
      );
      return;
    }
    if (!_responseConfig.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.composeAnnouncementValidationResponse),
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
    final l10n = context.l10n;
    final mediaQuery = MediaQuery.of(context);
    final dialogMaxHeight = mediaQuery.size.height * 0.88;
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(l10n.announcementsEditTitle),
      contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      content: SizedBox(
        height: dialogMaxHeight,
        width: mediaQuery.size.width * 0.9,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTextField(
                        controller: _titleController,
                        label: l10n.commonTitle,
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
                        label: l10n.commonMessage,
                        minLines: 7,
                        maxLines: 7,
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
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        AppButton.primary(
          label: l10n.commonSave,
          onPressed: _submit,
        ),
      ],
    );
  }
}
