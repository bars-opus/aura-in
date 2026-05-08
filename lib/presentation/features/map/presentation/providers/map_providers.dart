import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/map/domain/repositories/map_repository.dart';
import 'package:nano_embryo/presentation/features/map/presentation/data/datasources/supabase_map_datasource.dart';
import 'package:nano_embryo/presentation/features/map/presentation/data/repositories/map_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



/// Provider for SupabaseMapDataSource
final supabaseMapDataSourceProvider = Provider<SupabaseMapDataSource>((ref) {
  final supabaseClient = Supabase.instance.client;
  return SupabaseMapDataSource(supabaseClient);
});

/// Provider for MapRepository
final mapRepositoryProvider = Provider<MapRepository>((ref) {
  final dataSource = ref.watch(supabaseMapDataSourceProvider);
  return MapRepositoryImpl(dataSource);
});

