// test/booking/client_promo_code_field_test.dart
//
// Phase 13 — widget tests for ClientPromoCodeField. Strategy mirrors
// Phase 12's client_sticky_note_card_test.dart:
//   * Stub PromotionsRepository via a ProviderScope override.
//   * Wrap in ScreenUtilInit because the Snackbar helper used inside
//     the error path reads .r from flutter_screenutil.
//   * Pump inside a SingleChildScrollView to absorb test-viewport
//     overflow on the input row.
//
// Six contracts under test:
//   (a) on mount, validateAndApplyPromo(p_code=NULL) is called and a
//       returned silent code surfaces the applied state
//   (b) when no silent code matches, the field renders the default
//       text input + Apply button (no applied state)
//   (c) manual Apply with a valid code replaces auto-applied state
//       and calls onApplied with the new PromoValidation
//   (d) PromotionLimitReachedException surfaces a Snackbar without
//       updating onApplied
//   (e) the displayed line-item shows the source-keyed label
//       ("Loyalty reward" for source=loyalty, etc.)
//   (f) the X clears the applied state and fires onApplied(null)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/widgets/client_promo_code_field.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/promotion_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/promotion_model.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/promotions_repository.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';

class _MockRepo extends Mock implements PromotionsRepository {}

PromoValidation _validation({
  String id = 'promo-1',
  String code = 'SUMMER10',
  // Phase 17: int kobo. 10 GHS = 1000 kobo; 90 GHS = 9000 kobo.
  int amountOffMinor = 1000,
  int newTotalMinor = 9000,
  PromoSource source = PromoSource.ownerDefined,
}) =>
    PromoValidation(
      promotionId: id,
      code: code,
      amountOffMinor: amountOffMinor,
      newTotalMinor: newTotalMinor,
      source: source,
    );

