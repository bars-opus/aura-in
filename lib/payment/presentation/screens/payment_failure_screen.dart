import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/payment/config/payment_config.dart';
import 'package:nano_embryo/payment/presentation/controllers/payment_controller.dart';

class PaymentFailureScreen extends ConsumerWidget {
  const PaymentFailureScreen({required this.info, super.key});

  final PaymentErrorInfo info;

  static const _copy = <PaymentErrorCategory, ({String title, String body})>{
    PaymentErrorCategory.cancelled: (
      title: 'Payment cancelled',
      body:
          "You cancelled this payment before it completed. You can try again whenever you're ready.",
    ),
    PaymentErrorCategory.declined: (
      title: 'Card declined',
      body:
          'Your card was declined. Try a different card, or contact your bank to authorize the payment.',
    ),
    PaymentErrorCategory.network: (
      title: 'Connection lost',
      body:
          "We couldn't reach the payment provider. Check your connection and try again.",
    ),
    PaymentErrorCategory.validation: (
      title: "Payment couldn't be processed",
      body:
          'There was a problem with the payment details. Please review and try again.',
    ),
    PaymentErrorCategory.serverError: (
      title: 'Provider error',
      body:
          'The payment provider returned an error. Please try again in a moment.',
    ),
    PaymentErrorCategory.unknown: (
      title: 'Something went wrong',
      body: "We weren't able to complete this payment. Please try again.",
    ),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = _copy[info.category] ?? _copy[PaymentErrorCategory.unknown]!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isCancelled = info.category == PaymentErrorCategory.cancelled;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Icon(Icons.error_outline, size: 64, color: cs.error),
              const SizedBox(height: 24),
              Text(
                copy.title,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                copy.body,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton(
                onPressed: isCancelled
                    ? () => Navigator.of(context).pop()
                    : () async {
                        Navigator.of(context).pop();
                        await ref
                            .read(paymentControllerProvider.notifier)
                            .retryLast(context);
                      },
                child: Text(isCancelled ? 'Back to booking' : 'Try again'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
