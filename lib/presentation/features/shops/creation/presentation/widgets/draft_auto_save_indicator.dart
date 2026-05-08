// lib/features/shop/creation/presentation/widgets/draft_auto_save_indicator.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/shops/creation/providers/shop_creation_provider.dart';

enum SaveState { saved, saving, error }

class DraftAutoSaveIndicator extends ConsumerStatefulWidget {
  const DraftAutoSaveIndicator({super.key});

  @override
  ConsumerState<DraftAutoSaveIndicator> createState() =>
      _DraftAutoSaveIndicatorState();
}

class _DraftAutoSaveIndicatorState
    extends ConsumerState<DraftAutoSaveIndicator> {
  SaveState _saveState = SaveState.saved;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _showSavingIndicator() {
    _hideTimer?.cancel();
    setState(() => _saveState = SaveState.saving);

    // Show saving for a moment, then switch to saved
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _saveState = SaveState.saved);
        _hideTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _saveState = SaveState.saved);
            // Keep the checkmark but hide after 2 seconds
            _hideTimer = Timer(const Duration(seconds: 1), () {
              if (mounted) {
                setState(() => _saveState = SaveState.saved);
                // We keep the state but the UI will hide after timeout
              }
            });
          }
        });
      }
    });
  }

  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ✅ Move listen to build method
    ref.listen(shopCreationProvider, (previous, next) {
      if (previous != next) {
        _showSavingIndicator();
      }
    });

    // Only show when not in saved state (hides after timeout)
    if (_saveState == SaveState.saved) return const SizedBox.shrink();

    return Positioned(
      bottom: 20.h,
      child: SizedBox(
        height: 50.h,
        width: 300.w,
        child: SemanticContainerWidget(
          content: _getMessage(),
          icon: _getIcon(),
          title: '',
          backgroundColor: _getBackgroundColor().withOpacity(0.1),
          borderColor: _getBackgroundColor(),
          iconColor: _getBackgroundColor(),
          textTheme: theme.textTheme,
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (_saveState) {
      case SaveState.saved:
        return Colors.green;
      case SaveState.saving:
        return Colors.orange;
      case SaveState.error:
        return Colors.red;
    }
  }

  IconData _getIcon() {
    switch (_saveState) {
      case SaveState.saved:
        return Icons.check_circle;
      case SaveState.saving:
        return Icons.circle_outlined;
      case SaveState.error:
        return Icons.error;
    }
  }

  String _getMessage() {
    switch (_saveState) {
      case SaveState.saved:
        return 'Draft saved';
      case SaveState.saving:
        return 'Saving...';
      case SaveState.error:
        return 'Save failed';
    }
  }
}
