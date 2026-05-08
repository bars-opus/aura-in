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
