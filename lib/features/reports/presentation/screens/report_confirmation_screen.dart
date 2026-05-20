import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:speakup_connect/core/constants/route_constants.dart';
import 'package:speakup_connect/shared/widgets/app_button.dart';

/// Confirmation screen shown after a successful report submission.
///
/// Matches wireframe screen 5:
/// - Check icon in a coloured circle
/// - "Thank You!" heading
/// - Reference number (e.g., MONHS-2026-000001)
/// - Copy reference number button
/// - "Go to My Reports" primary button
/// - "Back to Home" secondary button
class ReportConfirmationScreen extends StatelessWidget {
  const ReportConfirmationScreen({super.key, this.referenceNumber});

  final String? referenceNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final refNum = referenceNumber ?? '—';

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    size: 56,
                    color: theme.colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Thank You!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your report has been submitted successfully. '
                  'We\'ll look into it and keep you posted.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 32),

                // Reference number card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Reference Number',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        refNum,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: refNum));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reference number copied!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text('Copy'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                AppButton.primary(
                  label: 'Go to My Reports',
                  onPressed: () => context.go(Routes.myReports),
                ),
                const SizedBox(height: 12),
                AppButton.text(
                  label: 'Back to Home',
                  onPressed: () => context.go(Routes.home),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
