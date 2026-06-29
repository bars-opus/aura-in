// lib/features/payment/presentation/widgets/payment_webview.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/payment/config/payment_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends ConsumerStatefulWidget {
  final String url;
  final String provider;
  final String reference;
  final Function(bool success) onComplete;

  const PaymentWebView({
    Key? key,
    required this.url,
    required this.provider,
    required this.reference,
    required this.onComplete,
  }) : super(key: key);

  @override
  ConsumerState<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends ConsumerState<PaymentWebView>
    with WidgetsBindingObserver {
  late final WebViewController _controller;
  late final PaymentConfig _config;

  bool _isLoading = true;
  bool _isComplete = false;
  bool _isVerifying = false;

  // Fast DB poll — checks bookings table at [PaymentConfig.dbPollInterval].
  Timer? _dbPollTimer;

  // Slow verify escalation — calls verify-payment edge fn at
  // [PaymentConfig.verifyEscalationInterval]. Started once in initState and
  // never reset, so it fires regardless of Paystack page navigations.
  Timer? _verifyTimer;

  // Realtime: detects booking row the moment the Paystack webhook fires,
  // giving <1s detection vs 4–60s for the polling paths.
  StreamSubscription<List<Map<String, dynamic>>>? _realtimeSubscription;

  late final String _successScheme;
  late final String _cancelScheme;
  late final String _failedScheme;
  late final String _appSchemePrefix;

  @override
  void initState() {
    super.initState();
    _config = ref.read(paymentConfigProvider);
    _successScheme = _config.successDeepLink.toLowerCase();
    _cancelScheme = _config.cancelDeepLink.toLowerCase();
    _failedScheme = _config.failedDeepLink.toLowerCase();
    _appSchemePrefix = '${_config.appScheme}://';

    WidgetsBinding.instance.addObserver(this);

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) {
                setState(() => _isLoading = true);
              },
              onPageFinished: (url) {
                if (_isComplete) return;
                setState(() {
                  _isLoading = false;
                });
                _startDbPolling();
              },
              onUrlChange: (change) {
                if (change.url == null) return;
                if (_isSuccessUrl(change.url!)) _handleSuccess();
                if (_isCancelUrl(change.url!)) _handleCancelled();
              },
              onNavigationRequest: (request) {
                if (request.url.toLowerCase().startsWith(_appSchemePrefix)) {
                  if (_isSuccessUrl(request.url)) {
                    _handleSuccess();
                  } else {
                    _handleCancelled();
                  }
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url));

    // Verify timer fires independently of page navigation.
    _verifyTimer = Timer.periodic(_config.verifyEscalationInterval, (_) {
      if (!_isComplete && !_isVerifying) _verifyPaymentDirectly();
    });

    // Realtime subscription — primary fast-path for async MoMo payments.
    _realtimeSubscription = Supabase.instance.client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('payment_intent_id', widget.reference)
        .listen(
      (rows) {
        if (!_isComplete && rows.any((r) => r['status'] == 'confirmed')) {
          _handleSuccess();
        }
      },
      onError: (_) {
        // DB poll and verify-payment timers serve as fallbacks on stream error.
      },
    );
  }

  // ── App lifecycle ───────────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isComplete) return;
    if (state == AppLifecycleState.resumed) {
      _checkBookingInDb();
      _startDbPolling();
      if (!_isVerifying) _verifyPaymentDirectly();
    } else if (state == AppLifecycleState.paused) {
      _dbPollTimer?.cancel();
    }
  }

  // ── DB polling (fast path — webhook already fired) ──────────────────────────

  void _startDbPolling() {
    _dbPollTimer?.cancel();
    _dbPollTimer = Timer.periodic(_config.dbPollInterval, (_) {
      if (_isComplete) {
        _dbPollTimer?.cancel();
        return;
      }
      _checkBookingInDb();
    });
  }

  Future<void> _checkBookingInDb() async {
    if (_isComplete) return;
    try {
      final result =
          await Supabase.instance.client
              .from('bookings')
              .select('id')
              .eq('payment_intent_id', widget.reference)
              .eq('status', 'confirmed')
              .maybeSingle();

      if (result != null) {
        _dbPollTimer?.cancel();
        _handleSuccess();
      }
    } catch (_) {
      // Poll will retry on next tick.
    }
  }

  // ── Verify escalation (slow path — webhook missed) ──────────────────────────

  Future<void> _verifyPaymentDirectly() async {
    if (_isComplete || _isVerifying) return;
    _isVerifying = true;

    try {
      final response = await Supabase.instance.client.functions.invoke(
        _config.verifyPaymentFunctionName,
        body: {'reference': widget.reference, 'provider': widget.provider},
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        _dbPollTimer?.cancel();
        _verifyTimer?.cancel();
        _handleSuccess();
      }
    } catch (_) {
      // Will retry on next timer tick.
    } finally {
      _isVerifying = false;
    }
  }

  // ── Outcome handlers ────────────────────────────────────────────────────────

  void _handleSuccess() {
    if (_isComplete) return;
    _isComplete = true;
    // Pop the WebView synchronously BEFORE notifying the controller. The
    // controller continues on the next microtask and pushes a success
    // BottomSheet onto the navigator — if that happens while we still hold
    // the top route, a deferred pop would pop the BottomSheet instead of us.
    if (mounted) Navigator.pop(context);
    widget.onComplete(true);
  }

  void _handleCancelled() {
    if (_isComplete) return;
    _isComplete = true;
    if (mounted) Navigator.pop(context);
    widget.onComplete(false);
  }

  bool _isSuccessUrl(String url) {
    final lower = url.toLowerCase();
    return lower.startsWith(_successScheme);
  }

  bool _isCancelUrl(String url) {
    final lower = url.toLowerCase();
    return lower.startsWith(_cancelScheme) || lower.startsWith(_failedScheme);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dbPollTimer?.cancel();
    _verifyTimer?.cancel();
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  // ── UI ───────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.provider == 'stripe' ? 'Stripe Checkout' : 'Paystack Payment',
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel payment',
          onPressed: () {
            if (!_isComplete) widget.onComplete(false);
            Navigator.pop(context);
          },
        ),
      ),
      // Stack keeps the loading spinner layered over the WebView. The old
      // _ConfirmingSheet overlay was removed — DB polling + realtime already
      // drive completion without a blocking sheet.
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularLoadingIndicator()),
        ],
      ),
    );
  }
}

