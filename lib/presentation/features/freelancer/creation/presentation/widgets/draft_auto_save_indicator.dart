// lib/features/freelancer/creation/presentation/widgets/draft_auto_save_indicator.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:nano_embryo/presentation/features/freelancer/creation/presentation/providers/freelancer_creation_provider.dart';

/// Floating indicator showing auto-save status for freelancer drafts
class DraftAutoSaveIndicator extends ConsumerStatefulWidget {
  const DraftAutoSaveIndicator({super.key});

  @override
  ConsumerState<DraftAutoSaveIndicator> createState() => _DraftAutoSaveIndicatorState();
}

class _DraftAutoSaveIndicatorState extends ConsumerState<DraftAutoSaveIndicator> {
  bool _isVisible = false;
  String _status = 'Saving...';

  @override
  void initState() {
    super.initState();
    _startAutoSaveListener();
  }

  void _startAutoSaveListener() {
    // Listen to draft changes
    ref.listen(freelancerCreationProvider, (previous, next) {
      if (previous != next) {
        _showSaveIndicator();
      }
    });
  }

  void _showSaveIndicator() {
    setState(() {
      _isVisible = true;
      _status = 'Saving...';
    });

    // Hide after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 20.h,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.md.w,
            vertical: Spacing.sm.h,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularLoadingIndicator(),
              Gap(Spacing.sm.w),
              Text(
                _status,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
