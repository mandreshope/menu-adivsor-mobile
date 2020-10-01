import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/models.dart';
import 'package:menu_advisor/src/pages/restaurant.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRCodeScanPage extends StatefulWidget {
  @override
  _QRCodeScanPageState createState() => _QRCodeScanPageState();
}

class _QRCodeScanPageState extends State<QRCodeScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;
  bool flashOn = false;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan code QR"),
        centerTitle: true,
      ),
      backgroundColor: BACKGROUND_COLOR,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Container(
              color: Colors.black45,
              child: loading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(CRIMSON),
                      ),
                    )
                  : null,
            ),
            Positioned(
              top: 200,
              left: 0,
              right: 0,
              child: Text(
                AppLocalizations.of(context).translate("center_camera"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: FloatingActionButton(
                child: Icon(
                  flashOn ? Icons.flash_on : Icons.flash_off,
                ),
                onPressed: () {
                  controller.toggleFlash();
                  setState(() {
                    flashOn = !flashOn;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((String scanData) async {
      controller.pauseCamera();
      if (!scanData
          .startsWith(RegExp(r'https://(www\.|)menuadvisor.fr/restaurants/'))) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context).translate('invalid_qr_code'),
        );
        controller.resumeCamera();
        return;
      }

      setState(() {
        loading = true;
      });
      Restaurant restaurant =
          await Api.instance.getRestaurant(id: scanData.split('/').last);

      RouteUtil.goTo(
        context: context,
        child: RestaurantPage(restaurant: restaurant),
        routeName: restaurantRoute,
        method: RoutingMethod.replaceLast,
      );
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
