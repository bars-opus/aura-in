import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nano_embryo/core/map/config/feature/marker_style.dart';

class CanvasMarkerBuilder {
  /// Draw a rectangular marker with a triangular pointer at the bottom.
  /// Displays a colored accent dot followed by the type code (e.g., "CONCERT").
  /// Both are centered horizontally and vertically.
  static Future<Uint8List> drawSimpleMarker({
    required String typeCode,
    required Color accentColor,
    required BuildContext context,
    bool isSelected = false,
    MarkerShape shape = MarkerShape.pill,
    double? width,
    double? height,
    double tailHeight = 30.0,
    double tailWidth = 50.0,
    // Color? backgroundColor,
    Color? borderColor,
  }) async {
    // Only the pill shape is implemented today (it is the current marker look).
    // Future shapes can branch off this enum without changing call sites.
    assert(
      shape == MarkerShape.pill,
      'MarkerShape.${shape.name} is not yet implemented; '
      'CanvasMarkerBuilder currently only supports MarkerShape.pill. '
      'Add a branch above or extend this function before using it.',
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Determine if dark mode is active
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color markerBackgroundColor =
        // isDarkMode ? colorScheme.background :
        colorScheme.primary;

    // Define text style for type code
    final typeStyle =
        textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 20.h,
          letterSpacing: 0.5,
        ) ??
        const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        );

