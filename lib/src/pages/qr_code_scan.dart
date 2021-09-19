import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:menu_advisor/src/components/dialogs.dart';
import 'package:menu_advisor/src/constants/colors.dart';
import 'package:menu_advisor/src/pages/list_lang.dart';
import 'package:menu_advisor/src/pages/restaurant.dart';
import 'package:menu_advisor/src/providers/BagContext.dart';
import 'package:menu_advisor/src/providers/SettingContext.dart';
import 'package:menu_advisor/src/routes/routes.dart';
import 'package:menu_advisor/src/services/api.dart';
import 'package:menu_advisor/src/utils/AppLocalization.dart';
import 'package:menu_advisor/src/utils/routing.dart';
import 'package:menu_advisor/src/utils/textTranslator.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRCodeScanPage extends StatefulWidget {
  @override
  _QRCodeScanPageState createState() => _QRCodeScanPageState();
}

class _QRCodeScanPageState extends State<QRCodeScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool flashOn = false;
  bool loading = false;
  CartContext _cartContext;
  SettingContext _settingContext;
  Barcode result;
  QRViewController controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  @override
  void initState() {
    super.initState();
    _cartContext = Provider.of<CartContext>(context, listen: false);
    _settingContext = Provider.of<SettingContext>(context, listen: false);
    _onQRViewCreated(controller);
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller?.scannedDataStream?.listen((scanData) {
      controller.pauseCamera();
      _handleQRcode(scanData.code);
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no Permission')),
      );
    }
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400) ? 150.0 : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _handleQRcode(String scanData) async {
    if (!scanData.startsWith(Api.apiURL)) {
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context).translate('invalid_qr_code'),
      );
      controller.resumeCamera();
      return;
    }

    //parse url
    Uri uri = Uri.dataFromString(scanData);
    String restaurantId = uri.pathSegments.last;
    bool withPrice = !uri.queryParameters.containsValue("priceless");
    _cartContext.withPrice = withPrice;
    bool haveLangage = uri.queryParameters.containsKey("language");
    String language = uri.queryParameters['language'];
    String multipleLanguage = uri.queryParameters.keys.firstWhere((v) => v.startsWith('multiple'));
    List languages = json.decode(multipleLanguage.split(":").last);
    bool haveMultipleLanguage;
    if (multipleLanguage != null && languages[0] != "") {
      haveMultipleLanguage = true;
    } else {
      haveMultipleLanguage = false;
    }

    //if have multiple language then go to choice language page
    if (haveMultipleLanguage) {
      RouteUtil.goTo(
        context: context,
        child: ListLang(
          langFromQRcode: languages,
          restaurant: restaurantId,
          withPrice: withPrice,
        ),
        routeName: restaurantRoute,
        method: RoutingMethod.replaceLast,
      );
      controller.resumeCamera();
      return;
    }

    if (haveLangage) {
      print("language = $language");
      showDialogProgress(context);
      await _settingContext.setlanguageCodeRestaurant(language);
      dismissDialogProgress(context);
    }

    RouteUtil.goTo(
      context: context,
      child: RestaurantPage(
        restaurant: restaurantId,
        withPrice: withPrice,
        fromQrcode: true,
      ),
      routeName: restaurantRoute,
      method: RoutingMethod.replaceLast,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextTranslator("Scan code QR"),
      ),
      backgroundColor: BACKGROUND_COLOR,
      body: SafeArea(
        child: Stack(
          children: [
            _buildQrView(context),
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
              child: TextTranslator(
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
                onPressed: () async {
                  // controller.toggleFlash();
                  await controller?.toggleFlash();
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

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
