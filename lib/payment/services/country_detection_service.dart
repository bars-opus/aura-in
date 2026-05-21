// lib/features/dashboard/services/country_detection_service.dart

/// Service to detect which payment provider to use based on country
class CountryDetectionService {
  // African countries that should use Paystack
  static const Set<String> _africanCountries = {
    'Nigeria',
    'NG',
    'NGN',
    'Ghana',
    'GH',
    'GHS',
    'Kenya',
    'KE',
    'KES',
    'South Africa',
    'ZA',
    'ZAR',
    'Uganda',
    'UG',
    'UGX',
    'Tanzania',
    'TZ',
    'TZS',
    'Rwanda',
    'RW',
    'RWF',
    'Zambia',
    'ZM',
    'ZMW',
    'Botswana',
    'BW',
    'BWP',
    'Mauritius',
    'MU',
    'MUR',
    'Senegal',
    'SN',
    'XOF',
    'Ivory Coast',
    'CI',
    'Cameroon',
    'CM',
    'XAF',
    'Egypt',
    'EG',
    'EGP',
    'Morocco',
    'MA',
    'MAD',
    'Tunisia',
    'TN',
    'TND',
  };

  /// Check if a country is in Africa (should use Paystack)
  static bool isAfricanCountry(String countryCode) {
    return _africanCountries.contains(countryCode.toUpperCase()) ||
        _africanCountries.contains(countryCode);
  }

  /// Get the recommended payment provider based on country
  static String getRecommendedProvider(String countryCode) {
    return isAfricanCountry(countryCode) ? 'paystack' : 'stripe';
  }

  /// Get the appropriate currency for the country
  static String getCurrencyForCountry(String countryCode) {
    final upperCode = countryCode.toUpperCase();
    switch (upperCode) {
      case 'NG':
      case 'NGN':
      case 'NIGERIA':
        return 'NGN';
      case 'GH':
      case 'GHS':
      case 'GHANA':
        return 'GHS';
      case 'KE':
      case 'KES':
      case 'KENYA':
        return 'KES';
      case 'ZA':
      case 'ZAR':
      case 'SOUTH AFRICA':
        return 'ZAR';
      default:
        return 'USD';
    }
  }
}
