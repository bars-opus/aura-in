import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StarRatingWidget extends StatefulWidget {
  final int rating;
  final int maxRating;
  final bool interactive;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final Function(int)? onRatingChanged;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.interactive = false,
    this.size = 24,
    this.activeColor,
    this.inactiveColor,
    this.onRatingChanged,
  });

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = widget.activeColor ?? theme.colorScheme.primary;
    final inactiveColor = widget.inactiveColor ?? theme.colorScheme.onSurface.withOpacity(0.3);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (index) {
        final starNumber = index + 1;
        final isSelected = starNumber <= _currentRating;

        return GestureDetector(
          onTap: widget.interactive
              ? () {
                  setState(() {
                    _currentRating = starNumber;
                  });
                  widget.onRatingChanged?.call(starNumber);
                }
              : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Icon(
              isSelected ? Icons.star : Icons.star_border,
              size: widget.size.w,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
        );
      }),
    );
  }
}