    // Measure text
    final typePainter = TextPainter(
      text: TextSpan(text: typeCode, style: typeStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    // Sizes
    final dotSize = 10.0.r;
    final spacing = 8.0.sp;
    final horizontalPadding = 16.0.sp;
    final verticalPadding = 12.0.sp;

    // Calculate total content width (dot + spacing + text)
    final totalContentWidth = dotSize + spacing + typePainter.width;

    // Determine final dimensions
    final effectiveWidth = width ?? totalContentWidth + horizontalPadding * 2;
    final rectangleHeight = height ?? typePainter.height + verticalPadding * 2;
    final totalHeight = rectangleHeight + tailHeight;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final borderRadius = 30.0.r;

    // Calculate tail points
    final startX = effectiveWidth / 2 - tailWidth / 2;
    final endX = effectiveWidth / 2 + tailWidth / 2;
    final yBase = rectangleHeight;
    final yTip = totalHeight;

    // ========== DRAW SHADOWS ONLY IN LIGHT MODE ==========
    if (!isDarkMode) {
      // 1. Soft outer glow (wide blur) - creates ambient occlusion
      final outerGlowPaint =
          Paint()
            ..color = Colors.black.withOpacity(0.1)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(4, 14, effectiveWidth, rectangleHeight),
          Radius.circular(borderRadius + 2),
        ),
        outerGlowPaint,
      );

      // 2. Tail outer glow - casting downward
      final tailOuterGlowPath =
          Path()
            ..moveTo(startX - 2, yBase + 5)
            ..lineTo(effectiveWidth / 2, yTip + 8)
            ..lineTo(endX + 2, yBase + 5)
            ..close();
      canvas.drawPath(tailOuterGlowPath, outerGlowPaint);

      // 3. Medium shadow (main floating effect) - darker and more spread
      final mediumShadowPaint =
          Paint()
            ..color = Colors.black.withOpacity(0.20)
            ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 18.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(2, 12, effectiveWidth, rectangleHeight),
          Radius.circular(borderRadius),
        ),
        mediumShadowPaint,
      );

      // 4. Tail medium shadow - casting downward
      final tailMediumShadowPath =
          Path()
            ..moveTo(startX - 1, yBase + 4)
            ..lineTo(effectiveWidth / 2, yTip + 6)
            ..lineTo(endX + 1, yBase + 4)
            ..close();
      canvas.drawPath(tailMediumShadowPath, mediumShadowPaint);

      // 5. Dark core shadow (creates depth) - sharper and darker
      final coreShadowPaint =
          Paint()
            ..color = Colors.black.withOpacity(0.1)
            ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 10.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(1, 10, effectiveWidth, rectangleHeight),
          Radius.circular(borderRadius - 1),
        ),
        coreShadowPaint,
      );

      // 6. Tail core shadow - casting downward
      final tailCoreShadowPath =
          Path()
            ..moveTo(startX, yBase)
            ..lineTo(effectiveWidth / 2, yTip + 3)
            ..lineTo(endX, yBase)
            ..close();
      canvas.drawPath(tailCoreShadowPath, coreShadowPaint);

      // 7. Optional: Extra deep shadow for maximum elevation
      final deepShadowPaint =
          Paint()
            ..color = Colors.black.withOpacity(0.20)
            ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 14.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(3, 14, effectiveWidth, rectangleHeight),
          Radius.circular(borderRadius),
        ),
        deepShadowPaint,
      );
    }
    // ========== DRAW MAIN MARKER BODY ==========

    // Draw rectangle background with subtle gradient for depth
    final rectGradient = ui.Gradient.linear(
      Offset(0, 0),
      Offset(0, rectangleHeight),
      [(markerBackgroundColor).withOpacity(0.98), markerBackgroundColor],
    );
    final bgPaint = Paint()..shader = rectGradient;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, effectiveWidth, rectangleHeight),
        Radius.circular(borderRadius),
      ),
      bgPaint,
    );

    // Draw triangular tail with gradient
    final tailGradient = ui.Gradient.linear(
      Offset(effectiveWidth / 2, yBase),
      Offset(effectiveWidth / 2, yTip),
      [
        (markerBackgroundColor).withOpacity(0.98),
        (markerBackgroundColor).withOpacity(0.92),
      ],
    );
    final tailPaint = Paint()..shader = tailGradient;
    canvas.drawPath(
      Path()
        ..moveTo(startX, yBase)
        ..lineTo(effectiveWidth / 2, yTip)
        ..lineTo(endX, yBase)
        ..close(),
      tailPaint,
    );

    // ========== DRAW BORDER IF SELECTED ==========
    if (!isSelected) {
      final borderPaint =
          Paint()
            ..color = borderColor ?? colorScheme.background
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3;

      final path = Path();

      // Start at top-left corner after the rounded corner
      path.moveTo(borderRadius, 0);

      // Top edge
      path.lineTo(effectiveWidth - borderRadius, 0);

      // Top-right corner arc
      path.arcToPoint(
        Offset(effectiveWidth, borderRadius),
        radius: Radius.circular(borderRadius),
      );

      // Right edge down to the bottom-right corner arc start
      path.lineTo(effectiveWidth, rectangleHeight - borderRadius);

      // Bottom-right corner arc (end at (effectiveWidth - borderRadius, rectangleHeight))
      path.arcToPoint(
        Offset(effectiveWidth - borderRadius, rectangleHeight),
        radius: Radius.circular(borderRadius),
      );

      // Move to the right base of the tail (endX, rectangleHeight)
      path.lineTo(endX, rectangleHeight);

      // Draw the right side of the tail down to the tip
      path.lineTo(effectiveWidth / 2, yTip);

      // Draw the left side of the tail back up to the left base
      path.lineTo(startX, rectangleHeight);

      // Move to the left base of the rectangle (borderRadius, rectangleHeight)
      path.lineTo(borderRadius, rectangleHeight);

      // Bottom-left corner arc (from (borderRadius, rectangleHeight) to (0, rectangleHeight - borderRadius))
      path.arcToPoint(
        Offset(0, rectangleHeight - borderRadius),
        radius: Radius.circular(borderRadius),
      );

      // Left edge up
      path.lineTo(0, borderRadius);

      // Top-left corner arc (from (0, borderRadius) to (borderRadius, 0))
      path.arcToPoint(
        Offset(borderRadius, 0),
        radius: Radius.circular(borderRadius),
      );

      path.close();

      // Draw the single continuous border
      canvas.drawPath(path, borderPaint);
    }

    // ========== DRAW CONTENT (DOT + TEXT) CENTERED ==========
    final xCenter = effectiveWidth / 2;
    final yCenter = rectangleHeight / 2;
    final startXContent = xCenter - totalContentWidth / 2;

    // Draw accent color dot with inner glow
    final dotX = startXContent + dotSize / 2;
    final dotY = yCenter;

    // Dot outer glow

    // Dot main color
    final dotPaint = Paint()..color = accentColor;
    canvas.drawCircle(Offset(dotX, dotY), dotSize / 2, dotPaint);

    // Dot border
    final dotBorderPaint =
        Paint()
          ..color = isDarkMode ? Colors.transparent : Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = isDarkMode ? 0 : 5;
    canvas.drawCircle(Offset(dotX, dotY), dotSize / 2, dotBorderPaint);

    // Draw type code text
    final textX = startXContent + dotSize + spacing;
    final textY = yCenter - typePainter.height / 2;
    typePainter.paint(canvas, Offset(textX, textY));

    // ========== ADD SUBTLE INNER SHADOW FOR DEPTH ==========
    final innerShadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1, 1, effectiveWidth - 2, rectangleHeight - 2),
        Radius.circular(borderRadius - 1),
      ),
      innerShadowPaint,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      effectiveWidth.toInt(),
      totalHeight.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Draw premium cluster marker
  static Future<Uint8List> drawClusterMarker({
    required int count,
    double size = 44,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final center = Offset(size / 2, size / 2);
    final radius = size / 2 - 2;

    // Draw outer glow
    final glowPaint =
        Paint()
          ..color = const Color(0xFF34C759).withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius + 4, glowPaint);

    // Draw gradient background
    final gradient = ui.Gradient.radial(center, radius, [
      const Color(0xFF4CD964),
      const Color(0xFF34C759),
    ]);
    final bgPaint = Paint()..shader = gradient;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw white inner ring
    final ringPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 2, ringPaint);

    // Draw count text
    final textPainter = TextPainter(
      text: TextSpan(
        text: count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: count > 99 ? 12 : 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'system-ui',
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
