// lib/features/products/presentation/screens/marketplace_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/marketplace_providers.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/filter_chip_row.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/marketplace_grid_sliver.dart';

/// Standalone Marketplace route (e.g. "Browse products" from orders). Hosts the
/// category FilterChipRow + the shared [MarketplaceGridSliver] in one scroll
/// view. The Discover Buy tab renders the same chip row + grid sliver inline.
class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(marketplaceFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Marketplace',
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh:
              ref.read(marketplaceProductsPagedProvider.notifier).refresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: FilterChipRow(
                  selectedCategory: filter.category,
                  onCategorySelected:
                      (category) => ref
                          .read(marketplaceFilterProvider.notifier)
                          .setCategory(category),
                  onFilterPressed: () => _showFilterBottomSheet(),
                ),
              ),
              SliverGap(Spacing.sm.h),
              const MarketplaceGridSliver(),
            ],
          ),
        ),
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
  SortOption _sortBy = SortOption.discover;
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
                      _sortBy = SortOption.discover;
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
