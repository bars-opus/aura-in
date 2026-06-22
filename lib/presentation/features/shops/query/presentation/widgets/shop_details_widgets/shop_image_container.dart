import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Single image tile used by ShopImagePageview and any other image container.
/// Pass [isPreview] = true when [imageUrl] is a local file path (e.g. during
/// product/shop creation before upload). Default is a network image.
class ShopImageContainer extends StatelessWidget {
  final String imageUrl;
  final bool isPreview;
  final BorderRadius? borderRadius;

  const ShopImageContainer({
    super.key,
    required this.imageUrl,
    this.isPreview = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final image = isPreview
        ? Image.file(
            File(imageUrl),
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (_, __, ___) => _placeholder(),
          )
        : Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (_, __, ___) => _placeholder(),
          );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _placeholder() {
    return Center(
      child: Icon(
        Icons.image_not_supported_rounded,
        color: Colors.grey.shade500,
        size: 50.h,
      ),
    );
  }
}
