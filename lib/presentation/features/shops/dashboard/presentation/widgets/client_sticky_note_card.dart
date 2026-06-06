// lib/presentation/features/shops/dashboard/presentation/widgets/client_sticky_note_card.dart
//
// Phase 12 — owner-private sticky note about a client. Surfaces on
// BookingDetailScreen under the isShopOwner branch. Client never sees
// it.
//
// Save model: explicit Save button, NO debounce, NO auto-save (locked
// product decision). The button enables only when the typed body
// differs from the last server-loaded body. After save success the
// snapshot updates and the button re-disables.
//
// Phase 12 limitation: BookingModel does not currently expose
// guestProfileId. This widget renders for registered-user bookings
// only (booking.userId is non-empty). Guest-booking sticky notes are
// out of scope for v1 — adding them requires extending the booking
// DTO to surface guest_profile_id.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/widgets/feedback/snackbar_widget.dart';
import 'package:nano_embryo/presentation/features/shops/booking/data/models/booking_model.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/client_notes_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/client_note_provider.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';

class ClientStickyNoteCard extends ConsumerStatefulWidget {
  final BookingModel booking;

  const ClientStickyNoteCard({super.key, required this.booking});

  @override
  ConsumerState<ClientStickyNoteCard> createState() =>
      _ClientStickyNoteCardState();
}

class _ClientStickyNoteCardState extends ConsumerState<ClientStickyNoteCard> {
  static const int _maxChars = 2000;

  final TextEditingController _controller = TextEditingController();
  String _initialBody = '';
  bool _didSeed = false;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ClientNoteKey get _key => ClientNoteKey(
        shopId: widget.booking.shopId,
        userId: widget.booking.userId,
      );

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(dashboardRepositoryProvider);
      final newBody = _controller.text;
      await repo.upsertClientNote(
        shopId: widget.booking.shopId,
        userId: widget.booking.userId,
        body: newBody,
      );
      _initialBody = newBody;
      ref.invalidate(clientNoteProvider(_key));
      if (!mounted) return;
      Snackbar.success(context, 'Note saved');
      setState(() => _saving = false);
    } on ClientNoteException catch (e) {
      if (!mounted) return;
      Snackbar.error(context, e.userMessage);
      setState(() => _saving = false);
    } catch (_) {
      if (!mounted) return;
      Snackbar.error(context, NoteSaveFailedException().userMessage);
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Skip rendering entirely for guest bookings — the BookingModel does
    // not surface guestProfileId in this version. Guest sticky notes
    // are a future-phase extension.
    if (widget.booking.userId.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final noteAsync = ref.watch(clientNoteProvider(_key));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sticky_note_2_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Private note about this client',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Only you can see this.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            noteAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "We couldn't load the note.",
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(clientNoteProvider(_key)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (note) {
                if (!_didSeed) {
                  _initialBody = note?.body ?? '';
                  _controller.text = _initialBody;
                  _didSeed = true;
                }
                return _buildEditor(theme);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditor(ThemeData theme) {
    final canSave = !_saving &&
        _controller.text != _initialBody &&
        _controller.text.length <= _maxChars;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: _controller,
          maxLines: null,
          minLines: 3,
          maxLength: _maxChars,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          inputFormatters: [LengthLimitingTextInputFormatter(_maxChars)],
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "e.g. Prefers no fringe, allergic to fragrance X.",
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_saving)
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            FilledButton(
              onPressed: canSave ? _save : null,
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}
