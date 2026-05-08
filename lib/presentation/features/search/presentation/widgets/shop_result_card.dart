// lib/features/search/presentation/widgets/shop_result_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/presentation/features/search/models/shop_search_result.dart';

class ShopResultCard extends StatelessWidget {
  final ShopSearchResult shop;
  final VoidCallback? onTap;

  const ShopResultCard({
    super.key,
    required this.shop,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shop image
              Container(
                width: 70.w,
                height: 70.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8.r),
                  image: shop.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(shop.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: shop.imageUrl == null
                    ? Icon(
                        Icons.store,
                        size: 30.h,
                        color: Colors.grey.shade400,
                      )
                    : null,
              ),
              SizedBox(width: 12.w),

              // Shop info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            shop.title,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (shop.verified)
                          Icon(
                            Icons.verified,
                            size: 16.h,
                            color: Colors.blue,
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),

                    // Rating and distance
                    Wrap(
                      spacing: 8.w,
                      children: [
                        if (shop.averageRating != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 14.h,
                                color: Colors.amber,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                shop.averageRating!.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                ' (${shop.reviewCount ?? 0})',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        if (shop.distanceKm != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 12.h,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                '${shop.distanceKm!.toStringAsFixed(1)}km',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),

                    // Luxury level tag
                    if (shop.luxuryLevel != null)
                      Container(
                        margin: EdgeInsets.only(top: 4.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getLuxuryLevelColor(shop.luxuryLevel!)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          shop.luxuryLevel!,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: _getLuxuryLevelColor(shop.luxuryLevel!),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    // Top services preview (if available)
                    if (shop.topServices != null && shop.topServices!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          shop.topServices!.take(3).join(' • '),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),

              // Chevron
              Icon(
                Icons.chevron_right,
                size: 20.h,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLuxuryLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'budget':
        return Colors.green;
      case 'mid-range':
        return Colors.blue;
      case 'premium':
        return Colors.purple;
      case 'luxury':
        return Colors.amber;
      case 'ultraluxury':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
