// lib/features/dashboard/data/repositories/promotions_repository.dart
//
// Promotion CRUD + redemption surface for the Tools tab.
//
// Phase 10.5 changes (Tasks 3.2 + 3.3):
//   * Every raw `throw Exception('Failed to ...: $e')` is replaced with
//     a typed PromotionException subtype routed through PostgrestException
//     codes (NOT English string-matching). UI gets stable codes.
//   * incrementUsage now calls the atomic redeem_promotion RPC instead
//     of the two-step (counter UPDATE + ledger INSERT) pattern that left
//     the counter over-counted on partial failure (checklist 1.10).
//   * _getTotalRevenueImpact collapses from O(N) Postgrest calls to
//     exactly one via .inFilter on promotion_ids (checklist 3.2).
//   * getPromotions caps at 200 rows server-side (checklist 3.1, 2.5).

import 'package:nano_embryo/core/utils/logging/app_logger.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/promotion_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/promotion_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PromotionsRepository {
  final SupabaseClient _supabase;
  static const String _table = 'promotions';
  static const String _redemptionsTable = 'promotion_redemptions';
  static const int _maxPromotionsPerShop = 200;

  PromotionsRepository({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  Future<List<Promotion>> getPromotions(
    String shopId, {
    bool? activeOnly,
  }) async {
    try {
      // Postgrest builder narrows on each chained method; use dynamic
      // to match the existing repo pattern in this codebase.
      dynamic query = _supabase.from(_table).select().eq('shop_id', shopId);
      if (activeOnly == true) {
        query = query.eq('is_active', true);
      }
      query = query.order('created_at', ascending: false);
      query = query.limit(_maxPromotionsPerShop);

      final response = await query;
      final List<Map<String, dynamic>> promotions = List.from(response);
      return promotions.map(Promotion.fromJson).toList();
    } on PostgrestException catch (e) {
      throw PromotionException('getPromotions: ${e.code} ${e.message}',
          code: 'PROMO_LOAD_FAILED');
    } catch (e) {
      throw PromotionException('getPromotions unexpected: $e',
          code: 'PROMO_LOAD_FAILED');
    }
  }

  Future<Promotion> createPromotion(Promotion promotion) async {
    try {
      final response = await _supabase
          .from(_table)
          .insert(promotion.toJson())
          .select()
          .single();
      return Promotion.fromJson(response);
    } on PostgrestException catch (e) {
      // 23505 = unique_violation — robust against any future schema
      // rename. String-matching on 'duplicate key' was fragile and
      // English-only.
      if (e.code == '23505') throw DuplicateCodeException();
      throw PromotionException('createPromotion: ${e.code} ${e.message}',
          code: 'PROMO_CREATE_FAILED');
    } catch (e) {
      throw PromotionException('createPromotion unexpected: $e',
          code: 'PROMO_CREATE_FAILED');
    }
  }

  Future<Promotion> updatePromotion(Promotion promotion) async {
    try {
      final response = await _supabase
          .from(_table)
          .update(promotion.toJson())
          .eq('id', promotion.id)
          .select()
          .single();
      return Promotion.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '23505') throw DuplicateCodeException();
      throw PromotionException('updatePromotion: ${e.code} ${e.message}',
          code: 'PROMO_UPDATE_FAILED');
    } catch (e) {
      throw PromotionException('updatePromotion unexpected: $e',
          code: 'PROMO_UPDATE_FAILED');
    }
  }

  Future<void> deletePromotion(String promotionId) async {
    try {
      await _supabase.from(_table).delete().eq('id', promotionId);
    } on PostgrestException catch (e) {
      throw PromotionException('deletePromotion: ${e.code} ${e.message}',
          code: 'PROMO_DELETE_FAILED');
    } catch (e) {
      throw PromotionException('deletePromotion unexpected: $e',
          code: 'PROMO_DELETE_FAILED');
    }
  }

  /// Atomically redeems [promotionId] for [bookingId]. Idempotent on
  /// (promotion_id, booking_id) — second call returns the same id and
  /// does NOT double-bump the counter.
  ///
  /// Replaces the previous two-step (RPC + INSERT) pattern via the
  /// new redeem_promotion RPC (migration 20260604000400).
  Future<void> incrementUsage(
    String promotionId,
    String bookingId,
    String userId,
    double discountAmount,
  ) async {
    try {
      await _supabase.rpc(
        'redeem_promotion',
        params: {
          'p_promotion_id': promotionId,
          'p_booking_id': bookingId,
          'p_user_id': userId,
          'p_discount_amount': discountAmount,
        },
      );
    } on PostgrestException catch (e) {
      final hint = e.hint ?? '';
      if (hint.contains('PROMO_LIMIT_REACHED')) {
        throw PromotionLimitReachedException();
      }
      if (hint.contains('AMOUNT_MUST_BE_POSITIVE') ||
          hint.contains('NULL_NOT_ALLOWED')) {
        throw InvalidDiscountAmountException();
      }
      if (e.code == 'P0002' || e.code == '42501') {
        throw PromotionNotFoundException(promotionId);
      }
      throw PromotionException('redeem_promotion: ${e.code} ${e.message}',
          code: 'PROMO_REDEEM_FAILED');
    } catch (e) {
      throw PromotionException('redeem_promotion unexpected: $e',
          code: 'PROMO_REDEEM_FAILED');
    }
  }

  Future<Map<String, dynamic>> getPromotionStats(String shopId) async {
    try {
      final promotions = await getPromotions(shopId);

      final totalRedemptions = promotions.fold<int>(
        0,
        (sum, p) => sum + p.usageCount,
      );
      final totalRevenueImpact = await _getTotalRevenueImpact(promotions);

      final activePromotions = promotions.where((p) => p.isValid).length;
      final expiredPromotions = promotions.where((p) => p.isExpired).length;

      final mostUsed = promotions.isNotEmpty
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
      // Stats are optional UX — degrade to zeros rather than break the
      // surrounding controller.
      AppLogger.warn(
        'promotions.stats_failed',
        fields: {'shop_id': shopId, 'error': e.toString()},
      );
      return const {
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

  /// Total discount given out across all of a shop's promotions.
  ///
  /// Previously O(N) Postgrest calls (one per promotion). Now O(1):
  /// a single `.inFilter` over the promotion IDs, then fold client-side.
  Future<double> _getTotalRevenueImpact(List<Promotion> promotions) async {
    if (promotions.isEmpty) return 0.0;
    try {
      final promotionIds = promotions.map((p) => p.id).toList();
      final response = await _supabase
          .from(_redemptionsTable)
          .select('discount_amount')
          .inFilter('promotion_id', promotionIds);
      final rows = List<Map<String, dynamic>>.from(response);
      return rows.fold<double>(
        0,
        (sum, r) => sum + ((r['discount_amount'] as num?)?.toDouble() ?? 0),
      );
    } catch (e) {
      // Graceful degradation: revenue impact is an analytics field,
      // not a correctness-critical one. Logging + zero return mirrors
      // the surrounding stats-fallback shape.
      AppLogger.warn(
        'promotions.revenue_impact_failed',
        fields: {'error': e.toString()},
      );
      return 0.0;
    }
  }
}
