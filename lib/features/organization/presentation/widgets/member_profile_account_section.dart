import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/organization/domain/entities/user_profile_entity.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/shared/widgets/app_text_field.dart';

/// Sign-in username and contact email on Settings / Profile.
class MemberProfileAccountSection extends ConsumerWidget {
  const MemberProfileAccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;

    if (profile == null || !profile.isApproved) {
      return const SizedBox.shrink();
    }

    return _MemberProfileAccountCard(profile: profile);
  }
}

class _MemberProfileAccountCard extends ConsumerWidget {
  const _MemberProfileAccountCard({required this.profile});

  final UserProfileEntity profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final studentId = profile.studentId?.trim();
    final email = profile.email?.trim();
    final isUpdating = ref.watch(updateMemberContactEmailProvider).isLoading;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AccountRow(
            label: 'Username / student ID',
            value: studentId?.isNotEmpty == true ? studentId! : 'Not set',
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 10),
          _AccountRow(
            label: 'Contact email',
            value: email?.isNotEmpty == true ? email! : 'Not set',
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in with your student ID or contact email and your password.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: isUpdating
                  ? null
                  : () => _editEmail(context, ref, email),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(email?.isNotEmpty == true ? 'Change email' : 'Add email'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editEmail(
    BuildContext context,
    WidgetRef ref,
    String? currentEmail,
  ) async {
    final newEmail = await showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _EditContactEmailDialog(initialEmail: currentEmail),
    );

    if (newEmail == null || !context.mounted) return;

    final ok = await ref
        .read(updateMemberContactEmailProvider.notifier)
        .update(email: newEmail.isEmpty ? null : newEmail);

    if (!context.mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newEmail.isEmpty ? 'Contact email removed' : 'Contact email updated',
          ),
        ),
      );
    } else {
      final error = ref.read(updateMemberContactEmailProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error?.toString() ?? 'Could not update email'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnset = value == 'Not set';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isUnset
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditContactEmailDialog extends StatefulWidget {
  const _EditContactEmailDialog({this.initialEmail});

  final String? initialEmail;

  @override
  State<_EditContactEmailDialog> createState() =>
      _EditContactEmailDialogState();
}

class _EditContactEmailDialogState extends State<_EditContactEmailDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(viewInsets: EdgeInsets.zero),
        child: AlertDialog(
          scrollable: true,
          title: const Text('Contact email'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Used for notifications and sign-in. Your student ID remains '
                  'your username for school accounts.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _controller,
                  label: 'Email (optional)',
                  hint: 'you@school.edu',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: (v) => context.l10n.validateOptionalEmail(v),
                ),
              ],
            ),
          ),
          actions: [
            if (widget.initialEmail?.isNotEmpty == true)
              TextButton(
                onPressed: () => Navigator.pop(context, ''),
                child: const Text('Remove'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                Navigator.pop(context, _controller.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
