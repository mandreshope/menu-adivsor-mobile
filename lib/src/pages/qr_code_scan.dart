import 'package:flutter/material.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRCodeScanPage extends StatefulWidget {
  @override
  _QRCodeScanPageState createState() => _QRCodeScanPageState();
}

class _QRCodeScanPageState extends State<QRCodeScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String qrText = "";
  QRViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      body: Stack(
        fit: StackFit.expand,
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      print(scanData);
      setState(() {
        qrText = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
