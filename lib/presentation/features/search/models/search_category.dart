// lib/features/search/domain/models/search_category.dart
enum SearchCategory {
  all('All', 0),
  shops('Shops', 1),
  freelancers('Freelancers', 2),
  products('Products', 3),
  profiles('Profiles', 4);

  final String displayName;
  final int displayOrder;

  const SearchCategory(this.displayName, this.displayOrder);

  static SearchCategory fromDisplayName(String name) {
    return values.firstWhere((e) => e.displayName == name, orElse: () => all);
  }
}
