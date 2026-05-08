// lib/features/freelancer/presentation/providers/freelancer_list_providers.dart

import 'package:nano_embryo/presentation/features/freelancer/data/repositories/supabase_freelancer_repository.dart';
import 'package:nano_embryo/presentation/features/freelancer/enums/freelancer_category_mapper.dart';
import 'package:nano_embryo/presentation/features/shops/query/providers/service_category_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nano_embryo/core/providers/location_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/data/models/nearby_freelancer_dto.dart';

part 'freelancer_list_providers.g.dart';

/// State class for freelancer list
class FreelancerListState {
  final List<NearbyFreelancerDTO> freelancers;
  final int? nextOffset;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final bool hasReachedMax;

  FreelancerListState({
    required this.freelancers,
    this.nextOffset,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.hasReachedMax = false,
  });

  FreelancerListState copyWith({
    List<NearbyFreelancerDTO>? freelancers,
    int? nextOffset,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    bool? hasReachedMax,
  }) {
    return FreelancerListState(
      freelancers: freelancers ?? this.freelancers,
      nextOffset: nextOffset ?? this.nextOffset,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  factory FreelancerListState.initial() {
    return FreelancerListState(
      freelancers: [],
      nextOffset: null,
      isLoading: true,
      hasError: false,
      errorMessage: null,
      hasReachedMax: false,
    );
  }
}

/// Provider for top rated freelancers list (paginated)
@riverpod
class TopRatedFreelancersList extends _$TopRatedFreelancersList {
  @override
  Future<FreelancerListState> build() {
    return Future.value(FreelancerListState.initial());
  }

  Future<void> loadFirstPage() async {
    final userLocation = ref.read(userLocationNotifierProvider);
    final selectedCategory = ref.read(selectedServiceCategoryProvider);

    if (userLocation == null) {
      state = AsyncValue.data(FreelancerListState.initial());
      return;
    }

    final repository = ref.read(freelancerRepositoryProvider);
    final freelancerTypes =
        FreelancerCategoryMapper.getFreelancerTypesForCategory(
          selectedCategory,
        );

    state = const AsyncValue.loading();

    try {
      final result = await repository.getTopRatedFreelancersPaginated(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
        offset: 0,
        limit: 20,
        freelancerTypes: freelancerTypes.isEmpty ? null : freelancerTypes,
      );

      state = AsyncValue.data(
        FreelancerListState(
          freelancers: result.items,
          nextOffset: result.nextOffset,
          isLoading: false,
          hasReachedMax: result.nextOffset == null,
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // 👇 ADD THIS MISSING METHOD
  Future<void> loadNextPage() async {
    final currentState = state;
    if (currentState is! AsyncData) return;

    final data = currentState.value;
    if (data == null ||
        data.isLoading ||
        data.hasReachedMax ||
        data.nextOffset == null) {
      return;
    }

    final userLocation = ref.read(userLocationNotifierProvider);
    if (userLocation == null) return;

    final selectedCategory = ref.read(selectedServiceCategoryProvider);
    final freelancerTypes =
        FreelancerCategoryMapper.getFreelancerTypesForCategory(
          selectedCategory,
        );

    final repository = ref.read(freelancerRepositoryProvider);
    state = AsyncValue.data(data!.copyWith(isLoading: true));

    try {
      final result = await repository.getTopRatedFreelancersPaginated(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
        offset: data.nextOffset ?? 0,
        limit: 20,
        freelancerTypes: freelancerTypes.isEmpty ? null : freelancerTypes,
      );

      final seen = <String>{...data.freelancers.map((f) => f.id)};
      final newItems = result.items.where((f) => seen.add(f.id)).toList();
      final updatedList = [...data.freelancers, ...newItems];
      state = AsyncValue.data(
        data.copyWith(
          freelancers: updatedList,
          nextOffset: result.nextOffset,
          isLoading: false,
          hasReachedMax: result.nextOffset == null,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(
        data.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> refresh() async {
    await loadFirstPage();
  }
}

/// Provider for nearby freelancers list (paginated)
@riverpod
class NearbyFreelancersList extends _$NearbyFreelancersList {
  @override
  Future<FreelancerListState> build() {
    return Future.value(FreelancerListState.initial());
  }

  Future<void> loadFirstPage() async {
    final userLocation = ref.read(userLocationNotifierProvider);
    final selectedCategory = ref.read(selectedServiceCategoryProvider);

    if (userLocation == null) {
      state = AsyncValue.data(FreelancerListState.initial());
      return;
    }

    final repository = ref.read(freelancerRepositoryProvider);
    final freelancerTypes =
        FreelancerCategoryMapper.getFreelancerTypesForCategory(
          selectedCategory,
        );

    state = const AsyncValue.loading();

    try {
      final result = await repository.getNearbyFreelancersPaginated(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
        offset: 0,
        limit: 20,
        freelancerTypes: freelancerTypes.isEmpty ? null : freelancerTypes,
      );

      state = AsyncValue.data(
        FreelancerListState(
          freelancers: result.items,
          nextOffset: result.nextOffset,
          isLoading: false,
          hasReachedMax: result.nextOffset == null,
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadNextPage() async {
    final currentState = state;
    if (currentState is! AsyncData) return;

    final data = currentState.value;
    if (data == null ||
        data.isLoading ||
        data.hasReachedMax ||
        data.nextOffset == null) {
      return;
    }

    final userLocation = ref.read(userLocationNotifierProvider);
    if (userLocation == null) return;

    final selectedCategory = ref.read(selectedServiceCategoryProvider);
    final freelancerTypes =
        FreelancerCategoryMapper.getFreelancerTypesForCategory(
          selectedCategory,
        );

    final repository = ref.read(freelancerRepositoryProvider);
    state = AsyncValue.data(data.copyWith(isLoading: true));

    try {
      final result = await repository.getNearbyFreelancersPaginated(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
        offset: data.nextOffset ?? 0,
        limit: 20,
        freelancerTypes: freelancerTypes.isEmpty ? null : freelancerTypes,
      );

      final seen = <String>{...data.freelancers.map((f) => f.id)};
      final newItems = result.items.where((f) => seen.add(f.id)).toList();
      final updatedList = [...data.freelancers, ...newItems];
      state = AsyncValue.data(
        data.copyWith(
          freelancers: updatedList,
          nextOffset: result.nextOffset,
          isLoading: false,
          hasReachedMax: result.nextOffset == null,
        ),
      );
    } catch (e) {
      state = AsyncValue.data(
        data.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> refresh() async {
    await loadFirstPage();
  }
}
