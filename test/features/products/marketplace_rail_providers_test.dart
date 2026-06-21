// test/features/products/marketplace_rail_providers_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nano_embryo/presentation/features/products/data/models/product_model.dart';
import 'package:nano_embryo/presentation/features/products/data/repositories/product_repository.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/marketplace_providers.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/product_providers.dart';

class _FakeProductRepo implements ProductRepository {
  SortOption? lastSortBy;
  int? lastLimit;
  double? lastRadiusKm;
  double? lastUserLat;

  @override
  Future<List<ProductModel>> getMarketplaceProducts({
    String? category,
    SortOption? sortBy,
    double? minPrice,
    double? maxPrice,
    bool showVerifiedOnly = false,
    required int limit,
    required int page,
    int seed = 0,
    double? userLat,
    double? userLng,
    double? radiusKm,
    List<String>? shopTypes,
  }) async {
    lastSortBy = sortBy;
    lastLimit = limit;
    lastRadiusKm = radiusKm;
    lastUserLat = userLat;
    return const [];
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('topRatedProductsProvider requests popular sort, limit 10', () async {
    final fake = _FakeProductRepo();
    final container = ProviderContainer(overrides: [
      productRepositoryProvider.overrideWithValue(fake),
    ]);
    addTearDown(container.dispose);

    await container.read(topRatedProductsProvider.future);

    expect(fake.lastSortBy, SortOption.popular);
    expect(fake.lastLimit, 10);
  });
}
