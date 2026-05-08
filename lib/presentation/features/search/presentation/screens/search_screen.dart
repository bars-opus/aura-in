// lib/features/search/presentation/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/core/widgets/search_text_field.dart';
import 'package:nano_embryo/presentation/features/search/domain/models/category_search_section.dart';
import 'package:nano_embryo/presentation/features/search/models/search_category.dart';
import 'package:nano_embryo/presentation/features/search/models/unified_search_result.dart';
import 'package:nano_embryo/presentation/features/search/presentation/screens/category_results_screen.dart';
import 'package:nano_embryo/presentation/features/search/presentation/state/search_providers.dart';
import 'package:nano_embryo/presentation/features/search/presentation/widgets/category_result_card.dart';
import 'package:nano_embryo/presentation/features/search/presentation/widgets/horizontal_shop_list.dart';
import 'package:nano_embryo/presentation/features/search/presentation/widgets/search_suggestions.dart';
import 'package:nano_embryo/presentation/features/search/presentation/widgets/vertical_category_list.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = true;
  final List<String> _selectedFilters = ['All'];
  late AnimationController _animationController;
  final FocusNode _searchFocusNode = FocusNode();
  bool _hasRequestedFocus = false;
  final ScrollController _scrollController = ScrollController();

  static const List<String> _availableFilters = [
    'All',
    'Shops',
    'Freelancers',
    'Products',
    'Profiles',
  ];

  static const Map<String, IconData> _filterIcons = {
    'All': Icons.apps,
    'Shops': Icons.storefront_outlined,
    'Freelancers': Icons.work_outline,
    'Products': Icons.shopping_bag_outlined,
    'Profiles': Icons.person_outline,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      _searchFocusNode.requestFocus();
      if (_selectedFilters.isEmpty) {
        setState(() {
          _selectedFilters.add('All');
        });
      }
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _cancelSearch() {
    _hasRequestedFocus = false;

    setState(() {
      _isSearching = !_isSearching;

      if (_isSearching) {
        if (mounted && _isSearching && !_hasRequestedFocus) {
          _hasRequestedFocus = true;
          _searchFocusNode.requestFocus();
        }
        Navigator.pop(context);
      } else {
        _searchController.clear();
        ref.read(searchQueryProvider.notifier).state = '';
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _searchFocusNode.unfocus();
          }
        });
        Navigator.pop(context);
      }
    });

    HapticFeedback.lightImpact();
  }

  void _handleFiltersChanged(List<String> newFilters) {
    final String? selectedFilter =
        newFilters.isNotEmpty ? newFilters.last : null;

    setState(() {
      _selectedFilters.clear();
      if (selectedFilter != null) {
        _selectedFilters.add(selectedFilter);
      }
    });

    SearchCategory? selectedCategory;
    if (selectedFilter != null && selectedFilter != 'All') {
      selectedCategory = SearchCategory.values.firstWhere(
        (c) => c.displayName == selectedFilter,
        orElse: () => SearchCategory.shops,
      );
    }

    // Remove "unified." prefix
    ref.read(selectedCategoryProvider.notifier).state = selectedCategory;

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    final query = ref.read(searchQueryProvider);
    if (query.isNotEmpty) {
      ref.invalidate(allSearchSectionsProvider);
    }
  }

  void _handleSearchChanged(String query) {
    ref.read(searchQueryProvider.notifier).state = query;
    ref.read(searchProvider.notifier).search(query); // Remove "unified."
  }

  void _handleSearchSubmitted(String query) {
    _searchFocusNode.unfocus();
  }

  Widget _buildAnimatedSearchBar() {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
      axisAlignment: -1.0,
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
        ),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutBack,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.onBackground,
                  width: .1,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.md.w,
                vertical: Spacing.sm.h,
              ),
              child: FilterableSearchFormField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: false,
                hintText: 'Search shops, professionals, products...',
                filterChips: _availableFilters,
                filterIcons: _filterIcons,
                selectedFilters: _selectedFilters,
                onFiltersChanged: _handleFiltersChanged,
                onSearchSubmitted: _handleSearchSubmitted,
                onCancelPressed: _cancelSearch,
                onSearchChanged: _handleSearchChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final allSections = ref.watch(allSearchSectionsProvider);

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            _searchFocusNode.unfocus();
          },
          child: Column(
            children: [
              _buildAnimatedSearchBar(),
              Expanded(
                child: _buildContent(
                  selectedCategory,
                  searchQuery,
                  allSections,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // lib/features/search/presentation/screens/search_screen.dart
  Widget _buildContent(
    SearchCategory? selectedCategory,
    String query,
    AsyncValue<List<CategorySearchSection>> sectionsState,
  ) {
    if (query.isEmpty) {
      return SearchSuggestions(
        onSuggestionSelected: (suggestion) {
          _searchController.text = suggestion;
          ref.read(searchQueryProvider.notifier).state = suggestion;
          ref.read(searchProvider.notifier).search(suggestion);
        },
      );
    }

    return sectionsState.when(
      data: (sections) {
        if (sections.isEmpty) {
          return _buildEmptyState(query);
        }

        if (selectedCategory != null) {
          final categorySection = sections.firstWhere(
            (s) => s.category == selectedCategory,
            orElse: () => CategorySearchSection.empty(selectedCategory),
          );
          if (categorySection.results.isEmpty) {
            return _buildEmptyState(
              query,
              category: selectedCategory.displayName,
            );
          }
          return _buildVerticalOnlyView(
            categorySection,
            selectedCategory.displayName,
          );
        }

        // Define display order: Shops (horizontal) → Freelancers → Profiles
        const displayOrder = [
          SearchCategory.shops,
          SearchCategory.freelancers,
          SearchCategory.profiles,
        ];

        final sectionMap = {for (var s in sections) s.category: s};
        final children = <Widget>[];

        for (final category in displayOrder) {
          final section = sectionMap[category];
          if (section != null && section.results.isNotEmpty) {
            if (category == SearchCategory.shops) {
              children.add(
                HorizontalShopList(
                  shops: section.results,
                  onSeeAll: () => _navigateToCategoryResults(category, query),
                  onItemTap: _onResultTap,
                ),
              );
            } else {
              children.add(
                VerticalCategoryList(
                  section: section,
                  onSeeAll: () => _navigateToCategoryResults(category, query),
                  onItemTap: _onResultTap,
                ),
              );
            }
          }
        }

        return SingleChildScrollView(
          controller: _scrollController,
          child: Column(children: children),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildVerticalOnlyView(
    CategorySearchSection section,
    String selectedCategory,
  ) {
    return CardInkWell(
      elevation: 0,
      color: selectedCategory == 'Profiles' ? null : Colors.transparent,
      padding: const EdgeInsets.all(0),
      margin:
          selectedCategory == 'Profiles'
              ? const EdgeInsets.symmetric(vertical: Spacing.md)
              : null,
      onTap: () {},
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.all(Spacing.md.h),
        itemCount: section.results.length,
        separatorBuilder: (_, __) => AppDivider(),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: Spacing.sm.h),
            child: CategoryResultCard(
              result: section.results[index],
              onTap: () => _onResultTap(section.results[index]),
              isHorizontal: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String query, {String? category}) {
    return Center(
      child: EmptyStateWidget(
        icon: Icons.search_off,
        title: category != null ? 'No $category found' : 'No results found',
        subtitle: 'Searched for: "$query"',
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: ErrorStateWidget(
        title: 'Something went wrong',
        subtitle: error,
        onPrimaryAction: () {
          final query = ref.read(searchQueryProvider);
          if (query.isNotEmpty) {
            ref.invalidate(allSearchSectionsProvider);
          }
        },
      ),
    );
  }

  void _navigateToCategoryResults(SearchCategory category, String query) {
    _searchFocusNode.unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CategoryResultsScreen(
              category: category,
              query: query,
              filters: ref.read(searchFiltersProvider),
            ),
      ),
    );
  }

  void _onResultTap(UnifiedSearchResult result) {
    _searchFocusNode.unfocus();
    switch (result.category) {
      case SearchCategory.shops:
        break;
      case SearchCategory.freelancers:
        break;
      case SearchCategory.profiles:
        break;

      case SearchCategory.products:
        break;
      case SearchCategory.all:
        break;
    }
  }
}
