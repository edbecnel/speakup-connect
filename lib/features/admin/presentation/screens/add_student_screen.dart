import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/utils/validators.dart';
import 'package:speakup_connect/features/organization/presentation/providers/organization_provider.dart';
import 'package:speakup_connect/features/organization/presentation/providers/roster_provider.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';
import 'package:speakup_connect/shared/widgets/app_text_field.dart';

/// Admin form to provision a student with ID-as-password login.
class AddStudentScreen extends ConsumerStatefulWidget {
  const AddStudentScreen({super.key});

  @override
  ConsumerState<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends ConsumerState<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  int? _gradeLevel;

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(provisionStudentProvider.notifier).provision(
          studentId: _studentIdController.text,
          fullName: _nameController.text,
          gradeLevel: _gradeLevel!,
          email: _emailController.text,
        );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added ${_nameController.text.trim()}. '
            'They can sign in with their student ID as the password.',
          ),
        ),
      );
      context.pop();
    } else {
      final error = ref.read(provisionStudentProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error?.toString() ?? 'Could not add student'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(provisionStudentProvider).isLoading;
    final gradeLevels = ref.watch(orgGradeLevelsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Creates a pre-approved account. The student signs in using '
              'their school ID in both fields until email auth is enabled.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _nameController,
              label: 'Full name',
              hint: 'e.g. Juan Dela Cruz',
              prefixIcon: Icons.person_outline,
              textInputAction: TextInputAction.next,
              autofocus: true,
              validator: (v) => Validators.required(v, fieldName: 'Full name'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _studentIdController,
              label: 'Student ID',
              hint: 'School-issued ID (min. 6 characters)',
              prefixIcon: Icons.badge_outlined,
              textInputAction: TextInputAction.next,
              validator: Validators.studentId,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _emailController,
              label: 'Email (optional)',
              hint: 'Contact email for future login',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validators.optionalEmail,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _gradeLevel,
              decoration: const InputDecoration(
                labelText: 'Grade',
                border: OutlineInputBorder(),
              ),
              items: gradeLevels
                  .map(
                    (g) => DropdownMenuItem(
                      value: g,
                      child: Text('Grade $g'),
                    ),
                  )
                  .toList(),
              onChanged: isLoading ? null : (v) => setState(() => _gradeLevel = v),
              validator: (v) =>
                  v == null ? 'Select a grade' : null,
            ),
            const SizedBox(height: 28),
            AppButton.primary(
              label: isLoading ? 'Adding…' : 'Add Student',
              onPressed: isLoading ? null : _submit,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
