import 'package:flutter/material.dart';

/// A universal animation widget that provides scale and fade-in effects
/// with optional stagger delays for multiple widgets.
///
/// Features:
/// - Scale animation from 0 to target scale
/// - Fade-in animation
/// - Staggered delays for multiple items
/// - Customizable curves and durations
/// - Can be used with any child widget
class AnimatedScaleFade extends StatefulWidget {
  /// The child widget to animate
  final Widget child;

  /// Animation duration (default: 600ms)
  final Duration duration;

  /// Animation curve (default: easeOutBack)
  final Curve curve;

  /// Starting scale value (default: 0.0)
  final double beginScale;

  /// Ending scale value (default: 1.0)
  final double endScale;

  /// Whether to start animation automatically (default: true)
  final bool autoStart;

  /// Stagger delay index (for multiple items)
  final int? staggerIndex;

  /// Delay between each staggered item (default: 0.05 seconds)
  final double staggerDelay;

  /// Callback when animation completes
  final VoidCallback? onAnimationComplete;

  /// Whether to apply opacity fade (default: true)
  final bool fadeIn;

  /// Minimum opacity for fade (default: 0.0)
  final double beginOpacity;

  /// Maximum opacity for fade (default: 1.0)
  final double endOpacity;

  const AnimatedScaleFade({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutBack,
    this.beginScale = 0.0,
    this.endScale = 1.0,
    this.autoStart = true,
    this.staggerIndex,
    this.staggerDelay = 0.05,
    this.onAnimationComplete,
    this.fadeIn = true,
    this.beginOpacity = 0.0,
    this.endOpacity = 1.0,
  });

  @override
  State<AnimatedScaleFade> createState() => _AnimatedScaleFadeState();
}

class _AnimatedScaleFadeState extends State<AnimatedScaleFade>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    if (widget.autoStart) {
      _controller.forward();
    }
  }

  /// Start the animation manually
  void startAnimation() {
    if (!_controller.isAnimating && !_controller.isCompleted) {
      _controller.forward();
    }
  }

  /// Reset and start animation
  void resetAndStart() {
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate delay for stagger effect
        final delay = (widget.staggerIndex ?? 0) * widget.staggerDelay;
        final progress = (_controller.value - delay).clamp(0.0, 1.0);

        // Scale animation
        final scale = Tween<double>(
          begin: widget.beginScale,
          end: widget.endScale,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(delay, 1.0, curve: widget.curve),
          ),
        ).value;

        // Opacity animation
        double opacity = widget.endOpacity;
        if (widget.fadeIn) {
          opacity = Tween<double>(
            begin: widget.beginOpacity,
            end: widget.endOpacity,
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(delay, 1.0, curve: Curves.easeOut),
            ),
          ).value;
        }

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Helper extension for easy use
extension AnimatedWidgetExtension on Widget {
  /// Apply scale and fade animation to any widget
  Widget animated({
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeOutBack,
    double beginScale = 0.0,
    double endScale = 1.0,
    bool autoStart = true,
    int? staggerIndex,
    double staggerDelay = 0.05,
    VoidCallback? onAnimationComplete,
    bool fadeIn = true,
    double beginOpacity = 0.0,
    double endOpacity = 1.0,
  }) {
    return AnimatedScaleFade(
      child: this,
      duration: duration,
      curve: curve,
      beginScale: beginScale,
      endScale: endScale,
      autoStart: autoStart,
      staggerIndex: staggerIndex,
      staggerDelay: staggerDelay,
      onAnimationComplete: onAnimationComplete,
      fadeIn: fadeIn,
      beginOpacity: beginOpacity,
      endOpacity: endOpacity,
    );
  }
}
