// lib/features/shop/creation/providers/draft_context_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls whether shared creation screens (hours, contacts, documents,
/// social links, media) write to the shop draft or the freelancer draft.
///
/// Set to [DraftContext.freelancer] in FreelancerCreationDashboard.initState()
/// and reset to [DraftContext.shop] in its dispose() so shop flows are
/// never affected.
enum DraftContext { shop, freelancer }

final draftContextProvider = StateProvider<DraftContext>(
  (ref) => DraftContext.shop,
);
