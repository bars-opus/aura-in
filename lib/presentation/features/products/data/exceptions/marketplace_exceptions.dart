// Marketplace domain exceptions. Mirrors the wallet feature's exception
// pattern so error boundaries throughout the app can pattern-match on
// concrete types instead of stringly-typed AuthException.

abstract class MarketplaceException implements Exception {
  final String message;
  final String? code;

  MarketplaceException(this.message, {this.code});

  @override
  String toString() =>
      '$runtimeType: $message${code != null ? ' (code: $code)' : ''}';
}

// ── Product ──────────────────────────────────────────────────
class ProductException extends MarketplaceException {
  ProductException(super.message, {super.code});
}

class ProductNotFoundException extends ProductException {
  ProductNotFoundException(String productId)
      : super('Product not found: $productId', code: 'product_not_found');
}

class ProductInactiveException extends ProductException {
  ProductInactiveException(String productId)
      : super('Product is no longer available: $productId',
            code: 'product_inactive');
}

class ProductImageUploadException extends ProductException {
  ProductImageUploadException(String detail)
      : super('Image upload failed: $detail', code: 'image_upload_failed');
}

// ── Order ────────────────────────────────────────────────────
class OrderException extends MarketplaceException {
  OrderException(super.message, {super.code});
}

class OrderNotFoundException extends OrderException {
  OrderNotFoundException(String orderId)
      : super('Order not found: $orderId', code: 'order_not_found');
}

class OutOfStockException extends OrderException {
  OutOfStockException(String productId, {int? requested, int? available})
      : super(
          'Insufficient stock for product $productId'
          '${requested != null ? ' (requested $requested, available ${available ?? 0})' : ''}',
          code: 'out_of_stock',
        );
}

class IllegalOrderTransitionException extends OrderException {
  IllegalOrderTransitionException(String from, String to)
      : super('Illegal order transition: $from → $to',
            code: 'illegal_transition');
}

class OrderUnauthorizedException extends OrderException {
  OrderUnauthorizedException()
      : super('You are not authorized to act on this order',
            code: 'unauthorized');
}

class TotalMismatchException extends OrderException {
  TotalMismatchException()
      : super('Order total mismatch — please refresh your cart',
            code: 'total_mismatch');
}

class RateLimitException extends OrderException {
  RateLimitException()
      : super('You\'re doing that too often — please slow down and try again',
            code: 'rate_limited');
}

// ── Review ───────────────────────────────────────────────────
class ProductReviewException extends MarketplaceException {
  ProductReviewException(super.message, {super.code});
}

class NotEligibleToReviewException extends ProductReviewException {
  NotEligibleToReviewException()
      : super('You can only review products from a delivered order',
            code: 'not_eligible');
}

// ── Cart ─────────────────────────────────────────────────────
class CartException extends MarketplaceException {
  CartException(super.message, {super.code});
}

class MultiShopCartException extends CartException {
  MultiShopCartException()
      : super('Your cart already contains items from another shop. '
            'Please complete or clear that order before adding new items.',
            code: 'multi_shop_cart');
}

// ── Dispute ──────────────────────────────────────────────────
class DisputeException extends MarketplaceException {
  DisputeException(super.message, {super.code});
}

// ── Generic ──────────────────────────────────────────────────
/// Maps an unknown exception (network, PostgrestException, etc.)
/// to a domain-typed MarketplaceException without leaking the
/// underlying Supabase types into the UI layer.
MarketplaceException mapToMarketplaceException(Object error, String context) {
  final raw = error.toString();
  // Heuristic mapping for known Postgres error patterns surfaced from RPCs.
  if (raw.contains('rate_limited') || raw.contains('53400')) {
    return RateLimitException();
  }
  if (raw.contains('out_of_stock') || raw.contains('insufficient stock')) {
    return OutOfStockException(_extractUuid(raw) ?? 'unknown');
  }
  if (raw.contains('not found') || raw.contains('P0002')) {
    return MarketplaceGenericException('$context: not found',
        code: 'not_found');
  }
  if (raw.contains('unauthorized') || raw.contains('42501')) {
    return OrderUnauthorizedException();
  }
  if (raw.contains('illegal transition')) {
    return IllegalOrderTransitionException('unknown', 'unknown');
  }
  if (raw.contains('total mismatch')) {
    return TotalMismatchException();
  }
  return MarketplaceGenericException('$context: $raw');
}

class MarketplaceGenericException extends MarketplaceException {
  MarketplaceGenericException(super.message, {super.code});
}

String? _extractUuid(String s) {
  final m = RegExp(
    r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}',
  ).firstMatch(s);
  return m?.group(0);
}
