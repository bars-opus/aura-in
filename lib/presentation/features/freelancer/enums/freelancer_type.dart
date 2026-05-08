import 'package:flutter/material.dart';

/// Enum for freelancer professional types
/// Used for categorizing freelancers by their primary service offering
enum FreelancerType {
  barber('Barber', Icons.content_cut),
  hairdresser('Hairdresser', Icons.face),
  nailTech('Nail Technician', Icons.color_lens),
  makeupArtist('Makeup Artist', Icons.brush),
  masseuse('Masseuse', Icons.spa),
  esthetician('Esthetician', Icons.science),
  lashTech('Lash Technician', Icons.visibility),
  browArtist('Brow Artist', Icons.brush),
  waxingSpecialist('Waxing Specialist', Icons.clean_hands),
  tattooArtist('Tattoo Artist', Icons.edit),
  piercingSpecialist('Piercing Specialist', Icons.circle),
  cosmetologist('Cosmetologist', Icons.auto_awesome),
  bridalSpecialist('Bridal Specialist', Icons.celebration),
  editorialStylist('Editorial Stylist', Icons.style),
  other('Other', Icons.help_outline);

  const FreelancerType(this.displayName, this.icon);

  final String displayName;
  final IconData icon;

  /// Get enum from string value (for JSON deserialization)
  static FreelancerType fromString(String value) {
    return FreelancerType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FreelancerType.other,
    );
  }

  /// Get list of all display names for dropdowns
  static List<String> get displayNames =>
      values.map((e) => e.displayName).toList();

  /// Get list of all values for API calls
  static List<String> get apiValues => values.map((e) => e.name).toList();
}
