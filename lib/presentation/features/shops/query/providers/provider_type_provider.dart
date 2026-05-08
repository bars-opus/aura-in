// lib/features/discover/providers/provider_type_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'provider_type_provider.g.dart';

/// Provider types available for each service category
enum ProviderType {
  shops('Shops'),
  freelancers('Freelancers'),
  buy('Buy');

  final String label;
  const ProviderType(this.label);
}

/// Current selected provider type
@riverpod
class SelectedProviderType extends _$SelectedProviderType {
  @override
  ProviderType build() {
    return ProviderType.shops; // Default to shops
  }

  void selectType(ProviderType type) {
    state = type;
  }
}
