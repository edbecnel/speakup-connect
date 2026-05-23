import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speakup_connect/core/constants/app_constants.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/features/reports/domain/entities/report_category_entity.dart';
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
    // Guard: surface form-validation failures that would otherwise be silent.
    final formState = ref.read(submitReportFormProvider);
    if (!formState.isStep1Valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete Step 1: select a category, '
            'title (min 5 chars), and description (min 10 chars).',
          ),
        ),
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

    ref.listen(submitReportProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: ${next.error}'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text('Submit a Concern'),
      ),
      body: Column(
        children: [
          // --- Step Progress Indicator ---
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

          // --- Nav Buttons ---
          _WizardNavBar(
            currentStep: _currentStep,
            isLoading: submitState.isLoading,
            canProceedStep1: () {
              if (!_step1FormKey.currentState!.validate()) return false;
              // sync title/description into provider
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

// --- Step 1: Category & Details ---

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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What type of concern is this?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            // Category chips
            categoriesAsync.when(
              loading: () => const AppLoadingIndicator(),
              error: (e, _) => AppErrorWidget(
                message: 'Failed to load categories',
                onRetry: () => ref.invalidate(reportCategoriesProvider),
              ),
              data: (categories) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  final selected = formState.categoryId == cat.categoryId;
                  return FilterChip(
                    label: Text(cat.label),
                    selected: selected,
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
              label: 'Title',
              hint: 'Brief summary of your concern (min 5 characters)',
              prefixIcon: Icons.title_rounded,
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().length < 5) {
                  return 'Title must be at least 5 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: descriptionController,
              label: 'Description',
              hint: 'Describe the concern in detail (min 10 characters)',
              prefixIcon: Icons.description_outlined,
              maxLines: 5,
              validator: (v) {
                if (v == null || v.trim().length < 10) {
                  return 'Description must be at least 10 characters';
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

// --- Step 2: Photos & Anonymous ---

class _Step2PhotosAnonymous extends ConsumerWidget {
  const _Step2PhotosAnonymous({required this.onPickImage});

  final Future<void> Function(ImageSource) onPickImage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(submitReportFormProvider);
    final notifier = ref.read(submitReportFormProvider.notifier);
    final theme = Theme.of(context);
    final canAddMore = formState.photoPaths.length < AppConstants.maxPhotosPerReport;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attach Photos (optional)',
            style: theme.textTheme.titleMedium,
          ),
          Text(
            'Up to ${AppConstants.maxPhotosPerReport} photos',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),

          // Photo previews
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

          // Anonymous toggle
          SwitchListTile.adaptive(
            value: formState.isAnonymous,
            onChanged: (v) => notifier.updateIsAnonymous(v),
            title: const Text('Submit Anonymously'),
            subtitle: const Text(
              'Your name and account will not be linked to this report.',
            ),
            secondary: const Icon(Icons.visibility_off_outlined),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                onPickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
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

// --- Step 3: Review ---

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

    final categoryLabel = categoriesAsync.value
        ?.firstWhere(
          (c) => c.categoryId == formState.categoryId,
          orElse: () => const ReportCategoryEntity(
            categoryId: '',
            label: 'Unknown',
            iconName: 'report',
            sortOrder: 0,
          ),
        )
        .label ?? '—';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review Your Report', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          _ReviewRow(label: 'Category', value: categoryLabel),
          _ReviewRow(label: 'Title', value: titleController.text),
          _ReviewRow(label: 'Description', value: descriptionController.text),
          _ReviewRow(label: 'Photos', value: '${formState.photoPaths.length} attached'),
          _ReviewRow(
            label: 'Submitted As',
            value: formState.isAnonymous ? 'Anonymous' : 'Signed In',
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
                      'Anonymous reports cannot be tracked. Save your reference number.',
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

// --- Step Progress Indicator ---

class _StepProgressIndicator extends StatelessWidget {
  const _StepProgressIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const labels = ['Details', 'Photos', 'Review'];

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

// --- Wizard Nav Bar ---

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: AppButton.secondary(
                label: 'Back',
                onPressed: onBack,
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: currentStep < 2
                ? AppButton.primary(
                    label: 'Next',
                    onPressed: () {
                      if (currentStep == 0 && !canProceedStep1()) return;
                      onNext();
                    },
                  )
                : AppButton.primary(
                    label: 'Submit Report',
                    onPressed: onSubmit,
                    isLoading: isLoading,
                  ),
          ),
        ],
      ),
    );
  }
}

