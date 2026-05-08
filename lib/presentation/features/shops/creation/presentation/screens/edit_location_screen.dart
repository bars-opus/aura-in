// lib/features/shop/creation/presentation/screens/edit_location_screen.dart

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nano_embryo/core/utils/location/location_search_mode.dart';
import 'package:nano_embryo/presentation/features/currency/domain/entities/currency.dart';
import 'package:nano_embryo/presentation/features/currency/domain/entities/parsed_address.dart';
import 'package:nano_embryo/presentation/features/currency/domain/mappers/country_currency_mapper.dart';
import 'package:nano_embryo/presentation/features/currency/presentation/widgets/currency_selector.dart';
import 'package:nano_embryo/presentation/features/shops/booking/utility/booking_shop_exports.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/shop_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';

class EditLocationScreen extends ConsumerStatefulWidget {
  final bool showBottonNextButton;
  const EditLocationScreen({super.key, required this.showBottonNextButton});

  @override
  ConsumerState<EditLocationScreen> createState() => _EditLocationScreenState();
}

class _EditLocationScreenState extends ConsumerState<EditLocationScreen> {
  String _getCountryCodeFromName(String countryName) {
    const Map<String, String> countryCodeMap = {
      'United States': 'US',
      'USA': 'US',
      'Canada': 'CA',
      'United Kingdom': 'GB',
      'UK': 'GB',
      'France': 'FR',
      'Germany': 'DE',
      'Italy': 'IT',
      'Spain': 'ES',
      'Australia': 'AU',
      'Japan': 'JP',
      'China': 'CN',
      'India': 'IN',
      'Brazil': 'BR',
      'Mexico': 'MX',
      'Ghana': 'GH',
      'Nigeria': 'NG',
      'South Africa': 'ZA',
    };
    return countryCodeMap[countryName] ?? '';
  }

  void _onCurrencySelected(Currency currency) {
    // Only update the shop draft — never touch the user's personal location.
    ref.read(shopCreationProvider.notifier).updateCurrency(currency);
  }

