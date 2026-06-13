import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/core/l10n/app_localizations_extension.dart';
import 'package:speakup_connect/features/reports/domain/entities/report_category_entity.dart';
import 'package:speakup_connect/features/reports/presentation/l10n/report_ui_l10n.dart';
import 'package:speakup_connect/features/reports/presentation/providers/report_provider.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/app_error_widget.dart';
import 'package:speakup_connect/shared/widgets/app_loading_indicator.dart';
import 'package:speakup_connect/shared/widgets/app_text_field.dart';

/// 3-step "Submit a Concern" wizard.
///
/// Step 1 — Choose Category + Fill Details
/// Step 2 — Attach Photos + Anonymous toggle
/// Step 3 — Review & Submit
class SubmitReportScreen extends ConsumerStatefulWidget {
  const SubmitReportScreen({super.key});

  @override
  ConsumerState<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends ConsumerState<SubmitReportScreen> {
  int _currentStep = 0;
  final _step1FormKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1280,
    );
    if (picked != null) {
      ref.read(submitReportFormProvider.notifier).addPhoto(picked.path);
    }
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final formState = ref.read(submitReportFormProvider);
    if (!formState.isStep1Valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.submitConcernStep1Incomplete)),
      );
      return;
    }

    final report = await ref.read(submitReportProvider.notifier).submit();
    if (report != null && mounted) {
      context.go(Routes.reportConfirmation, extra: report.referenceNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(submitReportFormProvider);
    final submitState = ref.watch(submitReportProvider);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    ref.listen(submitReportProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.submitConcernSubmissionFailed('${next.error}')),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.submitConcernTitle),
      ),
      body: Column(
        children: [
          _StepProgressIndicator(currentStep: _currentStep),
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _Step1CategoryDetails(
                  formKey: _step1FormKey,
                  titleController: _titleController,
                  descriptionController: _descriptionController,
                ),
                _Step2PhotosAnonymous(
                  onPickImage: _pickImage,
                ),
                _Step3Review(
                  titleController: _titleController,
                  descriptionController: _descriptionController,
                ),
              ],
            ),
          ),
          _WizardNavBar(
            currentStep: _currentStep,
            isLoading: submitState.isLoading,
            canProceedStep1: () {
              if (!_step1FormKey.currentState!.validate()) return false;
              ref.read(submitReportFormProvider.notifier)
                  .updateTitle(_titleController.text.trim());
              ref.read(submitReportFormProvider.notifier)
                  .updateDescription(_descriptionController.text.trim());
              return formState.categoryId != null &&
                  _titleController.text.trim().length >= 5 &&
                  _descriptionController.text.trim().length >= 10;
            },
            onNext: () => setState(() => _currentStep++),
            onBack: () => setState(() => _currentStep--),
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }
}

