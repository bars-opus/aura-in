// lib/core/link/entity_share_links.dart
import 'package:nano_embryo/core/link/config/aurain_link_config.dart';

/// Builds shareable web URLs for the entities that expose a "More" menu.
///
/// IMPORTANT: the web app (aura-in-web) only serves a fixed set of public
/// pages — `/book/<slug>` (a shop's booking page), `/m/<slug>` (a shop's
/// products page), plus `/order/<id>`, `/booking/<id>`, `/r/<id>`. There is no
/// public web page for a user profile or a freelancer. So we only produce a
/// deep link when the entity actually has a destination; otherwise callers
/// fall back to [homeUrl], which always resolves.
class EntityShareLinks {
  EntityShareLinks._();

  static String get _domain => AuraInLinkConfig.getConfig().baseDomain;

  /// The app's public home page — a guaranteed-valid fallback when an entity
  /// has no dedicated web page (profiles, freelancers, or a shop with no slug).
  static String get homeUrl {
    final fallback = AuraInLinkConfig.getConfig().fallbackWebUrl;
    return (fallback != null && fallback.isNotEmpty)
        ? fallback
        : 'https://$_domain';
  }

  /// A shop's booking page: `/book/<bookingSlug>`. Returns [homeUrl] when the
  /// shop has no slug yet (older shops / failed sync).
  static String shopBooking(String? bookingSlug) {
    final slug = bookingSlug?.trim() ?? '';
    return slug.isEmpty ? homeUrl : 'https://$_domain/book/$slug';
  }

  /// A shop's products page: `/m/<productsSlug>`. Returns [homeUrl] when the
  /// shop has no products slug.
  static String shopProducts(String? productsSlug) {
    final slug = productsSlug?.trim() ?? '';
    return slug.isEmpty ? homeUrl : 'https://$_domain/m/$slug';
  }

  /// Share text: the display name (if any) followed by the link.
  static String shareText({required String url, String? displayName}) {
    final name = (displayName ?? '').trim();
    return name.isEmpty ? url : '$name\n$url';
  }
}