  void _onAddressSelected(ParsedAddress address) {
    // Prefer the ISO countryCode from ParsedAddress; fall back to name lookup.
    final code =
        address.countryCode?.isNotEmpty == true
            ? address.countryCode!
            : _getCountryCodeFromName(address.country ?? '');

    // Auto-detect the primary currency for this country.
    final detectedCurrency =
        code.isNotEmpty ? CountryCurrencyMapper.getPrimaryCurrency(code) : null;

    ref
        .read(shopCreationProvider.notifier)
        .updateLocation(
          address: address.fullAddress,
          city: address.city ?? '',
          country: address.country ?? '',
          latitude: address.latitude,
          longitude: address.longitude,
          currencyCode: detectedCurrency?.code,
          currencySymbol: detectedCurrency?.symbol,
        );
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(shopCreationProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // All location data comes exclusively from the shop draft.
    // The user's personal browsing location is completely separate.
    final address = draft.address ?? '';
    final city = draft.city ?? '';
    final country = draft.country ?? '';
    final latitude = draft.latitude;
    final longitude = draft.longitude;

    final displayLocation = address.isNotEmpty ? address : null;
    final hasLocation = displayLocation != null;

    // Read currency directly from draft
    Currency? selectedCurrency;
    if (draft.currencyCode != null) {
      selectedCurrency =
          Currencies.fromCode(draft.currencyCode) ??
          Currency(
            code: draft.currencyCode!,
            symbol: draft.currencySymbol ?? '\$',
            name: draft.currencyCode!,
            flag: '',
          );
    }

    // Country code for multi-currency note only — the picker always shows all
    // currencies so the user can manually override the auto-detected one.
    String countryCode = '';
    bool showMultiCurrencyNote = false;
    if (country.isNotEmpty) {
      countryCode = _getCountryCodeFromName(country);
      if (countryCode.isNotEmpty) {
        showMultiCurrencyNote = CountryCurrencyMapper.hasMultipleCurrencies(
          countryCode,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          // if (hasLocation)
          //   AppTextButton(
          //     text: 'Save',
          //     onPressed: () {
          //       _saveAndExit(draft);
          //     },
          //   ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(Spacing.md.h),
        children: [
          SemanticContainerWidget(
            content:
                'This helps customers find you. You can use your current location or search for an address.',
            icon: Icons.info_outline,
            title: 'Where is your shop located?',
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            borderColor: colorScheme.primary,
            iconColor: colorScheme.primary,
            textTheme: theme.textTheme,
          ),
          Gap(Spacing.md.h),

          // Location Display
          if (hasLocation) ...[
            CardInkWell(
              margin: EdgeInsets.only(bottom: Spacing.md.h),
              onTap: _openLocationPicker,
              child: Column(
                children: [
                  HighlightContainer(
                    child: InfoRowWidget(
                      subtitle: 'Selected Location',
                      title: displayLocation,
                      icon: Icons.location_on,
                      avatarRadius: 25.h,
                      backgroundColor: colorScheme.primary,
                      iconColor: colorScheme.onPrimary,
                      onTap: _openLocationPicker,
                      disableTrailing: false,
                      showAvatar: true,
                      showDivider: false,
                      showTrailingArrow: true,
                      trailing: AppIconButton(
                        icon: Icons.edit,
                        onPressed: _openLocationPicker,
                      ),
                    ),
                  ),
                  Gap(Spacing.md.h),
                  // Location details preview
                  _buildDetailRow(
                    'Address',
                    address,
                    Icons.location_on_outlined,
                  ),
                  if (latitude != null)
                    _buildDetailRow(
                      'Coordinates',
                      '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}',
                      Icons.map,
                    ),
                  _buildDetailRow(
                    'City',
                    city.isNotEmpty ? city : address.split(',').first.trim(),
                    Icons.location_city,
                  ),
                  _buildDetailRow('Country', country, FontAwesomeIcons.globe),
                  Gap(Spacing.lg),

                  // Currency Selector
                  CurrencySelector(
                    selectedCurrency: selectedCurrency,
                    onCurrencySelected: (currency) {
                      _onCurrencySelected(currency);
                    },
                    errorText: null,
                    availableCurrencies: Currencies.all,
                  ),
                  if (showMultiCurrencyNote) ...[
                    SizedBox(height: Spacing.sm.h),
                    Container(
                      padding: EdgeInsets.all(Spacing.sm.h),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange,
                            size: 16.sp,
                          ),
                          SizedBox(width: Spacing.sm.w),
                          Expanded(
                            child: Text(
                              CountryCurrencyMapper.getMultiCurrencyMessage(
                                    countryCode,
                                  ) ??
                                  'This country has multiple currencies. Please select the appropriate one.',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // No location selected
          if (!hasLocation) ...[
            CardInkWell(
              elevation: 0,
              padding: const EdgeInsets.all(0),
              child: Center(
                child: EmptyStateWidget(
                  icon: Icons.location_on,
                  subtitle: 'Set your shop location to continue',
                  title: 'No location set',
                  actionLabel: 'Set Location',
                  onAction: _openLocationPicker,
                ),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar:
          hasLocation
              ? SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Spacing.md.h),
                  child: AppButton(
                    elevation: 0,
                    label: 'Continue to amenities',
                    center: false,
                    iconData: Icons.location_on,
                    prefixIcon: Icons.emoji_objects,
                    prefixIconColor: colorScheme.background,
                    onPressed: () {
                      _saveAndContinue(draft);
                    },
                    size: ButtonSize.small,
                    width: double.infinity,
                    padding: Spacing.horizontalMd,
                    height: 40.h,
                  ),
                ),
              )
              : null,
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InfoRowWidget(
      subtitle: '$label: ',
      title: value,
      icon: icon,
      avatarRadius: 25.h,
      backgroundColor: colorScheme.primary,
      iconColor: colorScheme.onBackground.withOpacity(.5),
      onTap: _openLocationPicker,
      disableTrailing: true,
      showAvatar: false,
      showDivider: true,
      showTrailingArrow: false,
    );
  }

  Future<void> _openLocationPicker() async {
    await BottomSheetUtils.showDocumentationBottomSheet(
      maxHeight: 500.h,
      context: context,
      widget: LocationPickerBottomSheet(
        mode: LocationSearchMode.address,
        onLocationSelected: (ParsedAddress address) {
          _onAddressSelected(address);
        },
      ),
    );
  }

  void _saveAndExit(ShopDraft draft) {
    if (draft.currencyCode == null) {
      context.showErrorSnackbar('Currency is required');

      return;
    }

    // Draft is already updated via real-time updates, just close
    Navigator.pop(context);
  }

  void _saveAndContinue(ShopDraft draft) async {
    if (draft.currencyCode == null) {
      context.showErrorSnackbar('Currency is required');
      return;
    } else {
      Navigator.pop(context);
    }

    // Navigate to next screen
    context.push('/manageAmenities');
  }
}
