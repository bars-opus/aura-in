// lib/presentation/features/shops/dashboard/presentation/screens/create_broadcast_screen.dart
//
// Phase 14 — broadcast compose form. LoyaltyRuleScreen is the precedent:
// explicit Save (Send), dirty-check, error toasts via classifier-mapped
// userMessage.
//
// Flow:
//   subject + body + audience + (optional service) + (optional promo)
//   → live recipient preview (debounced 500ms)
//   → Send → confirmation dialog → RPC → on success pop with result
//                                  → on BroadcastException show toast
//
// Strings hardcoded EN; Wave 3 swaps to loc.*.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/i10n/generated/app_localizations.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/exceptions/broadcast_exceptions.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/broadcast_dto.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/data/models/promotion_model.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/broadcasts_provider.dart';
import 'package:nano_embryo/presentation/features/shops/dashboard/providers/dashboard_providers.dart';

class CreateBroadcastScreen extends ConsumerStatefulWidget {
  final String shopId;

  const CreateBroadcastScreen({super.key, required this.shopId});

  @override
  ConsumerState<CreateBroadcastScreen> createState() =>
      _CreateBroadcastScreenState();
}

class _CreateBroadcastScreenState extends ConsumerState<CreateBroadcastScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  BroadcastAudience _audienceType = BroadcastAudience.allClients;
  String? _audienceParam; // slot_id when byService
  String? _promotionId;

  /// Server-resolved recipient count for the current audience selection.
  /// Null = unknown (debounce in flight or unrequested). The Send button
  /// stays disabled while null.
  int? _previewCount;
  bool _previewing = false;
  String? _previewError;
  Timer? _previewDebounce;

  bool _sending = false;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    _previewDebounce?.cancel();
    super.dispose();
  }

  // ── Live preview ─────────────────────────────────────────────────

  void _schedulePreview() {
    _previewDebounce?.cancel();
    setState(() {
      _previewing = true;
      _previewError = null;
    });
    _previewDebounce = Timer(const Duration(milliseconds: 500), _runPreview);
  }

  Future<void> _runPreview() async {
    if (_audienceType == BroadcastAudience.byService &&
        _audienceParam == null) {
      setState(() {
        _previewing = false;
        _previewCount = null;
        // Hardcoded fallback when called from a context without
        // localization; the parent screen swaps to loc.* once rendered.
        _previewError = 'Pick a service to preview.';
      });
      return;
    }
    try {
      final repo = ref.read(promotionsRepositoryProvider);
      final n = await repo.previewBroadcastAudience(
        shopId: widget.shopId,
        audienceType: _audienceType,
        audienceParam: _audienceParam,
      );
      if (!mounted) return;
      setState(() {
        _previewing = false;
        _previewCount = n;
      });
    } on BroadcastException catch (e) {
      if (!mounted) return;
      setState(() {
        _previewing = false;
        _previewCount = null;
        _previewError = e.userMessage;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _previewing = false;
        _previewCount = null;
        _previewError = "Couldn't preview audience.";
      });
    }
  }


  // ── Send ─────────────────────────────────────────────────────────

  bool get _canSend {
    if (_sending) return false;
    if (_previewing) return false;
    if (_previewCount == null) return false;
    if (_previewCount! > 1000) return false;
    if (_subjectCtrl.text.trim().isEmpty) return false;
    if (_bodyCtrl.text.trim().isEmpty) return false;
    if (_audienceType == BroadcastAudience.byService &&
        _audienceParam == null) {
      return false;
    }
    return true;
  }

  Future<void> _onSendPressed() async {
    if (!_formKey.currentState!.validate()) return;
    final confirmed = await _showConfirmDialog();
    if (confirmed != true) return;
    setState(() => _sending = true);
    try {
      final repo = ref.read(promotionsRepositoryProvider);
      final res = await repo.sendBroadcast(
        shopId: widget.shopId,
        subject: _subjectCtrl.text.trim(),
        body: _bodyCtrl.text.trim(),
        audienceType: _audienceType,
        audienceParam: _audienceParam,
        promotionId: _promotionId,
      );
      ref.invalidate(broadcastsProvider(widget.shopId));
      if (!mounted) return;
      Navigator.of(context).pop<(String, int)>((
        res.broadcastId,
        res.recipientCount,
      ));
    } on BroadcastException catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.userMessage)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(BroadcastSaveFailedException().userMessage)),
      );
    }
  }

  Future<bool?> _showConfirmDialog() async {
    final loc = AppLocalizations.of(context)!;
    final count = _previewCount ?? 0;
    final body = switch (_audienceType) {
      BroadcastAudience.allClients => loc.broadcastConfirmBodyAll(count),
      BroadcastAudience.recent => loc.broadcastConfirmBodyRecent(count),
      BroadcastAudience.lapsed => loc.broadcastConfirmBodyLapsed(count),
      BroadcastAudience.byService => loc.broadcastConfirmBodyService(count),
    };
    final bodyText = _promotionId == null
        ? body
        : '$body${loc.broadcastConfirmBodyWithPromoSuffix}';
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.broadcastConfirmTitle),
        content: Text(bodyText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.broadcastConfirmCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(loc.broadcastConfirmSend),
          ),
        ],
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(loc.broadcastCreateTitle),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              // Subject
              TextFormField(
                controller: _subjectCtrl,
                maxLength: 100,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                decoration: InputDecoration(
                  labelText: loc.broadcastSubjectLabel,
                  helperText: loc.broadcastSubjectHelper,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return loc.broadcastSubjectRequired;
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Body
              TextFormField(
                controller: _bodyCtrl,
                maxLines: 6,
                minLines: 4,
                maxLength: 800,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                decoration: InputDecoration(
                  labelText: loc.broadcastBodyLabel,
                  helperText: loc.broadcastBodyHelper,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return loc.broadcastBodyRequired;
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Audience
              Text(loc.broadcastAudienceLabel, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<BroadcastAudience>(
                segments: [
                  ButtonSegment(
                    value: BroadcastAudience.allClients,
                    label: Text(loc.broadcastAudienceAllClients),
                  ),
                  ButtonSegment(
                    value: BroadcastAudience.recent,
                    label: Text(loc.broadcastAudienceRecent),
                  ),
                  ButtonSegment(
                    value: BroadcastAudience.lapsed,
                    label: Text(loc.broadcastAudienceLapsed),
                  ),
                  ButtonSegment(
                    value: BroadcastAudience.byService,
                    label: Text(loc.broadcastAudienceByService),
                  ),
                ],
                selected: {_audienceType},
                onSelectionChanged: (s) {
                  setState(() {
                    _audienceType = s.first;
                    if (_audienceType != BroadcastAudience.byService) {
                      _audienceParam = null;
                    }
                  });
                  _schedulePreview();
                },
              ),
              const SizedBox(height: 16),

              // Service dropdown — only when byService
              if (_audienceType == BroadcastAudience.byService)
                _ServicePicker(
                  shopId: widget.shopId,
                  value: _audienceParam,
                  onChanged: (v) {
                    setState(() => _audienceParam = v);
                    _schedulePreview();
                  },
                ),
              if (_audienceType == BroadcastAudience.byService)
                const SizedBox(height: 16),

              // Promo dropdown
              _PromoPicker(
                shopId: widget.shopId,
                value: _promotionId,
                onChanged: (v) => setState(() => _promotionId = v),
              ),
              const SizedBox(height: 24),

              // Live preview
              _PreviewRow(
                previewing: _previewing,
                count: _previewCount,
                error: _previewError,
                onScheduleInitial: () {
                  // First time the user interacts with the screen,
                  // kick off a preview so they see the default
                  // "all clients" count without explicitly tapping
                  // anything.
                  if (_previewCount == null &&
                      !_previewing &&
                      _previewError == null) {
                    _schedulePreview();
                  }
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('broadcast_send_button'),
                  onPressed: _canSend ? _onSendPressed : null,
                  icon: _sending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(loc.broadcastSendButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServicePicker extends ConsumerWidget {
  final String shopId;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _ServicePicker({
    required this.shopId,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final slotsAsync = ref.watch(activeServicesProvider(shopId));
    return slotsAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text(
        loc.broadcastServiceLoadFailed,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      data: (slots) {
        if (slots.isEmpty) {
          return Text(
            loc.broadcastServiceEmpty,
            style: Theme.of(context).textTheme.bodySmall,
          );
        }
        return DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: loc.broadcastServiceLabel,
            border: const OutlineInputBorder(),
          ),
          items: slots
              .map((s) => DropdownMenuItem(
                    value: s.id,
                    child: Text(s.serviceName),
                  ))
              .toList(),
          onChanged: onChanged,
          validator: (v) => v == null ? loc.broadcastServicePickRequired : null,
        );
      },
    );
  }
}

class _PromoPicker extends ConsumerWidget {
  final String shopId;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _PromoPicker({
    required this.shopId,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read via FutureBuilder. activeOnly=true keeps the list short; we
    // still filter source==ownerDefined client-side because the server
    // rejects loyalty/recovery codes anyway (defence in depth + cleaner
    // UI; loyalty codes shouldn't even appear in the dropdown).
    final repoFuture = Future(() async {
      final repo = ref.read(promotionsRepositoryProvider);
      final all = await repo.getPromotions(shopId, activeOnly: true);
      return all
          .where((p) => p.source == PromoSource.ownerDefined && !p.isArchived)
          .toList();
    });

    final loc = AppLocalizations.of(context)!;
    return FutureBuilder<List<Promotion>>(
      future: repoFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return DropdownButtonFormField<String?>(
            value: null,
            decoration: InputDecoration(
              labelText: loc.broadcastPromoLabel,
              helperText: loc.broadcastPromoHelper,
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(loc.broadcastPromoNone),
              ),
            ],
            onChanged: null,
          );
        }
        final promos = snapshot.data!;
        return DropdownButtonFormField<String?>(
          value: value,
          decoration: InputDecoration(
            labelText: loc.broadcastPromoLabel,
            helperText: loc.broadcastPromoHelper,
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(loc.broadcastPromoNone),
            ),
            ...promos.map((p) => DropdownMenuItem<String?>(
                  value: p.id,
                  child: Text(p.code),
                )),
          ],
          onChanged: onChanged,
        );
      },
    );
  }
}

class _PreviewRow extends StatefulWidget {
  final bool previewing;
  final int? count;
  final String? error;

  /// Optional callback the parent can use to lazily trigger an initial
  /// preview the first time the row is built without one. Avoids
  /// re-running the preview on every rebuild.
  final VoidCallback onScheduleInitial;

  const _PreviewRow({
    required this.previewing,
    required this.count,
    required this.error,
    required this.onScheduleInitial,
  });

  @override
  State<_PreviewRow> createState() => _PreviewRowState();
}

class _PreviewRowState extends State<_PreviewRow> {
  bool _kicked = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    if (!_kicked && !widget.previewing && widget.count == null &&
        widget.error == null) {
      _kicked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onScheduleInitial();
      });
    }

    if (widget.previewing) {
      return Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(loc.broadcastPreviewResolving, style: theme.textTheme.bodyMedium),
        ],
      );
    }
    if (widget.error != null) {
      return Text(
        widget.error!,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.error,
        ),
      );
    }
    if (widget.count == null) {
      return Text(
        loc.broadcastPreviewPickAudience,
        style: theme.textTheme.bodyMedium,
      );
    }
    final overCap = widget.count! > 1000;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.broadcastPreviewCount(widget.count!),
          style: theme.textTheme.bodyMedium,
        ),
        if (overCap) ...[
          const SizedBox(height: 4),
          Text(
            loc.broadcastPreviewCapWarning,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
