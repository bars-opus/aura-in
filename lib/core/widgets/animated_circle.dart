import 'package:nano_embryo/core/utils/exports/export_screens.dart';

class AnimatedCircle extends StatefulWidget {
  final bool animateSize;
  final bool animateShape;
  final double size;
  final double stroke;
  final Color firstColor;
  final Color secondColor;

  const AnimatedCircle({
    super.key,
    this.animateSize = false,
    this.animateShape = false,
    this.size = 100,
    this.stroke = 5,
    this.firstColor = Colors.red,
    this.secondColor = Colors.blue,
  });

  @override
  State<AnimatedCircle> createState() => _AnimatedCircleState();
}

class _AnimatedCircleState extends State<AnimatedCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<BorderRadius?> _shapeAnimation;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _buildAnimations();
  }

  @override
  void didUpdateWidget(AnimatedCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.firstColor != oldWidget.firstColor ||
        widget.secondColor != oldWidget.secondColor ||
        widget.size != oldWidget.size) {
      _buildAnimations();
    }
  }

  void _buildAnimations() {
    _colorAnimation = ColorTween(
      begin: widget.firstColor,
      end: widget.secondColor,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _shapeAnimation = BorderRadiusTween(
      begin: BorderRadius.circular((widget.size / 2)),
      end: BorderRadius.circular(0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _sizeAnimation = Tween<double>(
      begin: widget.size,
      end: (widget.size * 0.5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCircle() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final size = widget.animateSize ? _sizeAnimation.value : widget.size.r;
        final borderRadius =
            widget.animateShape
                ? _shapeAnimation.value
                : BorderRadius.circular((widget.size / 2).r);

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(
              color: _colorAnimation.value ?? widget.firstColor,
              width: widget.stroke,
            ),
            color: Colors.transparent,
            borderRadius: borderRadius,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => _buildCircle();
}
