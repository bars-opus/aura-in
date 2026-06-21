import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/promotion_model.dart';

/// Lightweight result snapshot the parent screen reads from
/// [onApplied]. Mirrors [PromoValidation] but adds a source-keyed
/// display label that's already i18n-friendly for the line item.
class AppliedPromo {
  final String promotionId;
  final String code;

  /// Phase 17: int minor units (kobo). Display via `formatMoney(amountOffMinor, currency)`.
  final int amountOffMinor;
  final int newTotalMinor;
  final PromoSource source;

  const AppliedPromo({
    required this.promotionId,
    required this.code,
    required this.amountOffMinor,
    required this.newTotalMinor,
    required this.source,
  });

  /// Source-keyed label shown in the totals line item. Owner-defined
  /// codes show the code text; silent codes show a friendly name.
  String get displayLabel {
    switch (source) {
      case PromoSource.loyalty:
        return 'Loyalty reward';
      case PromoSource.recovery:
        return 'Welcome back';
      case PromoSource.ownerDefined:
        return 'Code: $code';
    }
  }
}
