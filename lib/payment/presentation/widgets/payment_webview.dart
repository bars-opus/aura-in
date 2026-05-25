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

  late final String _successScheme;
  late final String _cancelScheme;
  late final String _failedScheme;
  late final String _appSchemePrefix;

  String get _logTag =>
      '[PW ref=${widget.reference.length >= 8 ? widget.reference.substring(0, 8) : widget.reference}]';

  @override
  void initState() {
    super.initState();
    _config = ref.read(paymentConfigProvider);
    _successScheme = _config.successDeepLink.toLowerCase();
    _cancelScheme = _config.cancelDeepLink.toLowerCase();
    _failedScheme = _config.failedDeepLink.toLowerCase();
    _appSchemePrefix = '${_config.appScheme}://';

    WidgetsBinding.instance.addObserver(this);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint('$_logTag onPageStarted $url');
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            debugPrint('$_logTag onPageFinished $url → _startDbPolling()');
            setState(() => _isLoading = false);
            _startDbPolling();
          },
          onUrlChange: (change) {
            debugPrint('$_logTag onUrlChange ${change.url}');
            if (change.url == null) return;
            if (_isSuccessUrl(change.url!)) _handleSuccess();
            if (_isCancelUrl(change.url!)) _handleCancelled();
          },
          onNavigationRequest: (request) {
            if (request.url.toLowerCase().startsWith(_appSchemePrefix)) {
              debugPrint(
                '$_logTag onNavigationRequest ${request.url} → decision=prevent',
              );
              if (_isSuccessUrl(request.url)) {
                _handleSuccess();
              } else {
                _handleCancelled();
              }
              return NavigationDecision.prevent;
            }
            debugPrint(
              '$_logTag onNavigationRequest ${request.url} → decision=navigate',
            );
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    // Verify timer fires independently of page navigation.
    _verifyTimer = Timer.periodic(_config.verifyEscalationInterval, (_) {
      if (!_isComplete && !_isVerifying) _verifyPaymentDirectly();
    });

    debugPrint(
      '$_logTag init provider=${widget.provider} url=${widget.url} '
      'scheme=$_appSchemePrefix dbPoll=${_config.dbPollInterval.inSeconds}s '
      'verifyEsc=${_config.verifyEscalationInterval.inSeconds}s',
    );
  }

  // ── App lifecycle ───────────────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('$_logTag lifecycle state=$state isComplete=$_isComplete');
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
      debugPrint('$_logTag dbPoll tick isComplete=$_isComplete');
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
      final result = await Supabase.instance.client
          .from('bookings')
          .select('id')
          .eq('payment_intent_id', widget.reference)
          .eq('status', 'confirmed')
          .maybeSingle();

      debugPrint(
        '$_logTag checkBookingInDb result=${result == null ? 'null' : 'found id=${result['id']}'}',
      );

      if (result != null) {
        _dbPollTimer?.cancel();
        _handleSuccess();
      }
    } catch (e) {
      debugPrint('$_logTag checkBookingInDb error=$e');
    }
  }

  // ── Verify escalation (slow path — webhook missed) ──────────────────────────

  Future<void> _verifyPaymentDirectly() async {
    if (_isComplete || _isVerifying) return;
    _isVerifying = true;

    try {
      debugPrint(
        '🔍 ${_config.verifyPaymentFunctionName}: checking ${widget.reference}',
      );
      final response = await Supabase.instance.client.functions.invoke(
        _config.verifyPaymentFunctionName,
        body: {'reference': widget.reference, 'provider': widget.provider},
      );

      final data = response.data;
      debugPrint(
        '$_logTag verifyPayment result=${data is Map ? (data['success'] == true ? 'success' : 'not confirmed') : 'non-map'}',
      );
      if (data is Map<String, dynamic> && data['success'] == true) {
        debugPrint(
          '✅ ${_config.verifyPaymentFunctionName} confirmed — closing WebView',
        );
        _dbPollTimer?.cancel();
        _verifyTimer?.cancel();
        _handleSuccess();
      }
    } catch (e) {
      debugPrint('$_logTag verifyPayment error=$e');
    } finally {
      _isVerifying = false;
    }
  }

  // ── Outcome handlers ────────────────────────────────────────────────────────

  void _handleSuccess() {
    if (_isComplete) return;
    debugPrint('$_logTag _handleSuccess ENTRY');
    _isComplete = true;
    widget.onComplete(true);
    Future.delayed(const Duration(milliseconds: 300), () {
      debugPrint(
        '$_logTag _handleSuccess 300ms elapsed mounted=$mounted → popping',
      );
      if (mounted) {
        Navigator.pop(context);
        debugPrint('$_logTag _handleSuccess post-pop');
      }
    });
  }

  void _handleCancelled() {
    if (_isComplete) return;
    debugPrint('$_logTag _handleCancelled ENTRY');
    _isComplete = true;
    widget.onComplete(false);
    Future.delayed(const Duration(milliseconds: 300), () {
      debugPrint(
        '$_logTag _handleCancelled 300ms elapsed mounted=$mounted → popping',
      );
      if (mounted) {
        Navigator.pop(context);
        debugPrint('$_logTag _handleCancelled post-pop');
      }
    });
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
    debugPrint('$_logTag dispose isComplete=$_isComplete');
    WidgetsBinding.instance.removeObserver(this);
    _dbPollTimer?.cancel();
    _verifyTimer?.cancel();
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
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularLoadingIndicator()),
        ],
      ),
    );
  }
}
