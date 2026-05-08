// lib/features/shop/creation/presentation/providers/documents_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/presentation/features/shops/creation/domain/models/document_draft.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/draft_context_provider.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/domain/models/freelancer_draft.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/freelancer_creation_provider.dart'
    show freelancerCreationProvider;
import './shop_creation_provider.dart';

class DocumentsNotifier extends StateNotifier<List<DocumentDraft>> {
  final Ref _ref;

  DocumentsNotifier({required Ref ref, List<DocumentDraft>? initialDocuments})
    : _ref = ref,
      super(initialDocuments ?? []) {
    final draftContext = _ref.read(draftContextProvider);

    if (draftContext == DraftContext.freelancer) {
      _ref.listen<FreelancerDraft>(freelancerCreationProvider, (previous, next) {
        if (!_listsAreEqual(next.documents, state)) {
          print(
            '📄 DocumentsNotifier (freelancer): Syncing from draft (${next.documents.length} docs)',
          );
          state = next.documents;
        }
      });
    } else {
      _ref.listen(shopCreationProvider, (previous, next) {
        if (!_listsAreEqual(next.documents, state)) {
          print(
            '📄 DocumentsNotifier: Syncing from draft (${next.documents.length} docs)',
          );
          state = next.documents;
        }
      });
    }
  }

  bool _listsAreEqual(List<DocumentDraft> a, List<DocumentDraft> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
      if (a[i].type != b[i].type) return false;
      if (a[i].expiryDate != b[i].expiryDate) return false;
    }
    return true;
  }

  void addDocument(DocumentDraft document) {
    print('📄 Adding document: ${document.title}');
    state = [...state, document];
    _updateDraft();
  }

  void updateDocument(int index, DocumentDraft document) {
    print('📄 Updating document at index $index');
    final updated = List<DocumentDraft>.from(state);
    updated[index] = document;
    state = updated;
    _updateDraft();
  }

  void removeDocument(int index) {
    print('📄 Removing document at index $index');
    final updated = List<DocumentDraft>.from(state)..removeAt(index);
    state = updated;
    _updateDraft();
  }

  void reorderDocuments(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final docs = List<DocumentDraft>.from(state);
    final item = docs.removeAt(oldIndex);
    docs.insert(newIndex, item);
    state = docs;
    _updateDraft();
  }

  void _updateDraft() {
    if (_ref.read(draftContextProvider) == DraftContext.freelancer) {
      _ref.read(freelancerCreationProvider.notifier).updateDocuments(state);
    } else {
      _ref.read(shopCreationProvider.notifier).updateDocuments(state);
    }
  }
}

final documentsProvider =
    StateNotifierProvider<DocumentsNotifier, List<DocumentDraft>>((ref) {
      final draftContext = ref.watch(draftContextProvider);
      if (draftContext == DraftContext.freelancer) {
        final docs = ref.read(freelancerCreationProvider).documents;
        return DocumentsNotifier(ref: ref, initialDocuments: docs);
      }
      final draft = ref.watch(shopCreationProvider);
      return DocumentsNotifier(ref: ref, initialDocuments: draft.documents);
    });
