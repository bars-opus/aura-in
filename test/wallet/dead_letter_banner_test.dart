import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/wallet/data/models/withdrawal_request_model.dart';
import 'package:nano_embryo/wallet/presentation/widgets/dead_letter_banner.dart';
import 'package:nano_embryo/wallet/providers/dead_letter_withdrawals_provider.dart';

WithdrawalRequestModel _wd(String id, double amount) {
  final now = DateTime(2026, 5, 18, 10, 30);
  return WithdrawalRequestModel(
    id: id,
    shopId: 'shop_1',
    amount: amount,
    status: WithdrawalStatus.failed,
    paymentProvider: 'paystack',
    transferRecipientId: 'recipient_1',
    idempotencyKey: 'idem_$id',
    deadLetterReason: 'exhausted 5 retries: connection timeout',
    feeAmount: 0,
    netAmount: amount,
    createdAt: now,
    updatedAt: now,
  );
}

Widget _wrap(Stream<List<WithdrawalRequestModel>> stream) => ProviderScope(
      overrides: [
        deadLetterWithdrawalsProvider('shop_1').overrideWith((_) => stream),
      ],
      child: const MaterialApp(
        home: Scaffold(body: DeadLetterBanner(shopId: 'shop_1')),
      ),
    );

void main() {
  group('DeadLetterBanner', () {
    testWidgets('renders nothing when stream emits empty list',
        (tester) async {
      await tester.pumpWidget(_wrap(Stream.value(const [])));
      await tester.pump();
      expect(find.textContaining('needs review'), findsNothing);
    });

    testWidgets('renders banner when stream emits non-empty list',
        (tester) async {
      await tester.pumpWidget(_wrap(Stream.value([_wd('w1', 250.0)])));
      await tester.pump();
      expect(find.text('Withdrawal needs review'), findsOneWidget);
      expect(find.textContaining('250.00'), findsOneWidget);
    });

    testWidgets('expands to show withdrawal details on tap', (tester) async {
      await tester.pumpWidget(_wrap(Stream.value([_wd('w1', 250.0)])));
      await tester.pump();
      expect(find.text('Contact support'), findsNothing);
      await tester.tap(find.text('Withdrawal needs review'));
      await tester.pump();
      expect(find.text('Contact support'), findsOneWidget);
      expect(find.textContaining('exhausted 5 retries'), findsOneWidget);
    });
  });
}
