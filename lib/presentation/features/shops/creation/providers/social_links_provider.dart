// lib/features/shop/creation/presentation/providers/social_links_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/social_link_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/draft_context_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/freelancer_creation_provider.dart'
    show freelancerCreationProvider;
import 'shop_creation_provider.dart';

class SocialLinksNotifier extends StateNotifier<List<SocialLinkDraft>> {
  final Ref _ref;

  SocialLinksNotifier({
    required Ref ref,
    List<SocialLinkDraft>? initialLinks,
  }) : _ref = ref,
       super(initialLinks ?? []);

  void addLink(SocialLinkDraft link) {
    state = [...state, link];
    _updateDraft();
  }

  void updateLink(int index, SocialLinkDraft link) {
    final updated = List<SocialLinkDraft>.from(state);
    updated[index] = link;
    state = updated;
    _updateDraft();
  }

  void removeLink(int index) {
    final updated = List<SocialLinkDraft>.from(state)..removeAt(index);
    state = updated;
    _updateDraft();
  }

  void reorderLinks(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final links = List<SocialLinkDraft>.from(state);
    final item = links.removeAt(oldIndex);
    links.insert(newIndex, item);
    state = links;
    _updateDraft();
  }

  void _updateDraft() {
    if (_ref.read(draftContextProvider) == DraftContext.freelancer) {
      _ref.read(freelancerCreationProvider.notifier).updateSocialLinks(state);
    } else {
      _ref.read(shopCreationProvider.notifier).updateSocialLinks(state);
    }
  }
}

final socialLinksProvider =
    StateNotifierProvider<SocialLinksNotifier, List<SocialLinkDraft>>((ref) {
      final draftContext = ref.watch(draftContextProvider);
      if (draftContext == DraftContext.freelancer) {
        final links = ref.read(freelancerCreationProvider).socialLinks;
        return SocialLinksNotifier(ref: ref, initialLinks: links);
      }
      final draft = ref.watch(shopCreationProvider);
      return SocialLinksNotifier(ref: ref, initialLinks: draft.socialLinks);
    });
