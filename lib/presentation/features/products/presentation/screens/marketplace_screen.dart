// lib/features/products/presentation/screens/marketplace_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nano_embryo/core/widgets/app_text_form_field.dart';
import 'package:nano_embryo/core/widgets/feedback/circular_loading_indicator.dart';
import 'package:nano_embryo/presentation/features/products/data/utils/marketplace_strings.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/marketplace_providers.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/filter_chip_row.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/product_grid_item.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(marketplaceFilterProvider);
    final state = ref.watch(marketplaceProductsPagedProvider);
    final notifier = ref.read(marketplaceProductsPagedProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _isSearching ? _buildSearchAppBar() : _buildMainAppBar(),
      body: Column(
        children: [
          if (!_isSearching)
            FilterChipRow(
              selectedCategory: filter.category,
              onCategorySelected: (category) => ref
                  .read(marketplaceFilterProvider.notifier)
                  .setCategory(category),
              onFilterPressed: () => _showFilterBottomSheet(),
            ),
          Expanded(child: _buildGrid(state, notifier, theme)),
        ],
      ),
    );
  }

  Widget _buildGrid(
    dynamic state,
    dynamic notifier,
    ThemeData theme,
  ) {
    if (state.isInitialLoading) {
      return const Center(child: CircularLoadingIndicator());
    }
    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 48.w, color: theme.colorScheme.error),
            SizedBox(height: 16.h),
            Text(MarketplaceStrings.failedToLoad,
                style: theme.textTheme.titleMedium),
            SizedBox(height: 8.h),
            Text(state.error!,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: notifier.refresh,
              child: Text(MarketplaceStrings.retry),
            ),
          ],
        ),
      );
    }
    if (state.items.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
            notifier.loadNext();
          }
          return false;
        },
        child: GridView.builder(
          padding: EdgeInsets.all(12.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.75,
          ),
          itemCount: state.items.length + (state.hasMore ? 2 : 0),
          itemBuilder: (context, index) {
            if (index >= state.items.length) {
              return const Center(child: CircularProgressIndicator());
            }
            final product = state.items[index];
            return ProductGridItem(
              product: product,
              onTap: () => context.pushNamed(
                'productDetail',
                extra: product.id,
              ),
            );
          },
        ),
      ),
    );
  }

  AppBar _buildMainAppBar() {
    return AppBar(
      title: Text(
        'Marketplace',
        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
      ],
    );
  }

  AppBar _buildSearchAppBar() {
    return AppBar(
      title: AppTextFormField(
        controller: _searchController,
        hintText: 'Search products...',
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _searchController.clear();
            // TODO: Implement search
          },
        ),
        onChanged: (value) {
          // TODO: Implement debounced search
        },
        label: '',
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.clear();
            });
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.storefront_outlined,
            size: 80.w,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'No products found',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try adjusting your filters or search terms',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          OutlinedButton(
            onPressed: () {
              ref.read(marketplaceFilterProvider.notifier).reset();
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder:
          (context) => FilterBottomSheet(
            onApply: (minPrice, maxPrice, sortBy, showVerifiedOnly) {
              final notifier = ref.read(marketplaceFilterProvider.notifier);
              notifier.setPriceRange(minPrice, maxPrice);
              notifier.setSortBy(sortBy);
              notifier.setShowVerifiedOnly(showVerifiedOnly);
              Navigator.pop(context);
            },
          ),
    );
  }
}

// Filter Bottom Sheet Widget
class FilterBottomSheet extends StatefulWidget {
  final void Function(double?, double?, SortOption, bool) onApply;

  const FilterBottomSheet({super.key, required this.onApply});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  double? _minPrice;
  double? _maxPrice;
  SortOption _sortBy = SortOption.recent;
  bool _showVerifiedOnly = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Products',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),

          // Sort by
          Text('Sort by', style: theme.textTheme.titleMedium),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            children:
                SortOption.values.map((option) {
                  return FilterChip(
                    label: Text(option.label),
                    selected: _sortBy == option,
                    onSelected: (selected) {
                      setState(() {
                        _sortBy = option;
                      });
                    },
                  );
                }).toList(),
          ),

          SizedBox(height: 20.h),

          // Price range
          Text('Price Range', style: theme.textTheme.titleMedium),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: AppTextFormField(
                  hintText: 'Min',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _minPrice = double.tryParse(value);
                  },
                  label: 'Min',
                ),
              ),
              SizedBox(width: 12.w),
              Text('to'),
              SizedBox(width: 12.w),
              Expanded(
                child: AppTextFormField(
                  hintText: 'Min',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _maxPrice = double.tryParse(value);
                  },
                  label: 'Min',
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Verified shops only
          SwitchListTile(
            title: Text('Verified Shops Only'),
            subtitle: Text(
              'Show products only from verified shops',
              style: TextStyle(fontSize: 12.sp),
            ),
            value: _showVerifiedOnly,
            onChanged: (value) {
              setState(() {
                _showVerifiedOnly = value;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),

          SizedBox(height: 24.h),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _minPrice = null;
                      _maxPrice = null;
                      _sortBy = SortOption.recent;
                      _showVerifiedOnly = false;
                    });
                  },
                  child: const Text('Reset'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(
                      _minPrice,
                      _maxPrice,
                      _sortBy,
                      _showVerifiedOnly,
                    );
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
