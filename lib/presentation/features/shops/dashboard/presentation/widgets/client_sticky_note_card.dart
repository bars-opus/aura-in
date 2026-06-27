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
// Identity resolution: registered bookings have a non-empty
// booking.userId; guest bookings have booking.guestProfileId. The
// server's CHECK constraint guarantees exactly one is set. If both
// are absent (a malformed booking shape), the widget renders nothing
// rather than crash.

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
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

  /// Returns null when the booking has neither a registered nor a
  /// guest identity (malformed shape — render nothing).
  ClientNoteKey? get _key {
    final userId = widget.booking.userId.isEmpty ? null : widget.booking.userId;
    final guestId = widget.booking.guestProfileId;
    if (userId == null && guestId == null) return null;
    return ClientNoteKey(
      shopId: widget.booking.shopId,
      userId: userId,
      guestProfileId: guestId,
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    final key = _key;
    if (key == null) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(dashboardRepositoryProvider);
      final newBody = _controller.text;
      await repo.upsertClientNote(
        shopId: widget.booking.shopId,
        userId: key.userId,
        guestProfileId: key.guestProfileId,
        body: newBody,
      );
      _initialBody = newBody;
      ref.invalidate(clientNoteProvider(key));
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
    final key = _key;
    // Malformed booking with neither identity — render nothing rather
    // than crash. Defence in depth; the server CHECK guarantees one
    // identity per booking.
    if (key == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final noteAsync = ref.watch(clientNoteProvider(key));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIconButton(icon: Icons.sticky_note_2_outlined),
                const Gap(Spacing.sm),
                Text(
                  'Private note about this client\nOnly you can see this',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ],
            ),

            const Gap(Spacing.md),
            noteAsync.when(
              loading:
                  () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularLoadingIndicator()),
                  ),
              error:
                  (_, __) => ErrorStateWidget(
                    title: "We couldn't load the note.",
                    subtitle: '',
                    onPrimaryAction:
                        () => ref.invalidate(clientNoteProvider(key)),
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
    final canSave =
        !_saving &&
        _controller.text != _initialBody &&
        _controller.text.length <= _maxChars;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AppTextFormField(
          controller: _controller,
          isSmall: true,
          label: 'sticky note',
          hintText: "e.g. Prefers no fringe, allergic to fragrance X.",

          maxLines: null,
          minLines: 3,
          maxLength: _maxChars,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {}),
          inputFormatters: [LengthLimitingTextInputFormatter(_maxChars)],
        ),

        const Gap(Spacing.md),
        if (_saving) const CircularLoadingIndicator(),

        AppButton(
          elevation: 0,
          label: 'Save',
          onPressed: canSave ? _save : null,
          size: ButtonSize.small,
          width: double.infinity,
          padding: Spacing.horizontalMd,
          height: 40.h,
        ),
      ],
    );
  }
}
