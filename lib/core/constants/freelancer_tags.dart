/// Curated freelancer tag vocabulary. Tags are stored in the
/// `workers.specialties text[]` DB column (the column keeps its legacy name;
/// the product concept is "Tags"). Freelancers may also add custom tags
/// not in this list.
class FreelancerTags {
  FreelancerTags._();

  static const List<String> curated = [
    'Haircut',
    'Hair Coloring',
    'Balayage',
    'Braids',
    'Locs',
    'Wig Install',
    'Manicure',
    'Pedicure',
    'Nail Art',
    'Acrylics',
    'Makeup',
    'Bridal Makeup',
    'Lashes',
    'Brows',
    'Facial',
    'Waxing',
    'Massage',
    'Barbering',
  ];

  /// Max number of tags a freelancer may select (resource cap).
  static const int maxTags = 15;

  /// Max length of a single custom tag.
  static const int maxTagLength = 40;

  /// Normalize a tag for storage / comparison: trim + collapse internal
  /// whitespace. Returns '' if nothing remains after trimming.
  static String normalize(String raw) =>
      raw.trim().replaceAll(RegExp(r'\s+'), ' ');
}
