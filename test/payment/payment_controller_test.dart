import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nano_embryo/payment/config/payment_config.dart';
import 'package:nano_embryo/payment/presentation/controllers/payment_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================================================
// Mocks
// ============================================================================

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _MockFunctionsClient extends Mock implements FunctionsClient {}

class _MockFunctionResponse extends Mock implements FunctionResponse {}

class _MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class _MockPostgrestFilterBuilder<T> extends Mock
    implements PostgrestFilterBuilder<T> {}

class _MockPostgrestTransformBuilder<T> extends Mock
    implements PostgrestTransformBuilder<T> {}

// ============================================================================
// Helpers
// ============================================================================

PaymentConfig _testConfig({
  Future<void> Function(PaymentSuccessInfo)? onSuccess,
  Future<void> Function(PaymentErrorInfo)? onFailure,
}) =>
    PaymentConfig(
      appScheme: 'test',
      brandName: 'Test',
      defaultCurrency: 'GHS',
      dbConfirmAttemptsAfterWebViewSuccess: 1,
      dbConfirmAttemptsAfterWebViewCancel: 1,
      dbConfirmInterval: const Duration(milliseconds: 1),
      onPaymentSuccess: onSuccess,
      onPaymentFailure: onFailure,
    );

/// Build a stubbed FunctionResponse whose `.data` getter returns `body`.
_MockFunctionResponse _mockResponse(Map<String, dynamic>? body) {
  final resp = _MockFunctionResponse();
  when(() => resp.data).thenReturn(body);
  return resp;
}

/// Stub the create-booking + verify-payment edge function chain.
/// `createBookingBody`: response body for the first invoke (create-booking).
/// `verifyPaymentBody`: response body for any subsequent invoke (verify-payment).
/// `throws`: if non-null, the first invoke throws this object.
void _stubFunctions(
  _MockSupabaseClient client,
  _MockFunctionsClient functions, {
  Map<String, dynamic>? createBookingBody,
  Map<String, dynamic>? verifyPaymentBody,
  Object? throws,
}) {
  when(() => client.functions).thenReturn(functions);
  if (throws != null) {
    when(() => functions.invoke(any(), body: any(named: 'body')))
        .thenThrow(throws);
    return;
  }

  // Pre-build response mocks outside the `thenAnswer` so we don't nest
  // `when(...)` calls inside a stub closure (mocktail forbids this).
  final createResp = _mockResponse(createBookingBody);
  final verifyResp = _mockResponse(verifyPaymentBody);

  // Track which invoke we're answering — first is create-booking, rest are verify.
  var callCount = 0;
  when(() => functions.invoke(any(), body: any(named: 'body')))
      .thenAnswer((_) async {
    final resp = callCount == 0 ? createResp : verifyResp;
    callCount++;
    return resp;
  });
}

/// Stub the `from('bookings').select('*').eq(...).maybeSingle()` chain.
void _stubBookingsPoll(
  _MockSupabaseClient client, {
  Map<String, dynamic>? returns,
}) {
  final table = _MockSupabaseQueryBuilder();
  final filter = _MockPostgrestFilterBuilder<PostgrestList>();
  final transform = _MockPostgrestTransformBuilder<PostgrestMap?>();
  // SupabaseQueryBuilder also extends Future via the postgrest hierarchy, so
  // use thenAnswer here as well.
  when(() => client.from('bookings')).thenAnswer((_) => table);
  // select() / eq() / maybeSingle() all return Future subtypes
  // (PostgrestFilterBuilder<T> extends PostgrestTransformBuilder<T> extends
  // Future<T>). mocktail forbids `thenReturn`-ing a Future, so use
  // `thenAnswer` even when we're returning a builder synchronously.
  when(() => table.select(any())).thenAnswer((_) => filter);
  when(() => filter.eq(any(), any())).thenAnswer((_) => filter);
  when(() => filter.maybeSingle()).thenAnswer((_) => transform);
  when(() => transform.then<dynamic>(
        any(),
        onError: any(named: 'onError'),
      )).thenAnswer((invocation) {
    final onValue = invocation.positionalArguments[0]
        as dynamic Function(PostgrestMap?);
    return Future.value(onValue(returns));
  });
}

