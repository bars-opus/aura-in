import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationBubble extends StatelessWidget {
  final Map<String, dynamic> metadata;
  final String? fileUrl;
  final bool isUser;

  const LocationBubble({
    super.key,
    required this.metadata,
    required this.isUser,
    this.fileUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final address = metadata['address'] as String? ?? 'Shared location';
    final lat = (metadata['lat'] as num?)?.toDouble();
    final lng = (metadata['lng'] as num?)?.toDouble();
    final textColor = isUser ? colorScheme.onPrimary : colorScheme.onSurface;

    return InkWell(
      onTap: (lat != null && lng != null) ? () => _openMaps(lat, lng) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fileUrl != null)
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 220.w, maxHeight: 150.h),
              child: CachedNetworkImage(
                imageUrl: fileUrl!,
                fit: BoxFit.cover,
                width: 220.w,
                placeholder: (_, __) => SizedBox(
                  width: 220.w,
                  height: 150.h,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => SizedBox(
                  width: 220.w,
                  height: 80.h,
                  child: const Center(child: Icon(Icons.map_outlined)),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_pin, size: 16, color: textColor),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMaps(double lat, double lng) async {
    final Uri uri;
    if (Platform.isIOS) {
      uri = Uri.parse('https://maps.apple.com/?ll=$lat,$lng&q=Location');
    } else {
      uri = Uri.parse('geo:$lat,$lng?q=$lat,$lng(Location)');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