class _Step1CategoryDetails extends ConsumerWidget {
  const _Step1CategoryDetails({
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(reportCategoriesProvider);
    final formState = ref.watch(submitReportFormProvider);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.submitConcernCategoryPrompt,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            categoriesAsync.when(
              loading: () => const AppLoadingIndicator(),
              error: (e, _) => AppErrorWidget(
                message: l10n.submitConcernLoadCategoriesFailed,
                onRetry: () => ref.invalidate(reportCategoriesProvider),
              ),
              data: (categories) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  final selected = formState.categoryId == cat.categoryId;
                  return FilterChip(
                    label: Text(
                      localizedReportCategoryLabel(
                        l10n,
                        cat.categoryId,
                        fallbackLabel: cat.label,
                      ),
                      style: TextStyle(
                        color: selected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    selected: selected,
                    selectedColor: theme.colorScheme.primary,
                    checkmarkColor: theme.colorScheme.onPrimary,
                    onSelected: (_) {
                      ref
                          .read(submitReportFormProvider.notifier)
                          .updateCategory(cat.categoryId);
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(
              controller: titleController,
              label: l10n.commonTitle,
              hint: l10n.submitConcernTitleHint,
              prefixIcon: Icons.title_rounded,
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().length < 5) {
                  return l10n.submitConcernTitleMinLength;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: descriptionController,
              label: l10n.submitConcernDescriptionLabel,
              hint: l10n.submitConcernDescriptionHint,
              prefixIcon: Icons.description_outlined,
              maxLines: 5,
              validator: (v) {
                if (v == null || v.trim().length < 10) {
                  return l10n.submitConcernDescriptionMinLength;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Step2PhotosAnonymous extends ConsumerWidget {
  const _Step2PhotosAnonymous({required this.onPickImage});

  final Future<void> Function(ImageSource) onPickImage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(submitReportFormProvider);
    final notifier = ref.read(submitReportFormProvider.notifier);
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final canAddMore = formState.photoPaths.length < AppConstants.maxPhotosPerReport;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.submitConcernPhotosTitle,
            style: theme.textTheme.titleMedium,
          ),
          Text(
            l10n.submitConcernPhotosLimit(AppConstants.maxPhotosPerReport),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...formState.photoPaths.asMap().entries.map((e) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(e.value),
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => notifier.removePhoto(e.key),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              if (canAddMore)
                GestureDetector(
                  onTap: () => _showImageSourceSheet(context),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            value: formState.isAnonymous,
            onChanged: (v) => notifier.updateIsAnonymous(v),
            title: Text(l10n.submitConcernAnonymousTitle),
            subtitle: Text(l10n.submitConcernAnonymousSubtitle),
            secondary: const Icon(Icons.visibility_off_outlined),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context) {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.submitConcernTakePhoto),
              onTap: () {
                Navigator.pop(context);
                onPickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.submitConcernChooseGallery),
              onTap: () {
                Navigator.pop(context);
                onPickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Step3Review extends ConsumerWidget {
  const _Step3Review({
    required this.titleController,
    required this.descriptionController,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(submitReportFormProvider);
    final categoriesAsync = ref.watch(reportCategoriesProvider);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final category = categoriesAsync.value?.firstWhere(
      (c) => c.categoryId == formState.categoryId,
      orElse: () => const ReportCategoryEntity(
        categoryId: '',
        label: '',
        iconName: 'report',
        sortOrder: 0,
      ),
    );
    final resolvedCategory =
        (category == null || category.categoryId.isEmpty)
            ? l10n.commonUnknown
            : localizedReportCategoryLabel(
                l10n,
                category.categoryId,
                fallbackLabel: category.label,
              );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.submitConcernReviewTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          _ReviewRow(label: l10n.submitConcernReviewCategory, value: resolvedCategory),
          _ReviewRow(label: l10n.commonTitle, value: titleController.text),
          _ReviewRow(
            label: l10n.commonDescription,
            value: descriptionController.text,
          ),
          _ReviewRow(
            label: l10n.submitConcernReviewPhotos,
            value: l10n.submitConcernPhotosAttached(formState.photoPaths.length),
          ),
          _ReviewRow(
            label: l10n.submitConcernReviewSubmittedAs,
            value: formState.isAnonymous
                ? l10n.settingsAnonymous
                : l10n.commonSignedIn,
          ),
          if (formState.isAnonymous)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: theme.colorScheme.secondary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.submitConcernReviewAnonymousWarning,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _StepProgressIndicator extends StatelessWidget {
  const _StepProgressIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final labels = [
      l10n.submitConcernStepDetails,
      l10n.submitConcernStepPhotos,
      l10n.submitConcernStepReview,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(3, (i) {
          final isDone = i < currentStep;
          final isActive = i == currentStep;
          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Expanded(
                    child: Divider(
                      color: isDone
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                      thickness: 2,
                    ),
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isDone || isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                      child: isDone
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: isActive ? Colors.white : theme.colorScheme.onSurfaceVariant,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[i],
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                if (i < 2)
                  Expanded(
                    child: Divider(
                      color: i < currentStep
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                      thickness: 2,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _WizardNavBar extends StatelessWidget {
  const _WizardNavBar({
    required this.currentStep,
    required this.isLoading,
    required this.canProceedStep1,
    required this.onNext,
    required this.onBack,
    required this.onSubmit,
  });

  final int currentStep;
  final bool isLoading;
  final bool Function() canProceedStep1;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: AppButton.secondary(
                label: l10n.commonBack,
                onPressed: onBack,
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: currentStep < 2
                ? AppButton.primary(
                    label: l10n.commonNext,
                    onPressed: () {
                      if (currentStep == 0 && !canProceedStep1()) return;
                      onNext();
                    },
                  )
                : AppButton.primary(
                    label: l10n.submitConcernSubmitButton,
                    onPressed: onSubmit,
                    isLoading: isLoading,
                  ),
          ),
        ],
      ),
    );
  }
}
