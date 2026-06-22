// lib/features/products/presentation/screens/product_detail_screen.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/products/presentation/providers/product_providers.dart';
import 'package:nano_embryo/presentation/features/products/presentation/screens/product_detail_content_screen.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/product_info_section.dart';
import 'package:nano_embryo/presentation/features/products/presentation/widgets/product_reviews_section.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_loading_schimmer.dart';

/// Product detail, modelled on ShopDetailsScreen: a tabbed shell (Info /
/// Reviews) over the product's images. Takes the product id (every navigation
/// to this screen passes `product.id`).
class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  final String coverImageUrl;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.coverImageUrl = '',
  });

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<AppTabItem> _tabs;
  bool _tabsInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabs = _getInitialTabs();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  List<AppTabItem> _getInitialTabs() {
    return [
      AppTabItem(label: 'Info', icon: null, content: const SizedBox()),
      AppTabItem(label: 'Reviews', icon: null, content: const SizedBox()),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productProvider(widget.productId));
    final colorScheme = Theme.of(context).colorScheme;

    return productAsync.when(
      data: (product) {
        // Populate tab content once the product resolves. Boolean flag (not an
        // `is SizedBox` check) — const-widget type checks are unreliable under
        // AOT tree-shaking in release mode. (Same pattern as ShopDetailsScreen.)
        if (!_tabsInitialized) {
          _tabsInitialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _tabs = [
                  AppTabItem(
                    label: 'Info',
                    icon: null,
                    content: ProductInfoSection(product: product),
                  ),
                  AppTabItem(
                    label: 'Reviews',
                    icon: null,
                    content: Material(
                      color: colorScheme.neutral,
                      child: ProductReviewsSection(productId: product.id),
                    ),
                  ),
                ];
              });
            }
          });
        }
        return ProductDetailContent(
          product: product,
          tabController: _tabController,
          tabs: _tabs,
        );
      },
      loading:
          () => ShopDetailsLoadingSchimmer(coverImageUrl: widget.coverImageUrl),
      error: (error, _) => _buildErrorWidget(),
    );
  }

  Widget _buildErrorWidget() {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.neutral,
      body: Center(
        child: ErrorStateWidget(
          title: '',
          subtitle: 'Failed to load product details',
          onPrimaryAction:
              () => ref.invalidate(productProvider(widget.productId)),
        ),
      ),
    );
  }
}