Widget _harness({
  required PromotionsRepository repo,
  required ValueChanged<AppliedPromo?> onApplied,
  String? userId = 'user-a',
  String? guestProfileId,
  double bookingTotal = 100,
}) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) => ProviderScope(
      overrides: [
        promotionsRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ClientPromoCodeField(
              shopId: 'shop-a',
              userId: userId,
              guestProfileId: guestProfileId,
              bookingTotal: bookingTotal,
              onApplied: onApplied,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(<String>[]);
  });

  testWidgets('(a) auto-applies silent code on mount', (tester) async {
    final repo = _MockRepo();
    AppliedPromo? captured;
    when(() => repo.validateAndApplyPromo(
          shopId: any(named: 'shopId'),
          code: any(named: 'code'),
          userId: any(named: 'userId'),
          guestProfileId: any(named: 'guestProfileId'),
          bookingTotal: any(named: 'bookingTotal'),
          serviceIds: any(named: 'serviceIds'),
        )).thenAnswer((_) async => _validation(
          id: 'loyal-1',
          code: 'LOYAL-XYZ',
          amountOffMinor: 1500,
          newTotalMinor: 8500,
          source: PromoSource.loyalty,
        ));

    await tester.pumpWidget(_harness(repo: repo, onApplied: (p) => captured = p));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.code, 'LOYAL-XYZ');
    expect(captured!.source, PromoSource.loyalty);
    expect(find.text('Loyalty reward'), findsOneWidget);
  });

  testWidgets('(b) no silent code → renders default text field',
      (tester) async {
    final repo = _MockRepo();
    when(() => repo.validateAndApplyPromo(
          shopId: any(named: 'shopId'),
          code: any(named: 'code'),
          userId: any(named: 'userId'),
          guestProfileId: any(named: 'guestProfileId'),
          bookingTotal: any(named: 'bookingTotal'),
          serviceIds: any(named: 'serviceIds'),
        )).thenAnswer((_) async => null);

    await tester.pumpWidget(_harness(repo: repo, onApplied: (_) {}));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Apply'), findsOneWidget);
  });

  testWidgets('(c) manual Apply with valid code fires onApplied',
      (tester) async {
    final repo = _MockRepo();
    AppliedPromo? captured;
    final autoApplyCompleter =
        Future<PromoValidation?>.value(null); // no silent code
    when(() => repo.validateAndApplyPromo(
          shopId: any(named: 'shopId'),
          code: null,
          userId: any(named: 'userId'),
          guestProfileId: any(named: 'guestProfileId'),
          bookingTotal: any(named: 'bookingTotal'),
          serviceIds: any(named: 'serviceIds'),
        )).thenAnswer((_) => autoApplyCompleter);
    when(() => repo.validateAndApplyPromo(
          shopId: any(named: 'shopId'),
          code: 'SUMMER10',
          userId: any(named: 'userId'),
          guestProfileId: any(named: 'guestProfileId'),
          bookingTotal: any(named: 'bookingTotal'),
          serviceIds: any(named: 'serviceIds'),
        )).thenAnswer((_) async => _validation());

    await tester.pumpWidget(_harness(repo: repo, onApplied: (p) => captured = p));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'SUMMER10');
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pumpAndSettle();

    expect(captured?.code, 'SUMMER10');
    expect(captured?.amountOffMinor, 1000);
    expect(find.text('Code: SUMMER10'), findsOneWidget);
  });

  testWidgets('(d) limit reached → Snackbar fires, onApplied NOT called',
      (tester) async {
    final repo = _MockRepo();
    int onAppliedCount = 0;
    when(() => repo.validateAndApplyPromo(
          shopId: any(named: 'shopId'),
          code: null,
          userId: any(named: 'userId'),
          guestProfileId: any(named: 'guestProfileId'),
          bookingTotal: any(named: 'bookingTotal'),
          serviceIds: any(named: 'serviceIds'),
        )).thenAnswer((_) async => null);
    when(() => repo.validateAndApplyPromo(
          shopId: any(named: 'shopId'),
          code: 'OVERUSED',
          userId: any(named: 'userId'),
          guestProfileId: any(named: 'guestProfileId'),
          bookingTotal: any(named: 'bookingTotal'),
          serviceIds: any(named: 'serviceIds'),
        )).thenThrow(PromotionLimitReachedException());

    await tester.pumpWidget(_harness(
      repo: repo,
      onApplied: (_) => onAppliedCount++,
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'OVERUSED');
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pump(); // schedule the snackbar
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text(PromotionLimitReachedException().userMessage),
      findsOneWidget,
    );
    expect(onAppliedCount, 0);
  });

  testWidgets('(e) source-keyed label — recovery shows "Welcome back"',
      (tester) async {
    final repo = _MockRepo();
    when(() => repo.validateAndApplyPromo(
          shopId: any(named: 'shopId'),
          code: any(named: 'code'),
          userId: any(named: 'userId'),
          guestProfileId: any(named: 'guestProfileId'),
          bookingTotal: any(named: 'bookingTotal'),
          serviceIds: any(named: 'serviceIds'),
        )).thenAnswer((_) async => _validation(
          source: PromoSource.recovery,
          code: 'RECOVER-ABC',
        ));

    await tester.pumpWidget(_harness(repo: repo, onApplied: (_) {}));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    // The code text is NOT shown for silent codes — only the friendly
    // source-keyed label.
    expect(find.text('Code: RECOVER-ABC'), findsNothing);
  });

  testWidgets('(f) X clears applied state and fires onApplied(null)',
      (tester) async {
    final repo = _MockRepo();
    final emissions = <AppliedPromo?>[];
    when(() => repo.validateAndApplyPromo(
          shopId: any(named: 'shopId'),
          code: any(named: 'code'),
          userId: any(named: 'userId'),
          guestProfileId: any(named: 'guestProfileId'),
          bookingTotal: any(named: 'bookingTotal'),
          serviceIds: any(named: 'serviceIds'),
        )).thenAnswer((_) async => _validation());

    await tester.pumpWidget(_harness(repo: repo, onApplied: emissions.add));
    await tester.pumpAndSettle();

    // Auto-applied → first emission non-null.
    expect(emissions.length, 1);
    expect(emissions.first, isNotNull);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(emissions.length, 2);
    expect(emissions.last, isNull);
    expect(find.byType(TextField), findsOneWidget); // back to default form
  });
}
