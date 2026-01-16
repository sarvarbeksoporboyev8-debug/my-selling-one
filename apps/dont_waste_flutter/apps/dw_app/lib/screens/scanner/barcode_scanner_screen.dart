import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dw_ui/dw_ui.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Barcode/QR Scanner screen with overlay
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with SingleTickerProviderStateMixin {
  MobileScannerController? _controller;
  bool _isFlashOn = false;
  bool _hasScanned = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Keep screen on while scanning
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animationController.dispose();
    // Disable wakelock when leaving scanner
    WakelockPlus.disable();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() => _hasScanned = true);

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Show result
    _showScanResult(barcode);
  }

  void _showScanResult(Barcode barcode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ScanResultSheet(
        barcode: barcode,
        onRescan: () {
          Navigator.pop(context);
          setState(() => _hasScanned = false);
        },
        onUseCode: () {
          Navigator.pop(context);
          context.pop(barcode.rawValue);
        },
      ),
    );
  }

  void _toggleFlash() {
    _controller?.toggleTorch();
    setState(() => _isFlashOn = !_isFlashOn);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.7;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Overlay
          CustomPaint(
            size: size,
            painter: _ScannerOverlayPainter(
              scanAreaSize: scanAreaSize,
              borderRadius: 24,
            ),
          ),

          // Scan line animation
          Positioned(
            top: (size.height - scanAreaSize) / 2,
            left: (size.width - scanAreaSize) / 2,
            child: SizedBox(
              width: scanAreaSize,
              height: scanAreaSize,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      Positioned(
                        top: _animation.value * (scanAreaSize - 4),
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.primary,
                                AppColors.primary,
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.5),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Corner decorations
          Positioned(
            top: (size.height - scanAreaSize) / 2,
            left: (size.width - scanAreaSize) / 2,
            child: _ScannerCorners(size: scanAreaSize),
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(
                    icon: Icons.close,
                    onTap: () => context.pop(),
                  ),
                  _CircleButton(
                    icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    onTap: _toggleFlash,
                    isActive: _isFlashOn,
                  ),
                ],
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'Point camera at barcode or QR code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.black45,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final double scanAreaSize;
  final double borderRadius;

  _ScannerOverlayPainter({
    required this.scanAreaSize,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6);

    final scanRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: scanAreaSize,
        height: scanAreaSize,
      ),
      Radius.circular(borderRadius),
    );

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(scanRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScannerCorners extends StatelessWidget {
  final double size;

  const _ScannerCorners({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Top left
          Positioned(
            top: 0,
            left: 0,
            child: _Corner(position: _CornerPosition.topLeft),
          ),
          // Top right
          Positioned(
            top: 0,
            right: 0,
            child: _Corner(position: _CornerPosition.topRight),
          ),
          // Bottom left
          Positioned(
            bottom: 0,
            left: 0,
            child: _Corner(position: _CornerPosition.bottomLeft),
          ),
          // Bottom right
          Positioned(
            bottom: 0,
            right: 0,
            child: _Corner(position: _CornerPosition.bottomRight),
          ),
        ],
      ),
    );
  }
}

enum _CornerPosition { topLeft, topRight, bottomLeft, bottomRight }

class _Corner extends StatelessWidget {
  final _CornerPosition position;

  const _Corner({required this.position});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(40, 40),
      painter: _CornerPainter(position: position),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final _CornerPosition position;

  _CornerPainter({required this.position});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    switch (position) {
      case _CornerPosition.topLeft:
        path.moveTo(0, size.height * 0.6);
        path.lineTo(0, 8);
        path.quadraticBezierTo(0, 0, 8, 0);
        path.lineTo(size.width * 0.6, 0);
        break;
      case _CornerPosition.topRight:
        path.moveTo(size.width * 0.4, 0);
        path.lineTo(size.width - 8, 0);
        path.quadraticBezierTo(size.width, 0, size.width, 8);
        path.lineTo(size.width, size.height * 0.6);
        break;
      case _CornerPosition.bottomLeft:
        path.moveTo(0, size.height * 0.4);
        path.lineTo(0, size.height - 8);
        path.quadraticBezierTo(0, size.height, 8, size.height);
        path.lineTo(size.width * 0.6, size.height);
        break;
      case _CornerPosition.bottomRight:
        path.moveTo(size.width * 0.4, size.height);
        path.lineTo(size.width - 8, size.height);
        path.quadraticBezierTo(size.width, size.height, size.width, size.height - 8);
        path.lineTo(size.width, size.height * 0.4);
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanResultSheet extends StatelessWidget {
  final Barcode barcode;
  final VoidCallback onRescan;
  final VoidCallback onUseCode;

  const _ScanResultSheet({
    required this.barcode,
    required this.onRescan,
    required this.onUseCode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141416) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Code Detected',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getBarcodeTypeLabel(barcode.format),
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white60 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              barcode.rawValue ?? 'Unknown',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'monospace',
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRescan,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Scan Again',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onUseCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Use Code',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  String _getBarcodeTypeLabel(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.qrCode:
        return 'QR Code';
      case BarcodeFormat.ean13:
        return 'EAN-13 Barcode';
      case BarcodeFormat.ean8:
        return 'EAN-8 Barcode';
      case BarcodeFormat.upcA:
        return 'UPC-A Barcode';
      case BarcodeFormat.upcE:
        return 'UPC-E Barcode';
      case BarcodeFormat.code128:
        return 'Code 128 Barcode';
      case BarcodeFormat.code39:
        return 'Code 39 Barcode';
      default:
        return 'Barcode';
    }
  }
}
