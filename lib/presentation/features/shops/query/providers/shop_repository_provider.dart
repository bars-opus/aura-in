// lib/features/shops/presentation/providers/shop_repository_provider.dart

import 'package:nano_embryo/presentation/features/shops/query/utility/quey_shop_exports.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shop_repository_provider.g.dart';

/// Provider for the ShopRepository implementation
@riverpod
ShopRepository shopRepository(ShopRepositoryRef ref) {
  // Get the Supabase client from the existing provider
  final supabaseClient = ref.watch(supabaseClientProvider);

  // Return the Supabase implementation
  return SupabaseShopRepository(supabaseClient);
}
