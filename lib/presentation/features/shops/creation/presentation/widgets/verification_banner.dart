// lib/features/shop/presentation/widgets/verification_banner.dart
import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class VerificationBanner extends StatelessWidget {
  const VerificationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(Spacing.md.h),
      color: Colors.orange,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(Spacing.xs.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline,
                color: Colors.white,
              ),
            ),
            SizedBox(width: Spacing.sm.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pending Verification',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Your shop is under review. You can still make changes.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                // Show info dialog
                _showInfoDialog(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              child: const Text('Learn More'),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verification Process'),
        content: const Text(
          'Your shop has been submitted for verification. An admin will review your shop details and photos. '
          'This usually takes 1-2 business days. You\'ll be notified once your shop is approved.\n\n'
          'You can continue editing your shop while it\'s pending verification.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
