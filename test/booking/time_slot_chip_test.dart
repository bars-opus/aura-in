// test/booking/time_slot_chip_test.dart
//
// Phase 15 Wave 6.4 — widget tests for the _AdjustmentBadge on the
// TimeSlotChip.
//
// Five contracts:
//   (a) basePrice == null → no chip
//   (b) basePrice == price → no chip
//   (c) price < basePrice → "Discount" chip
//   (d) price > basePrice → "Surcharge" chip
//   (e) effective price text displays `price` (what the client will pay)

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/models/time_slot_model.dart';
import 'package:nano_embryo/presentation/features/shops/booking/presentation/widgets/time_slot/time_slot_chip.dart';

TimeSlotModel _slot({
  required int priceMinor,
  int? basePriceMinor,
}) {
  final start = DateTime(2026, 6, 11, 9, 0);
  final end = DateTime(2026, 6, 11, 10, 0);
  return TimeSlotModel(
    startTime: start,
    endTime: end,
    slotId: 'slot-a',
    serviceName: 'Haircut',
    actualEndTime: end,
    priceMinor: priceMinor,
    basePriceMinor: basePriceMinor,
    availableWorkers: const [],
    requiresWorkerSelection: false,
    bufferMinutes: 0,
  );
}

Widget _harness({required TimeSlotModel slot}) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) => ProviderScope(
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: TimeSlotChip(
            slot: slot,
            isSelected: false,
            onTap: () {},
            dayPeriod: 'Morning',
            currency: 'GHS',
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('(a) basePrice == null → no Discount/Surcharge chip',
      (tester) async {
    await tester.pumpWidget(_harness(slot: _slot(priceMinor: 5000)));
    await tester.pumpAndSettle();

    expect(find.text('Discount'), findsNothing);
    expect(find.text('Surcharge'), findsNothing);
  });

  testWidgets('(b) basePrice == price → no Discount/Surcharge chip',
      (tester) async {
    await tester.pumpWidget(_harness(slot: _slot(priceMinor: 5000, basePriceMinor: 5000)));
    await tester.pumpAndSettle();

    expect(find.text('Discount'), findsNothing);
    expect(find.text('Surcharge'), findsNothing);
  });

  testWidgets('(c) price < basePrice → Discount chip', (tester) async {
    await tester.pumpWidget(_harness(slot: _slot(priceMinor: 4000, basePriceMinor: 5000)));
    await tester.pumpAndSettle();

    expect(find.text('Discount'), findsOneWidget);
    expect(find.text('Surcharge'), findsNothing);
  });

  testWidgets('(d) price > basePrice → Surcharge chip', (tester) async {
    await tester.pumpWidget(_harness(slot: _slot(priceMinor: 6000, basePriceMinor: 5000)));
    await tester.pumpAndSettle();

    expect(find.text('Surcharge'), findsOneWidget);
    expect(find.text('Discount'), findsNothing);
  });

  testWidgets('(e) visible price reflects effective `price`, not basePrice',
      (tester) async {
    await tester.pumpWidget(_harness(slot: _slot(priceMinor: 4000, basePriceMinor: 5000)));
    await tester.pumpAndSettle();

    // Effective price text the client sees:
    expect(find.text('GHS 40.00'), findsOneWidget);
    // Base price string must NOT be rendered:
    expect(find.text('GHS 50.00'), findsNothing);
  });
}
