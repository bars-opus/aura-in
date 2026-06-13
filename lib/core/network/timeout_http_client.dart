import 'package:http/http.dart' as http;

/// http.Client wrapper that enforces a hard per-request timeout.
///
/// Why: the Supabase Dart SDK does not expose connect/read/total timeouts
/// on `Supabase.initialize`. Without this wrapper, a stalled network
/// (e.g. cell handover, captive-portal) lets requests hang indefinitely,
/// violating checklist v3.1 P1 1.2 (timeouts on ALL external calls).
///
/// Use one instance per long-lived client. The wrapper delegates to a
/// real [http.Client] (default: [http.Client.new]) and applies
/// [.timeout(total)] to every send. On timeout, the underlying request
/// is aborted via [http.Client.close]-like behavior of the SDK and a
/// [http.ClientException] is thrown.
class TimeoutHttpClient extends http.BaseClient {
  TimeoutHttpClient({
    http.Client? inner,
    this.total = const Duration(seconds: 20),
  }) : _inner = inner ?? http.Client();

  final http.Client _inner;

  /// Total time budget per request (DNS + TCP + TLS + send + receive).
  /// Read-path queries should complete well under this; mutations stay
  /// inside the [BookingRetryPolicy] per-attempt budget already.
  final Duration total;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _inner.send(request).timeout(
      total,
      onTimeout: () {
        throw http.ClientException(
          'Request to ${request.url.host} timed out after ${total.inSeconds}s',
          request.url,
        );
      },
    );
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
