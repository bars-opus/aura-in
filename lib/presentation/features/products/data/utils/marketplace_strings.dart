/// Central registry of user-visible strings in the marketplace feature.
///
/// Two reasons this file exists:
///   1. Single source of truth — change "Add to Cart" once, not 5 times.
///   2. i18n on-ramp — when the project adopts `flutter_localizations`
///      / `intl_translation`, swap the bodies for `AppLocalizations.of(context).addToCart`
///      etc. The callsites don't change.
class MarketplaceStrings {
  MarketplaceStrings._();

  // Marketplace / browsing
  static const String marketplaceTitle = 'Marketplace';
  static const String browseProducts = 'Browse products';
  static const String noProductsFound = 'No products found';
  static const String clearFilters = 'Clear filters';

  // Product detail
  static const String addToCart = 'Add to Cart';
  static const String addingToCart = 'Adding...';
  static const String outOfStock = 'Out of stock';
  static const String unavailable = 'Unavailable';
  static const String onlyNLeft = 'Only %d left';
  static const String addedToCart = 'Added to cart';
  static const String viewCart = 'View Cart';
  static const String replaceCartTitle = 'Replace cart?';
  static const String replaceCartBody =
      'Your cart already contains items from another shop. '
      'Clear that cart and add this product instead?';
  static const String keepCart = 'Keep cart';
  static const String replace = 'Replace';

  // Cart / checkout
  static const String cartTitle = 'My Cart';
  static const String cartEmpty = 'Your cart is empty';
  static const String cartEmptySubtitle =
      'Add items from the marketplace to get started';
  static const String total = 'Total';
  static const String proceedToCheckout = 'Proceed to Checkout';
  static const String checkoutTitle = 'Checkout';
  static const String placeOrder = 'Place Order';
  static const String placingOrder = 'Placing Order...';
  static const String codTitle = 'Cash on Delivery';
  static const String codSubtitle = 'Pay when you receive your order';
  static const String deliveryInfo = 'Delivery Information';
  static const String deliveryAddress = 'Delivery Address';
  static const String phoneNumber = 'Phone Number';
  static const String orderNotesOptional = 'Order Notes (Optional)';

  // Orders
  static const String myOrders = 'My Orders';
  static const String orderPlaced = 'Order placed';
  static const String reorder = 'Reorder Items';
  static const String cancelOrder = 'Cancel Order';
  static const String reportIssue = 'Report an issue';

  // Generic errors
  static const String failedToLoad = 'Failed to load';
  static const String retry = 'Retry';
  static const String youreOffline = 'No internet connection';
}
