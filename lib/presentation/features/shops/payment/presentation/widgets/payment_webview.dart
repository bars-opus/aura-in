// lib/features/payment/presentation/widgets/payment_webview.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  final String url;
  final String provider;
  final Function(bool success) onComplete;

  const PaymentWebView({
    Key? key,
    required this.url,
    required this.provider,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isComplete = false;
  String? _currentUrl;
  Timer? _pollingTimer; // ADD
  String? _reference;

  @override
  void initState() {
    super.initState();

    // Extract reference from the URL to poll against
    _reference = Uri.parse(widget.url).queryParameters['reference']; // ADD

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) {
                setState(() => _isLoading = true);
                // Extract reference once Paystack loads (it's in the URL)
                final uri = Uri.tryParse(url); // ADD
                if (uri != null && _reference == null) {
                  // ADD
                  _reference =
                      uri.queryParameters['reference'] ?? // ADD
                      uri.queryParameters['trxref']; // ADD
                } // ADD
              },
              onPageFinished: (url) {
                setState(() => _isLoading = false);
                if (_isPaymentSuccessful(url)) _handlePaymentSuccess();
                if (_isPaymentCancelled(url)) _handlePaymentCancelled();
                _startPolling(); // ADD - start polling once page loads
              },
              onUrlChange: (change) {
                if (change.url == null) return;
                if (_isPaymentSuccessful(change.url!)) _handlePaymentSuccess();
                if (_isPaymentCancelled(change.url!)) _handlePaymentCancelled();
              },
              onNavigationRequest: (request) {
                if (request.url.startsWith('nanoembryo://')) {
                  if (request.url.contains('payment-success')) {
                    _handlePaymentSuccess();
                  } else {
                    _handlePaymentCancelled();
                  }
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url));
  }

  // ADD: Poll Supabase every 4 seconds to check if webhook confirmed payment
  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      if (_isComplete) {
        _pollingTimer?.cancel();
        return;
      }
      await _checkPaymentStatus();
    });
  }

  // ADD
  Future<void> _checkPaymentStatus() async {
    if (_reference == null) return;
    try {
      final supabase = Supabase.instance.client;
      final result =
          await supabase
              .from('pending_payments')
              .select('status')
              .eq('payment_intent_id', _reference!)
              .maybeSingle();

      if (result != null && result['status'] == 'completed') {
        _pollingTimer?.cancel();
        _handlePaymentSuccess();
      }
    } catch (e) {
      // Silently ignore polling errors
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); // ADD
    super.dispose();
  }

  bool _isPaymentSuccessful(String url) {
    final lowerUrl = url.toLowerCase();
    // Only match YOUR app's success URL, not Paystack's internal URLs
    return lowerUrl.startsWith('nanoembryo://payment-success');
  }

  bool _isPaymentCancelled(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.startsWith('nanoembryo://payment-cancelled') ||
        lowerUrl.startsWith('nanoembryo://payment-failed');
  }

  void _handlePaymentSuccess() {
    if (_isComplete) return;
    _isComplete = true;
    print('✅ Payment successful!');
    widget.onComplete(true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _handlePaymentCancelled() {
    if (_isComplete) return;
    _isComplete = true;
    print('❌ Payment cancelled or failed');
    widget.onComplete(false);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) Navigator.pop(context);
    });
  }

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
          onPressed: () {
            if (!_isComplete) {
              widget.onComplete(false);
            }
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
