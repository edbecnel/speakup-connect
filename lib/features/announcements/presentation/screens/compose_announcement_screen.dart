import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speakup_connect/core/utils/picked_image_file.dart';
import 'package:speakup_connect/core/permissions/providers/permission_provider.dart';
import 'package:speakup_connect/features/announcements/domain/entities/bulletin_entity.dart';
import 'package:speakup_connect/features/announcements/presentation/providers/announcement_provider.dart';
import 'package:speakup_connect/features/announcements/presentation/widgets/announcement_image_section.dart';
import 'package:speakup_connect/features/groups/domain/entities/my_group_membership.dart';
import 'package:speakup_connect/features/groups/presentation/providers/group_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/user_profile_provider.dart';
import 'package:speakup_connect/features/reminders/presentation/widgets/expiration_picker_section.dart';
import 'package:speakup_connect/features/reminders/presentation/widgets/response_config_section.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/app_text_field.dart';

class ComposeAnnouncementScreen extends ConsumerStatefulWidget {
  const ComposeAnnouncementScreen({this.initialGroupId, super.key});

  final String? initialGroupId;

  @override
  ConsumerState<ComposeAnnouncementScreen> createState() =>
      _ComposeAnnouncementScreenState();
}

class _ComposeAnnouncementScreenState
    extends ConsumerState<ComposeAnnouncementScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  var _didPresetGroup = false;
  var _pickingImage = false;
  String? _previewImagePath;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPost = ref.watch(canPostAnnouncementsProvider);
    final leaderOnly = ref.watch(isGroupLeaderOnlyAnnouncementComposerProvider);
    final isAdmin = ref.watch(userProfileProvider).value?.isAdmin == true;
    final form = ref.watch(composeAnnouncementProvider);
    final notifier = ref.read(composeAnnouncementProvider.notifier);
    final submitState = ref.watch(submitAnnouncementProvider);
    final ledGroups = ref.watch(ledGroupMembershipsProvider);

    if (!_didPresetGroup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (widget.initialGroupId != null) {
          _presetGroup(widget.initialGroupId!, ledGroups);
        } else if (leaderOnly &&
            form.sourceGroupId == null &&
            ledGroups.isNotEmpty) {
          final m = ledGroups.first;
          ref.read(composeAnnouncementProvider.notifier).setSourceGroup(
                id: m.group.groupId,
                label: m.group.name,
              );
        }
        _didPresetGroup = true;
      });
    }

    final requireApproval = ref
            .watch(organizationConfigProvider)
            .asData
            ?.value
            .requireReminderApproval ??
        false;
    final canPublishDirectly =
        ref.watch(canReviewPendingRemindersProvider);
    final willNeedApproval = requireApproval && !canPublishDirectly;

    ref.listen(submitAnnouncementProvider, (prev, next) {
      if (prev?.isLoading == true && !next.isLoading) {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to post: ${next.error}'),
            backgroundColor: theme.colorScheme.error,
          ));
        } else if (next.asData?.value != null) {
          final result = next.asData!.value!;
          final msg = result.status == BulletinStatus.pending
              ? 'Announcement submitted for approval.'
              : 'Announcement published.';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(msg),
            backgroundColor: Colors.green.shade700,
          ));
          setState(() => _previewImagePath = null);
          if (context.canPop()) context.pop();
        }
      }
    });

    if (!canPost) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post Announcement')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'You do not have permission to post school-wide announcements.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Post Announcement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'School-wide announcements are visible to every member.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            if (willNeedApproval) ...[
              const SizedBox(height: 12),
              MaterialBanner(
                content: const Text(
                  'Your organization requires approval before announcements go live.',
                ),
                leading: const Icon(Icons.fact_check_outlined),
                backgroundColor:
                    theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                actions: const [SizedBox.shrink()],
              ),
            ],
            const SizedBox(height: 20),
            if (leaderOnly || ledGroups.isNotEmpty) ...[
              _GroupPicker(
                memberships: ledGroups,
                selectedId: form.sourceGroupId,
                required: leaderOnly,
                onSelected: (m) => notifier.setSourceGroup(
                  id: m.group.groupId,
                  label: m.group.name,
                ),
              ),
              const SizedBox(height: 16),
            ],
            AppTextField(
              controller: _titleCtrl,
              label: 'Title',
              hint: 'e.g. Join our club this semester',
              prefixIcon: Icons.title_rounded,
              textInputAction: TextInputAction.next,
              onChanged: notifier.setTitle,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _bodyCtrl,
              label: 'Message',
              hint: 'Share recruitment info, news, or updates…',
              prefixIcon: Icons.notes_rounded,
              maxLines: 6,
              textInputAction: TextInputAction.newline,
              onChanged: notifier.setBody,
            ),
            const SizedBox(height: 20),
            AnnouncementImageSection(
              imagePath: _previewImagePath ?? form.imagePath,
              isLoading: _pickingImage,
              onPick: _pickImage,
              onRemove: _clearImage,
            ),
            const SizedBox(height: 20),
            ExpirationPickerSection(
              value: form.expiration,
              onChanged: notifier.setExpiration,
            ),
            const SizedBox(height: 20),
            ResponseConfigSection(
              value: form.responseConfig,
              onChanged: notifier.setResponseConfig,
            ),
            if (isAdmin) ...[
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Pin to top of announcements'),
                subtitle: const Text('Pinned posts appear first for all members'),
                value: form.isPinned,
                onChanged: notifier.setPinned,
              ),
            ],
            if (!form.isValid && form.validationMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                form.validationMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 28),
            AppButton.primary(
              label: willNeedApproval ? 'Submit for Approval' : 'Publish',
              onPressed: form.isValid
                  ? () => ref.read(submitAnnouncementProvider.notifier).submit(
                        imagePath: _previewImagePath ?? form.imagePath,
                      )
                  : null,
              isLoading: submitState.isLoading,
            ),
          ],
        ),
      ),
    );
  }

  void _presetGroup(String groupId, List<MyGroupMembership> led) {
    final match = led.where((m) => m.group.groupId == groupId).firstOrNull;
    if (match != null) {
      ref.read(composeAnnouncementProvider.notifier).setSourceGroup(
            id: match.group.groupId,
            label: match.group.name,
          );
    }
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

      setState(() => _previewImagePath = path);
      ref.read(composeAnnouncementProvider.notifier).setImagePath(path);
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  void _clearImage() {
    setState(() => _previewImagePath = null);
    ref.read(composeAnnouncementProvider.notifier).clearImage();
  }
}

class _GroupPicker extends StatelessWidget {
  const _GroupPicker({
    required this.memberships,
    required this.selectedId,
    required this.required,
    required this.onSelected,
  });

  final List<MyGroupMembership> memberships;
  final String? selectedId;
  final bool required;
  final void Function(MyGroupMembership) onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (memberships.isEmpty) {
      return Text(
        required
            ? 'You must lead a group before posting announcements.'
            : 'Optional: post on behalf of a group you lead.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      );
    }

    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: selectedId ?? memberships.first.group.groupId,
      decoration: InputDecoration(
        labelText: required ? 'On behalf of' : 'Group (optional)',
        prefixIcon: const Icon(Icons.groups_outlined),
      ),
      items: memberships
          .map(
            (m) => DropdownMenuItem(
              value: m.group.groupId,
              child: Text(
                m.group.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (id) {
        final match =
            memberships.where((m) => m.group.groupId == id).firstOrNull;
        if (match != null) onSelected(match);
      },
    );
  }
}
