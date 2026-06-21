import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/core/constants/freelancer_tags.dart';

void main() {
  group('FreelancerTags.normalize', () {
    test('trims surrounding whitespace', () {
      expect(FreelancerTags.normalize('  Haircut  '), 'Haircut');
    });
    test('collapses internal whitespace', () {
      expect(FreelancerTags.normalize('Bridal   Makeup'), 'Bridal Makeup');
    });
    test('empty after trim returns empty string', () {
      expect(FreelancerTags.normalize('   '), '');
    });
  });

  test('curated list is non-empty and has no duplicates', () {
    expect(FreelancerTags.curated, isNotEmpty);
    expect(FreelancerTags.curated.toSet().length, FreelancerTags.curated.length);
  });
}
