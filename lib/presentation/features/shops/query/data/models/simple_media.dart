// Add this at the top of your shop_list_item_dto.dart file

// lib/features/shops/data/dtos/shop_media_dto.dart

class SimpleMedia {
  final String id;
  final String url;
  final String mediaType;
  final int? sortOrder;
  final String? caption;

  SimpleMedia({
    required this.id,
    required this.url,
    required this.mediaType,
    this.sortOrder,
    this.caption,
  });

  factory SimpleMedia.fromJson(Map<String, dynamic> json) {
    return SimpleMedia(
      id: json['id'] as String, // This should never be null
      url: json['url'] as String, // This should never be null
      mediaType: json['media_type'] as String, // This should never be null
      sortOrder: json['sort_order'] as int?, // Nullable - use 'as int?'
      caption: json['caption'] as String?, // Nullable - use 'as String?'
    );
  }
}