/// Inject a fake WebViewLauncher that returns the given result.
WebViewLauncher _fakeLauncher(bool result) => ({
      required context,
      required authorizationUrl,
      required reference,
      required provider,
    }) async =>
        result;

/// Pump a minimal MaterialApp and return its BuildContext for processPayment.
Future<BuildContext> _materializeContext(WidgetTester tester) async {
  late BuildContext capturedContext;
  await tester.pumpWidget(MaterialApp(
    home: Builder(builder: (ctx) {
      capturedContext = ctx;
      return const SizedBox.shrink();
    }),
  ));
  return capturedContext;
}

/// Invoke processPayment with default args — only override what the test cares about.
Future<Map<String, dynamic>?> _runProcessPayment(
  PaymentController controller, {
  required BuildContext context,
  String paymentProvider = 'paystack',
}) {
  return controller.processPayment(
    shopId: 's',
    userId: 'u',
    userEmail: 'e@x.com',
    services: const [],
    startTime: DateTime(2026, 5, 21),
    endTime: DateTime(2026, 5, 21, 1),
    actualEndTime: DateTime(2026, 5, 21, 1),
    // Phase 17: int kobo. 50 GHS = 5000 kobo.
    totalAmountMinor: 5000,
    depositAmountMinor: 5000,
    platformFeeMinor: 0,
    paymentProvider: paymentProvider,
    context: context,
  );
}

