/// Canonical shop-type vocabulary. Stored verbatim (display strings) on
/// shops.shop_type and products.shop_types so discovery filters overlap.
class ShopTypes {
  ShopTypes._();
  static const List<String> all = ['Salon', 'Barbershop', 'Spa', 'Nail Salon'];

  /// Maps a discover-tab category value (lowercase/snake_case, e.g. 'nail_salon')
  /// to the canonical product shop-type label (e.g. 'Nail Salon'). Returns null
  /// for categories with no product equivalent (lash_studio/waxing/massage) or
  /// an empty/unknown value — null means "no shop-type filter" (show all).
  static const Map<String, String> _tabToLabel = {
    'salon': 'Salon',
    'barbershop': 'Barbershop',
    'spa': 'Spa',
    'nail_salon': 'Nail Salon',
  };

  static String? labelForTab(String? tabValue) {
    if (tabValue == null || tabValue.isEmpty) return null;
    return _tabToLabel[tabValue];
  }
}
