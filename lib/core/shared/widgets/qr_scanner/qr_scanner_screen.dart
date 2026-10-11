import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../theming/theming_colors.dart';

class QrScannerScreen extends StatelessWidget {
  final void Function(String code) onDetect;
  final String? scanningLabel;

  final MobileScannerController controller = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
    torchEnabled: false,
    returnImage: false,
  );

  final ValueNotifier<bool> _hasScanned = ValueNotifier(false);
  final ValueNotifier<bool> _disposedFlag = ValueNotifier(false);

  QrScannerScreen({required this.onDetect, this.scanningLabel, super.key});

  void _disposeAfterTransition(BuildContext context) {
    if (_disposedFlag.value) return;
    final animation = ModalRoute.of(context)?.animation;

    if (animation == null || animation.status == AnimationStatus.dismissed) {
      _disposedFlag.value = true;
      controller.dispose();
      _hasScanned.dispose();
      return;
    }

    void listener(AnimationStatus status) {
      if (status == AnimationStatus.dismissed) {
        animation.removeStatusListener(listener);
        if (!_disposedFlag.value) {
          _disposedFlag.value = true;
          controller.dispose();
          _hasScanned.dispose();
        }
      }
    }

    animation.addStatusListener(listener);
  }

  Future<void> _handleDetection(
    BuildContext context,
    BarcodeCapture capture,
  ) async {
    if (_hasScanned.value) return;
    final String? code = capture.barcodes.isNotEmpty
        ? capture.barcodes.first.rawValue
        : null;
    if (code == null) return;

    _hasScanned.value = true;
    await controller.stop();
    if (!context.mounted) return;

    _disposeAfterTransition(context);
    Navigator.pop(context);
    onDetect(code);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final Rect cutoutRect = Rect.fromCenter(
      center: Offset(screenSize.width / 2, screenSize.height / 2),
      width: 250,
      height: 250,
    );
    final String resolvedLabel = scanningLabel ?? "defaultScanningLabel".tr();

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) return;
        _disposeAfterTransition(context);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: controller,
              fit: BoxFit.cover,
              scanWindow: cutoutRect,
              onDetect: (capture) => _handleDetection(context, capture),
              errorBuilder: (context, error) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      "cameraPermission".tr(),
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
              placeholderBuilder: (context) {
                return Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    size: 25,
                    color: ThemingColors.primaryColor,
                  ),
                );
              },
              overlayBuilder: (context, constraints) {
                return CustomPaint(
                  size: constraints.biggest,
                  painter: _ScannerOverlayPainter(
                    cutoutSize: 250,
                    borderColor: ThemingColors.primaryColor,
                    borderWidth: 3,
                    borderRadius: 20,
                    overlayColor: Colors.black.withAlpha((0.6 * 255).toInt()),
                    cornerLength: 30,
                  ),
                );
              },
            ),
            Positioned(
              top: 50,
              left: 15,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((0.4 * 255).toInt()),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Text(
                resolvedLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final double cutoutSize;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final Color overlayColor;
  final double cornerLength;

  _ScannerOverlayPainter({
    required this.cutoutSize,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.overlayColor,
    this.cornerLength = 30,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutoutSize,
      height: cutoutSize,
    );
    final RRect cutoutRRect = RRect.fromRectAndRadius(
      cutoutRect,
      Radius.circular(borderRadius),
    );

    final Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final Path cutoutPath = Path()..addRRect(cutoutRRect);
    final Path overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(overlayPath, Paint()..color = overlayColor);

    final Paint cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final double left = cutoutRect.left;
    final double top = cutoutRect.top;
    final double right = cutoutRect.right;
    final double bottom = cutoutRect.bottom;
    final double r = borderRadius;

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cornerLength)
        ..lineTo(left, top + r)
        ..arcToPoint(Offset(left + r, top), radius: Radius.circular(r))
        ..lineTo(left + cornerLength, top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(right - cornerLength, top)
        ..lineTo(right - r, top)
        ..arcToPoint(Offset(right, top + r), radius: Radius.circular(r))
        ..lineTo(right, top + cornerLength),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(right, bottom - cornerLength)
        ..lineTo(right, bottom - r)
        ..arcToPoint(Offset(right - r, bottom), radius: Radius.circular(r))
        ..lineTo(right - cornerLength, bottom),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(left + cornerLength, bottom)
        ..lineTo(left + r, bottom)
        ..arcToPoint(Offset(left, bottom - r), radius: Radius.circular(r))
        ..lineTo(left, bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.cutoutSize != cutoutSize ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.cornerLength != cornerLength;
  }
}
