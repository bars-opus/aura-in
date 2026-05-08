// lib/features/dashboard/data/repositories/promotions_repository.dart
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/promotion_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PromotionsRepository {
  final SupabaseClient _supabase;
  static const String _table = 'promotions';
  static const String _redemptionsTable = 'promotion_redemptions';

  PromotionsRepository({required SupabaseClient supabaseClient})
    : _supabase = supabaseClient;

  Future<List<Promotion>> getPromotions(
    String shopId, {
    bool? activeOnly,
  }) async {
    try {
      // Start with the query
      var query = _supabase.from(_table).select().eq('shop_id', shopId);

      // Apply active filter if needed
      if (activeOnly == true) {
        query = query.eq('is_active', true);
      }

      // Apply ordering LAST (after all filters)
      final response = await query.order('created_at', ascending: false);

      final List<Map<String, dynamic>> promotions = List.from(response);
      return promotions.map(Promotion.fromJson).toList();
    } catch (e) {
      throw Exception('Failed to fetch promotions: $e');
    }
  }

  Future<Promotion> createPromotion(Promotion promotion) async {
    try {
      final response =
          await _supabase
              .from(_table)
              .insert(promotion.toJson())
              .select()
              .single();

      return Promotion.fromJson(response);
    } catch (e) {
      if (e.toString().contains('duplicate key')) {
        throw Exception('Promotion code already exists');
      }
      throw Exception('Failed to create promotion: $e');
    }
  }

  Future<Promotion> updatePromotion(Promotion promotion) async {
    try {
      final response =
          await _supabase
              .from(_table)
              .update(promotion.toJson())
              .eq('id', promotion.id)
              .select()
              .single();

      return Promotion.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update promotion: $e');
    }
  }

  Future<void> deletePromotion(String promotionId) async {
    try {
      await _supabase.from(_table).delete().eq('id', promotionId);
    } catch (e) {
      throw Exception('Failed to delete promotion: $e');
    }
  }

  Future<void> incrementUsage(
    String promotionId,
    String bookingId,
    String userId,
    double discountAmount,
  ) async {
    try {
      // Increment usage count in promotions table
      await _supabase.rpc(
        'increment_promotion_usage',
        params: {'p_promotion_id': promotionId},
      );

      // Record redemption
      await _supabase.from(_redemptionsTable).insert({
        'promotion_id': promotionId,
        'booking_id': bookingId,
        'user_id': userId,
        'discount_amount': discountAmount,
      });
    } catch (e) {
      throw Exception('Failed to record promotion usage: $e');
    }
  }

  Future<Map<String, dynamic>> getPromotionStats(String shopId) async {
    try {
      final promotions = await getPromotions(shopId);

      final totalRedemptions = promotions.fold<int>(
        0,
        (sum, p) => sum + p.usageCount,
      );
      final totalRevenueImpact = await _getTotalRevenueImpact(shopId);

      final activePromotions = promotions.where((p) => p.isValid).length;
      final expiredPromotions = promotions.where((p) => p.isExpired).length;

      // Find most used promotion
      final mostUsed =
          promotions.isNotEmpty
              ? promotions.reduce((a, b) => a.usageCount > b.usageCount ? a : b)
              : null;

      return {
        'total_promotions': promotions.length,
        'active_promotions': activePromotions,
        'expired_promotions': expiredPromotions,
        'total_redemptions': totalRedemptions,
        'total_revenue_impact': totalRevenueImpact,
        'most_used_code': mostUsed?.code,
        'most_used_count': mostUsed?.usageCount ?? 0,
      };
    } catch (e) {
      return {
        'total_promotions': 0,
        'active_promotions': 0,
        'expired_promotions': 0,
        'total_redemptions': 0,
        'total_revenue_impact': 0.0,
        'most_used_code': null,
        'most_used_count': 0,
      };
    }
  }

  Future<double> _getTotalRevenueImpact(String shopId) async {
    try {
      // Get promotions first
      final promotions = await getPromotions(shopId);

      if (promotions.isEmpty) {
        return 0.0;
      }

      double totalImpact = 0.0;

      // Loop through each promotion and sum discount amounts
      for (final promotion in promotions) {
        final response = await _supabase
            .from(_redemptionsTable)
            .select('discount_amount')
            .eq('promotion_id', promotion.id);

        final redemptions = List<Map<String, dynamic>>.from(response);
        final promotionImpact = redemptions.fold<double>(
          0,
          (sum, r) => sum + (r['discount_amount'] as num).toDouble(),
        );
        totalImpact += promotionImpact;
      }

      return totalImpact;
    } catch (e) {
      return 0.0;
    }
  }
}
