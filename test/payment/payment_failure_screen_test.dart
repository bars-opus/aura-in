import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/payment/config/payment_config.dart';
import 'package:nano_embryo/payment/presentation/screens/payment_failure_screen.dart';

void main() {
  group('PaymentFailureScreen', () {
    Widget wrap(PaymentErrorInfo info) => ProviderScope(
          child: MaterialApp(
            home: PaymentFailureScreen(info: info),
          ),
        );

    testWidgets('renders declined-card copy for declined category',
        (tester) async {
      await tester.pumpWidget(wrap(
        const PaymentErrorInfo(
          message: 'Card declined',
          category: PaymentErrorCategory.declined,
        ),
      ));
      expect(find.text('Card declined'), findsOneWidget);
      expect(find.textContaining('Try a different card'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('renders cancelled copy for cancelled category',
        (tester) async {
      await tester.pumpWidget(wrap(
        const PaymentErrorInfo(
          message: 'User cancelled',
          category: PaymentErrorCategory.cancelled,
        ),
      ));
      expect(find.text('Payment cancelled'), findsOneWidget);
    });

    testWidgets('renders network copy for network category', (tester) async {
      await tester.pumpWidget(wrap(
        const PaymentErrorInfo(
          message: 'Network error',
          category: PaymentErrorCategory.network,
        ),
      ));
      expect(find.text('Connection lost'), findsOneWidget);
    });

    testWidgets('falls back to unknown copy for unknown category',
        (tester) async {
      await tester.pumpWidget(wrap(
        const PaymentErrorInfo(
          message: 'Mystery',
          category: PaymentErrorCategory.unknown,
        ),
      ));
      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });
}
