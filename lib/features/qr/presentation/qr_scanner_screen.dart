import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/widgets/snackbar_helpers.dart';
import '../domain/qr_payload.dart';

class QrScannerScreen extends StatefulWidget {
  final String expectedType; // 'user' or 'agent'

  const QrScannerScreen({super.key, this.expectedType = 'user'});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasDetected = false;
  String? _lastRejected; // the camera reports the same code every frame; warn once

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasDetected) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        final parsedId = _parsePayload(rawValue);
        if (parsedId != null) {
          _hasDetected = true;
          Navigator.of(context).pop(parsedId);
          break;
        }
      }
    }
  }

  /// Returns the agent phone (agent QR) or user ID (customer QR). A scan only fills the
  /// form; the user still goes through Review (§9.1), nothing is auto-submitted.
  String? _parsePayload(String raw) {
    final expected = widget.expectedType == 'agent' ? QrTargetType.agent : QrTargetType.user;
    switch (parseQrPayload(raw, expected: expected)) {
      case QrParsed(:final value):
        return value;
      case QrRejected(:final reason):
        if (_lastRejected != raw) {
          _lastRejected = raw;
          showErrorSnackBar(context, reason);
        }
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expectedType == 'agent' ? 'Scan Agent QR' : 'Scan Recipient QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.expectedType == 'agent'
                    ? 'Align the agent QR code inside the frame to scan.'
                    : 'Align the recipient QR code inside the frame to scan.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
