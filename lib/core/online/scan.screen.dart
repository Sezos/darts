import 'package:darts/core/online/online.dart';
import 'package:darts/l10n/l10n.dart';
import 'package:darts/utils/analytics.dart';
import 'package:darts/utils/colors.dart';
import 'package:darts/utils/snackbar.dart';
import 'package:darts/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Camera view that opens the profile behind a friend's DartScore QR code.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  var _handled = false;
  String? _lastRejected;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;
      final code = Online.parseCode(raw);
      if (code != null) {
        _handled = true;
        Analytics.qrScanned();
        context.pushReplacement('/friends/f/$code');
        return;
      }
      // Say so once per foreign code, not on every camera frame.
      if (raw != _lastRejected) {
        _lastRejected = raw;
        showSnackMsg(
          context.l10n.notDartScoreQr,
          context,
          type: SnackType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        title: BText(l10n.scanQr, fontWeight: .w800, size: .l),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: BComment(
                  error.errorCode == MobileScannerErrorCode.permissionDenied
                      ? l10n.cameraDenied
                      : l10n.onlineUnavailable,
                  color: BColors().textSecondary,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Viewfinder frame.
          IgnorePointer(
            child: Center(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: BColors().primary, width: 3),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 48,
            child: BText(
              l10n.scanHint,
              fontWeight: .w700,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
