// lib/features/shop/creation/presentation/providers/contacts_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/contact_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/shop_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/draft_context_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/domain/models/freelancer_draft.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/freelancer_creation_provider.dart'
    show freelancerCreationProvider;
import './shop_creation_provider.dart';

class ContactsNotifier extends StateNotifier<List<ContactDraft>> {
  final Ref _ref;

  ContactsNotifier({required Ref ref}) : _ref = ref, super([]) {
    final draftContext = _ref.read(draftContextProvider);

    if (draftContext == DraftContext.freelancer) {
      // Initialize from freelancer draft and listen for external changes
      // (e.g., loadExistingFreelancer).
      _syncFromFreelancerDraft(_ref.read(freelancerCreationProvider));
      _ref.listen<FreelancerDraft>(freelancerCreationProvider, (_, next) {
        _syncFromFreelancerDraft(next);
      });
    } else {
      // Initialize from shop draft and listen for external changes
      // (e.g., loadPublishedShop already ran before this notifier was first
      // accessed).
      _syncFromDraft(_ref.read(shopCreationProvider));
      _ref.listen<ShopDraft>(shopCreationProvider, (_, next) {
        _syncFromDraft(next);
      });
    }
  }

  void _syncFromDraft(ShopDraft draft) {
    final newContacts = draft.contacts.isNotEmpty
        ? draft.contacts
        : [
            if (draft.phone != null && draft.phone!.isNotEmpty)
              ContactDraft(
                type: ContactType.phone,
                value: draft.phone!,
                isPrimary: true,
                sortOrder: 0,
              ),
            if (draft.email != null && draft.email!.isNotEmpty)
              ContactDraft(
                type: ContactType.email,
                value: draft.email!,
                isPrimary: true,
                sortOrder: 1,
              ),
            if (draft.website != null && draft.website!.isNotEmpty)
              ContactDraft(
                type: ContactType.website,
                value: draft.website!,
                isPrimary: false,
                sortOrder: 2,
              ),
          ];

    if (!_listsEqual(newContacts)) {
      state = newContacts;
    }
  }

  void _syncFromFreelancerDraft(FreelancerDraft draft) {
    if (!_listsEqual(draft.contacts)) {
      state = draft.contacts;
    }
  }

  bool _listsEqual(List<ContactDraft> newContacts) {
    if (state.length != newContacts.length) return false;
    for (int i = 0; i < state.length; i++) {
      if (state[i].type != newContacts[i].type ||
          state[i].value != newContacts[i].value) {
        return false;
      }
    }
    return true;
  }

  void addContact(ContactDraft contact) {
    state = [...state, contact];
    _updateDraft();
  }

  void updateContact(int index, ContactDraft contact) {
    final updated = List<ContactDraft>.from(state);
    updated[index] = contact;
    state = updated;
    _updateDraft();
  }

  void removeContact(int index) {
    final updated = List<ContactDraft>.from(state)..removeAt(index);
    state = updated;
    _updateDraft();
  }

  void reorderContacts(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final contacts = List<ContactDraft>.from(state);
    final item = contacts.removeAt(oldIndex);
    contacts.insert(newIndex, item);
    state = contacts;
    _updateDraft();
  }

  void _updateDraft() {
    if (_ref.read(draftContextProvider) == DraftContext.freelancer) {
      _ref.read(freelancerCreationProvider.notifier).updateContacts(state);
    } else {
      _ref.read(shopCreationProvider.notifier).updateContacts(state);
    }
  }
}

final contactsProvider =
    StateNotifierProvider<ContactsNotifier, List<ContactDraft>>((ref) {
      ref.watch(draftContextProvider); // re-create when context switches
      return ContactsNotifier(ref: ref);
    });
