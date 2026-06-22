import 'dart:async';

import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/query/presentation/widgets/shop_details_widgets/shop_image_container.dart';

class ShopImagePageview extends StatefulWidget {
  final List<String> shopImageUrls;
  final Duration autoScrollDuration;
  final Duration transitionDuration;
  final double height;
  final bool isPreview;

  const ShopImagePageview({
    super.key,
    required this.shopImageUrls,
    this.autoScrollDuration = const Duration(seconds: 5),
    this.transitionDuration = const Duration(milliseconds: 500),
    this.height = 400,
    this.isPreview = false,
  });

  @override
  State<ShopImagePageview> createState() => _ShopImagePageviewState();
}

class _ShopImagePageviewState extends State<ShopImagePageview> {
  late PageController _pageController;
  Timer? _timer; // Make it nullable
  int _currentPage = 0;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    // Cancel existing timer if any
    _timer?.cancel();

    // Only start timer if there's more than 1 image
    if (widget.shopImageUrls.length <= 1) {
      _timer = null; // Explicitly set to null
      return;
    }

    _timer = Timer.periodic(widget.autoScrollDuration, (timer) {
      if (_isDisposed || !mounted) {
        timer.cancel();
        return;
      }

      _goToNextPage();
    });
  }

  @override
  void didUpdateWidget(ShopImagePageview oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset to first page if image list changes
    if (oldWidget.shopImageUrls.length != widget.shopImageUrls.length) {
      _pageController.jumpToPage(0);
      setState(() => _currentPage = 0);

      // Restart auto-scroll with new image count
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel(); // Safe null-aware call
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (!_pageController.hasClients) return;

    final nextPage = (_currentPage + 1) % widget.shopImageUrls.length;

    _pageController.animateToPage(
      nextPage,
      duration: widget.transitionDuration,
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Widget _buildImageContainer(String imageUrl) {
    return ShopImageContainer(imageUrl: imageUrl, isPreview: widget.isPreview);
  }

  @override
  Widget build(BuildContext context) {
    // Handle empty image list
    if (widget.shopImageUrls.isEmpty) {
      return Container(
        width: double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[300],
        ),
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 50,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView(
          controller: _pageController,
          physics: const AlwaysScrollableScrollPhysics(),
          onPageChanged: _onPageChanged,
          children: widget.shopImageUrls.map(_buildImageContainer).toList(),
        ),

        // Page Indicator
        if (widget.shopImageUrls.length > 1)
          Positioned(bottom: 16, child: _buildPageIndicator()),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.shopImageUrls.length, (index) {
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  _currentPage == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
            ),
          );
        }),
      ),
    );
  }
}
