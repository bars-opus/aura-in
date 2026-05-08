// In your worker_provider.dart or a separate service_provider.dart

// First, define a ServiceCategory model if you don't have one
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServiceCategory {
  final String id;
  final String name;
  final String? icon;
  final int displayOrder;

  ServiceCategory({
    required this.id,
    required this.name,
    this.icon,
    this.displayOrder = 0,
  });
}

// Provider for service categories (similar to your shop services)
final serviceCategoriesProvider = Provider<List<ServiceCategory>>((ref) {
  // Return your dummy categories
  return _getDummyCategories();
});

List<ServiceCategory> _getDummyCategories() {
  return [
    ServiceCategory(
      id: 'haircut',
      name: 'Haircut',
      icon: 'scissors',
      displayOrder: 1,
    ),
    ServiceCategory(
      id: 'braiding',
      name: 'Braiding',
      icon: 'braid',
      displayOrder: 2,
    ),
    ServiceCategory(
      id: 'coloring',
      name: 'Coloring',
      icon: 'color',
      displayOrder: 3,
    ),
    ServiceCategory(
      id: 'styling',
      name: 'Styling',
      icon: 'style',
      displayOrder: 4,
    ),
    ServiceCategory(
      id: 'grooming',
      name: 'Grooming',
      icon: 'grooming',
      displayOrder: 5,
    ),
    ServiceCategory(
      id: 'treatment',
      name: 'Treatment',
      icon: 'treatment',
      displayOrder: 6,
    ),
  ];
}
