// lib/features/shops/presentation/providers/shop_details_provider.dart
import 'package:nano_embryo/presentation/features/shops/query/data/models/dtos/shop_details_dto.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/shop_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shop_details_provider.g.dart';

@riverpod
Future<ShopDetailsDTO> shopDetails(
  ShopDetailsRef ref, {
  required String shopId,
}) {
  final repository = ref.watch(shopRepositoryProvider);
  // We need to add this method to our repository
  return repository.getShopDetailsById(shopId);
}
