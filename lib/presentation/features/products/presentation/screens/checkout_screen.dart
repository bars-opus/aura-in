// lib/features/products/presentation/screens/checkout_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/utils/location/location_search_mode.dart';
import 'package:nano_embryo/core/utils/phone_field_widget.dart';
import 'package:nano_embryo/presentation/features/currency/domain/entities/parsed_address.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/currency.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/input_sanitizer.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_logger.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_strings.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/cart_provider.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/connectivity_provider.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/order_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  // Phone uses PhoneFieldWidget (same as AddContactModal); it owns its own
  // controller and reports the validated E.164 string here.
  String? _e164Phone;
  // Saved phone (E.164) loaded from device, used to prefill PhoneFieldWidget.
  String? _initialPhone;
  bool _prefsLoaded = false;

  // Device-persisted checkout details so returning buyers don't re-type their
  // address/phone. Order notes are intentionally NOT persisted.
  static const _kSavedAddress = 'checkout_delivery_address';
  static const _kSavedPhone = 'checkout_customer_phone';

  bool _isPlacingOrder = false;

  /// Stable for the lifetime of this checkout screen — a tap-twice or
  /// network-retry within the same screen replays the same key so the
  /// server-side idempotency check returns the existing order_id
  /// instead of creating a duplicate.
  late final String _idempotencyKey = const Uuid().v4();

  @override
  void initState() {
    super.initState();
    _loadSavedDetails();
  }

  /// Prefill delivery address + phone from the last successful checkout.
  Future<void> _loadSavedDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAddress = prefs.getString(_kSavedAddress);
      final savedPhone = prefs.getString(_kSavedPhone);
      if (!mounted) return;
      setState(() {
        if (savedAddress != null) _addressController.text = savedAddress;
        if (savedPhone != null && savedPhone.isNotEmpty) {
          _initialPhone = savedPhone;
          _e164Phone = savedPhone; // valid until the user edits the field
        }
        _prefsLoaded = true;
      });
    } catch (e, stack) {
      MarketplaceLogger.warn(
        'checkout prefs load failed',
        error: e,
        stack: stack,
      );
      if (mounted) setState(() => _prefsLoaded = true);
    }
  }

  Future<void> _saveDetails(String address, String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSavedAddress, address);
      await prefs.setString(_kSavedPhone, phone);
    } catch (e, stack) {
      MarketplaceLogger.warn(
        'checkout prefs save failed',
        error: e,
        stack: stack,
      );
    }
  }

  Future<void> _openDeliveryLocationPicker() async {
    await BottomSheetUtils.showDocumentationBottomSheet(
      maxHeight: 500.h,
      context: context,
      widget: LocationPickerBottomSheet(
        mode: LocationSearchMode.address,
        onLocationSelected: _onDeliveryAddressSelected,
      ),
    );
  }

  void _onDeliveryAddressSelected(ParsedAddress address) {
    setState(() {
      _addressController.text = address.fullAddress;
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    // PhoneFieldWidget reports E.164 only when valid; null/empty = invalid.
    final phone = _e164Phone;
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final cleanAddress = InputSanitizer.clean(_addressController.text);
    if (cleanAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final cartState = ref.read(cartNotifierProvider);
    if (cartState.isEmpty) return;

    // Check if cart has items from multiple shops
    if (cartState.hasMultipleShops) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please order from one shop at a time'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final shopId = cartState.items.first.shopId;
    final items =
        cartState.items
            .map(
              (item) => {
                'product_id': item.productId,
                'quantity': item.quantity,
                'unit_price': item.price,
              },
            )
            .toList();

    setState(() => _isPlacingOrder = true);

    try {
      final orderNotifier = ref.read(orderNotifierProvider.notifier);
      final orderId = await orderNotifier.createOrder(
        shopId: shopId,
        items: items,
        totalAmount: cartState.totalAmount,
        deliveryAddress: cleanAddress,
        customerPhone: phone,
        customerNotes: InputSanitizer.clean(_notesController.text),
        idempotencyKey: _idempotencyKey,
      );

      if (mounted && orderId != null) {
        // Remember address + phone for next checkout (notes excluded).
        await _saveDetails(cleanAddress, phone);
        // Clear cart and navigate to order confirmation
        await ref.read(cartNotifierProvider.notifier).clearCart();
        if (!mounted) return;
        context.pushReplacementNamed('orderConfirmation', extra: orderId);
      }
    } catch (e, stack) {
      MarketplaceLogger.error('placeOrder failed', error: e, stack: stack);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to place order: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final colorScheme = theme.colorScheme;

    final isOnline = ref.watch(isOnlineProvider);

    return Scaffold(
      backgroundColor: colorScheme.neutral,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
        title: Text(
          MarketplaceStrings.checkoutTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ),
      body:
          cartState.isEmpty
              ? const Center(
                child: EmptyStateWidget(
                  title: 'Cart is empty',
                  subtitle: '',
                  icon: Icons.shopping_cart_checkout,
                ),
              )
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gap(Spacing.lg),
                      Text(
                        'Order Summary',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        semanticsLabel: 'Order summary',
                      ),
                      Gap(Spacing.sm),
                      // Order summary
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.5,
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Gap(Spacing.md),
                            ...cartState.items.map(
                              (item) => Padding(
                                padding: EdgeInsets.only(bottom: 8.h),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.quantity}x ${item.productName}',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurface,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      Currency.formatWithCurrency(
                                        item.subtotal,
                                        currencySymbol: item.currencySymbol,
                                        currencyCode: item.currencyCode,
                                      ),
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            AppDivider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  Currency.formatWithCurrency(
                                    cartState.totalAmount,
                                    currencySymbol: cartState.currencySymbol,
                                    currencyCode: cartState.currencyCode,
                                  ),
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Gap(Spacing.xxl),

                      // Delivery address
                      Text(
                        'Delivery Information',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      Gap(Spacing.sm),

                      CardInkWell(
                        margin: const EdgeInsets.all(0),
                        child: Column(
                          children: [
                            if (_addressController.text.isNotEmpty)
                              HighlightContainer(
                                child: InfoRowWidget(
                                  subtitle: 'Delivery address',
                                  title: _addressController.text,
                                  icon: Icons.location_on,
                                  avatarRadius: 25.h,
                                  backgroundColor: colorScheme.primary,
                                  iconColor: colorScheme.onPrimary,
                                  onTap: _openDeliveryLocationPicker,
                                  disableTrailing: false,
                                  showAvatar: true,
                                  showDivider: false,
                                  showTrailingArrow: true,
                                  trailing: AppIconButton(
                                    icon: Icons.edit,
                                    onPressed: _openDeliveryLocationPicker,
                                  ),
                                ),
                              )
                            else
                              OutlinedButton.icon(
                                onPressed: _openDeliveryLocationPicker,
                                icon: const Icon(Icons.location_on),
                                label: const Text('Select delivery address'),
                              ),

                            // Same phone widget as AddContactModal — reports E.164.
                            // Keyed on _prefsLoaded so it rebuilds with the saved
                            // initial value once device prefs resolve.
                            Gap(Spacing.md),
                            PhoneFieldWidget(
                              key: ValueKey('checkout_phone_$_prefsLoaded'),
                              initialValue: _initialPhone,
                              onChanged:
                                  (e164) => setState(() => _e164Phone = e164),
                            ),
                            Gap(Spacing.md),
                            AppTextFormField(
                              controller: _notesController,
                              label: 'Order Notes (Optional)',
                              hintText: 'Special instructions for delivery',
                              maxLines: 2,
                              maxLength: InputSanitizer.maxOrderNotes,
                              validator: InputSanitizer.optionalLength(
                                InputSanitizer.maxOrderNotes,
                                fieldName: 'Order notes',
                              ),
                            ),

                            // Payment info (COD)
                          ],
                        ),
                      ),
                      Gap(Spacing.md),

                      Semantics(
                        button: true,
                        label: MarketplaceStrings.placeOrder,
                        enabled: !_isPlacingOrder && isOnline,
                        child: AppButton(
                          elevation: 0,
                          label:
                              _isPlacingOrder
                                  ? MarketplaceStrings.placingOrder
                                  : MarketplaceStrings.placeOrder,
                          onPressed:
                              (_isPlacingOrder || !isOnline)
                                  ? null
                                  : _placeOrder,

                          size: ButtonSize.small,
                          width: double.infinity,
                          padding: Spacing.horizontalMd,
                          height: 40.h,
                        ),
                      ),
                      Gap(Spacing.sm),
                      SemanticContainerWidget(
                        content: MarketplaceStrings.codSubtitle,
                        icon: Icons.payments_outlined,
                        title: MarketplaceStrings.codTitle,
                        backgroundColor: colorScheme.primary.withValues(
                          alpha: 0.1,
                        ),
                        borderColor: colorScheme.primary,
                        iconColor: colorScheme.primary,
                        textTheme: theme.textTheme,
                      ),

                      Gap(Spacing.md),

                      // Offline banner — blocks Place Order with a clear reason.
                      if (!isOnline)
                        SemanticContainerWidget(
                          content: 'Connect to the internet and try again',
                          icon: Icons.wifi_off,
                          title: MarketplaceStrings.youreOffline,
                          backgroundColor: colorScheme.error.withValues(
                            alpha: 0.1,
                          ),
                          borderColor: colorScheme.error,
                          iconColor: colorScheme.error,
                          textTheme: theme.textTheme,
                        ),

                      // Place order button
                      Gap(Spacing.xxl),
                    ],
                  ),
                ),
              ),
    );
  }
}
