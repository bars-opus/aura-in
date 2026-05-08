// lib/features/freelancer/presentation/widgets/freelancer_portfolio_gallery.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/app/theme/design_tokens.dart';
import 'package:gap/gap.dart';
import 'package:nano_embryo/presentation/features/freelancer/presentation/providers/freelancer_details_provider.dart';

/// Widget displaying freelancer's portfolio images in a grid
class FreelancerPortfolioGallery extends ConsumerWidget {
  final String freelancerId;

  const FreelancerPortfolioGallery({
    super.key,
    required this.freelancerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsync = ref.watch(freelancerPortfolioProvider(freelancerId));
    final theme = Theme.of(context);

    return portfolioAsync.when(
      data: (images) {
        if (images.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portfolio',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(Spacing.sm.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: Spacing.sm.w,
                mainAxisSpacing: Spacing.sm.h,
                childAspectRatio: 1.0,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _showFullImage(context, images, index),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showFullImage(BuildContext context, List<String> images, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FullScreenImageGallery(
        images: images,
        initialIndex: index,
      ),
    );
  }
}

/// Full screen image gallery for portfolio viewing
class FullScreenImageGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageGallery({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageGallery> createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: Image.network(
                  widget.images[index],
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.white),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 40.h,
            right: 16.w,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.md.w,
                  vertical: Spacing.sm.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${widget.images.length}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
