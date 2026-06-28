import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:nano_embryo/core/utils/exports/export_screens.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// Renders a scannable QR code for a link, with a "Share QR" action so the
/// owner can drop the image onto a flyer, business card, or social post.
/// Customers scan it to open the shop / freelancer / products page on the web —
/// no app install required.
class LinkQrView extends StatelessWidget {
  final String url;

  /// Used in the shared image's filename and share caption.
  final String label;

  const LinkQrView({super.key, required this.url, required this.label});

  static const double _size = 200;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        // QR codes MUST be dark-on-light to scan reliably — never themed.
        // Light QR on a dark background is inverted and many scanners reject
        // it. Force literal black-on-white, matching the shared PNG.
        Container(
          padding: EdgeInsets.all(Spacing.md.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: colorScheme.outlineVariant, width: .5),
          ),
          child: QrImageView(
            data: url,
            version: QrVersions.auto,
            size: _size.w,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Colors.black,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Colors.black,
            ),
          ),
        ),
        Gap(Spacing.xl.h),
        AppButton(
          height: 30.h,
          label: 'Share QR code',
          onPressed: () => _shareQr(context),
          padding: Spacing.horizontalMd,
          variant: ButtonVariant.outline,
          size: ButtonSize.small,
          width: double.infinity,
        ),
      ],
    );
  }

  Future<void> _shareQr(BuildContext context) async {
    try {
      final bytes = await _renderQrPng();
      if (bytes == null) {
        if (context.mounted) context.showErrorSnackbar('Could not generate QR');
        return;
      }
      final dir = await getTemporaryDirectory();
      final safeLabel = label
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'^-+|-+$'), '');
      final file = File(
        '${dir.path}/qr-${safeLabel.isEmpty ? 'link' : safeLabel}.png',
      );
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([
        XFile(file.path),
      ], text: label.isEmpty ? url : '$label\n$url');
    } catch (_) {
      if (context.mounted) context.showErrorSnackbar('Could not share QR');
    }
  }

  /// Renders the QR to PNG bytes at a print-friendly resolution with a white
  /// quiet-zone border (scanners need the margin).
  Future<Uint8List?> _renderQrPng() async {
    const double dimension = 600;
    const double margin = 48;
    final painter = QrPainter(
      data: url,
      version: QrVersions.auto,
      gapless: true,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Color(0xFF000000),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Color(0xFF000000),
      ),
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const total = dimension + margin * 2;
    // White background incl. quiet zone.
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, total, total),
      Paint()..color = const Color(0xFFFFFFFF),
    );
    canvas.translate(margin, margin);
    painter.paint(canvas, const Size(dimension, dimension));

    final picture = recorder.endRecording();
    final image = await picture.toImage(total.toInt(), total.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }
}
