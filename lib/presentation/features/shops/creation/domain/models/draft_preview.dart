// lib/features/shop/creation/domain/entities/draft_preview.dart
import 'package:equatable/equatable.dart';
import 'shop_draft.dart';

/// Lightweight preview of a draft for display in list
class DraftPreview extends Equatable {
  final String profileId;
  final String? shopName;
  final String? shopType;
  final int completedSections;
  final int totalSections;
  final DateTime lastUpdated;
  final String? coverImagePath;

  const DraftPreview({
    required this.profileId,
    this.shopName,
    this.shopType,
    required this.completedSections,
    required this.totalSections,
    required this.lastUpdated,
    this.coverImagePath,
  });

  /// Create from full ShopDraft
  factory DraftPreview.fromDraft(ShopDraft draft, String profileId) {
    return DraftPreview(
      profileId: profileId,
      shopName: draft.shopName,
      shopType: draft.shopType,
      completedSections: draft.completedSectionsCount,
      totalSections: ShopDraft.totalSections,
      lastUpdated: draft.lastUpdated ?? DateTime.now(),
      coverImagePath: draft.localImagePaths.isNotEmpty 
          ? draft.localImagePaths.first 
          : null,
    );
  }

  /// Calculate completion percentage
  double get completionPercentage => 
      completedSections / totalSections;

  /// Get formatted last updated
  String get formattedLastUpdated {
    final now = DateTime.now();
    final difference = now.difference(lastUpdated);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  List<Object?> get props => [
    profileId, shopName, shopType, completedSections, 
    totalSections, lastUpdated, coverImagePath
  ];
}
