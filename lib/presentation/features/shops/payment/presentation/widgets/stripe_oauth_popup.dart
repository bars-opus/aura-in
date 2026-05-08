// ============================================================================
// Stripe OAuth Popup
// ============================================================================

import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StripeOAuthPopup extends StatefulWidget {
  final String url;
  final VoidCallback onSuccess;
  final Function(String) onError;

  const StripeOAuthPopup({
    super.key,
    required this.url,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<StripeOAuthPopup> createState() => _StripeOAuthPopupState();
}

class _StripeOAuthPopupState extends State<StripeOAuthPopup> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (url) {
                setState(() => _isLoading = false);
              },
              onUrlChange: (change) {
                final url = change.url;
                if (url == null) return;

                final uri = Uri.tryParse(url);
                if (uri == null) return;

                // Only act on YOUR callback URL, not Stripe's internal pages
                final isCallback =
                    uri.host == 'yourapp.com' && uri.path == '/stripe/callback';

                if (isCallback) {
                  if (uri.queryParameters['success'] == 'true') {
                    widget.onSuccess();
                  } else {
                    final error =
                        uri.queryParameters['error'] ?? 'Unknown error';
                    widget.onError(error);
                  }
                }
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(Spacing.md.h),
      child: Container(
        width: 500.w,
        height: 600.h,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(Spacing.md.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Connect Stripe Account',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading)
                    const Center(child: CircularLoadingIndicator()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