// ============================================================================
// Tests
// ============================================================================

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  group('PaymentController.processPayment', () {
    testWidgets('1. happy path — DB poll returns booking', (tester) async {
      final ctx = await _materializeContext(tester);
      final supabase = _MockSupabaseClient();
      final functions = _MockFunctionsClient();
      _stubFunctions(supabase, functions, createBookingBody: {
        'success': true,
        'reference': 'ref_1',
        'authorizationUrl': 'https://checkout.paystack.com/x',
      });
      _stubBookingsPoll(supabase, returns: {
        'id': 'booking_1',
        'total_amount': 50.0,
        'payment_intent_id': 'ref_1',
      });

      PaymentSuccessInfo? captured;
      final controller = PaymentController(
        supabase,
        _testConfig(onSuccess: (info) async => captured = info),
        webViewLauncher: _fakeLauncher(true),
      );

      final result = await _runProcessPayment(controller, context: ctx);

      expect(result, isNotNull);
      expect(result!['id'], 'booking_1');
      expect(captured?.reference, 'ref_1');
      expect(captured?.amountMinor, 5000);
    });

    testWidgets('2. happy path via verify-payment fallback', (tester) async {
      final ctx = await _materializeContext(tester);
      final supabase = _MockSupabaseClient();
      final functions = _MockFunctionsClient();
      _stubFunctions(
        supabase,
        functions,
        createBookingBody: {
          'success': true,
          'reference': 'ref_2',
          'authorizationUrl': 'https://x',
        },
        verifyPaymentBody: {
          'success': true,
          'booking': {
            'id': 'booking_2',
            'total_amount': 50.0,
            'payment_intent_id': 'ref_2',
          },
        },
      );
      _stubBookingsPoll(supabase, returns: null); // DB poll finds nothing

      PaymentSuccessInfo? captured;
      final controller = PaymentController(
        supabase,
        _testConfig(onSuccess: (info) async => captured = info),
        webViewLauncher: _fakeLauncher(true),
      );

      final result = await _runProcessPayment(controller, context: ctx);

      expect(result, isNotNull);
      expect(result!['id'], 'booking_2');
      expect(captured?.reference, 'ref_2');
    });

    testWidgets('3. create-booking returns success=false → validation',
        (tester) async {
      final ctx = await _materializeContext(tester);
      final supabase = _MockSupabaseClient();
      final functions = _MockFunctionsClient();
      _stubFunctions(supabase, functions, createBookingBody: {
        'success': false,
        'error': 'invalid input data',
      });

      PaymentErrorInfo? captured;
      final controller = PaymentController(
        supabase,
        _testConfig(onFailure: (info) async => captured = info),
        webViewLauncher: _fakeLauncher(true),
      );

      final result = await _runProcessPayment(controller, context: ctx);

      expect(result, isNull);
      expect(captured?.category, PaymentErrorCategory.validation);
    });

    testWidgets('4. create-booking returns null body → serverError',
        (tester) async {
      final ctx = await _materializeContext(tester);
      final supabase = _MockSupabaseClient();
      final functions = _MockFunctionsClient();
      _stubFunctions(supabase, functions, createBookingBody: null);

      PaymentErrorInfo? captured;
      final controller = PaymentController(
        supabase,
        _testConfig(onFailure: (info) async => captured = info),
        webViewLauncher: _fakeLauncher(true),
      );

      final result = await _runProcessPayment(controller, context: ctx);

      expect(result, isNull);
      expect(captured?.category, PaymentErrorCategory.serverError);
    });

    testWidgets('5. create-booking missing reference → serverError',
        (tester) async {
      final ctx = await _materializeContext(tester);
      final supabase = _MockSupabaseClient();
      final functions = _MockFunctionsClient();
      _stubFunctions(supabase, functions, createBookingBody: {
        'success': true,
        'authorizationUrl': 'https://x',
        // reference deliberately missing
      });

      PaymentErrorInfo? captured;
      final controller = PaymentController(
        supabase,
        _testConfig(onFailure: (info) async => captured = info),
        webViewLauncher: _fakeLauncher(true),
      );

      final result = await _runProcessPayment(controller, context: ctx);

      expect(result, isNull);
      expect(captured?.category, PaymentErrorCategory.serverError);
    });

    testWidgets('6. WebView dismissed + verify-payment fails → cancelled',
        (tester) async {
      final ctx = await _materializeContext(tester);
      final supabase = _MockSupabaseClient();
      final functions = _MockFunctionsClient();
      _stubFunctions(
        supabase,
        functions,
        createBookingBody: {
          'success': true,
          'reference': 'ref_6',
          'authorizationUrl': 'https://x',
        },
        verifyPaymentBody: {'success': false},
      );
      _stubBookingsPoll(supabase, returns: null);

      PaymentErrorInfo? captured;
      final controller = PaymentController(
        supabase,
        _testConfig(onFailure: (info) async => captured = info),
        webViewLauncher: _fakeLauncher(false), // user dismissed
      );

      final result = await _runProcessPayment(controller, context: ctx);

      expect(result, isNull);
      expect(captured?.category, PaymentErrorCategory.cancelled);
    });

    testWidgets(
        '7. WebView success but DB + verify both timeout → network',
        (tester) async {
      final ctx = await _materializeContext(tester);
      final supabase = _MockSupabaseClient();
      final functions = _MockFunctionsClient();
      _stubFunctions(
        supabase,
        functions,
        createBookingBody: {
          'success': true,
          'reference': 'ref_7',
          'authorizationUrl': 'https://x',
        },
        verifyPaymentBody: {'success': false},
      );
      _stubBookingsPoll(supabase, returns: null);

      PaymentErrorInfo? captured;
      final controller = PaymentController(
        supabase,
        _testConfig(onFailure: (info) async => captured = info),
        webViewLauncher: _fakeLauncher(true), // user paid but confirmation stuck
      );

      final result = await _runProcessPayment(controller, context: ctx);

      expect(result, isNull);
      expect(captured?.category, PaymentErrorCategory.network);
    });

    testWidgets('8. exception thrown in catch block → unknown',
        (tester) async {
      final ctx = await _materializeContext(tester);
      final supabase = _MockSupabaseClient();
      final functions = _MockFunctionsClient();
      _stubFunctions(supabase, functions, throws: Exception('boom'));

      PaymentErrorInfo? captured;
      final controller = PaymentController(
        supabase,
        _testConfig(onFailure: (info) async => captured = info),
        webViewLauncher: _fakeLauncher(true),
      );

      final result = await _runProcessPayment(controller, context: ctx);

      expect(result, isNull);
      expect(captured?.category, PaymentErrorCategory.unknown);
    });
  });

  group('PaymentController.retryLast', () {
    testWidgets('9. retryLast no-op when no prior intent', (tester) async {
      final ctx = await _materializeContext(tester);
      final controller = PaymentController(
        _MockSupabaseClient(),
        _testConfig(),
      );
      final result = await controller.retryLast(ctx);
      expect(result, isNull);
    });
  });
}
