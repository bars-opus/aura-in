// lib/features/search/presentation/screens/category_results_screen.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/search/models/search_category.dart';
import 'package:nano_embryo/presentation/features/search/models/search_filters.dart';
import 'package:nano_embryo/presentation/features/search/models/unified_search_result.dart';
import 'package:nano_embryo/presentation/features/search/presentation/state/search_providers.dart';
import 'package:nano_embryo/presentation/features/search/presentation/widgets/category_result_card.dart';

class CategoryResultsScreen extends ConsumerStatefulWidget {
  final SearchCategory category;
  final String query;
  final SearchFilters filters;

  const CategoryResultsScreen({
    super.key,
    required this.category,
    required this.query,
    required this.filters,
  });

  @override
  ConsumerState<CategoryResultsScreen> createState() =>
      _CategoryResultsScreenState();
}

class _CategoryResultsScreenState extends ConsumerState<CategoryResultsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Trigger search when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(categorySearchResultsProvider(widget.category).notifier)
          .search(widget.query, widget.filters);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Trigger search only once when dependencies are ready
    if (!_isInitialized) {
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch();
      });
    }
  }

  Future<void> _performSearch() async {
    final notifier = ref.read(
      categorySearchResultsProvider(widget.category).notifier,
    );
    await notifier.search(widget.query, widget.filters);
  }

  void _onScroll() {
    final state = ref.read(categorySearchResultsProvider(widget.category));
    if (state is AsyncData && state.value!.hasMore) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref
            .read(categorySearchResultsProvider(widget.category).notifier)
            .loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;
    final resultsState = ref.watch(
      categorySearchResultsProvider(widget.category),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
            children: [
              TextSpan(
                text: '${loc.searchResultsTitle(widget.category.displayName)}\n',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              TextSpan(
                text: loc.searchResultsSearchingFor(widget.query),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: resultsState.when(
        data: (result) {
          if (result.items.isEmpty) {
            return _buildEmptyState(loc);
          }
          return CardInkWell(
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: Spacing.md.h),
            margin: EdgeInsets.only(top: Spacing.sm.h),
            onTap: () {},
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.all(Spacing.md.h),
              separatorBuilder: (_, __) => AppDivider(),
              itemCount: result.items.length + (result.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == result.items.length) {
                  //  This only shows when hasMore is true
                  return _buildLoadingIndicator();
                }
                return Padding(
                  padding: EdgeInsets.only(bottom: Spacing.sm.h),
                  child: CategoryResultCard(
                    result: result.items[index],
                    onTap: () => _onResultTap(result.items[index]),
                    isHorizontal: false,
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularLoadingIndicator()),
        error: (error, stack) => _buildErrorState(error.toString(), loc),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations loc) {
    return Center(
      child: EmptyStateWidget(
        icon: Icons.search_off,
        title: loc.searchScreenNoResultsCategory(widget.category.displayName.toLowerCase()),
        subtitle: loc.searchResultsTryDifferent,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.md.h),
      child: Center(
        child: CircularLoadingIndicator()
      ),
    );
  }

  Widget _buildErrorState(String error, AppLocalizations loc) {
    return Center(
      child: ErrorStateWidget(
        title: loc.searchResultsSomethingWentWrong,
        subtitle: error,
        onPrimaryAction: () {
          ref
              .read(categorySearchResultsProvider(widget.category).notifier)
              .search(widget.query, widget.filters);
        },
      ),
    );
  }

  void _onResultTap(UnifiedSearchResult result) {
    switch (result.category) {
      case SearchCategory.shops:
        break;
      case SearchCategory.profiles:
        break;
      case SearchCategory.freelancers:
        break;
      case SearchCategory.products:
        context.pushNamed('productDetail', extra: <String, String?>{'productId': result.id, 'coverImageUrl': ''});
        break;
      case SearchCategory.all:
        break;
    }
  }
}
