import 'package:flutter/material.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/reminders/presentation/widgets/expiration_picker_section.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/app_text_field.dart';

/// Dialog to edit a broadcast reminder's title, body, and optional expiration.
class EditReminderDialog extends StatefulWidget {
  const EditReminderDialog({
    required this.initialTitle,
    required this.initialBody,
    this.initialExpiresAt,
    super.key,
  });

  final String initialTitle;
  final String initialBody;
  final DateTime? initialExpiresAt;

  static Future<
      ({
        String title,
        String body,
        DateTime? expiresAt,
        bool clearExpiration,
      })?> show(
    BuildContext context, {
    required String initialTitle,
    required String initialBody,
    DateTime? initialExpiresAt,
  }) {
    return showDialog<
        ({
          String title,
          String body,
          DateTime? expiresAt,
          bool clearExpiration,
        })>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditReminderDialog(
        initialTitle: initialTitle,
        initialBody: initialBody,
        initialExpiresAt: initialExpiresAt,
      ),
    );
  }

  @override
  State<EditReminderDialog> createState() => _EditReminderDialogState();
}

class _EditReminderDialogState extends State<EditReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late ExpirationPickerValue _expiration;
  late bool _hadExpiration;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _bodyController = TextEditingController(text: widget.initialBody);
    _expiration =
        ExpirationPickerValue.fromExpiresAt(widget.initialExpiresAt);
    _hadExpiration = widget.initialExpiresAt != null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final resolved = _expiration.resolve();
    if (_expiration.isEnabled && !_expiration.isValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.announcementsExpirationMustBeFuture)),
      );
      return;
    }
    final clearExpiration = _hadExpiration && !_expiration.isEnabled;
    Navigator.of(context).pop((
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      expiresAt: _expiration.isEnabled ? resolved : null,
      clearExpiration: clearExpiration,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.reminderEditBroadcastTitle),
      content: Form(
        key: _formKey,
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
                    return l10n.reminderEditEnterTitle;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _bodyController,
                label: l10n.commonMessage,
                maxLines: 4,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.reminderEditEnterMessage;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              ExpirationPickerSection(
                value: _expiration,
                onChanged: (v) => setState(() => _expiration = v),
              ),
            ],
          ),
        ),
      ),
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
