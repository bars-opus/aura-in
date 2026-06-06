// test/dashboard/client_sticky_note_card_test.dart
//
// Widget tests for ClientStickyNoteCard (Phase 12 Task 4.5). Strategy:
//  - Stub DashboardRepository via a ProviderScope override.
//  - Pump the card inside a minimal MaterialApp; we don't need
//    ScreenUtilInit because the widget doesn't rely on .h/.w units.
//  - Assert behavior across the documented states without snapshot
//    infra.
//
// Six contracts under test (matches Task 4.5 acceptance criteria):
//  (a) on first load, Save is disabled (body matches server state)
//  (b) typing in the field enables Save
//  (c) tapping Save calls repo.upsertClientNote exactly once with the
//      right (shopId, userId, body) tuple
//  (d) on save success, Save re-disables (text now matches new
//      _initialBody)
//  (e) on save error, Snackbar.error shows userMessage (we assert by
//      finding the message text after pump)
//  (f) char counter / 2000 cap is enforced by the formatter (typed
//      input longer than 2000 chars is truncated)
//
// Plus a guard:
//  (g) for guest bookings (userId.isEmpty), the card renders nothing
//      (BookingModel doesn't yet surface guestProfileId; this is the
//      Phase 12 scope cut documented in the widget header).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/models/booking_model.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/client_notes_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/client_note_dto.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/repositories/dashboard_repository.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/presentation/widgets/client_sticky_note_card.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';

class _MockDashboardRepository extends Mock implements DashboardRepository {}

BookingModel _fixtureBooking({
  String userId = 'user-a',
  String shopId = 'shop-a',
}) {
  final now = DateTime(2026, 6, 6, 12, 0);
  return BookingModel(
    id: 'booking-a',
    userId: userId,
    shopId: shopId,
    bookingDate: now,
    startTime: now,
    endTime: now.add(const Duration(hours: 1)),
    actualEndTime: now.add(const Duration(hours: 1)),
    status: BookingStatus.confirmed,
    totalAmount: 100,
    depositAmount: 0,
    paymentStatus: PaymentStatus.paid,
    createdAt: now,
    updatedAt: now,
    shopAddress: '',
  );
}

ClientNoteDTO? _existingNote(String body) => ClientNoteDTO(
      id: 'note-a',
      shopId: 'shop-a',
      userId: 'user-a',
      guestProfileId: null,
      body: body,
      updatedAt: DateTime(2026, 6, 1),
      updatedByUserId: 'owner-a',
    );

Widget _harness(DashboardRepository repo, {BookingModel? booking}) {
  // ScreenUtilInit is required because the Snackbar helper used by the
  // widget reads .r / .h / .w from flutter_screenutil at runtime; the
  // real app boots through ScreenUtilInit and any test calling
  // Snackbar.* without it will throw a LateInitializationError.
  //
  // SingleChildScrollView absorbs the overflow caused by the multi-line
  // TextField in the small test viewport.
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) => ProviderScope(
      overrides: [
        dashboardRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ClientStickyNoteCard(booking: booking ?? _fixtureBooking()),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  testWidgets(
    '(a) on first load, Save is disabled when body matches server state',
    (tester) async {
      final repo = _MockDashboardRepository();
      when(() => repo.getClientNote(
            shopId: any(named: 'shopId'),
            userId: any(named: 'userId'),
            guestProfileId: any(named: 'guestProfileId'),
          )).thenAnswer((_) async => _existingNote('existing note'));

      await tester.pumpWidget(_harness(repo));
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(FilledButton, 'Save');
      expect(saveButton, findsOneWidget);
      expect(tester.widget<FilledButton>(saveButton).onPressed, isNull);
    },
  );

  testWidgets('(b) typing in the field enables Save', (tester) async {
    final repo = _MockDashboardRepository();
    when(() => repo.getClientNote(
          shopId: any(named: 'shopId'),
          userId: any(named: 'userId'),
          guestProfileId: any(named: 'guestProfileId'),
        )).thenAnswer((_) async => _existingNote('initial'));

    await tester.pumpWidget(_harness(repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'initial + change');
    await tester.pump();

    final saveButton = find.widgetWithText(FilledButton, 'Save');
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNotNull);
  });

  testWidgets(
    '(c)+(d) tapping Save calls repo once and re-disables on success',
    (tester) async {
      final repo = _MockDashboardRepository();
      when(() => repo.getClientNote(
            shopId: any(named: 'shopId'),
            userId: any(named: 'userId'),
            guestProfileId: any(named: 'guestProfileId'),
          )).thenAnswer((_) async => _existingNote('initial'));
      when(() => repo.upsertClientNote(
            shopId: any(named: 'shopId'),
            userId: any(named: 'userId'),
            guestProfileId: any(named: 'guestProfileId'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => 'note-a');

      await tester.pumpWidget(_harness(repo));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'new body');
      await tester.pump();

      final saveButton = find.widgetWithText(FilledButton, 'Save');
      expect(tester.widget<FilledButton>(saveButton).onPressed, isNotNull);

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      verify(() => repo.upsertClientNote(
            shopId: 'shop-a',
            userId: 'user-a',
            guestProfileId: null,
            body: 'new body',
          )).called(1);

      // After save success, _initialBody now equals 'new body' so
      // Save should be disabled again (no diff).
      expect(tester.widget<FilledButton>(saveButton).onPressed, isNull);
    },
  );

  testWidgets('(e) on save error, Snackbar.error shows userMessage',
      (tester) async {
    final repo = _MockDashboardRepository();
    when(() => repo.getClientNote(
          shopId: any(named: 'shopId'),
          userId: any(named: 'userId'),
          guestProfileId: any(named: 'guestProfileId'),
        )).thenAnswer((_) async => _existingNote('initial'));
    when(() => repo.upsertClientNote(
          shopId: any(named: 'shopId'),
          userId: any(named: 'userId'),
          guestProfileId: any(named: 'guestProfileId'),
          body: any(named: 'body'),
        )).thenThrow(NoteTooLongException());

    await tester.pumpWidget(_harness(repo));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'new body');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pump(); // schedule the snackbar
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text(NoteTooLongException().userMessage),
      findsOneWidget,
    );
  });

  testWidgets('(f) max length enforced — pasted overlong text is truncated',
      (tester) async {
    final repo = _MockDashboardRepository();
    when(() => repo.getClientNote(
          shopId: any(named: 'shopId'),
          userId: any(named: 'userId'),
          guestProfileId: any(named: 'guestProfileId'),
        )).thenAnswer((_) async => _existingNote(''));

    await tester.pumpWidget(_harness(repo));
    await tester.pumpAndSettle();

    final huge = 'x' * 3000;
    await tester.enterText(find.byType(TextField), huge);
    await tester.pump();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller!.text.length, 2000);
  });

  testWidgets('(g) guest booking (empty userId) renders nothing',
      (tester) async {
    final repo = _MockDashboardRepository();
    // No stubs needed — getClientNote should never be called.

    await tester.pumpWidget(
      _harness(repo, booking: _fixtureBooking(userId: '')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(find.text('Private note about this client'), findsNothing);
    verifyNever(() => repo.getClientNote(
          shopId: any(named: 'shopId'),
          userId: any(named: 'userId'),
          guestProfileId: any(named: 'guestProfileId'),
        ));
  });
}
