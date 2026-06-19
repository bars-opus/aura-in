class FreelancerCategoryMapper {
  static const Map<String, List<String>> _categoryToFreelancerTypes = {
    // Salon services
    'salon': [
      'hairdresser',
      'cosmetologist',
      'makeupArtist',
      'bridalSpecialist',
      'editorialStylist',
      'hairstylist', // Added
    ],

    // Barbershop services
    'barbershop': [
      'barber',
      'hair_tattoo',
      'tattooArtist',
      'piercingSpecialist',
    ],

    // Spa services
    'spa': [
      'masseuse',
      'esthetician',
      'massage_therapist',
      'waxingSpecialist',
      'other',
    ],

    // Nail Salon services
    'nail_salon': ['nailTech', 'other'],

    // Lash Studio services
    'lash_studio': ['lashTech', 'browArtist'],

    // Waxing services
    'waxing': ['waxingSpecialist', 'esthetician'],

    // Massage services
    'massage': ['masseuse', 'massage_therapist', 'other'],

    // Makeup services
    'makeup': [
      'makeupArtist',
      'bridalSpecialist',
      'editorialStylist',
      'cosmetologist',
    ],

    // Skincare services
    'skincare': ['esthetician', 'cosmetologist', 'dermatology_assistant'],
  };

  /// Get matching freelancer types for a given service category
  static List<String> getFreelancerTypesForCategory(String category) {
    return _categoryToFreelancerTypes[category] ?? [];
  }

  /// Maps a freelancer type to the DB `shop_type` value used by the
  /// service_templates table. These MUST match the seeded shop_type strings
  /// exactly ('Salon' | 'Barbershop' | 'Spa' | 'Nail Salon') — the same values
  /// the shop creation flow stores (see edit_basics_screen `_shopTypes`).
  /// Only those four template sets exist, so professions fold into the closest.
  static const Map<String, String> _freelancerTypeToShopType = {
    'barber': 'Barbershop',
    'tattooArtist': 'Barbershop',
    'piercingSpecialist': 'Barbershop',
    'hairdresser': 'Salon',
    'makeupArtist': 'Salon',
    'bridalSpecialist': 'Salon',
    'editorialStylist': 'Salon',
    'cosmetologist': 'Salon',
    'masseuse': 'Spa',
    'esthetician': 'Spa',
    'waxingSpecialist': 'Spa',
    'browArtist': 'Spa',
    'lashTech': 'Spa',
    'nailTech': 'Nail Salon',
    'other': 'Salon',
  };

  /// Reverse lookup: given a freelancer type, return the DB shop_type whose
  /// service templates should be offered. Returns null when the freelancer type
  /// isn't recognised.
  static String? getCategoryForFreelancerType(String freelancerType) {
    return _freelancerTypeToShopType[freelancerType];
  }

  /// Get all available freelancer types
  static List<String> getAllFreelancerTypes() {
    return const [
      'barber',
      'hairdresser',
      'nailTech',
      'makeupArtist',
      'masseuse',
      'esthetician',
      'lashTech',
      'browArtist',
      'waxingSpecialist',
      'tattooArtist',
      'piercingSpecialist',
      'cosmetologist',
      'bridalSpecialist',
      'editorialStylist',
      'other',
    ];
  }

  /// Check if a freelancer type belongs to a category
  static bool freelancerBelongsToCategory(
    String freelancerType,
    String category,
  ) {
    return _categoryToFreelancerTypes[category]?.contains(freelancerType) ??
        false;
  }
}
