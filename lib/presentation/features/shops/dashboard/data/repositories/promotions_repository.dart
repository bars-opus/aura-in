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
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/broadcast_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/promotion_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/broadcast_dto.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/loyalty_rule_dto.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/promotion_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Phase 13 — server-authoritative result of validate_and_apply_promo.
/// Returned by [PromotionsRepository.validateAndApplyPromo]. Client
/// treats `amountOff` and `newTotal` as opaque (no client-side math).
class PromoValidation {
  final String promotionId;
  final String code;
  final double amountOff;
  final double newTotal;
  final PromoSource source;

  const PromoValidation({
    required this.promotionId,
    required this.code,
    required this.amountOff,
    required this.newTotal,
    required this.source,
  });
}

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

  // ── Phase 13 — checkout + loyalty surface ────────────────────────

  /// Checkout hot path. Read-only — does NOT insert a redemption row.
  /// Branches on [code]:
  ///   * null/empty → auto-apply highest-discount silent code for
  ///     (shopId, caller). Returns null when no silent code matches.
  ///   * non-empty → manual entry with full eligibility chain.
  ///
  /// Raises typed PromotionException subtypes for each HINT code the
  /// RPC raises. Never branches on string-matching.
  Future<PromoValidation?> validateAndApplyPromo({
    required String shopId,
    String? code,
    String? userId,
    String? guestProfileId,
    required double bookingTotal,
    List<String>? serviceIds,
  }) async {
    assert(
      (userId == null) != (guestProfileId == null),
      'Exactly one of userId / guestProfileId must be non-null',
    );
    try {
      final result = await _supabase.rpc(
        'validate_and_apply_promo',
        params: {
          'p_shop_id': shopId,
          'p_code': code,
          'p_user_id': userId,
          'p_guest_profile_id': guestProfileId,
          'p_booking_total': bookingTotal,
          'p_service_ids': serviceIds,
        },
      );
      // RETURNS TABLE → arrives as a List<Map>. Empty when auto-apply
      // path found no silent code; non-empty otherwise.
      final rows = (result as List?) ?? const [];
      if (rows.isEmpty) {
        // Auto-apply path returning empty is the documented "no silent
        // code matches" sentinel. Manual-entry path raises instead, so
        // this branch only fires for code == null/empty.
        return null;
      }
      final row = rows.first as Map<String, dynamic>;
      return PromoValidation(
        promotionId: row['promotion_id'] as String,
        code: row['code'] as String,
        amountOff: (row['amount_off'] as num).toDouble(),
        newTotal: (row['new_total'] as num).toDouble(),
        source: PromoSource.fromString(row['source'] as String),
      );
    } on PostgrestException catch (e) {
      AppLogger.warn(
        'promotion.validate_failed',
        fields: {'shop_id': shopId, 'error': e.toString()},
      );
      throw _classifyValidateError(e);
    } catch (e) {
      AppLogger.warn(
        'promotion.validate_failed',
        fields: {'shop_id': shopId, 'error': e.toString()},
      );
      throw PromotionException('validate_and_apply_promo unexpected: $e',
          code: 'PROMO_GENERIC');
    }
  }

  PromotionException _classifyValidateError(PostgrestException e) {
    final hint = e.hint ?? '';
    // 42501 is the not-found / wrong-shop path.
    if (e.code == '42501') {
      return PromotionNotFoundException(hint);
    }
    // 22023 with HINT routes to specific Phase 13 subtypes.
    if (e.code == '22023') {
      switch (hint) {
        case 'CODE_EXPIRED':
          return PromoExpiredException();
        case 'CODE_LIMIT_REACHED':
          return PromotionLimitReachedException();
        case 'CODE_PER_CLIENT_MAX':
          return PromoPerClientMaxException();
        case 'CODE_MIN_AMOUNT_NOT_MET':
          return PromoMinAmountNotMetException();
        case 'CODE_SERVICE_NOT_ELIGIBLE':
          return PromoServiceNotEligibleException();
        case 'CODE_WRONG_CLIENT':
          return PromoWrongClientException();
        default:
          return InvalidDiscountAmountException();
      }
    }
    return PromotionException('validate_and_apply_promo: ${e.code} ${e.message}',
        code: 'PROMO_VALIDATE_FAILED');
  }

  /// Loads the shop's ACTIVE loyalty rule. Returns null when no rule
  /// is configured (the trigger is then a no-op).
  Future<LoyaltyRuleDTO?> getLoyaltyRule({required String shopId}) async {
    try {
      final row = await _supabase
          .from('loyalty_rules')
          .select('*')
          .eq('shop_id', shopId)
          .eq('is_active', true)
          .maybeSingle();
      if (row == null) return null;
      return LoyaltyRuleDTO.fromJson(row);
    } on PostgrestException catch (e) {
      AppLogger.warn(
        'loyalty_rule.fetch_failed',
        fields: {'shop_id': shopId, 'error': e.toString()},
      );
      // Read-side failures degrade to "no rule" rather than crashing
      // the screen — same shape as the existing getPromotionStats
      // fallback.
      throw LoyaltyRuleSaveFailedException();
    }
  }

  /// Upserts the shop's loyalty rule. Server deactivates any existing
  /// active rule and inserts the new one atomically. Returns the new
  /// rule id (or null when [isActive] was false, which only deactivates
  /// without inserting).
  Future<String?> upsertLoyaltyRule({
    required String shopId,
    required int triggerVisitCount,
    required DiscountType discountType,
    required double discountValue,
    bool isActive = true,
  }) async {
    try {
      final result = await _supabase.rpc(
        'upsert_loyalty_rule',
        params: {
          'p_shop_id': shopId,
          'p_trigger_visit_count': triggerVisitCount,
          'p_discount_type': discountType.value,
          'p_discount_value': discountValue,
          'p_is_active': isActive,
        },
      );
      return result as String?;
    } on PostgrestException catch (e) {
      AppLogger.warn(
        'loyalty_rule.upsert_failed',
        fields: {'shop_id': shopId, 'error': e.toString()},
      );
      if (e.code == '42501') {
        throw PromotionNotFoundException(shopId);
      }
      final hint = e.hint ?? '';
      // Payload-validation hints map to the existing
      // InvalidDiscountAmountException; everything else falls through
      // to the dedicated loyalty save-failed exception.
      if (e.code == '22023' &&
          (hint == 'DISCOUNT_VALUE_NOT_POSITIVE' ||
              hint == 'PERCENTAGE_OUT_OF_RANGE' ||
              hint == 'INVALID_DISCOUNT_TYPE' ||
              hint == 'TRIGGER_VISIT_COUNT_OUT_OF_RANGE')) {
        throw InvalidDiscountAmountException();
      }
      throw LoyaltyRuleSaveFailedException();
    } catch (e) {
      AppLogger.warn(
        'loyalty_rule.upsert_failed',
        fields: {'shop_id': shopId, 'error': e.toString()},
      );
      throw LoyaltyRuleSaveFailedException();
    }
  }

  // ── Existing internal helpers (unchanged) ────────────────────────

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

  // ── Phase 14 — Broadcasts ─────────────────────────────────────────
  //
  // Three methods extend this repository in place (Phase 14 SPEC line
  // 129 + planner brief locked) rather than introducing a separate
  // broadcasts_repository.dart. The classifier follows the same HINT-
  // driven pattern as _classifyPromotionError — no string matching.

  Future<List<BroadcastDTO>> getBroadcasts(String shopId) async {
    try {
      final rows = await _supabase
          .from('broadcasts')
          .select()
          .eq('shop_id', shopId)
          .order('created_at', ascending: false);
      return (rows as List)
          .map((r) => BroadcastDTO.fromJson(r as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      AppLogger.warn(
        'broadcasts.list_failed',
        fields: {
          'shop_id': shopId,
          'error_code': e.code ?? '',
          'error': e.toString(),
        },
      );
      throw _classifyBroadcastError(e);
    }
  }

  Future<int> previewBroadcastAudience({
    required String shopId,
    required BroadcastAudience audienceType,
    String? audienceParam,
  }) async {
    try {
      final res = await _supabase.rpc(
        'preview_broadcast_audience',
        params: {
          'p_shop_id': shopId,
          'p_audience_type': audienceType.sqlValue,
          'p_audience_param': audienceParam,
        },
      );
      return (res as int?) ?? 0;
    } on PostgrestException catch (e) {
      AppLogger.warn(
        'broadcasts.preview_failed',
        fields: {
          'shop_id': shopId,
          'audience_type': audienceType.sqlValue,
          'error_code': e.code ?? '',
          'error': e.toString(),
        },
      );
      throw _classifyBroadcastError(e);
    }
  }

  /// Returns the new broadcast's id and the actual recipient_count
  /// (post-dedup, post-opt-out filtering). The server reflects the
  /// truth — callers should not re-derive from local audience estimates.
  Future<({String broadcastId, int recipientCount})> sendBroadcast({
    required String shopId,
    required String subject,
    required String body,
    required BroadcastAudience audienceType,
    String? audienceParam,
    String? promotionId,
  }) async {
    try {
      final res = await _supabase.rpc(
        'send_broadcast',
        params: {
          'p_shop_id': shopId,
          'p_subject': subject,
          'p_body': body,
          'p_audience_type': audienceType.sqlValue,
          'p_audience_param': audienceParam,
          'p_promotion_id': promotionId,
        },
      );
      // RPC RETURNS TABLE — Supabase returns a List<Map> (one row).
      final row = (res as List).first as Map<String, dynamic>;
      return (
        broadcastId: row['broadcast_id'] as String,
        recipientCount: (row['recipient_count'] as num).toInt(),
      );
    } on PostgrestException catch (e) {
      AppLogger.warn(
        'broadcasts.send_failed',
        fields: {
          'shop_id': shopId,
          'audience_type': audienceType.sqlValue,
          'error_code': e.code ?? '',
          'error': e.toString(),
        },
      );
      throw _classifyBroadcastError(e);
    }
  }

  /// Routes PostgrestException → typed BroadcastException via the
  /// (code, hint) tuple. Mirrors _classifyPromotionError's HINT-driven
  /// pattern — never branches on `e.message` text.
  BroadcastException _classifyBroadcastError(PostgrestException e) {
    final code = e.code;
    final hint = e.hint;

    if (code == '55P03') {
      if (hint == 'BROADCAST_DAILY_LIMIT') return BroadcastRateLimitException();
      if (hint == 'BROADCAST_IN_FLIGHT') return BroadcastInFlightException();
    }
    if (code == '22023') {
      switch (hint) {
        case 'AUDIENCE_TYPE_INVALID':
        case 'AUDIENCE_PARAM_REQUIRED':
        case 'AUDIENCE_PARAM_FORBIDDEN':
          return BroadcastInvalidAudienceException();
        case 'PROMO_NOT_VALID':
          return BroadcastPromoInvalidException();
        case 'BROADCAST_CAP_EXCEEDED':
          return BroadcastCapExceededException();
        case 'SUBJECT_TOO_LONG':
        case 'BODY_TOO_LONG':
        case 'REQUIRED_FIELD_MISSING':
          return BroadcastSaveFailedException();
      }
    }
    // 42501 sanitized not_found, plus anything unmapped.
    return BroadcastSaveFailedException();
  }
}
